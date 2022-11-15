#!/bin/bash
if [ $# -ne 2 ]
then
    echo "This script will create the whole OpenSBLI environment !"
    echo "Usage: ./translate.sh EnvDir source "
    echo "EnvDir: the directory for the environment."
    echo "source: python source file"
    exit 1
fi
EnvDir=$1
source=$2
source $1/Python2/bin/activate  # activate Python2
export PYTHONPATH=$PYTHONPATH:$1/opensbli-cpc_release
python source