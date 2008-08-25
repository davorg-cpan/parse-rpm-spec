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

Parse::RPM::Spec - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Parse::RPM::Spec;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Parse::RPM::Spec, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Dave Cross, E<lt>dave@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Dave Cross

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
