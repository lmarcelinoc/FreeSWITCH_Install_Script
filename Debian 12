# Ensure the system is up to date
apt-get update
apt-get -y upgrade

# Install necessary packages
apt-get install -y git subversion build-essential autoconf automake libtool libncurses-dev make libjpeg-dev libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.3-dev libopus-dev cmake libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1-dev unzip

# Install additional dependencies
apt-get install -y libavformat-dev libswscale-dev libpq-dev libshout3-dev

# Install Python 3.11 (or the version available in Debian 12)
apt-get install -y python3-dev python3-distutils

# Clone and install libks
cd /usr/src
rm -rf libks
git clone https://github.com/signalwire/libks.git
cd libks
cmake .
make
make install

# Clone and install signalwire-c
cd /usr/src
rm -rf signalwire-c
git clone https://github.com/signalwire/signalwire-c.git
cd signalwire-c
cmake .
make
make install

# Download and unzip FreeSWITCH
cd /usr/src
rm -rf freeswitch*
wget https://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.10-release.zip
unzip -o freeswitch-1.10.10-release.zip

# Create symlink for FreeSWITCH
rm -f /usr/src/freeswitch
ln -s /usr/src/freeswitch-1.10.10-release/ /usr/src/freeswitch

# Install spandsp
cd /usr/src/freeswitch
rm -rf spandsp
git clone https://github.com/freeswitch/spandsp.git
cd spandsp
./bootstrap.sh -j
./configure
make
make install
ldconfig

# Install sofia-sip
cd /usr/src/freeswitch
rm -rf sofia-sip
git clone https://github.com/freeswitch/sofia-sip.git
cd sofia-sip
./bootstrap.sh -j
./configure
make
make install
ldconfig

# Build FreeSWITCH
cd /usr/src/freeswitch
./bootstrap.sh -j
./configure
make
make install

# Install sounds and music
make all cd-sounds-install cd-moh-install

# Create FreeSWITCH system user
groupadd freeswitch
adduser --disabled-password --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH Voice Platform" --ingroup freeswitch freeswitch
chown -R freeswitch:freeswitch /usr/local/freeswitch/
chmod -R ug=rwX,o= /usr/local/freeswitch/
chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/

# Create systemd service file
systemctl stop freeswitch.service
rm /etc/systemd/system/freeswitch.service
cat <<EOF > /etc/systemd/system/freeswitch.service
[Unit]
Description=FreeSWITCH
After=syslog.target network.target local-fs.target

[Service]
Type=forking
ExecStartPre=/bin/chown -R freeswitch:freeswitch /usr/local/freeswitch
ExecStart=/usr/local/freeswitch/bin/freeswitch -u freeswitch -g freeswitch -ncwait
TimeoutSec=45s
Restart=always
RestartSec=90

User=root
Group=daemon
LimitCORE=infinity
LimitNOFILE=100000
LimitNPROC=60000
LimitSTACK=250000
LimitRTPRIO=infinity
LimitRTTIME=infinity

[Install]
WantedBy=multi-user.target
EOF

# Enable and start FreeSWITCH service
systemctl enable freeswitch.service
systemctl start freeswitch.service
systemctl status freeswitch.service
