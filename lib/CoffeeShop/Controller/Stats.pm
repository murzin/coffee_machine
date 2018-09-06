package CoffeeShop::Controller::Stats;
use Mojo::Base 'Mojolicious::Controller';
use DateTime;
use DateTime::Duration;

use Data::Dumper;

sub caffeine_level {
  my $c         = shift;
  my $usr_id    = $c->stash('id');
  my $dbh       = $c->app->dbh;

  $usr_id =~ /^\d+$/   
     or return $c->app->error($c, 400, [idError => 'Wrong user id format']);

  my $dt = DateTime->now->subtract(DateTime::Duration->new({'hours'=>23})); # using hour's upper border
  my $start_hour = $dt->ymd.'T'.$dt->hour.':00';

  my $rows = $dbh->selectall_arrayref("
  select strftime('%Y-%m-%dT%H:00', datetime(ts, '+1 hour')) as h, mch_caffein_mg_per_cup -- same - using upper border
  from user
  join consumption using (usr_id)
  join coffee_machine using (mch_id)
  where usr_id = ?
  and ts > ?
  order by ts asc
  ", {Slice => {}}, $usr_id, $dt->ymd.'T'.$dt->hms)
        or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  my $level     = [];
  my $consumed  = {};

  for my $row (@$rows) {
      $consumed->{$row->{h}} += $row->{mch_caffein_mg_per_cup};
  }

  for my $hour (0..23) {
      my $interval = DateTime::Duration->new({hours=>$hour});
      my $cur_dt = $dt->clone->add($interval);
      my $key = $cur_dt->ymd.'T'.sprintf('%02d', $cur_dt->hour).':00';
      if ($hour == 0) {
          push @$level, {$key => 0 + $consumed->{$key}//0};
      } else {
          my ($prev_level) = values %{$level->[-1]}; 
          my $cur_level = sprintf "%.2f", ($prev_level - ($prev_level/100*12.945)); # 12.945% per hour makes appr. 50% per 5 hours
          push @$level, {$key => 0 + ($consumed->{$key}//0) + $cur_level};
      }
  }

  return $c->render(json => $level); 
}

sub coffee_history {
  my $c     = shift;
  my $id    = $c->stash('id');
  my $type  = $c->stash('type');
  my $dbh   = $c->app->dbh;

  if ($type) {
      $type =~ /^machine|user$/
         or return $c->app->error($c, 400, [typeError => 'Unknown stats type']);
      $id =~ /^\d+$/   
         or return $c->app->error($c, 400, [idError => 'Wrong id format']);
  }

  my $rows = $dbh->selectall_arrayref("
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
    "order by ts asc",
    {Slice => {}}, $type ? $id : ())
        or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  my $history = [];
  for my $row (@$rows) {
      my $h = {timestamp => $row->{ts}};
      $h->{user} = {id => $row->{usr_id}, login => $row->{usr_login}}; 
      $h->{machine} = {id => $row->{mch_id}, name => $row->{mch_name}};
      push @$history, $h; 
  }

  $c->render(json => $history);
}

1;
