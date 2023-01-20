#!/bin/bash
# This script will run all CI tests on Orion 

#Example args for Orion
SBATCHARGS="--account=gfdlhires --partition=orion --output=/home/${USER}/ORION_RT/stdout/%x.%j --exclusive"
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=24 --job-name=Regional3km Regional3km.csh
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=74 --job-name=C768r15n3 C768r15n3.csh
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=49 --job-name=C768 C768.csh
sbatch ${SBATCHARGS} --time=00:04:00 --nodes=20 --job-name=C48n4 C48n4.csh
sbatch ${SBATCHARGS} --time=00:10:00 --nodes=5 --job-name=C48_res C48_res.csh
sbatch ${SBATCHARGS} --time=00:10:00 --nodes=5 --job-name=C48_test C48_test.csh
sbatch ${SBATCHARGS} --time=03:00:00 --nodes=298 --job-name=X-SHiELD C3072_res.csh
sbatch ${SBATCHARGS} --time=00:20:00 --nodes=74 --job-name=C384 C384.csh
