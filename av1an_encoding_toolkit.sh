#!/bin/bash

set -ex

sudo apt-get install -y \
    autoconf \
    automake \
    build-essential \
    clang \
    cmake \
    cython3 \
    ffmpeg \
    jq \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libfontconfig-dev \
    libtool \
    meson \
    mkvtoolnix \
    nasm \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-venv \
    rustup \
    yasm

NPROC=$(nproc)
WORKDIR=~/av1an-toolkit-sources

mkdir -p $WORKDIR

ZIMG_REL=$(curl -s "https://api.github.com/repos/sekrit-twc/zimg/releases/latest")
ZIMG_VER=$(echo $ZIMG_REL | jq -r .name)
ZIMG_TAR=zimg-$ZIMG_VER.tar.gz
cd $WORKDIR
wget -O $ZIMG_TAR $(echo $ZIMG_REL | jq -r .tarball_url)
tar xf $ZIMG_TAR
cd "$(tar tf $ZIMG_TAR | head -1)"
./autogen.sh
./configure
make -j$NPROC
sudo make install

VAPOR_REL=$(curl -s "https://api.github.com/repos/vapoursynth/vapoursynth/releases/latest")
VAPOR_VER=$(echo $VAPOR_REL | jq -r .name)
VAPOR_TAR=vapoursynth-$VAPOR_VER.tar.gz
cd $WORKDIR
wget -O $VAPOR_TAR $(echo $VAPOR_REL | jq -r .tarball_url)
tar xf $VAPOR_TAR
cd "$(tar tf $VAPOR_TAR | head -1)"
./autogen.sh
./configure CFLAGS="-march=native" CXXFLAGS="-march=native" --libdir=/usr/lib
make -j$NPROC
sudo make install
sudo mkdir -p /usr/lib/vapoursynth
sudo ldconfig

LSMASH_VER=$(curl -s "https://api.github.com/repos/l-smash/l-smash/tags" | jq -r '.[0].name')
LSMASH_TAR=l-smash-$LSMASH_VER.tar.gz
cd $WORKDIR
wget -O $LSMASH_TAR https://api.github.com/repos/l-smash/l-smash/tarball/refs/tags/$LSMASH_VER
tar xf $LSMASH_TAR
cd "$(tar tf $LSMASH_TAR | head -1)"
./configure --enable-shared --extra-cflags="-march=native"
make -j$NPROC
sudo make install

cd $WORKDIR
rm -rf L-SMASH-Works
git clone --depth 1 -b ffmpeg-4.5 https://github.com/AkarinVS/L-SMASH-Works
mkdir L-SMASH-Works/VapourSynth/build
cd $_
meson .. --optimization=3 --default-library=static -Db_lto=true -Dc_args="-march=native" -Dcpp_args="-march=native"
ninja -j$NPROC
sudo cp -v libvslsmashsource.so /usr/lib/vapoursynth/

FFMS2_REL=$(curl -s "https://api.github.com/repos/FFMS/ffms2/releases/latest")
FFMS2_VER=$(echo $FFMS2_REL | jq -r .name)
FFMS2_TAR=ffms2-$FFMS2_VER.tar.gz
cd $WORKDIR
wget -O $FFMS2_TAR $(echo $FFMS2_REL | jq -r .tarball_url)
tar xf $FFMS2_TAR
cd "$(tar tf $FFMS2_TAR | head -1)"
./autogen.sh
./configure CFLAGS="-O3 -march=native" CXXFLAGS="-O3 -march=native"
make -j$NPROC
sudo cp -vP src/core/.libs/libffms2.so* /usr/lib/vapoursynth/

rustup default stable

AVIAN_REL=$(curl -s "https://api.github.com/repos/master-of-zen/Av1an/releases/latest")
AVIAN_VER=$(echo $AVIAN_REL | jq -r .name)
AVIAN_TAR=av1an-$AVIAN_VER.tar.gz
cd $WORKDIR
wget -O $AVIAN_TAR $(echo $AVIAN_REL | jq -r .tarball_url)
tar xf $AVIAN_TAR
cd "$(tar tf $AVIAN_TAR | head -1)"
RUSTFLAGS="-C target-cpu=native" cargo build --release
sudo cp -v target/release/av1an /usr/local/bin

cd ~
python3 -m venv .venv/av1an
source .venv/av1an/bin/activate
pip3 install --upgrade pip
pip3 install wheel
cd $WORKDIR/vapoursynth-vapoursynth-*
pip3 wheel .
pip3 install VapourSynth-*.whl

cd $WORKDIR
SVTAV1_REL=$(curl -Ls https://gitlab.com/api/v4/projects/24327400/releases/permalink/latest)
SVTAV1_VER=$(echo $SVTAV1_REL | jq -r .name) 
SVTAV1_TAR=SVT-AV1-$SVTAV1_VER.tar.gz
wget -O $SVTAV1_TAR $(echo $SVTAV1_REL | jq -r '.assets.sources[] | select (.format == "tar.gz") | .url')
tar xf SVT-AV1-$SVTAV1_VER.tar.gz
cd SVT-AV1-$SVTAV1_VER/
./Build/linux/build.sh cc=clang cxx=clang++ jobs=$NPROC enable-lto static native release
sudo cp -v Bin/Release/SvtAv1EncApp /usr/local/bin/

cd $WORKDIR
rm -rf aom
git clone --depth=1 -b v3.9.1 https://aomedia.googlesource.com/aom/
cd aom/build
cmake .. -DBUILD_SHARED_LIBS=0 -DENABLE_DOCS=0 -DCONFIG_TUNE_BUTTERAUGLI=0 -DCONFIG_TUNE_VMAF=0 -DCONFIG_AV1_DECODER=0 -DENABLE_TESTS=0 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-flto -O3 -march=native" -DCMAKE_C_FLAGS="-flto -O3 -march=native -pipe -fno-plt"
make -j$NPROC
sudo make install

SSMLCR_VER=$(curl -s "https://api.github.com/repos/rust-av/ssimulacra2_bin/tags" | jq -r '.[0].name')
SSMLCR_TAR=ssimulacra2-bin_$SSMLCR_VER.tar.gz
cd $WORKDIR
wget -O $SSMLCR_TAR https://api.github.com/repos/rust-av/ssimulacra2_bin/tarball/refs/tags/$SSMLCR_VER
tar xf $SSMLCR_TAR
cd rust-av-ssimulacra2_bin-*
cargo build --release
sudo cp -v target/release/ssimulacra2_rs /usr/local/bin
