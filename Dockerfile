FROM ubuntu:18.04
MAINTAINER Pavel Pavlov <pavel.pavlov@alera.ru>
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
apt-get install -y software-properties-common build-essential curl git python libglib2.0-dev && \
rm -rf /tmp/v8jsbuild && mkdir -p /tmp/v8jsbuild && cd /tmp/v8jsbuild && \
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git && \
export PATH=`pwd`/depot_tools:"$PATH" &&\
fetch v8 &&  cd v8 && git checkout 6.4.388.18 && gclient sync && \
tools/dev/v8gen.py -vv x64.release -- is_component_build=true && \
ninja -C out.gn/x64.release/ && \
cp out.gn/x64.release/lib*.so /usr/lib/ && cp -R include/* /usr/include && \
cp out.gn/x64.release/natives_blob.bin /usr/lib && \
cp out.gn/x64.release/snapshot_blob.bin /usr/lib && \
cd out.gn/x64.release/obj && \
ar rcsDT libv8_libplatform.a v8_libplatform/*.o && \
rm -rf /tmp/v8jsbuild && \
apt-get remove -y software-properties-common build-essential curl git python libglib2.0-dev && \
apt-get autoremove -y && apt-get autoclean -y && rm -rf /var/lib/apt/lists/* && \
rm -rf /root/.vpython-root/ && rm -rf /root/.vpython_cipd_cache/

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
apt-get install -y software-properties-common php7.2-fpm php7.2-dev build-essential && \
ln -fs /usr/share/zoneinfo/Europe/Moscow /etc/localtime &&  dpkg-reconfigure --frontend noninteractive tzdata && \
pecl channel-update pecl.php.net && printf "\n" | pecl install v8js-2.1.0 && \
echo "extension=v8js.so" > /etc/php/7.2/mods-available/v8js.ini && \
phpenmod v8js &&\
apt-get remove -y software-properties-common php7.2-dev build-essential && \
apt-get autoremove -y && apt-get autoclean -y && \
rm -rf /var/lib/apt/lists/* && \
rm -rf /root/.vpython-root/ && rm -rf /root/.vpython_cipd_cache/