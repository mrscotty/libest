# Testing LibEST with Vagrant

# Provisioning

Starting the Vagrant instance will provision it with the tools needed for building
and testing LibEST, like automake, gcc, libssl, etc.

    vagrant up

# Building LibEST

The `vag-build.sh` is run inside the Vagrant guest instance. It clones the
current Git repository in the working directory and then makes and installs
LibEST inside the guest instance.

    vagrant ssh --command /vagrant/vag-build.sh

If you make any changes in this working directory of your repository, they can
be *pull*ed into the vagrant instance with (the --ff-only option should save you
from clobbering any local modifications):

    vagrant ssh --command "git -C ~/git/libest pull --ff-only"

# Running the Integration Test

This runs the integration test for using libEST, testing either against
the example EST server or a foreign EST server you specify.

These tests assume that you have already built and installed LibEST (see
"Building LibEST" section above).

## Using Example Server

IMPORTANT: The 01-basic-est.t will clobber the existing test CA!!!

    vagrant ssh --command "cd ~/git/libest && prove test/sit/*.t"

## Using External Server

First, create a configuration file that contains the information needed for 
your external server, named estclient.rc:

    EST_SERVER_NAME=<est-endpoint-hostname>
    EST_SERVER_PORT=<est-endpoint-port>
    EST_SERVER_USER=<est-user>
    EST_SERVER_PASS=<est-pass>
    EST_OPENSSL_CACERT=<path-to-est-cacert>

Note: the path to the est-cacert should either be absolute or relative
to the example/client-simple directory.

Running the test is similar to above, but the estclient.rc configuration
file is sourced:

    vagrant ssh --command "source /vagrant/estcient.rc; cd ~/git/libest && prove test/sit/*.t"


