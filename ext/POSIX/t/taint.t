#!./perl -Tw

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
    require Config; import Config;
    if ($^O ne 'VMS' and $Config{'extensions'} !~ /\bPOSIX\b/) {
	print "1..0\n";
	exit 0;
    }
}

require "./test.pl";
use Scalar::Util qw/tainted/;
plan(tests => 5);


use POSIX qw(fcntl_h open read mkfifo);
use strict ;

$| = 1;

my $buffer;
my @buffer;
my $testfd;

# Sources of taint:
#   The empty tainted value, for tainting strings

my $TAINT = substr($^X, 0, 0);

eval { mkfifo($TAINT. "TEST", 0) };
ok($@ =~ /^Insecure dependency/,              'mkfifo with tainted data');

eval { $testfd = open($TAINT. "TEST", O_WRONLY, 0) };
ok($@ =~ /^Insecure dependency/,              'open with tainted data');

eval { $testfd = open("TEST", O_RDONLY, 0) };
ok($@ eq "",                                  'open with untainted data');

read($testfd, $buffer, 2) if $testfd > 2;
is( $buffer, "#!",	                          '    read' );
ok(tainted($buffer),                          '    scalar tainted');
read($testfd, $buffer[1], 2) if $testfd > 2;

#is( $buffer[1], "./",	                      '    read' );
#ok(tainted($buffer[1]),                       '    array element tainted');
