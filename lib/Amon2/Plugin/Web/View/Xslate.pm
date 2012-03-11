package Amon2::Plugin::Web::View::Xslate;
use 5.008_001;
use strict;
use warnings;
use utf8;

our $VERSION = '0.01';

use Amon2;
use Amon2::Util;
use Text::Xslate;
use File::Spec;

sub init {
    my ($class, $c, $conf) = @_;

    my $default_conf = $conf || $class->default_conf;
    my $view_conf = $c->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir($c->base_dir(), 'tmpl') ];
    }

    my $view = Text::Xslate->new(
        $class->marge_conf($default_conf, $view_conf)
    );
    Amon2::Util::add_method($c, 'create_view', sub { $view });
}

sub marge_conf {
    my($class, $default_conf, $view_conf) = @_;

    return +{
        %$default_conf,
        %$view_conf,
    };
}

sub default_conf {
    return +{
        'syntax'   => 'TTerse',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c        => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
        },
    }
}

1;
__END__

=head1 NAME

Amon2::Plugin::Web::View::Xslate - #TODO

=head1 VERSION

This document describes Amon2::Plugin::Web::View::Xslate version 0.01.

=head1 SYNOPSIS

    # config/development.pl
    +{
        'Text::Xslate' => +{
            syntax => 'Kolon',
        }
    };

    # lib/Proj/Web.pm
    __PACKAGE__->load_plugin('Web::View::Xslate');

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

Kenta Sato E<lt>karupa@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, Kenta Sato. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
