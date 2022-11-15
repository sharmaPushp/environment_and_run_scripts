#!/bin/bash
if [ $# -eq 0 ]
then
    echo "This script will create the whole OpenSBLI environment !"
    echo "Usage: ./CreateOpenSBLIEnv.sh Dir"
    echo "Dir: the directory for the environment."
    exit 1
fi
mkdir -p $1
cd $1
wget -c https://github.com/jpmeng/utilities/archive/refs/heads/main.zip
unzip -j main.zip
rm main.zip
./InstallPython2.sh Python2
./InstallOPS.sh OPS-INSTALL ARCHER2
wget -c https://github.com/opensbli/opensbli/archive/refs/heads/cpc_release.zip
unzip cpc_release.zip
rm cpc_release.zip

