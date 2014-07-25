package SS::Site::Data;

use Moose;

use Dancer ':syntax';
use Dancer::Plugin::Database;

use SS::Data::Model;
use SS::Filter qw( cook );

=head1 NAME

SS::Data - Data handlers

=cut

sub model { SS::Data::Model->new( dbh => database ) }

prefix '/svc' => sub {
  post '/tag/remove/:acno/:id' => sub {
    model->remove_tag( param('acno'), param('id') );
  };
  post '/tag/add/:acno' => sub {
    model->get_tag( param('acno'), param('tag') );
  };
  get '/tag/complete/:size' => sub {
    model->tag_complete( param('size'), param('query') );
  };
};

prefix '/data' => sub {
  get '/ref/index' => sub {
    return model->refindex;
  };
  get '/ref/:name' => sub {
    return model->refdata( param('name') );
  };
  get '/page/:size/:start' => sub {
    return cook assets => model->page( param('size'), param('start') );
  };
  get '/tag/:size/:start/:id' => sub {
    return cook assets =>
     model->tag( param('size'), param('start'), param('id') );
  };
  get '/keywords/:acnos' => sub {
    return cook keywords => model->keywords( split /,/, param('acnos') );
  };
  get '/search/:size/:start' => sub {
    return cook assets =>
     model->search( param('size'), param('start'), param('q') );
  };
  get '/by/:size/:start/:field/:value' => sub {
    return cook assets =>
     model->by( param('size'), param('start'), param('field'),
      param('value') );
  };
  get '/region/:size/:start/:bbox' => sub {
    return cook assets =>
     model->region( param('size'), param('start'), split /,/,
      param('bbox') );
  };
};

1;

# vim:ts=2:sw=2:sts=2:et:ft=perl
