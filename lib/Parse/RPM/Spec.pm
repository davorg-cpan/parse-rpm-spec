package Parse::RPM::Spec;

use 5.006000;
use strict;
use warnings;

use Carp;
use Moose;

our $VERSION = 'v1.1.2';

has file          => ( is => 'ro', isa => 'Str', required => 1 );
has name          => ( is => 'rw', isa => 'Str' );
has version       => ( is => 'rw', isa => 'Str' );
has epoch	  => ( is => 'rw', isa => 'Str' );
has release       => ( is => 'rw', isa => 'Str' );
has summary       => ( is => 'rw', isa => 'Str' );
has license       => ( is => 'rw', isa => 'Str' );
has group         => ( is => 'rw', isa => 'Str' );
has url           => ( is => 'rw', isa => 'Str' );
has source        => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] } );
has buildroot     => ( is => 'rw', isa => 'Str' );
has buildarch     => ( is => 'rw', isa => 'Str' );
has buildrequires => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] } );
has requires      => ( is => 'rw', isa => 'ArrayRef[Str]', default => sub { [] } );
has [ qw( excludearch exclusivearch excludeos exclusiveos ) ]
  => ( is => 'rw', isa => 'Str' );

has parse_spec => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);

sub _build_parse_spec {
  return {
    scalars => {
      name      => qr[^Name:\s+(\S+)],
      version   => qr[^Version:\s+(\S+)],
      epoch     => qr[^Epoch:\s+(\S+)],
      release   => qr[^Release:\s+(\S+)],
      summary   => qr[^Summary:\s+(.+)],
      license   => qr[^License:\s+(.+)],
      group     => qr[^Group:\s+(\S+)],
      url       => qr[^URL:\s+(\S+)],
      buildroot => qr[^BuildRoot:\s+(\S+)],
      buildarch => qr[^BuildArch:\s+(\S+)],
      excludearch   => qr[^ExcludeArch:\s+(\S+)],
      exclusivearch => qr[^ExclusiveArch:\s+(\S+)],
      excludeos     => qr[^ExcludeOS:\s+(\S+)],
      exclusiveos   => qr[^ExclusiveOS:\s+(\S+)],
    },
    arrays => {
      source        => qr[^Source\d*:\s+(\S+)],
      buildrequires => qr[^BuildRequires:\s+(.+)],
      requires      => qr[^Requires:\s+(.+)],
    },
  };
}

sub BUILD {
  my $self = shift;

  $self->parse_file;

  return $self;
}

sub parse_file {
  my $self = shift;

  $self->file(shift) if @_;

  my $file = $self->file;

  unless (defined $file) {
    croak "No spec file to parse\n";
  }

  unless (-e $file) {
    croak "Spec file $file doesn't exist\n";
  }

  unless (-r $file) {
    croak "Cannot read spec file $file\n";
  }

  unless (-s $file) {
    croak "Spec file $file is empty\n";
  }

  open my $fh, '<', $file or croak "Cannot open $file: $!\n";

  my $scalars = $self->parse_spec->{scalars};
  my $arrays  = $self->parse_spec->{arrays};

  LINE: while (<$fh>) {
    foreach my $attr (keys %$scalars) {
      if (/$scalars->{$attr}/) {
        $self->$attr($1);
        next LINE;
      }
    }

    foreach my $attr (keys %$arrays) {
      if (/$arrays->{$attr}/) {
        push @{$self->$attr}, $1;
        next LINE;
      }
    }
  }

  return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Parse::RPM::Spec - Perl extension to parse RPM spec files.

=head1 SYNOPSIS

  use Parse::RPM::Spec;

  my $spec = Parse::RPM::Spec->new( { file => 'some_package.spec' } );

  print $spec->name;    # some_package
  print $spec->version; # 0.01 (for example)

=head1 DESCRIPTION

RPM is the package management system used on Linux distributions based on
Red Hat Linux. These days that includes Fedora, Red Hat Enterprise Linux,
Centos, SUSE, Mandriva and many more.

RPMs are build from the source of a packages along with a spec file. The
spec file controls how the RPM is built.

This module creates Perl objects which model spec files. Currently it gives
you simple access to various pieces of information from the spec file.

=head1 CAVEAT

This is still in development. I particular it doesn't currently parse all of
a spec file. It just does the bits that I currently use. I will be adding
support for the rest of the file very soon.

=head1 METHODS

=head2 $spec = Parse::RPM::Spec->new('some_package.spec')

Creates a new Parse::RPM::Spec object. Takes one mandatory parameter which
is the path to the spec file that you are interested in. Throws an exception
if it doesn't find a valid spec.

=head2 $spec->parse_file('some_package.spec')

Parses the given spec file. This is called as part of the initialisation
carried out by the C<new> method, so there is generally no need to call it
yourself.

=head2 $spec->file, $spec->name, $spec->version, $spec->epoch, $spec->release, $spec->summary, $spec->license, $spec->group, $spec->url, $spec->source, $spec->buildroot, $spec->buildarch, $spec->buildrequires, $spec->requires

Attribute accessors for the spec file object. Each one returns a piece of
information from the spec file header. The C<source>, C<buildrequires>
and C<requires> methods are slightly different. Because these keys can have
multiple values, they return a reference to an array of values.

=head2 Parse::RPM::Spec->meta

Moose-provided class method for introspection. Generally not needed
by users.

=head2 EXPORT

None.

=head1 TO DO

Plenty still to do here. Firstly, and most importantly, parsing the rest
of the spec file.

=head1 SEE ALSO

=over 4

=item *

Red Hat RPM Guide - L<http://docs.fedoraproject.org/drafts/rpm-guide-en/index.html>

=item *

Maximum RPM - L<http://www.rpm.org/max-rpm/s1-rpm-file-format-rpm-file-format.html>

=back

=head1 AUTHOR

Dave Cross, E<lt>dave@mag-sol.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Magnum Solutions Ltd.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
