#!/usr/bin/perl 

use Moo;    #                                                          {{{1
use strictures 2;
use 5.014_002;
use version; our $VERSION = qv('0.1');
use namespace::clean;    #                                             }}}1

{

    package Dn::Internal;

    use Moo;                                                         # {{{1
    use strictures 2;
    use namespace::clean -except => [ '_options_data', '_options_config' ];
    use autodie qw(open close);
    use Carp qw(cluck confess);
    use Dn::Common;
    use Dn::Menu;
    use English qw(-no_match_vars);
    use Function::Parameters;
    use Getopt::Long::Descriptive qw(describe_options);
    use MooX::HandlesVia;
    use MooX::Options;
    use Path::Tiny;
    use Readonly;
    use Try::Tiny;
    use Types::Common::Numeric qw(PositiveNum PositiveOrZeroNum SingleDigit);
    use Types::Common::String qw(NonEmptySimpleString LowerCaseSimpleStr);
    use Types::Standard qw(InstanceOf Int Str);
    use Types::Path::Tiny qw(AbsDir AbsPath);
    use experimental 'switch';

    my $cp = Dn::Common->new();

    Readonly my $TRUE  => 1;
    Readonly my $FALSE => 0;

    # debug
    use Data::Dumper::Simple;    #                                     }}}1

    # Options

    # option option (-o)                                               {{{1
    option 'option' => (
        is            => 'rw',
        format        => 's',
        required      => $TRUE,
        short         => 'o',
        documentation => 'An option',
    );

    # option flag   (-f)                                               {{{1
    option 'flag' => (
        is            => 'rw',
        required      => $FALSE,
        short         => 'f',
        documentation => 'A flag',
    );    #                                                            }}}1

    # Attributes

    # _attr                                                            {{{1
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

    # _attr_list                                                       {{{1
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
    );    #                                                            }}}1

    # Methods

    # main()                                                           {{{1
    #
    # does:   main method
    # params: nil
    # prints: feedback
    # return: n/a, dies on failure
    method main () {
        # do stuff...
    }

    # _help                                                            {{{1
    #
    # does:   if help is requested, display it and exit
    #
    # params: nil
    # prints: help message if requested
    # return: n/a, exits after displaying help
    method _help () {
        my ($opt, $usage) = Getopt::Long::Descriptive::describe_options(
            'dn-show-time %o',
            [ 'help|h', 'print usage message and exit' ],
        );
        print($usage->text), exit if $opt->help;
    }

    # _other()                                                         {{{1
    #
    # does:   something
    # params: nil
    # prints: nil, except error messages
    # return: scalar string
    method _other () {
        # do more stuff...
    }    #                                                             }}}1

}

my $p = Dn::Internal->new_with_options->main;

1;

# POD                                                                  {{{1
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

=item B<-o>

Whether to . Boolean.

Optional. Default: false.

=item B<-h>

Display help and exit.

=back

=head1 DESCRIPTION

A full description of the application and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

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

=head2 Executables

=over

=item 

=back

=head1 CONFIGURATION AND ENVIRONMENT

=head2 Autostart

To run this automatically at KDE5 (and possible other desktop environments) startup, place a symlink to the F<dn-konsole-su.desktop> file in a user's F<~/.config/autostart> directory. While this appears to be the preferred method, it is also possible to place a symlink to the F<dn-konsole-su> script in a user's F<~/.config/autostart-scripts> directory. (See L<KDE bug 338242|https://bugs.kde.org/show_bug.cgi?id=338242> for further details.)

=head2 Configuration files

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
# vim:fdm=marker
