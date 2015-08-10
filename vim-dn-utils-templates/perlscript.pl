#!/usr/bin/perl 

use Moo;
use strictures 2;
use 5.014_002;
use version; our $VERSION = qv('0.1');

{

    package Dn::Internal;

    use Moo;
    use strictures 2;
    use namespace::clean -except => [ '_options_data', '_options_config' ];
    use autodie qw(open close);
    use Carp qw(cluck confess);
    use Dn::Common;
    use Dn::Menu;
    use English qw(-no_match_vars);
    use Function::Parameters;
    use MooX::HandlesVia;
    use MooX::Options;
    use Path::Tiny;
    use Readonly;
    use Try::Tiny;
    use Types::Common::Numeric qw(PositiveNum PositiveOrZeroNum SingleDigit);
    use Types::Common::String qw(NonEmptySimpleString LowerCaseSimpleStr);
    use Types::Standard qw(InstanceOf Int Str);
    use Types::Path::Tiny qw(AbsDir AbsPath)
    use experimental 'switch';
    my $cp = Dn::Common->new();

    Readonly my $TRUE  => 1;
    Readonly my $FALSE => 0;

    # debug
    use Data::Dumper::Simple;

    # ATTRIBUTES

    option 'option' => (    # requires value
        is            => 'rw',
        format        => 's',
        required      => $TRUE,
        short         => 'o',
        documentation => 'An option',
    );

    option 'flag' => (    # flag (default format)
        is            => 'rw',
        required      => $FALSE,
        short         => 'f',
        documentation => 'A flag',
    );

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

    # main()
    #
    # does:   main method
    # params: nil
    # prints: feedback
    # return: result
    method main () {
        # do stuff...
    }
}

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

=item MooX::Options

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
