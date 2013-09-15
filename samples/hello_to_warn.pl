use strict;
use warnings;
use FindBin;
use lib 'lib';
use lib "$FindBin::Bin/../lib";
use RewriteOnCalled;

my $rewrite_on_called = RewriteOnCalled->new;
$rewrite_on_called->register('main', 'legacy_warn', sub {
    my ($self, @args) = @_;
    my $args_string = $self->dump(\@args);
    "warn($args_string)";
});

legacy_warn();

legacy_warn('world');

legacy_warn('world', '!');
legacy_warn({'world' => '!'});
legacy_warn(['world', '!']);

my $world = 'world';
# $world will be 'world'
legacy_warn($world);

if (0) {
    # will ignored because not called
    legacy_warn("world", 2);
}

# inner legacy_warn will removed
legacy_warn(legacy_warn());

__END__

after:

# legacy_warn();
warn();

# legacy_warn('world');
warn('world');

# legacy_warn('world', '!');
warn('world', '!');
# legacy_warn({'world' => '!'});
warn({'world' => '!'});
# legacy_warn(['world', '!']);
warn(['world','!']);

my $world = 'world';
# $world will be 'world'
# legacy_warn($world);
warn('world');

if (0) {
    # will ignored because not called
    legacy_warn("world", 2);
}

# inner legacy_warn will removed
# legacy_warn(legacy_warn());
warn();
