package Parse::RPM::Spec;

use 5.006000;
use strict;
use warnings;

use Carp;

our @ISA = qw(Exporter);

our $VERSION = '0.01';

my @attr = qw(name version release summary license gropu url source
              buildroot buildarch buildrequires requires);

my %attr = map { $_ => 1 } @attr;

sub new {
  my $class = shift;

  my $args = shift;
  my $self = {};

  if (my $type = ref $args) {
    if ($type eq 'HASH') {
      $self = $args;
    } else {
      croak "Unknown reference of type $type passed to ${class}::new\n";
    }
  } else {
    $self->{file} = $args;
  }

  $self = bless $self, $class;

  $self->parse_file;

  return $self;
}

sub parse_file {
  my $self = shift;

  my $file = shift || $self->{file};

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

  open my $fh, $file or croak "Cannot open $file: $!\n";

  while (<$fh>) {
    /^Name:\s*(\S+)/         and $self->{name}      = $1;
    /^Version:\s*(\S+)/      and $self->{version}   = $1;
    /^Release:\s*(\S+)/      and $self->{release}   = $1;
    /^Summary:\s*(\S+)/      and $self->{summary}   = $1;
    /^License:\s*(.+)/       and $self->{license}   = $1;
    /^Group:\s*(\S+)/        and $self->{group}     = $1;
    /^URL:\s*(\S+)/          and $self->{url}       = $1;
    /^Source0:\s*(\S+)/      and $self->{source}    = $1;
    /^BuildRoot:\s*(\S+)/    and $self->{buildroot} = $1;

    /^BuildRequires:\s*(.+)/ and push @{$self->{buildrequires}}, $1;
    /^Requires:\s*(.+)/      and push @{$self->{requires}},      $1;
  }

  return $self;
}

sub AUTOLOAD {
  our $AUTOLOAD;

  my $self = shift;

  my ($attr) = $AUTOLOAD =~ /.*::(.*)/;

  unless ($attr{$attr}) {
    croak "Invalid attribute: $attr\n";
  }

  my $val = $self->{$attr};

  if (@_) {
    $self->{$attr} = shift;
  }

  return $val;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Parse::RPM::Spec - Perl extension to parse RPM spec files.

=head1 SYNOPSIS

  use Parse::RPM::Spec;

  my $spec = Parse::RPM::Spec->new('some_pacakge.spec');

  print $spec->name;    # some_package
  print $spec->version; # 0.01 (for example)

=head1 DESCRIPTION

RPM is the package management system used on Linux distributions based on
Red Hat Linux. These days that includes Fedora, Red Hat Enterprise Linux,
Centos, SUSE, Mandriva and many more.

RPMs are build from the source of a packages along with a spec file. The
spec file controls how the RPM is built.

This module creates Perl objects which module spec files. Currently it gives
you simple access to various pieces of information from the spec file.

=head1 CAVEAT

This is still in development. I particular it doesn't currently parse all of
a spec file. It just does the bits that I currently use. I will be adding
support for the rest of the file very soon.

=head1 METHODS

=head2 $spec = Parse::RPM::Spec->new('some_package.spec')

Creates a new Parse::EPM::Spec object. Takes one mandatory parameter which
is the path to the spec file that you are interested in. Throws an exception
if it doesn't find a valid spec.

=head2 $spec->parse_file('some_package.spec')

Parses the given spec file. This is called as part of the initialisation
carried out by the C<new> method, so there is generally no need to call it
yourself.

=head2 $spec->name, $spec->version, $spec->release, $spec->summary, $spec->license, $spec->group, $spec->url, $spec->source, $spec->buildroot, $spec->buildarch, $spec->buildrequires, $spec->requires

Attribute accessors for the spec file object. Each one returns a piece of
information from the spec file header. The C<buildrequires> and C<requires>
methods are slightly different. Because these keys can have multiple values,
they return a reference to an array of values.

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
