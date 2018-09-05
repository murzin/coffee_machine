package CoffeeShop::Controller::Machine;
use Mojo::Base 'Mojolicious::Controller';

sub register {
  my $c    = shift;
  my $args = $c->req->json;
  my $dbh  = $c->app->dbh;

  $dbh->do("insert into coffee_machine (mch_name, mch_caffein_mg_per_cup) values (?, ?)",
            {}, $args->{name}, $args->{mg})
            or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  my $usr_id = $dbh->selectcol_arrayref("select last_insert_rowid()")
            or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  $c->render(json => {id => $usr_id->[0]});
}

1;
