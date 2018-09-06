package CoffeeShop::Controller::Consumption;
use Mojo::Base 'Mojolicious::Controller';

use DateTime::Format::ISO8601;
use Data::Dumper;

sub consume {
  my $c      = shift;
  my $usr_id = $c->stash('usr_id');
  my $mch_id = $c->stash('mch_id');
  my $dbh    = $c->app->dbh;

  $dbh->do("insert into consumption(usr_id, mch_id, ts) values (?, ?, datetime())",
            {}, $usr_id, $mch_id)
            or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  $c->rendered(200);
}

sub consume_ts {
  my $c      = shift;
  my $args   = $c->req->json;
  my $usr_id = $c->stash('usr_id');
  my $mch_id = $c->stash('mch_id');
  my $dbh    = $c->app->dbh;

  my $ts;
  eval { $ts = DateTime::Format::ISO8601->parse_datetime($args->{timestamp}) };
  if ($@) {
      return $c->app->error($c, 400, [datetimeFormatError => $@ =~ s/ at .+$//r]);
  }

  $dbh->do("insert into consumption(usr_id, mch_id, ts) values (?, ?, ?)",
           {}, $usr_id, $mch_id, $ts->ymd('-') . 'T' . $ts->hms(':'))
           or return $c->app->error($c, 400, [dbError => $DBI::errstr]);

  $c->rendered(200);
}

1;
