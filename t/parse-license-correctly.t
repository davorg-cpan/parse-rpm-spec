use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok('Parse::RPM::Spec') };

my $spec = Parse::RPM::Spec->new( { file => 't/perl-License-Syntax.spec' } );

is($spec->license, 'GPL-1.0-or-later OR Artistic-1.0-Perl', 'Correct license');

done_testing;
