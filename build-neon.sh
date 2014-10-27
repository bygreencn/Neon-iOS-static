#!/bin/sh

#  Automatic build script for neon 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Sui Libin on 20-09-14.
#  Copyright 2014 Sui Libin. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################
#  Change values here													  #
#																		  #
VERSION="0.30.0"                                                           #
SDKVERSION="8.1"                                                          #
MIN_VERSION="6.0"                                                         #
#																		  #
###########################################################################
#																		  #
# Don't change anything under this line!								  #
#																		  #
###########################################################################


CURRENTPATH=`pwd`
ARCHS="i386 x86_64 armv7 armv7s arm64"
DEVELOPER=`xcode-select -print-path`

set -e
if [ ! -e neon-${VERSION}.tar.gz ]; then
	echo "Downloading neon-${VERSION}.tar.gz"
    curl -O http://www.webdav.org/neon/neon-${VERSION}.tar.gz
else
	echo "Using neon-${VERSION}.tar.gz"
fi

mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

for ARCH in ${ARCHS}
do
    tar zxf neon-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
	cd "${CURRENTPATH}/src/neon-${VERSION}"

	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		PLATFORM="iPhoneSimulator"
	else
		PLATFORM="iPhoneOS"
	fi
	
	echo "Building neon-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
	echo "Please stand by..."
	
	export DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"

    export LD=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ld
    export CC=${DEVELOPER}/usr/bin/gcc
    export CXX=${DEVELOPER}/usr/bin/g++

    export AR=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar
    export AS=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/as
    export NM=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/nm
    export RANLIB=${DEVELOPER}/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib

    export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${CURRENTPATH}/lib -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions -L${CURRENTPATH}/lib"
    export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions -I${CURRENTPATH}/include"
    export CPPFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions -I${CURRENTPATH}/include"
    export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions -I${CURRENTPATH}/include"
    export LIBS="-lz -lexpat -lssl -lcrypto"

    HOST="${ARCH}"
    if [ "${ARCH}" == "x86_64" ];
    then
        echo "Patch..."
        #Patch config.sub to support aarch64
        cd "${CURRENTPATH}/src"
        patch -p0 < "../config.neon.diff"
        cd "${CURRENTPATH}/src/neon-${VERSION}"
    elif [ "${ARCH}" == "arm64" ];
    then
        HOST="aarch64"

        echo "Patch..."
        #Patch config.sub to support aarch64
        cd "${CURRENTPATH}/src"
        patch -p0 < "../config.neon.diff"
        cd "${CURRENTPATH}/src/neon-${VERSION}"
    fi


	mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-neon-${VERSION}.log"

    echo "Configure..."

	./configure --host="${HOST}-apple-darwin" --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" --disable-shared --enable-static --with-expat --with-ssl=openssl --with-libs="${CURRENTPATH}" > "${LOG}" 2>&1
    echo "Make..."
    make -j4 >> "${LOG}" 2>&1
    echo "Make install..."
    make install >> "${LOG}" 2>&1
	cd "${CURRENTPATH}"
    rm -rf "${CURRENTPATH}/src/neon-${VERSION}"
done

echo "Build library..."
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libneon.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libneon.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libneon.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libneon.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libneon.a -output ${CURRENTPATH}/lib/libneon.a
lipo -info ${CURRENTPATH}/lib/libneon.a
mkdir -p ${CURRENTPATH}/include
cp  -r ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/* ${CURRENTPATH}/include
echo "Building done."
echo "Done."
