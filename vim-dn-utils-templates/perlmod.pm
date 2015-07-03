package Dn::Internal;

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

# parameter: my_param
#            public, scalar string, required, default='default'
#            parameters require MooseX::App::Simple
parameter 'param' => (
    is            => 'rw',
    isa           => 'Str',
    accessor      => '_param',
    required      => $TRUE,
    default       => 'default_value',
    documentation => 'First parameter',
);

# option: -o
#         public, boolean, optional, default=<false>
#         options require MooseX::App::Simple
option 'o' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => $FALSE,
    reader        => '_option',
    documentation => 'Enable this to do fancy stuff',
);

# attribute: _attr_1
#            private, scalar string, required
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


# attribute: _attr_2
#            private, scalar string, default='value'
has '_attr_2' => (
    is            => 'ro',
    isa           => 'Str',
    default       => 'value',
    documentation => 'Shown in usage',
);

# attributes: _attr_3, _attr_4
#             private, scalar integer
has [ '_attr_3', '_attr_4' ] => (
    is  => 'rw',
    isa => 'Int',
);

# attribute: _attr_5
#            private, class
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

#   info($msg)
#
#   does:   display informational notification
#   params: msg  - message string
#                  (scalar, required)
#   prints: nil
#   return: nil
method info ($msg) {
    $self->notify($msg);
    return;
}

#   run()
#
#   does:   main method
#   params: nil
#   prints: feedback
#   return: result
method run () {
    # do stuff...
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

=head1 METHODS

=head2 method1(param)

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

=head2 Dn::Common

Common methods used in the author's scripts.

=head2 INCOMPATIBILITIES

Modules this one cannot be used with, and why.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to <Maintainer name(s)>
 (<contact address>)
Patches are welcome.

=head1 AUTHORS/AUTHORS

David Nebauer, L<david E<lt>atE<gt> nebauer E<lt>dotE<gt> org|mailto:david@nebauer.org>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2015 David Nebauer <david@nebauer.org>

<GPL3>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

<Perl>

This is free software; you can redistribute it and/or modify it under
the terms of the Artictic License 2.0.

See <http://www.perlfoundation.org/artistic_license_2_0>

<Perl or GPL>

This is free software; you can redistribute it and/or modify it under
the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 1 <http://dev.perl.org/licenses/gpl1.html>,
or (at your option) any later version
<http://www.gnu.org/licenses/license-list.html#GNUGPL>,

or

b) the "Artistic License"
<http://www.perlfoundation.org/artistic_license_2_0>.

=cut
