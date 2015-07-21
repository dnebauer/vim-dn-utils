#!/usr/bin/perl 

use Moose;
use 5.014_002;
use version; our $VERSION = qv('0.1');

{

    package Dn::Internal;

    use Moose;
    use MooseX::App::Simple qw(Color);    # requires exception on next line
    use namespace::autoclean -except => ['new_with_options'];

    #use namespace::autoclean;    # remove if using MooseX::App::Simple
    use MooseX::MakeImmutable;
    use Moose::Util::TypeConstraints;
    use Function::Parameters;
    use Try::Tiny;
    use autodie qw(open close);
    use English qw(-no_match_vars);
    use Carp;
    use Readonly;
    use Dn::Common;
    my $cp = Dn::Common->new();
    use Dn::Menu;
    use Cwd qw(abs_path);
    use experimental 'switch';

    with 'MooseX::Getopt::Usage';    # remove if using MooseX::App::Simple

    sub getopt_usage_config {    # remove if using MooseX::App::Simple
        return ( usage_sections => ['USAGE|OPTIONS|DESCRIPTION'] );
    }

    Readonly my $TRUE  => 1;
    Readonly my $FALSE => 0;

    # debug
    use Data::Dumper::Simple;

    # ATTRIBUTES

    subtype 'FilePath' => as 'Str' => where { -f abs_path($_) } =>
        message {qq[Invalid file '$_']};

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

    #   method: notify($msg, $type = 'info')
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

    #   main()
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

my $p = Dn::Internal->new_with_options->main;

1;

__END__

=head1 NAME

myscript - does stuff ...

=head1 USAGE

B<myscript param> [ I<-o> ]

B<myscript -h>

=head1 REQUIRED ARGUMENTS

=over

=item B<param>

Does... String.

Required.

=back

=head1 OPTIONS

=over

=item B<o>

Flag. Whether to... Boolean.

Optional. Default=<false>.

=item B<-h>

Display help and exit.

=back

=head1 DESCRIPTION

A full description of the application and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 DEPENDENCIES

=head2 Moose

=head2 namespace::autoclean

=head2 Moose::Util::TypeConstraints

=head2 MooseX::Getopt::Usage

=head2 MooseX::MakeImmutable

=head2 MooseX::App::Simple

=head2 Try::Tiny

=head2 autodie

=head2 English

=head2 Carp

=head2 Function::Parameters

=head2 Readonly

Use modern perl features.

=head2 Dn::Common

Utility methods.

=head2 Dn::Menu

Provides graphical and console menus.

=head1 CONFIGURATION AND ENVIRONMENT

System-wide configuration file provides details of...

=over

=item F</etc/myscript/myscriptrc>

Configuration file

=back

=head1 BUGS AND LIMITATIONS

Please report any bugs to the author.

=head1 AUTHOR

David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2015 David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
