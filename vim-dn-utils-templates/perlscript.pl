#!/usr/bin/perl 

use Moo;    #                                                          {{{1
use strictures 2;
use 5.006;
use 5.22.1;
use version; our $VERSION = qv('0.1');
use namespace::clean;    #                                             }}}1

{

    package Dn::Internal;

    use Moo;                                                         # {{{1
    use strictures 2;
    use namespace::clean -except => [ '_options_data', '_options_config' ];
    use autodie qw(open close);
    use Carp qw(confess);
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
    use Types::Standard;
    use experimental 'switch';

    my $cp = Dn::Common->new();

    Readonly my $TRUE  => 1;
    Readonly my $FALSE => 0;

    # debug
    use Data::Dumper::Simple;    #                                     }}}1

    # options

    # option (-o)                                                      {{{1
    option 'option' => (
        is            => 'ro',
        format        => 's',
        required      => $TRUE,
        short         => 'o',
        documentation => 'An option',
    );

    # flag   (-f)                                                      {{{1
    option 'flag' => (
        is            => 'ro',
        short         => 'f',
        documentation => 'A flag',
    );    #                                                            }}}1

    # attributes

    # _attr                                                            {{{1
    has '_attr_1' => (
        is            => 'lazy',
        isa           => Types::Standard::Str,
        documentation => 'Shown in usage',
    );

    method _build__attr_1 () {
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
        documentation => 'Array of values',
    );    #                                                            }}}1

    # methods

    # main()                                                           {{{1
    #
    # does:   main method
    # params: nil
    # prints: feedback
    # return: n/a, dies on failure
    method main () {
    }

    # _help()                                                          {{{1
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

        return;
    }

    # _other()                                                         {{{1
    #
    # does:   something
    # params: nil
    # prints: nil, except error messages
    # return: scalar string
    #         dies on failure
    method _other () {
    }    #                                                             }}}1

}

my $p = Dn::Internal->new_with_options->main;

1;

# POD                                                                  {{{1
__END__

=head1 NAME

myscript - does stuff ...

=head1 USAGE

B<myscript param> [ B<-o> ]

B<myscript -h>

=head1 REQUIRED ARGUMENTS

=over

=item B<param>

Does...

Scalar string. Required.

=back

=head1 REQUIRED OPTIONS

=over

=item B<-o>  B<--option>

Does...

Scalar string. Required.

=back

=head1 OPTIONS

=over

=item B<-o>  B<--option>

Whether to .

Boolean. Optional. Default: false.

=item B<-h>

Display help and exit.

=back

=head1 DESCRIPTION

A full description of the application and its features.
May include numerous subsections (i.e., =head2, =head3, etc.).

=head1 DIAGNOSTICS

Supposedly a listing of every error and warning message
that the module can generate (even the ones that will
"never happen"), with a full explanation of each problem,
one or more likely causes, and any suggested remedies.

Really?

=head1 DEPENDENCIES

=head2 Perl modules

autodie, Carp, Dn::Common, Dn::Menu, English, experimental, Function::Parameters, Moo, MooX::HandlesVia, MooX::Options, namespace::clean, Path::Tiny, Readonly, strictures, Try::Tiny, Types::Common::Numeric, Types::Common::String, Types::Path::Tiny, Types::Standard, version.

=head2 Executables

wget.

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

Copyright (c) 2016 David Nebauer E<lt>davidnebauer@hotkey.net.auE<gt>

This script is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
# vim:fdm=marker
