FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
#shared libraries and dependencies
RUN apt update && \
    apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 \
        libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev \
        libsqlite3-dev libminiupnpc-dev libzmq3-dev libfmt-dev 

## uncomment for QT gui build
RUN apt update && \
    apt-get install -y qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev \
        libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev

#BerkleyDB for wallet support
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:luke-jr/bitcoincore && \
    apt-get update && \
    apt-get install -y libdb4.8-dev libdb4.8++-dev


## for static build but depends currently broken
#RUN apt-get -y install curl make automake cmake g++-multilib libtool binutils-gold bsdmainutils pkg-config python3 patch
#WORKDIR /rcncoin/depends
#RUN make

RUN groupadd -g 1000 rcncoin && \
    useradd -u 1000 -g rcncoin -s /bin/sh rcncoin

COPY ./rcncoin /rcncoin

WORKDIR /rcncoin

RUN ./autogen.sh && \
    ./configure --disable-test --disable-bench
## for static build but depends currently broken
#RUN CONFIG_SITE=$PWD/depends/x86_64-pc-linux-gnu/share/config.site ./configure ./configure --disable-tests --disable-bench
RUN make -j4
RUN make install



RUN mkdir -p /home/rcncoin/.rcncoin && \
    chown -R rcncoin:rcncoin /home/rcncoin
USER rcncoin
COPY rcncoin.conf /home/rcncoin/.rcncoin/rcncoin.conf
COPY entrypoint.sh /entrypoint.sh
#CMD ["tail", "-F", "/dev/null"]

#RUN rcncoind -daemon

#CMD ["tail", "-F", "/dev/null"]

#CMD ["rcncoind", "--printtoconsole"]
