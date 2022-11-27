#!/bin/bash

# if called with any argument unset the variables
if [ $# -gt 10 ]
then
	echo "Proxy is now disabled"
	unset APT_CONFIG
	unset http_proxy
	unset HTTP_PROXY
	unset https_proxy
	unset HTTPS_PROXY
	unset ftp_proxy
	unset no_proxy
	git config --global --unset core.gitproxy
	rm -f ~/.wgetrc

else
	echo "Proxy is now enabled"
	export APT_CONFIG=~/proxy/apt_proxy.conf
	export http_proxy="http://placeholder_proxy.domain:8080"
	export HTTP_PROXY="http://placeholder_proxy.domain:8080"
	export https_proxy="http://placeholder_proxy.domain:8080"
    export HTTPS_PROXY="http://placeholder_proxy.domain:8080"
	export ftp_proxy="ftp://laceholder_proxy.domain:8080"
	export no_proxy="localhost,127.0.0.1"
	git config --global core.gitproxy gitproxy
	rm -f ~/.wgetrc
	touch ~/.wgetrc
	echo "use_proxy=yes" >> ~/.wgetrc
	echo "http_proxy=http://placeholder_proxy.domain:8080" >> ~/.wgetrc
	echo "https_proxy=http://placeholder_proxy.domain:8080" >> ~/.wgetrc

fi
