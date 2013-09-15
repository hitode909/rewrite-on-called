use strict;
use warnings;
use FindBin;
use lib 'lib';
use lib "$FindBin::Bin/../lib";
use RewriteOnCalled;

package Adder {
    sub new {
        my ($class) = @_;

        bless {}, $class;
    }

    # DEPRECATED: use add instead
    sub legacy_add {
        my ($class, %args) = @_;
        $args{a} + $args{b};
    }

    sub add {
        my ($class, $a, $b) = @_;

        $a + $b;
    }
};

my $rewrite_on_called = RewriteOnCalled->new;
$rewrite_on_called->register('Adder', 'legacy_add', sub {
    my ($self, $adder, %args) = @_;
    my $a = $args{a};
    my $b = $args{b};
    my $args_string = $self->dump([$a, $b]);
    "add($args_string)";
});

my $adder = Adder->new;
warn $adder->legacy_add(a => 1, b => 2);

__END__

after:

my $adder = Adder->new;
# warn $adder->legacy_add(a => 1, b => 2);
warn $adder->add(1, 2);
