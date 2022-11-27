#!/bin/bash
sudo docker build -t yocto-mini . || sudo -E docker build -t yocto-mini . || { echo "=> ERROR: Failed to build yocto-mini image. Check your proxy and/or Docker settings." && exit 1 ; }