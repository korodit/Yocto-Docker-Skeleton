# syntax=docker/dockerfile:1
FROM ubuntu:18.04
RUN apt update && apt -y upgrade
RUN apt -y install debconf-utils
WORKDIR /
RUN touch preseed.txt && echo "tzdata tzdata/Areas select Europe" >> preseed.txt \
        && echo "tzdata tzdata/Zones/Europe select Athens" >> preseed.txt \
        && debconf-set-selections /preseed.txt
RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt -y install \
        gnulib gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
        cpio python python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 \
        libegl1-mesa libsdl1.2-dev git-gui lib32stdc++-7-dev lib32ncurses5 lib32ncurses5-dev pbzip2 xterm locales netcat\
        tmux sudo vim netcat proxychains

RUN echo "set-option -g default-shell /bin/bash" >> /etc/tmux.conf
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
COPY ./extrafiles/proxy/gitproxy /bin/gitproxy
RUN chmod +x /bin/gitproxy
COPY ./extrafiles/setup-build-env.sh /setup-build-env.sh
COPY ./extrafiles/uname.sh /bin/uname.sh
RUN chmod +x /setup-build-env.sh && chmod +x /bin/uname.sh
COPY ./extrafiles/bash_profile.sh /etc/skel/.bash_profile
COPY ./extrafiles/proxy /etc/skel/proxy
RUN ln -s /home/poky /etc/skel/poky
RUN ln -s /home/build /etc/skel/build
RUN ln -s /home/downloads /etc/skel/downloads
ENTRYPOINT ["/setup-build-env.sh"]