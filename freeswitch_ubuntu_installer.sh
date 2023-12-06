version=1.10.10.

apt -y update
apt -y install sudo
sudo apt install -y git subversion build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev libtool libtool-bin libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.2-dev libopus-dev cmake libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev python3.11-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1-dev unzip python3.11-distutils
sudo apt install -y libavformat-dev libswscale-dev libpq-dev libshout3-dev

sudo apt -y install unzip

cd /usr/src
sudo git clone https://github.com/signalwire/libks.git
cd libks
sudo cmake .
sudo make
sudo make install

cd /usr/src
git clone https://github.com/signalwire/signalwire-c.git
cd signalwire-c
sudo cmake .
sudo make
sudo make install

cd /usr/src
rm freeswitch*zip*
sudo wget https://files.freeswitch.org/freeswitch-releases/freeswitch-$version-release.zip
sudo unzip freeswitch-$version-release.zip

sleep 10


# Remove existing symlink if it exists
sudo rm -f /usr/src/freeswitch

# Create new symlink
cd /usr/src
sudo ln -s /usr/src/freeswitch-${version}-release/ /usr/src/freeswitch

cd /usr/src/freeswitch
git clone https://github.com/freeswitch/spandsp.git
cd spandsp
./bootstrap.sh -j
./configure
make
make install
ldconfig

cd /usr/src/freeswitch
git clone https://github.com/freeswitch/sofia-sip.git
cd sofia-sip
./bootstrap.sh -j
./configure
make
make install
ldconfig

cd /usr/src/freeswitch
./bootstrap.sh -j
./configure
make
make install

sudo make all cd-sounds-install cd-moh-install
sudo ln -s /usr/local/freeswitch/bin/freeswitch /usr/bin/
sudo ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin
cd /usr/local
sudo groupadd freeswitch
sudo adduser --disabled-password  --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH Voice Platform" --ingroup freeswitch freeswitch
sudo chown -R freeswitch:freeswitch /usr/local/freeswitch/
sudo chmod -R ug=rwX,o= /usr/local/freeswitch/
sudo chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/

rm /etc/systemd/system/freeswitch.service
sudo tee -a /etc/systemd/system/freeswitch.service  <<EOF
[Unit]
Description=freeswitch
Wants=network-online.target
Requires=syslog.socket network.target local-fs.target
After=syslog.socket network.target network-online.target local-fs.target

[Service]
Type=forking
Environment="DAEMON_OPTS=-nonat"
EnvironmentFile=-/etc/default/freeswitch
ExecStartPre=/bin/chown -R freeswitch:freeswitch /usr/local/freeswitch
ExecStart=/usr/bin/freeswitch -u freeswitch -g freeswitch -ncwait $DAEMON_OPTS
TimeoutSec=45s
Restart=always
RestartSec=90
StartLimitInterval=0
StartLimitBurst=6

User=root
Group=daemon
LimitCORE=infinity
LimitNOFILE=100000
LimitNPROC=60000
LimitSTACK=250000
LimitRTPRIO=infinity
LimitRTTIME=infinity
IOSchedulingClass=realtime
IOSchedulingPriority=2
CPUSchedulingPolicy=rr
CPUSchedulingPriority=89
UMask=0007
NoNewPrivileges=false

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable freeswitch.service
sudo systemctl start freeswitch.service
sudo systemctl status freeswitch.service
