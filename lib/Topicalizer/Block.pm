package Topicalizer::Block;

# Copyright (c) 2012 Iain Campbell. All rights reserved.
#
# This work may be used and modified freely, but I ask that the copyright 
# notice remain attached to the file. You may modify this module as you 
# wish, but if you redistribute a modified version, please attach a note 
# listing the modifications you have made.

BEGIN {
    $Topicalizer::Block::AUTHORITY = 'cpan:CPANIC';
    $Topicalizer::Block::VERSION   = '1.00';
    $Topicalizer::Block::VERSION   = eval $Topicalizer::Block::VERSION;
}

use 5.008_004;
use strict;
use warnings;
use Params::Callbacks qw/list item/;

require Exporter;

our @ISA = qw/Exporter/;

our @EXPORT_OK = qw/block yield list item/;

our %EXPORT_TAGS = (
    all => [ @EXPORT_OK ]
);

our $callbacks;
our $has_yielded;
our $topic;

# RESULT = block { STATEMENT(S) } LIST;

sub block (&;@) {
    local $_;
    local($has_yielded, $topic) = (0, shift);
    local($callbacks) = Params::Callbacks->extract(@_);
    my @result = $topic->();
    return @result if $has_yielded; 
    return $callbacks->yield(@result);
}

# RESULT = yield LIST;

sub yield {
    $has_yielded = 1;
    $callbacks->yield(@_);
}

1;
__END__
=pod

=encoding utf-8

=head1 NAME

Topicalizer::Block - Topicalizer built around Params::Callbacks

=head1 SYNOPSIS

    use Topicalizer::Block qw/:all/;

    # Give me odd numbers between 1 and 10, along block some witty banter

    my @odds = block { 1..10 } item { 
        $_ % 2 ? $_ : (); 
    } item { 
        printf "%2d\n", $_; 
        return $_; 
    } list {
        printf "--\n%2d items\n", scalar @_;
        return @_;
    };

    # Ask for numbers, tell me about the odd ones

    block {
        block {
            my @set;

            print "Enter some numbers, or just Enter to stop\n\n"; 
            
            while (chomp(my $number = <STDIN>)) {
                last unless $number;
                next unless $number =~ /^\d+$/;
                push @set, yield $number;
            }

            return @set;
        } item { 
            $_ % 2 ? $_ : () 
        };
    }
    item { 
        printf "%4d\n", $_; 
        return $_;
    } list {
        printf "----\n%4d items\n", scalar @_;
        return @_;
    };

=head1 DESCRIPTION

This package introduces a topicalizer function, called C<block>. The function
complements such Perl built-ins as C<map>, C<grep> and C<sort>.

=over 5

=item B<RESULT = block STATEMENT-BLOCK CALLBACK-LIST;>

Execute a block of statements to arrive at a result that can be processed by 
the listed callbacks.

=item B<RESULT = yield LIST;>

Normally, the result of the C<block> is yielded automatically once the 
block terminates, or once you use the C<return> statement. That is, your
result is yielded to the callback queue for processing before being delivered
to the caller.

But what about those situations in which you would like to yield result to
the callback queue, returning the processed result back to the C<block> block?

The C<yield> function despatches its arguments immediately to the callback 
queue, returning whatever comes out of the other end. The C<block>'s
execution then continues.

Yielding early, cancels automatic dispatch to the callback queue.

=item B<list STATEMENT-BLOCK [CALLBACK-LIST]>

The list function introduces a callback that consumes an entire result set 
in C<@_>.

    @result = block {
        @result_out;
    } list {
        @result_in = @_;
        ...
        @result_out;
    } list {
        @result_in = @_;
        ...
        @result_out;
    } list {
        @result_in = @_;
        ...
        @final_result;
    };
    
=item B<item STATEMENT-BLOCK [CALLBACK-LIST]>

Use in place of C<list> when you want to introduce a callback that consumes
an result set one item at a time, or a callback that works on a scalar 
result in C<$_> or $_[0]. 

    @result = block {
        @result_out;
    } item {
        $result_in = shift;
        ...
        $resul_out;
    } item {
        $result_in = shift;
        ...
        $result_out;
    } item {
        $result_in = shift;
        ...
        $result_out;
    };
 
Results processed using the C<item> blocks are always gathered up into a list
before being passed on. Therefore, both the C<item> and C<list> callbacks may 
be mixed freely.

=back

=head1 EXPORTS

=head2 @EXPORT

None.

=head2 @EXPORT_OK

=over 5 

=item block, yield, list, item

=back 

=head2 %EXPORT_TAGS

=over 5

=item C<:all>

Everything in @EXPORT_OK.

=back 

=head1 BUGS REPORTS

Please report any bugs to L<http://rt.cpan.org/>

=head1 AUTHOR

Iain Campbell <cpanic@cpan.org>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2012 by Iain Campbell

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut