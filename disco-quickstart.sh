VER="${1:-3.1}"
COMP="${2:-NCOMP}"
YOCTO=6.6.51-linux4microchip+fpga-2024.09

# In Progress

#if [[ $(uname -r) != $YOCTO ]]; then
	#echo "Improper Yocto Version detected, VectorBlox demo might not function as intended."
	#echo "Yocto Version: $YOCTO required"
	# echo "Please download at https://github.com/polarfire-soc/meta-polarfire-soc-yocto-bsp/releases/download/v2023.02.1/core-image-minimal-dev-mpfs-video-kit-20230328105837.rootfs.wic.gz"
	#exit
#fi


# Check that libjpeg is installed, if not install
if [ $(ls /usr/include/jpeglib.h) != "/usr/include/jpeglib.h" ]; then
	mkdir -p /tmp/build && cd /tmp/build
    wget https://ijg.org/files/jpegsrc.v9e.tar.gz
    tar xf jpegsrc.v9*.tar.gz
    cd jpeg-9*
    ./configure --prefix=/usr
    make -j"$(nproc || echo 2)"
	make install
fi

# Placeholder
if [ ! -d samples_V500_${COMP}_${VER} ]; then
	if [ ! -f samples_V500_${COMP}_${VER}.zip ]; then
		wget --no-check-certificate https://raw.githubusercontent.com/ahenderson10/temp_assets/refs/heads/main/samples_V500_NCOMP_3.1.zip ~
	fi
	unzip samples_V500_${COMP}_${VER}.zip -d ~
fi

if [ ! -d VectorBlox-SDK-release-v$VER ]; then
	if [ ! -f release-v$VER.zip ]; then
		wget --no-check-certificate https://github.com/Microchip-Vectorblox/VectorBlox-SDK/archive/refs/tags/release-v$VER.zip ~
	fi
	if [ -f VectorBlox-SDK-release-v$VER.zip ]; then
		mv VectorBlox-SDK-release-v$VER.zip release-v$VER.zip
	fi
	unzip release-v$VER.zip -d ~
	
	cd VectorBlox-SDK-release-v$VER/example/soc-c
fi

if [ ! -f run-model ];then
    make clean
    make kit=discovery
	make overlay
fi
	
if [ -f run-model ];then
	./run-model ~/samples_V500_${COMP}_${VER}/mobilenet_v2_V500_ncomp.vnnx ../../tutorials/test_images/oreo.jpg CLASSIFY
fi
