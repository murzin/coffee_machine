package CoffeeShop;
use Mojo::Base 'Mojolicious';
use Mojo::File qw(path);

use DBI;
use Data::Dumper;

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');
  my $log    = $self->log;

    $log->warn("Mojolicious Mode is " . $self->mode);
    $log->warn("Log Level        is " . $log->level);
    $log->warn("App Path         is " . $self->home);

    $self->{dbh} = DBI->connect("dbi:SQLite:dbname=".path($self->home, $config->{sqlite3_db_file}), "", "") or die $DBI::errstr;

    my $rows = $self->dbh->selectall_arrayref("select * from user");
    $log->warn(Dumper $rows);

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

sub dbh {
    my $self = shift;
    $self->{dbh} or die "dbh gone!";
}
1;
