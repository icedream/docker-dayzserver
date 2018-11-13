FROM jlesage/baseimage-gui:debian-9

# wine
ADD https://dl.winehq.org/wine-builds/Release.key /wine-builds.key
RUN \
	export DEBIAN_FRONTEND=noninteractive \
	&& apt-get -y update \
	&& apt-get -y install gnupg2 apt-transport-https \
	&& apt-key add /wine-builds.key \
	&& rm /wine-builds.key

RUN \
	export DEBIAN_FRONTEND=noninteractive \
	&& dpkg --add-architecture i386 \
	&& echo "deb https://dl.winehq.org/wine-builds/debian/ stretch main" >> /etc/apt/sources.list.d/wine.list \
	&& apt-get -y update \
	&& add-pkg winehq-stable procps

COPY . /opt/dayzserver/

# RUN useradd -k /var/empty -G tty -m -N -r dayzserver

RUN cp -va /opt/dayzserver/docker/rootfs/* / && rm -r /opt/dayzserver/docker
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/local/bin/gosu
RUN chmod -v a+x /usr/local/bin/* /*.sh
RUN mv -v /opt/dayzserver/mpmissions /opt/dayzserver/mpmissions.template && ln -s /config/mpmissions /opt/dayzserver/mpmissions
ENV APP_NAME="DayZ Server"
WORKDIR /config

