package RewriteOnCalled;
use strict;
use warnings;
use PPI;
use List::Util qw(first);
use List::MoreUtils qw(any);
use Data::Dumper;

sub new {
    my ($class) = @_;

    bless {}, $class;
}

# Register a hook.  When $module->$method called, RewiriteOnCalled
# arguments:
#   $module: Module name to rewrite
#   $method: Method name to rewrite
#   $rewrite: Callback to rewrite code. arguments: (RewriteOnCalled, (original arguments). return replaced code(String)
sub register {
    my ($self, $module, $method, $rewrite) = @_;

    no strict 'refs';
    no warnings qw/redefine prototype/;

    my $module_method = "$module\::$method";

    *{$module_method} = sub {
        my @caller = caller(0);
        my $file_name = $caller[1];
        my $line_number = $caller[2];

        my $doc = PPI::Document->new($file_name);

        my $statement = first {
            any {
                ($_ eq $method || $_ eq $module_method) && $_->line_number == $line_number;
            } $_->children;
        } @{$doc->find('PPI::Statement')};

        my ($part1, $part2) = $self->_extract_part($statement, $method);

        my $comment_out = ($statement =~ s/^/# /rgm) . "\n";
        my $comment_out_doc = PPI::Document->new(\$comment_out);
        for my $comment (@{$comment_out_doc->find('PPI::Token::Comment')}) {
            $statement->insert_before($comment);
        }

        my $rewritten_body = $rewrite->($self, @_);

        my $new_content = $part1 . $rewritten_body . $part2;

        my $replace_to = PPI::Document->new(\$new_content);

        $statement->insert_before($replace_to->find('PPI::Statement')->[0]);
        $statement->remove;

        $doc->save($file_name);

        die "$method replaced";
    };
}

# utility to serialize argumentas
sub dump {
    my ($self, $args) = @_;
    join ', ', Data::Dumper->new($args)->Terse(1)->Sortkeys(1)->Indent(0)->Dump;
}

# <part1>method(   )<part2>
sub _extract_part {
    my ($self, $statement, $method) = @_;

    my ($part1, $part2, $method_found, $paren_stack, $paren_found) = ('', '', 0, 0, 0);

    for my $token (@{$statement->find('PPI::Token')}) {
        if ($paren_found) {
            $part2 .= $token;
        } elsif ($method_found) {
            if ($token eq '(') {
                $paren_stack++;
                next;
            } elsif ($token eq ')') {
                $paren_stack--;
                if ($paren_stack == 0) {
                    $paren_found = 1;
                }
            }
        } else {
            if ($token eq $method) {
                $method_found = 1;
            } else {
                $part1 .= $token;
            }
        }
    }
    ($part1, $part2);
}

1;
