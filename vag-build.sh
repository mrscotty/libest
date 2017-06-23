#!/bin/bash
#
# vag-build.sh - build the reference libest
#
# NOTE: run as default vagrant user

set -e

git clone /vagrant ~/git/libest

cd ~/git/libest && ./configure && make && sudo make install


