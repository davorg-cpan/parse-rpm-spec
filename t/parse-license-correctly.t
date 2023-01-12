use strict;
use warnings;

use Test::More;
use Test::Exception;

use Parse::RPM::Spec;

my $spec = Parse::RPM::Spec->new( { file => 't/perl-License-Syntax.spec' } );

is($spec->license, 'GPL-1.0-or-later OR Artistic-1.0-Perl', 'Correct license');

done_testing;
