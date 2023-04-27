#!/bin/bash
# This script will run all CI tests on C4 

export COMPILER="gnu"
ACCOUNT="gfdl_f"
export BUILDDIR="/ncrc/home1/Lauren.Chilutti/SHiELD_dev/SHiELD_build"
RELEASE="`cat ${BUILDDIR}/release`"
export SCRATCHDIR="${SCRATCH}/${USER}/soloCI_${RELEASE}"

mkdir -p ${BUILDDIR}/RTS/CI/stdout

SBATCHARGS="--account=${ACCOUNT} --qos=debug --time=00:10:00 --clusters=c4 --output=./stdout/%x.o%j --mail-user=${USER}@noaa.gov --mail-type=fail"
sbatch ${SBATCHARGS} --nodes=3 C128r20.solo.superC
sbatch ${SBATCHARGS} --nodes=3 C128r3.solo.TC
sbatch ${SBATCHARGS} --nodes=3 C128r3.solo.TC.d1
sbatch ${SBATCHARGS} --nodes=3 C128r3.solo.TC.h6
sbatch ${SBATCHARGS} --nodes=3 C128r3.solo.TC.tr8
sbatch ${SBATCHARGS} --nodes=3 C192.sw.BLvortex
sbatch ${SBATCHARGS} --nodes=3 C192.sw.BTwave
sbatch ${SBATCHARGS} --nodes=3 C192.sw.modon
sbatch ${SBATCHARGS} --nodes=6 C256r20.solo.superC
sbatch ${SBATCHARGS} --nodes=6 C384.sw.BLvortex
sbatch ${SBATCHARGS} --nodes=3 C384.sw.BTwave
sbatch ${SBATCHARGS} --nodes=11 C512r20.solo.superC
sbatch ${SBATCHARGS} --nodes=11 C768.sw.BTwave
sbatch ${SBATCHARGS} --nodes=3 C96.solo.BCdry
sbatch ${SBATCHARGS} --nodes=3 C96.solo.BCdry.hyd
sbatch ${SBATCHARGS} --nodes=1 C96.solo.BCmoist
sbatch ${SBATCHARGS} --nodes=1 C96.solo.BCmoist.hyd
sbatch ${SBATCHARGS} --nodes=1 C96.solo.BCmoist.hyd.d3
sbatch ${SBATCHARGS} --nodes=1 C96.solo.BCmoist.nhK
sbatch ${SBATCHARGS} --nodes=1 C96.solo.mtn_rest
sbatch ${SBATCHARGS} --nodes=1 C96.solo.mtn_rest.hyd
sbatch ${SBATCHARGS} --nodes=1 C96.solo.mtn_rest.hyd.diff2
sbatch ${SBATCHARGS} --nodes=1 C96.solo.mtn_rest.nonmono.diff2
sbatch ${SBATCHARGS} --nodes=1 C96.sw.BLvortex
sbatch ${SBATCHARGS} --nodes=1 C96.sw.BTwave
sbatch ${SBATCHARGS} --nodes=1 C96.sw.modon
sbatch ${SBATCHARGS} --nodes=1 C96.sw.RHwave
sbatch ${SBATCHARGS} --nodes=1 d96_1k.solo.mtn_rest_shear
sbatch ${SBATCHARGS} --nodes=1 d96_1k.solo.mtn_rest_shear.olddamp
sbatch ${SBATCHARGS} --nodes=1 d96_1k.solo.mtn_schar
sbatch ${SBATCHARGS} --nodes=1 d96_1k.solo.mtn_schar.mono
sbatch ${SBATCHARGS} --nodes=1 d96_2k.solo.bubble
sbatch ${SBATCHARGS} --nodes=1 d96_2k.solo.bubble.n0
sbatch ${SBATCHARGS} --nodes=1 d96_2k.solo.bubble.nhK
sbatch ${SBATCHARGS} --nodes=1 d96_500m.solo.mtn_schar
