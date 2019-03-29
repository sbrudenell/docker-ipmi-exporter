#!/bin/bash -e

. /etc/profile

mkdir -p /usr/src/freeipmi || exit 1
cd /usr/src/freeipmi || exit 1

# install required packages
apk update
apk add --no-cache \
    bash \
    wget \
    curl \
    ncurses \
    git \
    netcat-openbsd \
    alpine-sdk \
    autoconf \
    automake \
    gcc \
    make \
    libtool \
    pkgconfig \
    util-linux-dev \
    openssl-dev \
    gnutls-dev \
    zlib-dev \
    libmnl-dev \
    libnetfilter_acct-dev \
    file \
    gawk

# install libgpg-error
wget 'https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.31.tar.bz2'
tar -jxvpf libgpg-error-1.31.tar.bz2
cd libgpg-error-1.31
./configure --prefix=/opt/netdata --enable-static
make && make install
cd ..

# make the rest of the commands use the netdata paths
export PATH="/opt/netdata/bin:${PATH}"
export CFLAGS="-I/opt/netdata/include"
export LDFLAGS="-L/opt/netdata/lib"

# install libgcrypt
wget 'https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.2.tar.bz2'
tar -jxvpf libgcrypt-1.8.2.tar.bz2
cd libgcrypt-1.8.2/
./configure --prefix=/opt/netdata --enable-static
make && make install
cd ..

# install freeipmi
wget https://ftp.gnu.org/gnu/freeipmi/freeipmi-1.6.2.tar.gz
tar -zxvpf freeipmi-1.6.2.tar.gz
cd freeipmi-1.6.2/
./configure --prefix=/opt/netdata --enable-static --disable-shared

# linux does not have getmsg() and putmsg()
cat >>config/config.h <<EOF

// use gcc statement expressions to fail calls to getmsg() and putmsg()
#define getmsg(a, b, c, d) ({ errno = ENOSYS; -1; })
#define putmsg(a, b, c, d) ({ errno = ENOSYS; -1; })

EOF

make LDFLAGS="-L/opt/netdata/lib -all-static" && make install

for t in ipmimonitoring ipmi-sensors ipmi-dcmi bmc-info
do 
    ln -s "/opt/netdata/sbin/${t}" "/usr/sbin/${t}"
done
