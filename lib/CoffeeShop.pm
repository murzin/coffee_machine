package CoffeeShop;
use Mojo::Base 'Mojolicious';
use Mojo::File qw(path);

use DBI;
use Data::Dumper;

# This method will run once at server start
sub startup {
    my $self   = shift;
    my $config = $self->plugin('Config');
    my $log    = $self->log;

    $log->warn("Mojolicious Mode is " . $self->mode);
    $log->warn("Log Level        is " . $log->level);
    $log->warn("App Path         is " . $self->home);

    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=".path($self->home, $config->{sqlite3_db_file}), "", "") or die $DBI::errstr;
    $self->{dbh}->do("PRAGMA foreign_keys=ON") or die $DBI::errstr;

    my $r = $self->routes;

    $r->get('/')->to('example#welcome');
    $r->put('/user/request')->to('user#request');
    $r->post('/machine')->to('machine#register');
    $r->get('/coffee/buy/:usr_id/:mch_id')->to('consumption#consume');
    $r->put('/coffee/buy/:usr_id/:mch_id')->to('consumption#consume_ts');
}

sub dbh {
    my $self = shift;
    $self->{dbh} or die "dbh gone!"; # my be reconnect or use DBIx::Connector
}

sub error {
    my $self    = shift;
    my $c       = shift;
    my $code    = shift || 418;
    my $err_msg = shift || [unknownError => 'Unknown Error'];

    $self->log->error("App Error: ".$err_msg->[0]." : ".$err_msg->[1]);
    $c->render(json   => {error_code => $err_msg->[0], error_text => $err_msg->[1]},
               status => $code);
}

1;
