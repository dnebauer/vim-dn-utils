package Dn::Package;

use Moo;    #                                                          {{{1
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
use Data::Dumper::Simple;    #                                         }}}1

# Attributes

# has _attr                                                            {{{1
has '_attr' => (
    is            => 'ro',
    isa           => Types::Standard::Str,
    required      => $TRUE,
    builder       => '_build_attr',
    documentation => 'Insert here',
);

method _build_attr_1 () {
    return My::App->new->get_value;
}

# has _attr_list                                                       {{{1
has '_attr_list' => (
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
);    #                                                                }}}1

# Methods

# my_method($thing)                                                    {{{1
#
# does:   it does stuff
# params: $thing - for this [optional, default=grimm]
# prints: nil
# return: scalar boolean
method my_method ($thing) {
}    #                                                                 }}}1

1;

# POD                                                                  {{{1
__END__

=head1 NAME

My::Module - what I do

=head1 SYNOPSIS

    use My::Module;
    ...

=head1 DESCRIPTION

Full description. May have subsections.

=head1 METHODS

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

=head2 Perl modules

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

=head2 Execuutables

=over

=item 

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
# vim:fdm=marker
