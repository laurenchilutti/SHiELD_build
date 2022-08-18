#!/bin/tcsh

module load fre/bronx-19

echo "This script compares RESTARTS"

set C768 = "n"
set C768RES = "20160801.00Z.C768.nh.32bit.non-mono.C768/rundir/RESTART"

set C768r15n3 = "n"
set C768r15n3RES = "20170501.00Z.C768r15n3_hwt.nh.32bit.non-monoC768r15n3/rundir/RESTART"

set C48_RES = "y"
set C48_RESRES = "20160801.00Z.C48.nh.32bit.non-mono.C48_res/restart/tmp*"

set REGIONAL = "y"
set REGIONALRES = "20170114.00Z.C3072_alaska.nh.32bit.non-monoRegional3km/restart/tmp*"

set C48n4 = "y"
set C48n4RES = "20150801.00Z.C48n4.nh.32bit.non-mono.C48n4/rundir/RESTART"

set C48_4n2 = "n"
set C48_4n2RES = "20200826.12Z.C48.nh.32bit.non-mono.C48_4n2/rundir/RESTART"

source fms_test.csh
set OLDDIR = ${SCRATCH}/${USER}/SHiELD_${COMPILER}_202203alpha1_${BIT}

set NEWDIR = ${SCRATCH}/${USER}/SHiELD_${COMPILER}_${DESCRIPTOR}_${BIT}

if ( $C768 == "y" ) then
  cd $OLDDIR/$C768RES
  echo "C768"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$C768RES/$FILE
  end
endif

if ( $C768r15n3 == "y" ) then
  cd $OLDDIR/$C768r15n3RES
  echo "C768r15n3"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$C768r15n3RES/$FILE
  end
endif

if ( $C48_RES == "y" ) then
  cd $OLDDIR/$C48_RESRES
  echo "C48_res"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$C48_RESRES/$FILE
  end
endif

if ( $REGIONAL == "y" ) then
  cd $OLDDIR/$REGIONALRES
  echo "Regional_3km"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$REGIONALRES/$FILE
  end
endif

if ( $C48n4 == "y" ) then
  cd $OLDDIR/$C48n4RES
  echo "C48n4"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$C48n4RES/$FILE
  end
endif

if ( $C48_4n2 == "y" ) then
  cd $OLDDIR/$C48_4n2RES
  echo "C48_4n2"
  foreach FILE ( *.nc )
      echo "Comparing ${FILE}"
      nccmp -df $FILE $NEWDIR/$C48_4n2RES/$FILE
  end
endif
