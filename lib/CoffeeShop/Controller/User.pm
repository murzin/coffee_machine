package CoffeeShop::Controller::User;
use Mojo::Base 'Mojolicious::Controller';

sub request {
  my $c    = shift;
  my $args = $c->req->json;
  my $dbh  = $c->app->dbh;

  $args->{email} =~ /^[^@]+@[^@]+$/  # just a trivial check
            or return $c->app->error($c, 400, [emailFormatError => 'Seems email format is wrong']);

  $dbh->do("insert into user (usr_login, usr_email, usr_password) values (?, ?, ?)",
            {}, $args->{login}, $args->{email}, $args->{password})
            or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  my $usr_id = $dbh->selectcol_arrayref("select last_insert_rowid()")
            or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  $c->render(json => {id => $usr_id->[0]});
}

1;
