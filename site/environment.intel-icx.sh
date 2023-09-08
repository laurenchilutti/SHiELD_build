#!/bin/sh
#***********************************************************************
#*                   GNU Lesser General Public License
#*
#* This file is part of the SHiELD Build System.
#*
#* The SHiELD Build System free software: you can redistribute it
#* and/or modify it under the terms of the
#* GNU Lesser General Public License as published by the
#* Free Software Foundation, either version 3 of the License, or
#* (at your option) any later version.
#*
#* The SHiELD Build System distributed in the hope that it will be
#* useful, but WITHOUT ANYWARRANTY; without even the implied warranty
#* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#* See the GNU General Public License for more details.
#*
#* You should have received a copy of the GNU Lesser General Public
#* License along with theSHiELD Build System
#* If not, see <http://www.gnu.org/licenses/>.
#***********************************************************************
#
#  DISCLAIMER: This script is provided as-is and as such is unsupported.
#


hostname=`hostname`

case $hostname in
   gaea5? | c5n* )
      echo " gaea C5 environment "

      . ${MODULESHOME}/init/sh
      module unload PrgEnv-pgi PrgEnv-intel PrgEnv-gnu
      module load   PrgEnv-intel
      module rm intel-classic
      module rm intel-oneapi
      module rm intel
      module rm gcc
      module load python/3.9
      module load cmake/3.23.1
      module load libyaml/0.2.5
      module load intel/2023.1.0
      module unload cray-libsci
      module load cray-hdf5
      module load cray-netcdf
      module load craype-hugepages4M

      # Add -DHAVE_GETTID to the FMS cppDefs
      export FMS_CPPDEFS=-DHAVE_GETTID

      # make your compiler selections here
      export FC=ftn
      export CC=cc
      export CXX=CC
      export LD=ftn
      export TEMPLATE=site/intel-icx.mk
      export LAUNCHER=srun

      # highest level of AVX support
      export AVX_LEVEL=-march=core-avx2
      echo -e ' '
      module list
      ;;
   * )
      echo " no environment available based on the hostname "
      ;;
esac

