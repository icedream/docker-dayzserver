FROM debian:stretch

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
	&& apt-get -y install --install-recommends bash winehq-stable xserver-xorg-video-dummy \
	&& apt-get clean

WORKDIR /opt/dayzserver/
COPY . .

COPY docker/xorg.conf /etc/X11/xorg.conf
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN useradd -k /var/empty -G tty -m -N -r dayzserver
USER dayzserver

RUN wineboot

CMD ["/entrypoint.sh"]
