#!/usr/bin/perl
#
# 01-basic-est.t - Basic test for EST support
#
# This script uses the example server and client to run tests
# for the basic EST functionality.
#
# IMPORTANT: Running this script will DESTROY the existing example CA
# in example/server/ca/.
#
# USAGE:
#
# Run this script from the base directory of the libest repo with this
# command:
#
#   prove test/sit/*.t
#
# To use an external EST server instead of the example server from libest,
# set the following environment variables:
#
#   EST_SERVER_NAME=<hostname>
#   EST_SERVER_PORT=<port>
#   EST_SERVER_USER=<est-user>
#   EST_SERVER_PASS=<est-pass>
#   EST_OPENSSL_CACERT=<path-to-est-cacert>


use strict;
use warnings;

use Cwd;
use Test::More;
$| = 1;

my $server_dir       = 'example/server';
my $client_dir       = 'example/client';
my $clientsimple_dir = 'example/client-simple';

# Used by example server; relative to $server_dir in server child process
$ENV{EST_TRUSTED_CERTS}    = 'trustedcerts.crt';
$ENV{EST_CACERTS_RESP}     = 'estCA/cacert.crt';
$ENV{EST_OPENSSL_CACONFIG} = 'estExampleCA.cnf';

# Used by example client-simple; relative to $clientsimple_dir
# By default, we use the one generated for our example server
$ENV{EST_OPENSSL_CACERT} ||= '../server/estCA/cacert.crt';

# Used when calling example client-simple
$ENV{EST_SERVER_NAME} ||= '127.0.0.1';
$ENV{EST_SERVER_PORT} ||= 8085;
$ENV{EST_SERVER_USER} ||= 'estuser';
$ENV{EST_SERVER_PASS} ||= 'estpwd';

my $out;
my $pid;

my $basedir = getcwd;


###########################################################################
#
# Initialize example CA
#
# IMPORTANT: This CLOBBERS the existing example CA !!!
#
###########################################################################

diag("EST_SERVER_NAME=$ENV{EST_SERVER_NAME}");
    my $srv;
if ( $ENV{EST_SERVER_NAME} eq '127.0.0.1' ) {
    chdir($server_dir) or die "Error: chdir $server_dir: $!";
    
    # Redirecting STDIN causes the prompt to be skipped.
    $out = qx{./createCA.sh </dev/null 2>&1};
    is( $?, 0, './createCA.sh returns 0' )
      or BAIL_OUT("Error creating example CA");
    like(
        $out,
        qr{Resetting the est server password file}s,
        "createCA.sh output seems to be complete"
    );

    ok( -f "extCA/index.txt", 'extCA/index.txt exists' );
    ok( -f "estCA/index.txt", 'estCA/index.txt exists' );


###########################################################################
#
# Start EST server in background using example CA
#
###########################################################################

    $pid = open( $srv,
        '-|',
"./estserver -c estCA/private/estservercertandkey.pem -k estCA/private/estservercertandkey.pem -r estrealm"
    );

    if ( not $pid ) {
        die "Error running est server: $!";
    }

    sleep 1;    # let the server in the child process stabilize

    $out = qx{ps -ef};
    like(
        $out,
        qr{example/server/.libs/lt-estserver}s,
        "confirm estserver is running"
    ) or BAIL_OUT ("Failed to find estserver in process table");
    chdir($basedir) or die "Error: chdir $basedir $!";
}

###########################################################################
#
# Run EST client tests
#
###########################################################################

diag("Setting LD_LIBRARY_PATH");
$ENV{LD_LIBRARY_PATH} = '/usr/local/est/lib';

diag("Run EST client tests...");
chdir($clientsimple_dir) or die "Error: chdir $clientsimple_dir: $!";
$out =
qx{./estclient_simple -s $ENV{EST_SERVER_NAME} -p $ENV{EST_SERVER_PORT} -u $ENV{EST_SERVER_USER} -h $ENV{EST_SERVER_PASS}};
is( $?, 0, "estclient_simple returned 0" );
like( $out, qr{Success}, "output of estclient_simple" );


###########################################################################
#
# Clean up (including ending child process)
#
###########################################################################

if ( $ENV{EST_SERVER_NAME} eq '127.0.0.1' ) {

    # if we're using the example server from libest
    diag "Killing example server PID $pid";
    kill( 'TERM', $pid );
    wait();
}

done_testing();

