package With;

# Copyright (c) 2012 Iain Campbell. All rights reserved.
#
# This work may be used and modified freely, but I ask that the copyright 
# notice remain attached to the file. You may modify this module as you 
# wish, but if you redistribute a modified version, please attach a note 
# listing the modifications you have made.

BEGIN {
    $With::AUTHORITY = 'cpan:CPANIC';
    $With::VERSION   = '1.000_000';
    $With::VERSION   = eval $With::VERSION;
}

use 5.008_004;
use strict;
use warnings;
use Params::Callbacks qw/list item/;

require Exporter;

our @ISA = qw/Exporter/;

our @EXPORT_OK = qw/with yield list item/;

our %EXPORT_TAGS = (
    all => [ @EXPORT_OK ]
);

our $callbacks;
our $has_yielded;
our $topic;

# RESULT = with { STATEMENT(S) } LIST;

sub with (&;@) {
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

With - Topicalizer built around Params::Callbacks

=head1 SYNOPSIS

    use With qw/:all/;

    # Give me odd numbers between 1 and 10, along with some witty banter

    my @odds = with { 1..10 } item { 
        $_ % 2 ? $_ : (); 
    } item { 
        printf "%2d\n", $_; 
        return $_; 
    } list {
        printf "--\n%2d items\n", scalar @_;
        return @_;
    };

    # Ask for numbers, tell me about the odd ones

    with {
        with {
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

This package introduces a topicalizer function, called C<with>. The function
complements such Perl built-ins as C<map>, C<grep> and C<sort>.

=over 5

=item B<RESULT = with STATEMENT-BLOCK CALLBACK-LIST;>

Execute a block of statements to arrive at a result that can be processed by 
the listed callbacks.

=item B<RESULT = yield LIST;>

Normally, the result of the C<with> block is yielded automatically once the 
block terminates, or once you use the C<return> statement. That is, your
result is yielded to the callback queue for processing before being delivered
to the caller.

But what about those situations in which you would like to yield result to
the callback queue, returning the processed result back to the C<with> block?

The C<yield> function despatches its arguments immediately to the callback 
queue, returning whatever comes out of the other end. The C<with> block's
execution then continues.

Yielding early, cancels automatic dispatch to the callback queue.

=item B<list STATEMENT-BLOCK [CALLBACK-LIST]>

The list function introduces a callback that consumes an entire result set 
in C<@_>.

    @result = with {
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

	@result = with {
		@result_out;
    } item {
        $result_in = shift;
        ...
		$resul_out;
    } item {
        $result_in = shift;
        ...
		$resul_out;
    } item {
        $result_in = shift;
        ...
		$resul_out;
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

=item with, yield, list, item

=back 

=head2 %EXPORT_TAGS

=over 5

=item C<:all>

Everything in @EXPORT_OK.

=back 

=head1 BUGS AND FEATURE REQUESTS

Too many features; not enough bugs? Just drop me a line and I'll see what
I can do to help.  

=head1 AUTHOR

Iain Campbell <cpanic@cpan.org>

=head1 COPYRIGHT AND LICENCE

Copyright (C) 2012 by Iain Campbell

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.

=cut