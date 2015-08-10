package Dn::Package;

use Moo;
use strictures 2;
use 5.014_002;
use version; our $VERSION = qv('0.1');
use namespace::clean;

use autodie qw(open close);
use Carp;
use Dn::Common;
use Dn::Menu;
use English qw(-no_match_vars);
use Function::Parameters;
use MooX::HandlesVia;
use Path::Tiny;
use Readonly;
use Try::Tiny;
use Types::Common::Numeric qw(PositiveNum PositiveOrZeroNum SingleDigit);
use Types::Common::String qw(NonEmptySimpleString LowerCaseSimpleStr);
use Types::Standard qw(InstanceOf Int Str);
use Types::Path::Tiny qw(AbsDir AbsPath)
use experimental 'switch';
my $cp = new Dn::Common;

Readonly my $TRUE  => 1;
Readonly my $FALSE => 0;

# debug
use Data::Dumper::Simple;

# ATTRIBUTES

has '_attr_1' => (
    is            => 'ro',
    isa           => Types::Standard::Str,
    required      => $TRUE,
    builder       => '_build_attr_1',
    documentation => 'Shown in usage',
);

method _build_attr_1 () {
    return My::App->new->get_value;
}

has '_attr_2_list' => (
    is  => 'rw',
    isa => Types::Standard::ArrayRef [
        Types::Standard::InstanceOf ['Config::Simple']
    ],
    lazy        => $TRUE,
    default     => sub { [] },
    handles_via => 'Array',
    handles     => {
        _attrs    => 'elements',
        _add_attr => 'push',
        _has_attr => 'count',
    },
    documentation => q{Array of values},
);

# attributes: _attr_3, _attr_4
#             private, scalar integer
has [ '_attr_3', '_attr_4' ] => (
    is  => 'rw',
    isa => Types::Standard::Int,
);

# attribute: _attr_5
#            private, class
has '_attr_5' => (
    is      => 'rw',
    isa     => Types::Standard::InstanceOf['Net::DBus::RemoteObject'],
    builder => '_build_attr_5',
);

method _build_attr_5 () {
    return Net::DBus->session->get_service('org.freedesktop.ScreenSaver')
        ->get_object('/org/freedesktop/ScreenSaver');
}

# METHODS

# my_method($thing)
#
# does:   it does stuff
# params: $thing - for this [optional, default=grimm]
# prints: nil
# return: scalar boolean
method my_method ($thing) {
}

1;

__END__

=head1 NAME

My::Module - what I do

=head1 SYNOPSIS

    use My::Module;
    ...

=head1 DESCRIPTION

Full description. May have subsections.

=head1 SUBROUTINES/METHODS

=head2 method1($param)

=head3 Purpose

Method purpose.

=head3 Parameters

=over

=item $param

Parameter details. Scalar string.

Required.

=back

=head1 DIAGNOSTICS

Supposedly a listing of every error and warning message
that the module can generate (even the ones that will
"never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

Really?

=head1 CONFIGURATION AND ENVIRONMENT

Config files and locations, and available settings.

Config variables, and available settings.

=head1 DEPENDENCIES

=over

=item autodie

=item Carp

=item Dn::Common

=item Dn::Menu

=item English

=item experimental

=item Function::Parameters

=item Moo

=item MooX::HandlesVia

=item namespace::clean

=item Path::Tiny

=item Readonly

=item strictures

=item Try::Tiny

=item Types::Common::Numeric

=item Types::Common::String

=item Types::Path::Tiny

=item Types::Standard

=item version

=back

=head2 INCOMPATIBILITIES

Modules this one cannot be used with, and why.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2015 David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
