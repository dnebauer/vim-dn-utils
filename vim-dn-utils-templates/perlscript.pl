#!/usr/bin/perl 

use Moose;
use 5.014_002;
use version; our $VERSION = qv('0.1');

{
package Dn::Internal;

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
use Dn::CommonPerl;
my $cp = new Dn::CommonPerl;
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
}

# MAIN PACKAGE

my $p = Dn::Internal->new_with_options->run;

1;

__END__

=head1 NAME

myscript - does stuff ...

=head1 USAGE

B<myscript param> [ I<-o> ]

B<myscript -h>

=head1 REQUIRED OPTIONS

=over

=item B<param>

Does... String.

=back

=head1 OPTIONS

=over

=item B<o>

Flag. Whether to... Boolean, Default=<false>.

=item B<-h>

Display help and exit.

=back

=head1 CONFIGURATION

System-wide configuration file provides details of...

=head1 EXIT VALUE

Returns an error value if the script fails.

=head1 FILES

=over

=item F</etc/myscript/myscriptrc>

Configuration file

=back

=head1 AUTHORS

David Nebauer, L<david E<lt>atE<gt> nebauer E<lt>dotE<gt> org|mailto:david@nebauer.org>

=cut
