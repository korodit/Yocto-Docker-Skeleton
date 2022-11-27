#!/bin/bash

if [ -d "build-files" ]; then
  echo "ERROR: 'build-files' directory already exists, have you already run setup?"
  exit 1
fi

mkdir -p build-files/build-dir && \
mkdir -p build-files/downloads && \
cd build-files && \
git clone https://git.yoctoproject.org/poky && \
cd poky  && \
git checkout sumo && \
git clone https://git.openembedded.org/meta-openembedded && \
cd meta-openembedded && \
git checkout sumo && \
cd .. && \
git clone https://git.yoctoproject.org/meta-security && \
cd meta-security && \
git checkout sumo && \
cd .. && \
git clone https://github.com/ros/meta-ros.git && \
cd meta-ros && \
git checkout legacy && \
cd .. && \
git clone https://git.yoctoproject.org/meta-java && \
cd meta-java && \
git checkout thud && \
sed -i 's/LAYERSERIES_COMPAT_meta-java = "thud"/LAYERSERIES_COMPAT_meta-java = "thud sumo"/g' conf/layer.conf && \
cd .. && \
git clone https://github.com/intel-iot-devkit/meta-iot-cloud.git && \
cd meta-iot-cloud && \
git checkout sumo && \
cd .. && \
git clone https://git.yoctoproject.org/git/meta-intel && \
cd meta-intel && \
git checkout sumo && \
cd .. && \
git clone https://git.yoctoproject.org/git/meta-intel-qat && \
cd meta-intel-qat && \
git checkout thud && \
sed -i 's/LAYERSERIES_COMPAT_intel-qat = "thud"/LAYERSERIES_COMPAT_intel-qat = "thud sumo"/g' conf/layer.conf && \
cd .. && \
git clone https://git.linaro.org/openembedded/meta-linaro.git && \
cd meta-linaro && \
git checkout sumo && \
cd ../../.. && \
cp ./.env.template ./.env
