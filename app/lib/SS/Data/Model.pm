package SS::Data::Model;

use Moose;

use Geo::WKT;
use List::Util qw( shuffle );
use Sphinx::Search;

=head1 NAME

SS::Data::Model - Data model

=cut

has dbh => ( is => 'ro', isa => 'DBI::db' );

use constant MAX_PAGE => 500;

my %REF = map { $_ => 1 } qw(
 collection copyright_class copyright_holder format kind location
 news_restriction personality photographer subject
);

sub _fix_lat_long {
  my $self = shift;
  my $rs   = shift;
  for my $rec (@$rs) {
    my $loc = delete $rec->{location};
    next unless $loc;
    my $pt = parse_wkt_point($loc);
    next unless $pt;
    @{$rec}{ 'latitude', 'longitude' } = $pt->latlong;
  }
  return $rs;
}

sub refindex { [sort keys %REF] }

sub refdata {
  my $self = shift;
  my $name = shift;
  die "Bad refdata name $name" unless $REF{$name};
  my $ref
   = $self->dbh->selectall_hashref( "SELECT id, name FROM ss_$name",
    'id' );
  $_ = $_->{name} for values %$ref;
  return $ref;
}

sub page {
  my ( $self, $size, $start ) = @_;
  $size = MAX_PAGE if $size > MAX_PAGE;
  $self->_fix_lat_long(
    $self->dbh->selectall_arrayref(
      "SELECT i.*, AsText(c.location) AS location FROM ss_image AS i "
       . "LEFT JOIN ss_coordinates AS c ON i.acno=c.acno "
       . "WHERE hash IS NOT NULL "
       . "ORDER BY seq ASC LIMIT ?, ?",
      { Slice => {} },
      $start,
      $size
    )
  );
}

sub by {
  my ( $self, $size, $start, $field, $value ) = @_;
  $size = MAX_PAGE if $size > MAX_PAGE;
  return [] unless $field =~ /^\w+$/ && $REF{$field};
  $self->_fix_lat_long(
    $self->dbh->selectall_arrayref(
      "SELECT i.*, AsText(c.location) AS location FROM ss_image AS i "
       . "LEFT JOIN ss_coordinates AS c ON i.acno=c.acno "
       . "WHERE hash IS NOT NULL AND `${field}_id` = ? LIMIT ?, ?",
      { Slice => {} },
      $value,
      $start,
      $size
    )
  );
}

sub search {
  my ( $self, $size, $start, $query ) = @_;
  $size = MAX_PAGE if $size > MAX_PAGE;

  my $sph = Sphinx::Search->new();
  $sph->SetMatchMode(SPH_MATCH_EXTENDED);
  $sph->SetSortMode(SPH_SORT_RELEVANCE);
  $sph->SetLimits( $start, $size );
  my $results = $sph->Query( $query, 'ss_idx' );

  my @ids = map { $_->{doc} } @{ $results->{matches} };
  return [] unless @ids;
  my $ids = join ', ', @ids;
  my $sql
   = "SELECT i.*, AsText(c.location) AS location FROM ss_image AS i "
   . "LEFT JOIN ss_coordinates AS c ON i.acno=c.acno "
   . "WHERE i.acno IN ($ids) "
   . "ORDER BY FIELD(i.acno, $ids) ";

  $self->_fix_lat_long(
    $self->dbh->selectall_arrayref( $sql, { Slice => {} } ) );
}

sub bbox_to_polygon {
  wkt_polygon(
    [$_[1], $_[0]],
    [$_[3], $_[0]],
    [$_[3], $_[2]],
    [$_[1], $_[2]],
    [$_[1], $_[0]]
  );
}

sub region {
  my ( $self, $size, $start, @bbox ) = @_;

  $size = MAX_PAGE if $size > MAX_PAGE;
  my $sql = join ' ',
   "SELECT i.*, AsText(c.location) AS location FROM ss_image AS i, ss_coordinates AS c",
   "WHERE i.acno=c.acno",
   "AND Contains(GeomFromText(?), c.location)",
   "LIMIT ?, ?";

  return $self->_fix_lat_long(
    $self->dbh->selectall_arrayref(
      $sql, { Slice => {} },
      bbox_to_polygon(@bbox), $start, $size
    )
  );
}

sub keywords {
  my ( $self, @acno ) = @_;
  my @bad = grep { !/^\d+$/ } @acno;
  die "Bad acno: ", join( ', ', @bad ) if @bad;
  my $sql = join ' ',
   'SELECT ik.acno, k.id, k.name, COUNT(ik2.acno) AS freq',
   'FROM ss_keyword AS k, ss_image_keyword AS ik, ss_image_keyword AS ik2',
   'WHERE ik.acno IN (', join( ', ', map { "?" } @acno ), ')',
   'AND ik.id=k.id',
   'AND ik2.id=k.id',
   'GROUP BY ik2.id',
   'ORDER BY acno, freq DESC';
  my $rs = $self->dbh->selectall_arrayref( $sql, { Slice => {} }, @acno );
  my $by_acno = { map { $_ => [] } @acno };
  for my $row (@$rs) {
    my $acno = delete $row->{acno};
    push @{ $by_acno->{$acno} }, $row;
  }
  return $by_acno;
}

sub tag {
  my ( $self, $size, $start, $id ) = @_;
  $size = MAX_PAGE if $size > MAX_PAGE;
  $self->_fix_lat_long(
    $self->dbh->selectall_arrayref(
      "SELECT i.*, AsText(c.location) AS location FROM ss_image AS i "
       . "LEFT JOIN ss_coordinates AS c ON i.acno=c.acno, "
       . "ss_image_keyword AS ik "
       . "WHERE hash IS NOT NULL AND ik.acno=i.acno AND ik.id=? LIMIT ?, ?",
      { Slice => {} },
      $id,
      $start,
      $size
    )
  );
}

sub get_tag {
  my ( $self, $acno, $tag ) = @_;
  $self->dbh->do( 'INSERT IGNORE INTO ss_keyword (name) VALUES (?)',
    {}, $tag );
  my $id = (
    $self->dbh->selectrow_array(
      'SELECT id FROM ss_keyword WHERE name=?',
      {}, $tag
    )
  )[0];
  $self->dbh->do(
    'INSERT INTO ss_image_keyword (id, acno) VALUES (?, ?)',
    {}, $id, $acno );
  return { id => $id, name => $tag };
}

sub remove_tag {
  my ( $self, $acno, $id ) = @_;
  $self->dbh->do( 'DELETE FROM ss_image_keyword WHERE id=? AND acno=?',
    {}, $id, $acno );
  return { id => $id };
}

sub tag_complete {
  my ( $self, $size, $prefix ) = @_;
  $size = MAX_PAGE if $size > MAX_PAGE;
  my $rs = $self->dbh->selectcol_arrayref(
    join( ' ',
      'SELECT k.name, COUNT(ik.acno) AS freq',
      'FROM ss_keyword AS k',
      'LEFT JOIN ss_image_keyword AS ik ON ik.id=k.id',
      'WHERE name LIKE ?',
      'GROUP BY k.id',
      'ORDER BY freq DESC LIMIT ?' ),
    {},
    "$prefix%",
    $size
  );
  return {
    query       => $prefix,
    suggestions => $rs,
  };
}

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
