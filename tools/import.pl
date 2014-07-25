#!/usr/bin/env perl

use autodie;
use strict;
use warnings;

use DBI;
use Digest::SHA1;
use Geo::WKT;
use Image::Size;
use JSON;
use Memoize;
use Path::Class;

memoize 'ref_data';

use constant DB_SRC  => 'shitshifter';
use constant DB_DST  => 'ss';
use constant DB_USER => 'root';
use constant DB_PASS => '';
use constant DB_HOST => 'localhost';

use constant STRIP   => '/pictures';
use constant IMG_SRC => dir 'orig';
use constant IMG_DST => dir 'app/public/asset';

{
  my $dbs = dbh(DB_SRC);
  my $dbd = dbh(DB_DST);

  my $sel_i = $dbs->prepare('SELECT * FROM image');

  my $sel_g = $dbs->prepare(
    join ' ', 'SELECT title',
    'FROM gallery AS g, imageGallery AS ig',
    'WHERE ig.gallery_id=g.id AND ig.image_id=?'
  );

  my $sel_r = $dbs->prepare(
    join ' ',
    'SELECT realName',
    'FROM userDetails AS ud, imageRider AS ir',
    'WHERE ir.user_id=ud.id AND ir.image_id=?'
  );

  my $sel_p = $dbs->prepare(
    join ' ',
    'SELECT realName',
    'FROM userDetails',
    'WHERE id=?'
  );

  $sel_i->execute;
  while ( my $row = $sel_i->fetchrow_hashref ) {

    # Link file
    my $src = file IMG_SRC, file( $row->{path} )->relative(STRIP);
    unless ( -e $src ) {
      print "*** $src missing, skipping\n";
      next;
    }
    my $hash = hash_file($src);
    my $dst = mk_dst_name( IMG_DST, $hash );
    print "$src -> $dst\n";
    $dst->parent->mkpath;
    link $src, $dst unless -e $dst;

    my ( $w, $h, $err ) = imgsize("$dst");
    die $err unless defined $w && defined $h;

    transaction(
      $dbd,
      sub {

        # Keywords
        my @kw = ( $row->{setName}, split /,/, $row->{keywords} );
        for my $query ( $sel_g, $sel_r ) {
          $query->execute( $row->{id} );
          push @kw, map { $_->[0] } @{ $query->fetchall_arrayref };
        }

        my %seen = ();
        for my $kw ( grep { length } map { tidy($_) } @kw ) {
          next if $seen{ lc $kw }++;
          print "  $kw\n";
          my $kw_id = ref_data( $dbd, 'ss_keyword', $kw );
          insert( $dbd, 'ss_image_keyword', { id => $kw_id, acno => $row->{id} } );
        }

        # Photographer
        if ( $row->{photographer} > 0 ) {
          $row->{photographer} = (
            $dbs->selectrow_array(
              'SELECT realName FROM userDetails WHERE id=?', {},
              $row->{photographer}
            )
          )[0];
        }
        else {
          $row->{photographer} = '';
        }

        # Location
        if ( $row->{latitude} || $row->{longitude} ) {
          $dbd->do(
            join( ' ',
              'INSERT INTO ss_coordinates (acno, location)',
              'VALUES (?, GeomFromText(?))' ),
            {},
            $row->{id},
            wkt_point( $row->{longitude}, $row->{latitude} )
          );
        }

        my $img_rec = {
          acno        => $row->{id},
          headline    => $row->{title},
          annotation  => $row->{description},
          width       => $w,
          height      => $h,
          origin_date => $row->{taken},
          hash        => $hash,
          seq         => rand,
          photographer_id =>
           ref_data( $dbd, 'ss_photographer', $row->{photographer} ),

#            collection_id => ref_data( $dbd, 'ss_collection', $row->{collection} ),
#            copyright_class_id =>
#             ref_data( $dbd, 'ss_copyright_class', $row->{copyrightclass} ),
#            copyright_holder_id =>
#             ref_data( $dbd, 'ss_copyright_holder', $row->{copyrightholder} ),
#            format_id   => ref_data( $dbd, 'ss_format',   $row->{format} ),
#            kind_id     => ref_data( $dbd, 'ss_kind',     $kind ),
#            location_id => ref_data( $dbd, 'ss_location', $row->{location} ),
#            news_restriction_id =>
#             ref_data( $dbd, 'ss_news_restriction', $row->{newsrestrictions} ),
#            personality_id =>
#             ref_data( $dbd, 'ss_personality', $row->{personalities} ),
#            subject_id => ref_data( $dbd, 'ss_subject', $row->{subject} ),
        };

        insert( $dbd, 'ss_image', $img_rec );

      }
    );
  }

  $dbs->disconnect;
  $dbd->disconnect;
}

sub tidy {
  my $s = shift;
  s/^\s+//, s/\s+$//, s/\s+/ /g for $s;
  return $s;
}

sub trim {
  my $s = shift;
  s/^\s+//, s/\s+$// for $s;
  return $s;
}

sub mk_dst_name {
  my ( $root, $hash ) = @_;
  my @path = $hash =~ /^(...)(...)(.+)$/;
  $path[-1] .= '.jpg';
  return file( $root, @path );
}

sub hash_file {
  my $obj = shift;
  open my $fh, '<', $obj;
  return Digest::SHA1->new->addfile($fh)->hexdigest;
}

sub ref_data {
  my ( $dbh, $tbl, $value ) = @_;
  return undef unless defined $value && length $value;
  my ( $sql, @bind ) = make_select( $tbl, { name => $value }, ['id'] );
  my ($id) = $dbh->selectrow_array( $sql, {}, @bind );
  return $id if defined $id;
  insert( $dbh, $tbl, { name => $value } );
  return $dbh->last_insert_id( undef, undef, $tbl, 'id' );
}

sub transaction {
  my ( $dbh, $cb ) = @_;
  $dbh->do('START TRANSACTION');
  eval { $cb->() };
  if ( my $err = $@ ) {
    $dbh->do('ROLLBACK');
    die $err;
  }
  $dbh->do('COMMIT');
}

sub insert {
  my ( $dbh, $tbl, $rec ) = @_;
  my @k = sort keys %$rec;
  my $sql
   = "INSERT INTO `$tbl` ("
   . join( ', ', map "`$_`", @k )
   . ") VALUES ("
   . join( ', ', map '?', @k ) . ")";
  my $sth = $dbh->prepare($sql);
  $sth->execute( @{$rec}{@k} );
}

sub make_where {
  my $sel = shift;
  my ( @bind, @term );
  for my $k ( sort keys %$sel ) {
    my $v = $sel->{$k};
    my ( $op, $vv ) = 'ARRAY' eq ref $v ? @$v : ( '=', $v );
    push @term, "`$k` $op ?";
    push @bind, $vv;
  }
  @term = ('TRUE') unless @term;
  return ( join( ' AND ', @term ), @bind );
}

sub make_select {
  my ( $tbl, $sel, $cols ) = @_;

  my ( $where, @bind ) = make_where($sel);

  my @sql = (
    'SELECT',
    ( $cols ? join ', ', map "`$_`", @$cols : '*' ),
    "FROM `$tbl` WHERE ", $where
  );

  return ( join( ' ', @sql ), @bind );
}

sub show_sql {
  my ( $sql, @bind ) = @_;
  my $next = sub {
    my $val = shift @bind;
    return 'NULL' unless defined $val;
    return $val if $val =~ /^\d+(?:\.\d+)?$/;
    $val =~ s/\\/\\\\/g;
    $val =~ s/\n/\\n/g;
    $val =~ s/\t/\\t/g;
    return "'$val'";
  };
  $sql =~ s/\?/$next->()/eg;
  return $sql;
}

sub dbh {
  my $db = shift;
  return DBI->connect(
    sprintf( 'DBI:mysql:database=%s;host=%s', $db, DB_HOST ),
    DB_USER, DB_PASS, { RaiseError => 1 } );
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

