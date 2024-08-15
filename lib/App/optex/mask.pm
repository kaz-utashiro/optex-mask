package App::optex::mask;

use 5.024;
use warnings;

our $VERSION = "0.01";

=encoding utf-8

=head1 NAME

App::optex::mask - optex data masking module

=head1 SYNOPSIS

    optex -Mmask patterns -- --mask=deepl command

=head1 DESCRIPTION

App::optex::mask is an B<optex> module for masking data given as
standard input to a command to be executed. It transforms strings
matching a specified pattern according to a set of rules before giving
them as input to a command, and restores the resulting content to the
original string.

Multiple conversion rules can be specified, but currently only
C<deepl> is supported. The C<deepl> rule converts a string to an XML
tag such as C<< <m id=999 /> >>.

=head1 LICENSE

Copyright ©︎ 2024 Kazumasa Utashiro

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kazumasa Utashiro

=cut

use List::Util qw(first);
use Hash::Util qw(lock_keys);
use Data::Dumper;

our @mask_pattern;
my  @restore_list;

my %option = (
    debug => undef,
);
lock_keys(%option);

my($mod, $argv);

sub initialize {
    ($mod, $argv) = @_;
    if (defined (my $i = first { $argv->[$_] eq '--' } keys @$argv)) {
	@mask_pattern = splice @$argv, 0, $i;
	shift @$argv eq '--' or die;
    }
}

sub debug {
    $option{debug} or return;
    my $mark = shift;
    warn $_[0] =~ s/^/$mark: /mgr;
}

sub mask {
    my %arg = @_;
    my $mode = $arg{mode};
    local $_ = do { local $/; <> } // die $!;
    my $id = 0;
    debug('1', $_);
    for my $pat (@mask_pattern) {
	s{$pat}{
	    my $tag = sprintf("<m id=%d />", ++$id);
	    push @restore_list, $tag, ${^MATCH};
	    $tag;
	}gpe;
    }
    debug('2', $_);
    return $_;
}

sub unmask {
    my %arg = @_;
    my $mode = $arg{mode};
    local $_ = do { local $/; <> } // die $!;
    my @restore = @restore_list;
    debug('3', $_);
    while (my($str, $replacement) = splice @restore, 0, 2) {
	s/\Q$str/$replacement/g;
    }
    use Encode ();
    $_ = Encode::decode('utf8', $_) if not utf8::is_utf8($_);
    debug('4', $_);
    print $_;
}

sub set {
    while (my($k, $v) = splice(@_, 0, 2)) {
	exists $option{$k} or next;
	$option{$k} = $v;
    }
    ();
}

1;

__DATA__

builtin mask-pattern=s @mask_pattern

autoload -Mutil::filter --osub --psub

option --mask-encode --psub __PACKAGE__::mask(mode=$<shift>)
option --mask-decode --osub __PACKAGE__::unmask(mode=$<shift>)

option --mask \
	--mask-encode $<copy(0,1)> \
	--mask-decode $<move(0,1)>

option --mask-deepl --mask deepl
