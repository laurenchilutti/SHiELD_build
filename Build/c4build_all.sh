#!/bin/bash


export EXTERNAL_LIBS=/ncrc/home1/Lauren.Chilutti/SHiELD_dev/SHiELD_build/Build/c42023.02-alpha3

./BUILDlibfms
./BUILDnceplibs

./COMPILE clean repro 32bit intel
cp bin/SHiELD_nh.repro.32bit.intel.x bin/c4/.
#./COMPILE clean repro 32bit gnu &

./COMPILE clean repro 64bit solo nh intel 
cp bin/SOLO_nh.repro.64bit.intel.x bin/c4/.
#./COMPILE clean repro 64bit solo nh gnu &
./COMPILE clean repro 64bit solo sw intel 
cp bin/SOLO_sw.repro.64bit.intel.x bin/c4/.
#./COMPILE clean repro 64bit solo sw gnu &
./COMPILE clean repro 64bit solo hydro intel 
cp bin/SOLO_hydro.repro.64bit.intel.x bin/c4/.
#./COMPILE clean repro 64bit solo hydro gnu &
