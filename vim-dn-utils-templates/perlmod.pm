package Dn::Package;

use Moose;
use 5.014_002;
use version; our $VERSION = qv('0.1');

use MooseX::App::Simple qw(Color);    # requires exception on next line
use namespace::autoclean -except => ['new_with_options'];
#use namespace::autoclean;    # remove if using MooseX::App::Simple
use MooseX::MakeImmutable;
use Moose::Util::TypeConstraints;
use Function::Parameters;
use Try::Tiny;
use Fatal qw(open close);
use English qw(-no_match_vars);
use Carp;
use Readonly;
use Dn::Common;
my $cp = new Dn::Common;
use Dn::Menu;
my $m = new Dn::Menu;

with 'MooseX::Getopt::Usage';    # remove if using MooseX::App::Simple

Readonly my $TRUE  => 1;
Readonly my $FALSE => 0;

# debug
use Data::Dumper;
$Data::Dumper::Useqq   = $TRUE;
$Data::Dumper::Deparse = $TRUE;

# ATTRIBUTES

parameter 'param' => (
    is            => 'rw',
    isa           => 'Str',
    accessor      => '_param',
    required      => $TRUE,
    default       => 'default_value',
    documentation => 'First parameter',
);

option 'option' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => $FALSE,
    reader        => '_option',
    cmd_aliases   => [qw(o)],
    documentation => 'Enable this to do fancy stuff',
);

has '_attr_1' => (
    is            => 'ro',
    isa           => 'Str',
    required      => $TRUE,
    builder       => '_build_attr_1',
    documentation => 'Shown in usage',
);

method _build_attr_1 () {
    return My::App->new->get_value;
}


has '_attr_2' => (
    is            => 'ro',
    isa           => 'Str',
    default       => 'value',
    documentation => 'Shown in usage',
);

has [ '_attr_3', '_attr_4' ] => (
    is  => 'rw',
    isa => 'Int',
);

has '_attr_5' => (
    is      => 'rw',
    isa     => 'Net::DBus::RemoteObject',
    traits  => ['NoGetOpts'],
    builder => '_build_attr_5',
);

method _build_attr_5 () {
    return Net::DBus->session->get_service('org.freedesktop.ScreenSaver')
        ->get_object('/org/freedesktop/ScreenSaver');
}

# METHODS

#   notify($msg, $type = 'info)
#
#   does:   display notification
#   params: msg  - message string
#                  (scalar, required)
#           type - message type
#                  (scalar, optional, default='info')
#                  (must be 'info'|'warn'|'error')
#   prints: nil
#   return: nil
method notify ( $msg, $type = 'info' ) {
    my %valid_type = map { ( $_ => 1 ) } qw(info warn error);
    if ( not $valid_type{$type} ) {
        $type = 'info';
    }
    $cp->notify_sys(
        msg   => $msg,
        title => 'Keep Awake',
        type  => $type,
        icon  => '@pkgdata@/dn-keep-awake.png',
    );
    return;
}

MooseX::MakeImmutable->lock_down;

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

=head2 Moose
=head2 MooseX::App::Simple
=head2 namespace::autoclean
=head2 MooseX::MakeImmutable
=head2 Moose::Util::TypeConstraints
=head2 MooseX::Getopt::Usage
=head2 Function::Parameters
=head2 Try::Tiny
=head2 Fatal
=head2 English
=head2 Carp
=head2 Readonly

Modern perl features.

=head2 Dn::Common
=head2 Dn::Menu

Provide utility methods.

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
