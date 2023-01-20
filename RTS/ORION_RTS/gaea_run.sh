#!/bin/bash
# This script will run all CI tests on C4 

export BUILD_AREA="~/SHiELD_github/SHiELD_build"
export BASEDIR="${SCRATCH}/${USER}/"
export COMPILER="intel"
export INPUT_DATA="/lustre/f2/pdata/gfdl/gfdl_W/fvGFS_INPUT_DATA"
export INPUT_DATA1="/lustre/f2/pdata/gfdl/gfdl_W/fvGFS_INPUT_DATA"

mkdir -p stdout

#Example args for Gaea C4 where YOURGROUPLETTER is replaced with the group letter associated with your account
SBATCHARGS="--account=gfdl_YOURGROUPLETTER --clusters=c4 --output=./stdout/%x.o%j"
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=82 --job-name=C768r15n3 C768r15n3.csh
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=54 --job-name=C768 C768.csh
sbatch ${SBATCHARGS} --time=00:45:00 --nodes=10 --job-name=C48n4 C48n4.csh
sbatch ${SBATCHARGS} --time=00:10:00 --nodes=6 --job-name=C48_res C48_res.csh
sbatch ${SBATCHARGS} --time=00:10:00 --nodes=6 --job-name=C48_test C48_test.csh
sbatch ${SBATCHARGS} --time=03:00:00 --nodes=331 --job-name=X_SHiELD C3072_res.csh
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=72 --job-name=C384 C384.csh
#Regional3km input data is unique
export INPUT_DATA="/lustre/f2/dev/Lauren.Chilutti/Alaska_c3072"
export INPUT_DATA1="/lustre/f2/pdata/gfdl/gfdl_W/fvGFS_INPUT_DATA"
sbatch ${SBATCHARGS} --time=00:10:00 --nodes=29 --job-name=Regional3km Regional3km.csh

