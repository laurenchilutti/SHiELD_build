#!/bin/bash


export EXTERNAL_LIBS=/ncrc/home1/Lauren.Chilutti/SHiELD_dev/SHiELD_build/Build/c52023.03-alpha1


#./BUILDlibfms gnu &
#./BUILDlibfms intel
#./BUILDnceplibs gnu &
#./BUILDnceplibs intel
./BUILDlibfms intel-icx
./BUILDnceplibs intel
cp -rf $EXTERNAL_LIBS/nceplibs/intel $EXTERNAL_LIBS/nceplibs/intel-icx


#./COMPILE clean repro 32bit gnu &
#./COMPILE clean repro 32bit intel
./COMPILE clean repro 32bit intel-icx

#./COMPILE clean repro 64bit solo nh gnu &
#./COMPILE clean repro 64bit solo nh intel
./COMPILE clean repro 64bit solo nh intel-icx
#./COMPILE clean repro 64bit solo sw gnu &
#./COMPILE clean repro 64bit solo sw intel
./COMPILE clean repro 64bit solo sw intel-icx
#./COMPILE clean repro 64bit solo hydro gnu &
#./COMPILE clean repro 64bit solo hydro intel
./COMPILE clean repro 64bit solo hydro intel-icx
