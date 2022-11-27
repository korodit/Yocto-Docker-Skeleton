#!/bin/bash
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

export LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
cd /home/yoctouser/poky && . oe-init-build-env /home/yoctouser/build