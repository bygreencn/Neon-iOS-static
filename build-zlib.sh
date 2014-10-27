#!/bin/sh

#  Automatic build script for zlib 
#  for iPhoneOS and iPhoneSimulator
#
#  Created by Sui Libin on 20.09.14.
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
VERSION="1.2.8"                                                           #
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
if [ ! -e zlib-${VERSION}.tar.gz ]; then
	echo "Downloading zlib-${VERSION}.tar.gz"
    curl -O http://ncu.dl.sourceforge.net/project/libpng/zlib/${VERSION}/zlib-${VERSION}.tar.gz
else
	echo "Using zlib-${VERSION}.tar.gz"
fi

mkdir -p "${CURRENTPATH}/src"
mkdir -p "${CURRENTPATH}/bin"
mkdir -p "${CURRENTPATH}/lib"

for ARCH in ${ARCHS}
do
	tar zxf zlib-${VERSION}.tar.gz -C "${CURRENTPATH}/src"
	cd "${CURRENTPATH}/src/zlib-${VERSION}"

	if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]];
	then
		PLATFORM="iPhoneSimulator"
	else
		PLATFORM="iPhoneOS"
	fi
	
	echo "Building zlib-${VERSION} for ${PLATFORM} ${SDKVERSION} ${ARCH}"
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

    export LDFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -L${CURRENTPATH}/lib -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions"
    export CFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions"
    export CPPFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions"
    export CXXFLAGS="-arch ${ARCH} -pipe -no-cpp-precomp -isysroot ${SDKROOT} -I${CURRENTPATH}/include -miphoneos-version-min=${MIN_VERSION} -fheinous-gnu-extensions"

    HOST="${ARCH}"
#if [ "${ARCH}" == "arm64" ];
#then
#HOST="aarch64"
#echo "Patch..."
#fi

	mkdir -p "${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk"
	LOG="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk/build-zlib-${VERSION}.log"

    echo "Configure..."
    if [[ "${ARCH}" == "x86_64" || "${ARCH}" == "arm64" ]];
    then
        ./configure --archs="-arch ${ARCH}" --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" --static --64 > "${LOG}" 2>&1
    else
        ./configure --archs="-arch ${ARCH}" --prefix="${CURRENTPATH}/bin/${PLATFORM}${SDKVERSION}-${ARCH}.sdk" --static > "${LOG}" 2>&1
    fi

    echo "Make..."
    make -j4 >> "${LOG}" 2>&1
    echo "Make install..."
    make install >> "${LOG}" 2>&1
	cd "${CURRENTPATH}"
	rm -rf "${CURRENTPATH}/src/zlib-${VERSION}"
done

echo "Build library..."
lipo -create ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib/libz.a ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib/libz.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib/libz.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib/libz.a ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib/libz.a -output ${CURRENTPATH}/lib/libz.a
lipo -info ${CURRENTPATH}/lib/libz.a
mkdir -p ${CURRENTPATH}/include
cp  ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/include/* ${CURRENTPATH}/include
echo "Building done."
echo "Done."
