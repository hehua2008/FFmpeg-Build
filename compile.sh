#!/usr/bin/env bash

echo '♻️ ' Create Ramdisk

if df | grep Ramdisk > /dev/null ; then tput bold ; echo ; echo ⏏ Eject Ramdisk ; tput sgr0 ; fi

if df | grep Ramdisk > /dev/null ; then diskutil eject Ramdisk ; sleep 1 ; fi

DISK_ID=$(hdid -nomount ram://70000000)

newfs_hfs -v tempdisk ${DISK_ID}

diskutil mount ${DISK_ID}

sleep 1

SOURCE="/Volumes/tempdisk/sw"

COMPILED="/Volumes/tempdisk/compile"

mkdir ${SOURCE}

mkdir ${COMPILED}

export PATH=${SOURCE}/bin:$PATH

export CC=clang && export PKG_CONFIG_PATH="${SOURCE}/lib/pkgconfig"

# export MACOSX_DEPLOYMENT_TARGET=10.9

# set -o errexit

#
# ask user to copy all files to ramdisk
#

echo
echo Copy all files to ramdisk tempdisk/compile folder and press a key when ready
read -s



# echo '♻️ ' Copy environment files

#grep -rl "am__api_version='1.16'" ${COMPILED} | xargs sed -i "" "s#am__api_version='1.16'#am__api_version='1.17'#g"

cp -a ${COMPILED}/environment/ ${SOURCE}

ln -s aclocal ${SOURCE}/bin/aclocal-1.17

ln -s aclocal ${SOURCE}/bin/aclocal-1.16

ln -s aclocal ${SOURCE}/bin/aclocal-1.16.5

ln -s automake ${SOURCE}/bin/automake-1.17

ln -s automake ${SOURCE}/bin/automake-1.16

ln -s automake ${SOURCE}/bin/automake-1.16.5

grep -rl "HOMEBREW_PERL" ${SOURCE}/bin | xargs sed -i "" "s#@@HOMEBREW_PERL@@#/usr/bin/perl#g"

grep -rl "HOMEBREW_CELLAR" ${SOURCE} | xargs sed -i "" "s#@@HOMEBREW_CELLAR@@/automake/1.17#${SOURCE}#g"

grep -rl "HOMEBREW_CELLAR" ${SOURCE} | xargs sed -i "" "s#@@HOMEBREW_CELLAR@@/autoconf/2.72#${SOURCE}#g"

grep -rl "HOMEBREW_CELLAR" ${SOURCE} | xargs sed -i "" "s#@@HOMEBREW_CELLAR@@/libtool/2.4.7#${SOURCE}#g"

grep -rl "HOMEBREW_PREFIX" ${SOURCE} | xargs sed -i "" "s#@@HOMEBREW_PREFIX@@/opt/m4/bin/m4#${SOURCE}/bin/m4#g"

sleep 1



# echo '♻️ ' Start compiling YASM

#
# compile YASM
#

#cd ${COMPILED}

#cd yasm-1.3.0

#./configure --prefix=${SOURCE}

#make -j 10

#make install

#sleep 1



echo '♻️ ' Start compiling NASM

#
# compile NASM
#

cd ${COMPILED}

cd nasm-2.16.03

./configure --prefix=${SOURCE}

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling PKG

#
# compile PKG
#

cd ${COMPILED}

cd pkg-config-0.29.2

export LDFLAGS="-framework Foundation -framework Cocoa"

export CFLAGS="-Wno-int-conversion"

./configure --prefix=${SOURCE} --with-pc-path=${SOURCE}/lib/pkgconfig --with-internal-glib --disable-shared --enable-static

make -j 10

make install

unset LDFLAGS

sleep 1



echo '♻️ ' Start compiling XZ

#
# compile XZ
#

cd ${COMPILED}

cd xz-5.6.2

./configure --prefix=${SOURCE} --disable-shared --enable-static --disable-docs --disable-examples

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling ZLIB

#
# ZLIB
#

cd ${COMPILED}

cd zlib-1.3.1

./configure --prefix=${SOURCE} --static

make -j 10

make install

rm ${SOURCE}/lib/libz.*

sleep 1



echo '♻️ ' Start compiling CMAKE

#
# compile CMAKE
#

cd ${COMPILED}

cd cmake-3.30.2

./configure --prefix=${SOURCE}

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling xml2

#
# compile libxml2
#

cd ${COMPILED}

cd libxml2-v2.13.3

./autogen.sh

./configure --prefix=${SOURCE} --disable-shared --enable-static --without-python

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling Lame

#
# compile Lame
#

cd ${COMPILED}

cd lame

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling X264

#
# x264
#

cd ${COMPILED}

cd x264

./configure --prefix=${SOURCE} --disable-shared --enable-static --enable-pic

make -j 10

make install

make install-lib-static

# echo
# echo continue
# read -s

sleep 1



echo '♻️ ' Start compiling X265

#
# x265
#

rm -f ${SOURCE}/include/x265*.h 2>/dev/null

rm -f ${SOURCE}/lib/libx265.a 2>/dev/null

cd ${COMPILED}

cd x265

#curl -fL 'https://github.com/Vargol/ffmpeg-apple-arm64-build/raw/master/build/x265_arm64_threading.patch' > x265_arm64_threading.patch && \
#patch -p1 < x265_arm64_threading.patch

patch -p1 < ${COMPILED}/x265_arm64_threading.patch

sleep 1



echo '♻️ ' X265 12bit

cd ${COMPILED}

cd x265/source

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DHIGH_BIT_DEPTH=ON -DMAIN12=ON -DENABLE_SHARED=NO -DEXPORT_C_API=NO -DENABLE_CLI=OFF

make

mv libx265.a libx265_main12.a

make clean-generated

rm CMakeCache.txt

sleep 1



echo '♻️ ' X265 10bit

cd ${COMPILED}

cd x265/source

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DHIGH_BIT_DEPTH=ON -DMAIN10=ON -DENABLE_HDR10_PLUS=ON -DENABLE_SHARED=NO -DEXPORT_C_API=NO -DENABLE_CLI=OFF

make clean

make

mv libx265.a libx265_main10.a

make clean-generated && rm CMakeCache.txt

sleep 1



echo '♻️ ' X265 full

cd ${COMPILED}

cd x265/source

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DEXTRA_LIB="x265_main10.a;x265_main12.a" -DEXTRA_LINK_FLAGS=-L. -DLINKED_10BIT=ON -DLINKED_12BIT=ON -DENABLE_SHARED=OFF -DENABLE_CLI=OFF

make clean

make

mv libx265.a libx265_main.a

libtool -static -o libx265.a libx265_main.a libx265_main10.a libx265_main12.a 2>/dev/null

make install

sleep 1



echo '♻️ ' Start compiling VPX

#
# VPX
#

cd ${COMPILED}

cd libvpx

./configure --prefix=${SOURCE} --enable-vp8 --enable-postproc --enable-vp9-postproc --enable-vp9-highbitdepth --disable-examples --disable-docs --enable-multi-res-encoding --disable-unit-tests --enable-pic --disable-shared

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling EXPAT

#
# EXPAT
#

cd ${COMPILED}

cd expat-2.6.2

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling Gettext

#
# Gettext
#

cd ${COMPILED}

cd gettext-0.22.5

./configure --prefix=${SOURCE} --disable-dependency-tracking --disable-silent-rules --disable-debug --with-included-gettext --with-included-glib \
--with-included-libcroco --with-included-libunistring --with-included-libxml --with-emacs --disable-java --disable-native-java --disable-csharp \
--disable-shared --enable-static --without-git --without-cvs --disable-docs --disable-examples

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling LIBPNG

#
# LIBPNG
#

cd ${COMPILED}

cd libpng

./configure --prefix=${SOURCE} --disable-dependency-tracking --disable-silent-rules --enable-static --disable-shared

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling ENCA

#
# ENCA
#

cd ${COMPILED}

cd enca-1.19

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling FRIBIDI

#
# FRIBIDI
#

cd ${COMPILED}

cd fribidi-1.0.15

./configure --prefix=${SOURCE} --disable-shared --enable-static --disable-silent-rules --disable-debug --disable-dependency-tracking

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling FREETYPE

#
# FREETYPE
#

cd ${COMPILED}

cd freetype

# pip3 install docwriter

#./configure --prefix=${SOURCE} --disable-shared --enable-static --enable-freetype-config

mkdir freetype_build

cd freetype_build

cmake ${COMPILED}/freetype -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling FONTCONFIG

#
# FONTCONFIG
#

cd ${COMPILED}

cd fontconfig-2.15.0

./configure --prefix=${SOURCE} --enable-iconv --disable-libxml2 --disable-dependency-tracking --disable-silent-rules --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling harfbuzz

#
# HARFBUZZ
#

cd ${COMPILED}

cd harfbuzz-8.5.0

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling SDL

#
# compile SDL
#

cd ${COMPILED}

cd SDL2-2.30.6

./autogen.sh

./configure --prefix=${SOURCE} --disable-shared --enable-static --without-x --enable-hidapi

make -j 14

make install

sleep 1



echo '♻️ ' Start compiling LIBASS

#
# LIBASS
#

cd ${COMPILED}

cd libass-0.17.3

./configure --prefix=${SOURCE} --disable-fontconfig --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling OPUS

#
# OPUS
#

cd ${COMPILED}

cd opus

#sed -i "" "s#wget https://media.xiph.org/opus/models/\$model#curl -fL https://media.xiph.org/opus/models/\$model > \$model#g" dnn/download_model.sh

sed -i "" "s#wget https://media.xiph.org/opus/models/\$model#cp ${COMPILED}/\$model \$model#g" dnn/download_model.sh

./autogen.sh

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling LIBOGG

#
# LIBOGG
#

cd ${COMPILED}

cd libogg

./autogen.sh

./configure --prefix=${SOURCE} --disable-shared --enable-static --disable-dependency-tracking

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling LIBVORBIS

#
# LIBVORBIS
#

cd ${COMPILED}

cd libvorbis

#curl -fL 'https://github.com/xiph/vorbis/commit/c2174eea91165866f09a45a9817c54aba6b0eddf.patch' > configure.patch && \
#patch ./configure.ac < configure.patch

patch ./configure.ac < ${COMPILED}/c2174eea91165866f09a45a9817c54aba6b0eddf.patch

./autogen.sh

./configure --prefix=${SOURCE} --with-ogg-libraries=${SOURCE}/lib --with-ogg-includes=${SOURCE}/include/ --enable-static --disable-shared

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling THEORA

#
# THEORA
#

cd ${COMPILED}

cd libtheora

#curl -fL 'https://gitlab.xiph.org/xiph/theora/-/commit/7288b539c52e99168488dc3a343845c9365617c8.diff' > png2theora.patch && \
#patch ./examples/png2theora.c < png2theora.patch

#patch ./examples/png2theora.c < ${COMPILED}/7288b539c52e99168488dc3a343845c9365617c8.diff

./autogen.sh

./configure --prefix=${SOURCE} --disable-asm --with-ogg-libraries=${SOURCE}/lib --with-ogg-includes=${SOURCE}/include/ --with-vorbis-libraries=${SOURCE}/lib --with-vorbis-includes=${SOURCE}/include/ --enable-static --disable-shared

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling Vid-stab

#
# Vidstab
#

cd ${COMPILED}

cd vidstab

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DLIBTYPE=STATIC -DBUILD_SHARED_LIBS=OFF -DUSE_OMP=OFF -DENABLE_SHARED=off

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling SNAPPY

#
# SNAPPY
#

cd ${COMPILED}

cd snappy

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DENABLE_SHARED=OFF -DENABLE_CLI=OFF

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling OpenJPEG

#
# OpenJPEG
#

cd ${COMPILED}

cd openjpeg

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DENABLE_C_DEPS=ON -DLIBTYPE=STATIC -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

make -j 10

make install

rm ${SOURCE}/lib/libopenjp2.2.5.2.dy*
rm ${SOURCE}/lib/libopenjp2.dy*
rm ${SOURCE}/lib/libopenjp2.7.dy*

sleep 1



echo '♻️ ' Start compiling AOM

#
# AOM
#

cd ${COMPILED}

cd aom

mkdir aom_build

cd aom_build

cmake ${COMPILED}/aom -DENABLE_TESTS=0 -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DLIBTYPE=STATIC -DAOM_TARGET_CPU=ARM64 -DCONFIG_RUNTIME_CPU_DETECT=0

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling WEBP

#
# WEBP
#

cd ${COMPILED}

cd libwebp

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DENABLE_C_DEPS=ON -DLIBTYPE=STATIC -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

make -j 10

make install

sleep 1



echo '♻️ ' compile zimg

cd ${COMPILED}

cd zimg

./autogen.sh

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling SVT-AV1

#
# SVT-AV1
#

cd ${COMPILED}

cd SVT-AV1

cmake -DCMAKE_INSTALL_PREFIX:PATH=${SOURCE} -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF -DLIBTYPE=STATIC -DENABLE_SHARED=OFF -DENABLE_STATIC=ON

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling KVAZAAR

#
# KVAZAAR
#

cd ${COMPILED}

cd kvazaar-2.3.1

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling libudfread

#
# libudfread
#

cd ${COMPILED}

cd libudfread

./bootstrap

./configure --prefix=${SOURCE} --disable-shared --enable-static

make -j 10

make install

sleep 1



echo '♻️ ' Start compiling libbluray

#
# compile libbluray
#

cd ${COMPILED}

cd libbluray-1.3.4

#curl -fL 'https://github.com/Vargol/ffmpeg-apple-arm64-build/raw/master/build/libblu_dec_init.patch' > libblu_dec_init.patch && \
#patch -p1 < libblu_dec_init.patch

patch -p1 < ${COMPILED}/libblu_dec_init.patch

./bootstrap

./configure --prefix=${SOURCE} --disable-shared --enable-static --disable-dependency-tracking --disable-silent-rules --without-libxml2 --without-freetype --disable-doxygen-doc --disable-bdjava-jar

make -j 14

make install

sleep 1



echo '♻️ ' Start compiling FFMPEG

cd ${COMPILED}

cd ffmpeg

git am ${COMPILED}/avbuild/patches-master/*.patch

export LDFLAGS="-L${SOURCE}/lib"

export CFLAGS="-I${SOURCE}/include"

export LDFLAGS="$LDFLAGS -framework VideoToolbox"

./configure --prefix=${SOURCE} --extra-cflags="-fno-stack-check" --arch=arm64 --cc=/usr/bin/clang --enable-gpl --enable-libbluray --enable-libopenjpeg --enable-libopus --enable-libmp3lame --enable-libx264 --enable-libx265 --enable-libvpx --enable-libwebp --enable-libass --enable-libfreetype --enable-fontconfig --enable-libtheora --enable-libvorbis --enable-libsnappy --enable-libaom --enable-libvidstab --enable-libzimg --enable-libsvtav1 --enable-libkvazaar --enable-libharfbuzz --pkg-config-flags=--static --enable-sdl2 --enable-ffplay --enable-postproc --enable-neon --enable-runtime-cpudetect --disable-indev=qtkit --disable-indev=x11grab_xcb

make -j 10

make install
