package CoffeeShop::Controller::Stats;
use Mojo::Base 'Mojolicious::Controller';
use Data::Dumper;

sub coffee {
  my $c     = shift;
  my $id    = $c->stash('id');
  my $type  = $c->stash('type');
  my $dbh   = $c->app->dbh;

  if ($type) {
      $type =~ /machine|user/
         or return $c->app->error($c, 400, [typeError => 'Unknown stats type']);
      $id =~ /\d+/   
         or return $c->app->error($c, 400, [idError => 'Wrong id format']);
  }

  my $sql = "
    select usr_id, usr_login, mch_id, mch_name, mch_caffein_mg_per_cup, ts
    from user
    join consumption using (usr_id)
    join coffee_machine using (mch_id)
    where 1=1 ".(
    $type eq 'machine' ?
    "and mch_id = ? "  :
    $type eq 'user'    ?
    "and usr_id = ? "  :
    "").
    "order by ts desc";
    #warn $sql;
  my $rows = $dbh->selectall_arrayref($sql, {Slice => {}}, $type ? $id : ())
  or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  my $history = [];
  for my $row (@$rows) {
      my $h = {timestamp => $row->{ts}};
      $h->{user} = {id => $row->{usr_id}, login => $row->{usr_login}}; 
      $h->{machine} = {id => $row->{mch_id}, name => $row->{mch_name}};
      push @$history, $h; 
  }
  #warn Dumper $history;

  $c->render(json => $history);
}

1;
