#!/bin/bash
##@brief compile generated OPS C/C++ code
##@author Jianping Meng
##@contributors Pushpender Sharma Teja Ala
##@details

function usage {
    echo "This script will compile the C/C++ code generated by OpenSBLI!"
    echo "./$(basename $0) -h -> showing usage"
    echo "./$(basename $0) -H -> Specifying the HDF5 directory"
    echo "./$(basename $0) -e -> Sepcifying the envirment directory."
    echo "./$(basename $0) -m -> Specifying the machine type"
    echo "Machine type can be: Ubuntu ARCHER2 IRIDIS5 Fedora DAaaS"
    echo "If without specifying the machine, the script will assume all dependencies prepared!"

}

Machine="None"
ScriptPath="${BASH_SOURCE:-$0}"
AbsolutScriptPath="$(realpath "${ScriptPath}")"
EnvDir="$(dirname "${AbsolutScriptPath}")"

HDF5Root=""
if [ -d "${EnvDir}/HDF5" ]
then
    HDF5Root="-DHDF5_ROOT=${EnvDir}/HDF5"
fi

optstring="e:m:H:h"


while getopts ${optstring} options; do
    case ${options} in
        h)
            usage
            exit 0
        ;;
        H)
            HDF5Root="-DHDF5_ROOT=${OPTARG}"
        ;;
        e)
            EnvDir=${OPTARG}
        ;;
        m)
            Machine=${OPTARG}
        ;;
        :)
            echo "$0: Must supply an argument to -$OPTARG." >&2
            exit 1
        ;;
        ?)
            echo "Invalid option: -${OPTARG}."
            exit 2
        ;;
    esac
done

OPTIMISATION="-DCFLAG=-ftree-vectorize -DCXXFLAG=-ftree-vectorize"

if [ $Machine == "CIRRUS" ]
then
    module load nvidia/nvhpc
    module load cmake/3.22.1
    if [ -z ${HDF5Root} ]
    then
        module load hdf5parallel/1.12.0-nvhpc-openmpi
    fi
fi

if [ $Machine == "ARCHER2" ]
then
    module purge PrgEnv-cray
    module load load-epcc-module
    module load cmake/3.21.3
    module load PrgEnv-gnu
    module load cray-python/3.9.13.1

    if [ -z ${HDF5Root} ]
    then
        module load cray-hdf5-parallel
    fi
fi

if [ $Machine == "IRIDIS5" ]
then
    module load gcc/6.4.0
    if [ -z ${HDF5Root} ]
    then
        module load hdf5/1.10.2/gcc/parallel
    fi
    #module load cuda/10.0
    module load cmake
    module load python/3.9.7
fi

OpenSBLIBuild="BUILD_OPS_C_SAMPLE(OpenSBLI \"NONE\" \"NONE\" \"NONE\" \"NO\" \"NO\")"

cp $EnvDir/CMakeLists.txt .
sed -i '/add_subdirectory/d' CMakeLists.txt
sed -i "\$a${OpenSBLIBuild}" CMakeLists.txt
rm -rf build
mkdir build
cd build
cmake ../ -DOPS_INSTALL_DIR=$EnvDir/OPS-INSTALL -DCMAKE_BUILD_TYPE=Release -DOPS_TEST=OFF ${OPTIMISATION} -DAPP_INSTALL_DIR=$HOME/OPS-APP -DGPU_NUMBER=1 ${HDF5Root}
cmake --build . -j 4
