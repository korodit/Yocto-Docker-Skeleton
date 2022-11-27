#!/bin/sh
# This script exists because some recipes have hardcoded
# checks for kernels below 5.x . Use this to override.
# result=`uname.orig "$@"`
# echo "$result"
# exit 0;
if [ "$#" -eq "1" ] && [ "$1" = "-r" ]; then
#if [ "$#" -eq "1" ]; then
        echo "4.15.0-184-generic"
#elif [ "$#" -eq "1" ] && [ "$1" = "-s" ]; then
#       echo "kappa"
elif [ "$#" -eq "1" ] && [ "$1" = "-s" ]; then
        echo "Linux"
else
        result=`/bin/uname.orig "$@"`
        echo "$result"
fi