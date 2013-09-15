# RewriteOnCalled

- A Perl Class for runtime source code replacement.
- Register method name and callback. When the method is called, callback will be called.
- Arguments are passed to callback. Use it to replae legacy method calling.
- Useful for Refactoring.

## Examples

### Replacing method name

When you want to replace function "legacy_warn" to "warn",

#### Before

```perl
my $rewrite_on_called = RewriteOnCalled->new;
$rewrite_on_called->register('main', 'legacy_warn', sub {
    my ($self, @args) = @_;
    my $args_string = $self->dump(\@args);
    "warn($args_string)";
});

legacy_warn('world');
```

#### After

```
# legacy_warn('world');
warn('world');
```

### Replacing argument style

When "old_add" accepts Hash-style arguments, but new "add" accepts List-style arguments,

#### Before

```perl
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
```

#### After

```perl
my $adder = Adder->new;
# warn $adder->legacy_add(a => 1, b => 2);
warn $adder->add(1, 2);
```

License
=======

MIT