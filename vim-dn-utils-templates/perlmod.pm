package Dn::Package;

use Moo;    #                                                          {{{1
use strictures 2;
use 5.006;
use v5.22.1;
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
use Types::Standard;
use experimental 'switch';

my $cp = Dn::Common->new();
Readonly my $TRUE  => 1;
Readonly my $FALSE => 0;

# debug
use Data::Dumper::Simple;    #                                         }}}1

# Attributes

# has _attr_1                                                          {{{1
has '_attr_1' => (
    is            => 'lazy',
    isa           => Types::Standard::Str,
    documentation => 'Insert here',
);

method _build__attr_1 () {
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
    documentation => 'Array of values',
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

=head1 ATTRIBUTES

=head2 attr_1

Does stuff...

Scalar string. Required.

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

autodie, Carp, Dn::Common, Dn::Menu, English, experimental, Function::Parameters, Moo, MooX::HandlesVia, namespace::clean, Path::Tiny, Readonly, strictures, Try::Tiny, Types::Common::Numeric, Types::Common::String, Types::Path::Tiny, Types::Standard, version.

=back

=head2 Executables

wget.

=head2 INCOMPATIBILITIES

Modules this one cannot be used with, and why.

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2016 David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
# vim:fdm=marker
