#!/bin/tcsh
#SBATCH --output=/work/noaa/gfdlscr/jmoualle/public/SHiELD_build/RTS/ORION_RTS/stdout/%x.o%j
#SBATCH --job-name=test_regional_C192_nest_3n4
#SBATCH --partition=orion
#SBATCH --account=gfdlhires
#SBATCH --time=00:59:00
#SBATCH --ntasks=800
##SBATCH --nodes=10


source ${MODULESHOME}/init/tcsh
module load intel/2020
module load netcdf/
module load hdf5/
module load impi/2020

# BUILD DIRECTORY
set BUILD_AREA = "/work/noaa/gfdlscr/jmoualle/public/SHiELD_build/"

#set BUILD_AREA = "~${USER}/public_SHiELD/SHiELD_build/"
unlimit
set echo
set CRES=C192
#set GRIDTYPE=REG_C3640
# Input directory
set INPUT_DATA = "/work/noaa/gfdlscr/pdata/gfdl/SHiELD/INPUT_DATA/"
# release number for the script
set RELEASE = 'v202101'#'R_SHiELD_202004_NEST' #"`cat ${BUILD_AREA}/release`"

# case specific details
set TYPE = "nh"          # choices:  nh, hydro
set MODE = "32bit"       # choices:  32bit, 64bit
set MONO = "non-mono"        # choices:  mono, non-mono
set MEMO = "$SLURM_JOB_NAME"
set MEMO = "test4"
if ( $?SLURM_JOB_ID > 0) then
  set CASE = `scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}'`
else
  set CASE = $0
endif
set CASE = `basename $CASE | rev | cut -c5- | rev`

if (! $?DATE) then
  set DATE=20190502.00Z
  set DATE=20200902.00Z
endif
set HYPT = "on"         # choices:  on, off  (controls hyperthreading)
set COMP = "repro"       # choices:  debug, repro, prod
#set COMP = "debug"       # choices:  debug, repro, prod
set NO_SEND = "no_send"  # choices:  send, no_send


# changeable parameters
# dycore definitions
#set npx = "2161"
#set npy = "1201"
set npx = "163"
set npy = "163"
set npz = "63"
#Reduced PEs; use a different layout/io_layout/blocksize for 3456 setup
set layout_x = "9" 
set layout_y = "6" 
set io_layout = "1,1"
set nthreads = "2" 

########### NEST
    set num_nest = "3"
    set npx_nest = (165 201 153)           #########249 465
    set npy_nest = (317 201 473)
#    set npx_nest = (77)           #########use if grid_spec is uncommented on the nest
 #   set npy_nest = (153)
    set layout_x_nest = (12 11 15)
    set layout_y_nest = (15 11 15) 
#    set layout_x_nest = (4 4 4)
#    set layout_y_nest = (4 4 5) 
    set io_layout_x_nest = (1 1 1)
    set io_layout_y_nest = (1 1 1)
set blocksize_nest = (32 32 32)


# blocking factor used for threading and general physics performance
set blocksize = "20"

# run length
set months = "0"
set days = "1"
set hours = "0" 
set minutes = "0"
set seconds = "90"
set dt_atmos = "90"
set nruns = 1
if (! $?irun) then
  set irun = 1
endif

# set the pre-conditioning of the solution
# =0 implies no pre-conditioning
# >0 means new adiabatic pre-conditioning
# <0 means older adiabatic pre-conditioning
set na_init = 0

# whether to initialize the nonhyrostatic state (recomputing dz)
set make_nh = ".F."

# variables for controlling initialization of NCEP/NGGPS ICs
set filtered_terrain = ".true."
set ncep_levs = "64"

# variables for gfs diagnostic output intervals and time to zero out time-accumulated data
#    set fdiag = "6.,12.,18.,24.,30.,36.,42.,48.,54.,60.,66.,72.,78.,84.,90.,96.,102.,108.,114.,120.,126.,132.,138.,144.,150.,156.,162.,168.,174.,180.,186.,192.,198.,204.,210.,216.,222.,228.,234.,240."
set fdiag = "1."
set fhzer = "1."
set fhcyc = "24."


# set various debug options
set no_dycore = ".F."
set dycore_only = ".F."
set chksum_debug = ".false."
set print_freq = "120"

# time steps
set k_split = "4"
set n_split = "5" 

      set k_split_nest = (2 2 2)    # array ?!?# 1 2 3
      set n_split_nest = (10 10 10) # 12 11 10

set EXE = x

# directory structure
#set BASEDIR    = "/lustre/f2/scratch/${USER}/NGGPS"
set BASEDIR    = "/work/noaa/gfdlscr/${USER}/"
set TABLEDIR = /ncrc/home2/Kai-yuan.Cheng/REGIONAL2/fv3_gfs_build/FV3GFS/RUN/REGIONAL/SHiELD_runscript_kyc/tables
set TABLEDIR = /home/jmoualle/tables 
set WORKDIR    = ${BASEDIR}/${RELEASE}/${DATE}.${TYPE}.${MEMO}.${MODE}/
set executable = ${BUILD_AREA}/Build/bin/SHiELD_${TYPE}.${COMP}.${MODE}.${EXE}


# input filesets
#set ICBASE  = /lustre/f2/dev/Kai-yuan.Cheng/SHiELD_IC/${GRIDTYPE} 
set ICBASE  = /work/noaa/gfdlscr/pdata/gfdl/gfdl_W/jmoualle/Regional_C192_nest_3n4/ 
set ICDIR   = ${ICBASE}/${DATE}_IC
set ICDIR   = ${ICBASE}/${DATE}_IC
set ICS     = ${ICDIR}/GFS_INPUT.tar
set FIXDIR  = /lustre/f2/pdata/gfdl/gfdl_W/Kai-yuan.Cheng/UFS_UTILS/fix/fix_am
set FIXDIR  = /work/noaa/gfdlscr/pdata/gfdl/gfdl_W/jmoualle/fix_am 
#set MLDFIX  = /lustre/f2/pdata/gfdl/gfdl_W/fvGFS_INPUT_DATA/climo_data.v201807/mld/mld_DR003_c1m_reg2.0.grb
set MLDFIX  = /work/noaa/gfdlscr/pdata/gfdl/gfdl_W/kcheng/fvGFS_INPUT_DATA/climo_data.v201910/mld/mld_DR003_c1m_reg2.0.grb
set GRIDDIR = ${ICBASE}/GRID/
set FIX_sfc = ${WORKDIR}/rundir

set FIX = ${INPUT_DATA}/fix.v201810
# sending file to gfdl
set gfdl_archive = /archive/${USER}/NGGPS/${RELEASE}/${DATE}.${CASE}/
set SEND_FILE =  /ncrc/home2/Kai-yuan.Cheng/Util/send_file_slurm.csh
set TIME_STAMP = /autofs/mnt/ncrc-svm1_home1/Jan-Huey.Chen/Util/time_stamp.csh


# mpi and hyperthreading
if (${HYPT} == "on") then
  set hyperthread = ".true."
  set div = 2
else
  set hyperthread = ".false."
  set div = 1
endif




    @ npes_g1 = ${layout_x} * ${layout_y}


##################################################################################
##################################################################################
set npes_nest = (0 0 0)   #array, grid_pes, size num_nest
set npes_nest_total = 0
set counter = 1

while ($counter <= $num_nest)
     @ npes_nest[$counter] = (${layout_x_nest[$counter]} * ${layout_y_nest[$counter]})
     @ npes_nest_total += $npes_nest[$counter]
     @ counter++
end
##################################################################################
##################################################################################









@ skip = ${nthreads} / ${div}
@ npes = ${npes_g1} + ${npes_nest_total}




set run_cmd = "srun --ntasks=$npes --cpus-per-task=$skip ./$executable:t"


setenv MPICH_ENV_DISPLAY
setenv MPICH_MPIIO_CB_ALIGN 2
setenv MALLOC_MMAP_MAX_ 0
setenv MALLOC_TRIM_THRESHOLD_ 536870912
setenv NC_BLKSZ 1M
# necessary for OpenMP when using Intel
    setenv KMP_STACKSIZE 256m
    setenv SLURM_CPU_BIND verbose


# build the date for curr_date and diag_table from DATE
unset echo
set y = `echo ${DATE} | cut -c1-4`
set m = `echo ${DATE} | cut -c5-6`
set d = `echo ${DATE} | cut -c7-8`
set h = `echo ${DATE} | cut -c10-11`
set echo
set curr_date = "${y},${m},${d},${h},0,0"


if ( $irun == 1 ) then

  # create folders for initial run
  rm -rf $WORKDIR
  mkdir -p $WORKDIR/rundir

  cd $WORKDIR/rundir
  mkdir RESTART
  mkdir INPUT

  # copy executable
  ln -s $executable .

  # GFS standard input data
  ln -sf $FIXDIR/ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77 INPUT/global_o3prdlos.f77
  ln -sf $FIXDIR/global_h2o_pltc.f77 INPUT/global_h2oprdlos.f77
  ln -sf $FIXDIR/global_solarconstant_noaa_an.txt INPUT/solarconstant_noaa_an.txt
  ln -sf $FIXDIR/global_sfc_emissivity_idx.txt INPUT/sfc_emissivity_idx.txt
  ln -sf $FIXDIR/global_co2historicaldata_glob.txt INPUT/co2historicaldata_glob.txt
  ln -sf $FIXDIR/co2monthlycyc.txt INPUT/co2monthlycyc.txt
  foreach file ( $FIXDIR/fix_co2_proj/global_co2historicaldata_????.txt )
    ln -sf $file INPUT/`echo $file:t | sed s/global_co2historicaldata/co2historicaldata/g`
  end
  ln -sf $FIXDIR/global_climaeropac_global.txt INPUT/aerosol.dat
  foreach file ( $FIXDIR/global_volcanic_aerosols_????-????.txt )
    ln -sf $file INPUT/`echo $file:t | sed s/global_volcanic_aerosols/volcanic_aerosols/g`
  end


  # Grid and orography data
  ln -s ${GRIDDIR}/* INPUT/


  ln -sf $GRIDDIR/fix_sfc/${CRES}.vegetation_greenness.tile7.halo0.nc  $FIX_sfc/${CRES}.vegetation_greenness.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.soil_type.tile7.halo0.nc             $FIX_sfc/${CRES}.soil_type.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.slope_type.tile7.halo0.nc            $FIX_sfc/${CRES}.slope_type.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.substrate_temperature.tile7.halo0.nc $FIX_sfc/${CRES}.substrate_temperature.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.facsf.tile7.halo0.nc                 $FIX_sfc/${CRES}.facsf.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.maximum_snow_albedo.tile7.halo0.nc   $FIX_sfc/${CRES}.maximum_snow_albedo.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.snowfree_albedo.tile7.halo0.nc       $FIX_sfc/${CRES}.snowfree_albedo.tile1.nc
  ln -sf $GRIDDIR/fix_sfc/${CRES}.vegetation_type.tile7.halo0.nc       $FIX_sfc/${CRES}.vegetation_type.tile1.nc

  # Date specific ICs (still a tarball)
  if ( -e ${ICS} ) then
    tar xf ${ICS}
  else
    ln -s ${ICDIR}/* INPUT/
  endif
##############################################################
##############################################################
  mv INPUT/sfc_data.tile7.nc INPUT/sfc_data.nc
#  mv INPUT/gfs_data.tile7.nc INPUT/gfs_data.nc
  cp INPUT/gfs_data.tile7.nc INPUT/gfs_data.tile1.nc
  cp INPUT/gfs_data.tile1.nc INPUT/gfs_data.nc



#  cp INPUT/gfs_data.tile8.nc INPUT/gfs_data.nest02.tile2.nc
#  cp INPUT/C192_grid.tile8.nc INPUT/C192_grid.nest02.tile2.nc
#  cp INPUT/C192_grid.tile8.nc INPUT/C192_grid.tile2.nc
#  cp INPUT/sfc_data.tile8.nc INPUT/sfc_data.nest02.tile2.nc
#  cp INPUT/C192_oro_data.tile8.nc INPUT/oro_data.tile8.nc
#  cp INPUT/C192_oro_data.tile8.nc INPUT/oro_data.nest02.tile2.nc
#  cp INPUT/C192_oro_data.tile8.nc INPUT/C192_oro_data.nest02.tile2.nc


foreach i ( $PWD/INPUT/*.tile8.nc )
    ln -s $i ${i:r:r}.nest02.tile2.nc
end

  cp INPUT/C192_oro_data.tile8.nc INPUT/oro_data.nest02.tile2.nc

foreach i ( $PWD/INPUT/*.tile9.nc )
    ln -s $i ${i:r:r}.nest03.tile3.nc
end
  cp INPUT/C192_oro_data.tile9.nc INPUT/oro_data.nest03.tile3.nc

foreach i ( $PWD/INPUT/*.tile10.nc )
    ln -s $i ${i:r:r}.nest04.tile4.nc
end
  cp INPUT/C192_oro_data.tile10.nc INPUT/oro_data.nest04.tile4.nc

  #cp INPUT/gfs_data.tile10.nc INPUT/gfs_data.nest04.tile4.nc



  cp INPUT/${CRES}_mosaic.nc INPUT/grid_spec.nc

  ln -s ${CRES}_grid.tile7.halo3.nc INPUT/${CRES}_grid.tile7.nc
  ln -s ${CRES}_grid.tile7.halo3.nc INPUT/${CRES}_grid.tile1.nc
  ln -s ${CRES}_grid.tile7.halo4.nc INPUT/grid.tile7.halo4.nc
  ln -s ${CRES}_grid.tile7.halo4.nc INPUT/grid.tile1.halo4.nc


  ln -s ${CRES}_oro_data.tile7.halo0.nc INPUT/oro_data.nc
  ln -s ${CRES}_oro_data.tile7.halo0.nc INPUT/oro_data.tile1.nc
  ln -s ${CRES}_oro_data.tile7.halo4.nc INPUT/oro_data.tile7.halo4.nc
  ln -s ${CRES}_oro_data.tile7.halo4.nc INPUT/oro_data.tile1.halo4.nc


# NEST
#foreach i ( $PWD/INPUT/*.tile8.nc )
#    ln -s $i ${i:r:r}.nest02.tile8.nc
#end




  set nggps_ic = ".T."
  set mountain = ".F."
  set external_ic = ".T."
  set warm_start = ".F."

else

  cd $WORKDIR/rundir

  # move the restart data into INPUT/
  mv RESTART/* INPUT/.

  # reset values in input.nml for restart run
  set make_nh = ".F."
  set nggps_ic = ".F."
  set mountain = ".T."
  set external_ic = ".F."
  set warm_start = ".T."
  set na_init = 0

endif







cp INPUT/aerosol.dat .
cp INPUT/co2historicaldata_20*.txt .
cp INPUT/sfc_emissivity_idx.txt .
cp INPUT/solarconstant_noaa_an.txt .







#
# write tables and namlist
#

# build the diag_table with the experiment name and date stamp
cat >! diag_table << EOF
${DATE}.${CASE}.${MODE}.${MONO}
$y $m $d $h 0 0 
EOF
cat ${TABLEDIR}/diag_table_hwt_simple1 >> diag_table

# field_table
cp ${TABLEDIR}/field_table_6species_tke field_table
#cp ${TABLEDIR}/field_table_6species_tke field_table

cp ${BUILD_AREA}/RUN/RETRO/data_table data_table
#cp ${BUILD_AREA}/RUN/RETRO/diag_table_no3d diag_table
#cp ${BUILD_AREA}/RUN/RETRO/diag_table_okc_hindcasts22 diag_table
#cp ${BUILD_AREA}/RUN/RETRO/diag_table_hwt diag_table
cp ${BUILD_AREA}/RUN/RETRO/field_table_6species field_table


# create an empty data_table
cat >! data_table << EOF
EOF
set twoway= (.T. .T. .T.)
#namlist for global domain
cat >! input.nml <<EOF
 &amip_interp_nml
     interp_oi_sst = .true.
     use_ncep_sst = .true.
     use_ncep_ice = .false.
     no_anom_sst = .false.
     data_set = 'reynolds_oi',
     date_out_of_range = 'climo',
/

 &atmos_model_nml
     blocksize = $blocksize
     chksum_debug = $chksum_debug
     dycore_only = $dycore_only
     fdiag = $fdiag
     first_time_step = .false.

/


 &diag_manager_nml
     flush_nc_files = .false.
     prepend_date = .F.
/

 &fms_io_nml
       checksum_required   = .false.
       max_files_r = 100,
       max_files_w = 100,
/

&fms_affinity_nml
 affinity=.false.
/

 &fms_nml
       clock_grain = 'ROUTINE',
       domains_stack_size = 30000000,
       print_memory_usage = .F.
/

 &fv_grid_nml
       grid_file = 'INPUT/grid_spec.nc' ! This line is IMPORTANT for regional model
/

 &fv_core_nml
       layout   = $layout_x,$layout_y
       io_layout = $io_layout
       npx      = $npx
       npy      = $npy
       ntiles   = 1,
       npz    = $npz
       grid_type = 0
       make_nh = $make_nh
       fv_debug = .F.
       range_warn = .F.
       reset_eta = .F.
       n_sponge = 30
       nudge_qv = .T.
       rf_fast = .F.
       tau = 5.
       rf_cutoff = 7.5e2
       d2_bg_k1 = 0.20
       d2_bg_k2 = 0.15
       kord_tm = -11
       kord_mt =  11
       kord_wz =  11
       kord_tr =  11
       hydrostatic = .F.
       phys_hydrostatic = .F.
       use_hydro_pressure = .F.
       beta = 0.
       a_imp = 1.
       p_fac = 0.1
       k_split  = $k_split
       n_split  = $n_split
       nwat = 6 
       na_init = $na_init
       d_ext = 0.0
       dnats = 2
       fv_sg_adj = 600
       d2_bg = 0.
       nord =  3
       dddmp = 0.1
       d4_bg = 0.12 
       vtdm4 = 0.02
       delt_max = 0.002
       ke_bg = 0.
       do_vort_damp = .true.
       external_ic = $external_ic
       nggps_ic = $nggps_ic
       mountain = $mountain
       ncep_ic = .F.
       d_con = 1.0
       hord_mt = 6
       hord_vt = 6
       hord_tm = 6
       hord_dp = 6
       hord_tr = -5
       lim_fac = 3.0
       adjust_dry_mass = .F.
       consv_te = 0.0
       do_sat_adj = .F.
       do_inline_mp = .T.
       consv_am = .F.
       fill = .T.
       dwind_2d = .F.
       print_freq = $print_freq
       warm_start = $warm_start
       no_dycore = $no_dycore
       z_tracer = .T.
       fill = .T.
!       write_3d_diags = .T.
       regional = .true.
       bc_update_interval = 6
/



&fv_nest_nml
    !num_nest        = $num_nest
    grid_pes        = $npes_g1 $npes_nest   ! npes_nest is an array pes for the nestss, fortran ok
    tile_coarse     = 0, 1 , 1 , 2     
    num_tile_top     = 1
    nest_refine     = 0, 4,4,4
    nest_ioffsets  = 999, 11,76,38 
    nest_joffsets  = 999, 16,76,63 
    p_split = 1
/




 &coupler_nml
       months = $months
       days  = $days
       hours = $hours
       minutes = $minutes
       seconds = $seconds
       dt_atmos = $dt_atmos
       dt_ocean = $dt_atmos
       current_date =  $curr_date
       calendar = 'julian'
       memuse_verbose = .false.
       atmos_nthreads = $nthreads
       use_hyper_thread = $hyperthread
/

 &external_ic_nml 
       filtered_terrain = .T.
       levp = $ncep_levs
       gfs_dwinds = .T.
       checker_tr = .F.
       nt_checker = 0
/

 &gfs_physics_nml
       fhzero         = $fhzer
       ldiag3d        = .false.
       fhcyc          = $fhcyc
       nst_anl        = .true.
       use_ufo        = .true.
       pre_rad        = .false.
       ncld           = 5
       zhao_mic       = .false.
       pdfcld         = .true. !Enabled---ljz
       fhswr          = 1200.
       fhlwr          = 1200.
       ialb           = 1
       iems           = 1
       IAER           = 111
       ico2           = 2
       isubc_sw       = 2
       isubc_lw       = 2
       isol           = 2
       lwhtr          = .true.
       swhtr          = .true.
       cnvgwd         = .false.
       shal_cnv       = .true.
       cal_pre        = .false.
       redrag         = .true.
       dspheat        = .true.
       hybedmf        = .f.
       random_clds    = .false.
       trans_trac     = .true.
       cnvcld         = .false.
       imfshalcnv     = 2
       imfdeepcnv     = 2
       cdmbgwd        = 3.5, 0.25
       prslrd0        = 0.
       ivegsrc        = 1
       isot           = 1
       debug          = .false.
       do_deep        = .true.
       xkzminv        = 1.0
       do_ocean       = .t. ! problem??
       ysupbl         = .false.
       !satmedmf       = .true.
       !isatmedmf      = 1
       cloud_gfdl     = .true. !Enabled---ljz                                                                                 
       do_inline_mp   = .true.
       xkzminv        = 1.0  ! restored
       xkzm_h         = 0.01 ! LJZ/SJL suggestion
       xkzm_m         = 0.01 
       gwd_p_crit     = 50.e2
       do_z0_hwrf17_hwonly = .true.
/


 &ocean_nml ! 201907: from SHiELD 2019 RT
     mld_option       = "obs"
     ocean_option     = "MLM" ! Ocean mixed layer model or SOM
     restore_method   = 2
     mld_obs_ratio    = 1.
     use_old_mlm      = .true. ! use the MLM similar to WRF
     stress_ratio     = 0.75   ! how much of actual wind stress is applied to ocean
     Gam              = 0.05   ! temperature lapse rate
     use_rain_flux    = .true. ! use rainfall induced cooling flux
     do_mld_restore   = .true.
     sst_restore_tscale = 15.
     mld_restore_tscale = 5.   ! 2019: more realistic value; does nothing without do_mld_restore
     start_lat        = -45.
     end_lat          = 45.
     eps_day          = 10.
 /

&gfdl_mp_nml
       sedi_transport = .true.
       do_sedi_w = .true.
       do_sedi_heat = .false.
       disp_heat = .true.
       rad_snow = .true.
       rad_graupel = .true.
       rad_rain = .true.
       const_vi = .F.
       const_vs = .F.
       const_vg = .F.
       const_vr = .F.
       vi_fac = 1.0 ! for non-constant
       vi_max = 1.0  ! increased
       vs_max = 6.0  ! increased
       vg_max = 12. ! increased
       vr_max = 12. ! increased
       qi_lim = 2. ! old Fast MP
       prog_ccn = .false.
       do_qa = .true.
       !do_sat_adj = .F.
       tau_l2v = 180
       tau_v2l =  22.5
       tau_g2v = 900.
       rthresh = 10.0e-6  ! This is a key parameter for cloud water ! use 10 for shallow conv
       dw_land  = 0.16
       dw_ocean = 0.10
       ql_gen = 1.0e-3
       ql_mlt = 1.0e-3
       qi0_crt = 7.5e-5    ! Increased for very high resolution
       qs0_crt = 1.0e-2 ! reduce snow --> graupel AC
       tau_i2s = 1000.   !ice to snow autoconversion time
       c_psaci = 0.05   ! Increased
       c_pgacs = 0.2 ! reduced rain --> graupel accretion
       c_cracw = 0.75
       rh_inc = 0.30
       rh_inr = 0.30
       rh_ins = 0.30
       ccn_l = 300.
       ccn_o = 100.
       use_ppm = .T.
       use_ccn = .true.
       z_slope_liq = .true.
       z_slope_ice = .true.
       fix_negative = .true.
       icloud_f = 0
       !do_cld_adj = .true.
       !f_dq_p = 3.0
/


 &cld_eff_rad_nml
       qmin = 1.0e-12
       beta = 1.22
       rewflag = 1
       reiflag = 5
       rewmin = 5.0
       rewmax = 15.0
       reimin = 10.0
       reimax = 150.0
       rermin = 15.0
       rermax = 10000.0
       resmin = 150.0
       resmax = 10000.0
       liq_ice_combine = .false.


  &interpolator_nml
       interp_method = 'conserve_great_circle'
/

&namsfc
       FNGLAC   = "$FIX/global_glacier.2x2.grb",
       FNMXIC   = "$FIX/global_maxice.2x2.grb",
       FNTSFC   = "$FIX/RTGSST.1982.2012.monthly.clim.grb",
       FNSNOC   = "$FIX/global_snoclim.1.875.grb",
       FNZORC   = "igbp",
       FNALBC   = "$FIX/global_snowfree_albedo.bosu.t1534.3072.1536.rg.grb",
       FNALBC2  = "$FIX/global_albedo4.1x1.grb",
       FNAISC   = "$FIX/CFSR.SEAICE.1982.2012.monthly.clim.grb",
       FNTG3C   = "$FIX/global_tg3clim.2.6x1.5.grb",
       FNVEGC   = "$FIX/global_vegfrac.0.144.decpercent.grb",
       FNVETC   = "$FIX/global_vegtype.igbp.t1534.3072.1536.rg.grb",
       FNSOTC   = "$FIX/global_soiltype.statsgo.t1534.3072.1536.rg.grb",
       FNSMCC   = "$FIX/global_soilmgldas.t1534.3072.1536.grb",
       FNMSKH   = "$FIX/seaice_newland.grb",
       FNTSFA   = "",
       FNACNA   = "",
       FNSNOA   = "",
       FNVMNC   = "$FIX/global_shdmin.0.144x0.144.grb",
       FNVMXC   = "$FIX/global_shdmax.0.144x0.144.grb",
       FNSLPC   = "$FIX/global_slope.1x1.grb",
       FNABSC   = "$FIX/global_mxsnoalb.uariz.t1534.3072.1536.rg.grb",
       LDEBUG   =.false.,
       FSMCL(2) = 99999
       FSMCL(3) = 99999
       FSMCL(4) = 99999
       FTSFS    = 90
       FAISS    = 99999
       FSNOL    = 99999
       FSICL    = 99999
       FTSFL    = 99999,
       FAISL    = 99999,
       FVETL    = 99999,
       FSOTL    = 99999,
       FvmnL    = 99999,
       FvmxL    = 99999,
       FSLPL    = 99999,
       FABSL    = 99999,
       FSNOS    = 99999,
       FSICS    = 99999,
/

!&namsfc
!       FNGLAC   = "$FIXDIR/global_glacier.2x2.grb",
!       FNMXIC   = "$FIXDIR/global_maxice.2x2.grb",
!       FNTSFC   = "$FIXDIR/RTGSST.1982.2012.monthly.clim.grb",
!       FNSNOC   = "$FIXDIR/global_snoclim.1.875.grb",
!       FNZORC   = "igbp",
!       FNALBC   = "$FIX_sfc/${CRES}.snowfree_albedo.tile1.nc",
!       !FNALBC   = "$FIX_sfc/${CRES}.snowfree_albedo.tileX.nc",
!       !FNALBC2  = "$FIX_sfc/${CRES}.facsf.tile1.nc",
!       FNALBC2  = "$FIX_sfc/${CRES}.facsf.tileX.nc",
!       FNAISC   = "$FIXDIR/CFSR.SEAICE.1982.2012.monthly.clim.grb",
!       FNTG3C   = "$FIX_sfc/${CRES}.substrate_temperature.tile1.nc",
!       FNVEGC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNVETC   = "$FIX_sfc/${CRES}.vegetation_type.tile1.nc",
!       FNSOTC   = "$FIX_sfc/${CRES}.soil_type.tile1.nc",
!       !FNTG3C   = "$FIX_sfc/${CRES}.substrate_temperature.tileX.nc",
!       !FNVEGC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNVETC   = "$FIX_sfc/${CRES}.vegetation_type.tileX.nc",
!       !FNSOTC   = "$FIX_sfc/${CRES}.soil_type.tileX.nc",
!       FNSMCC   = "$FIXDIR/global_soilmgldas.t1534.3072.1536.grb",
!       FNMSKH   = "$FIXDIR/seaice_newland.grb",
!       FNTSFA   = "",
!       FNACNA   = "",
!       FNSNOA   = "",
!       FNVMNC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNVMXC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNSLPC   = "$FIX_sfc/${CRES}.slope_type.tile1.nc",
!       FNABSC   = "$FIX_sfc/${CRES}.maximum_snow_albedo.tile1.nc",
!       !FNVMNC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNVMXC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNSLPC   = "$FIX_sfc/${CRES}.slope_type.tileX.nc",
!       !FNABSC   = "$FIX_sfc/${CRES}.maximum_snow_albedo.tileX.nc",
!       FNMLDC   = "$MLDFIX",
!       LDEBUG   =.false.,
!       FSMCL(2) = 99999
!       FSMCL(3) = 99999
!       FSMCL(4) = 99999
!       FTSFS    = 90
!       FAISS    = 99999
!       FSNOL    = 99999
!       FSICL    = 99999
!       FTSFL    = 99999,
!       FAISL    = 99999,
!       FVETL    = 99999,
!       FSOTL    = 99999,
!       FvmnL    = 99999,
!       FvmxL    = 99999,
!       FSLPL    = 99999,
!       FABSL    = 99999,
!       FSNOS    = 99999,
!       FSICS    = 99999,
!/
EOF







set counter = 0
set counterr = 0


while ($counter < $num_nest)


@ counter++
@ counterr = $counter + 1

cat >! input_nest0$counterr.nml <<EOF




 &amip_interp_nml
     interp_oi_sst = .true.
     use_ncep_sst = .true.
     use_ncep_ice = .false.
     no_anom_sst = .false.
     data_set = 'reynolds_oi',
     date_out_of_range = 'climo',
/

 &atmos_model_nml
     blocksize = $blocksize_nest[$counter]
     chksum_debug = $chksum_debug
     dycore_only = $dycore_only
     fdiag = $fdiag
     !first_time_step = .false.

/


 &diag_manager_nml
     flush_nc_files = .false.
     prepend_date = .F.
/

 &fms_io_nml
       checksum_required   = .false.
       max_files_r = 100,
       max_files_w = 100,
/

&fms_affinity_nml
 affinity=.false.
/

 &fms_nml
       clock_grain = 'ROUTINE',
       domains_stack_size = 300000000,
       print_memory_usage = .F.
/

 &fv_grid_nml
       !grid_file = 'INPUT/grid_spec.nc' ! This line is IMPORTANT for regional model
/

 &fv_core_nml
       layout   = $layout_x_nest[$counter], $layout_y_nest[$counter]    
       io_layout = $io_layout_x_nest[$counter], $io_layout_y_nest[$counter] 
       npx      = $npx_nest[$counter]
       npy      = $npy_nest[$counter]

       ntiles   = 1,
       npz    = $npz
       !grid_type = 0
       make_nh = $make_nh
       fv_debug = .F.
       range_warn = .F.
       reset_eta = .F.
       n_sponge = 4
       nudge_qv = .T.
       rf_fast = .F.
       tau = 3.
       !rf_cutoff = 7.5e2
       rf_cutoff = 8e2
       d2_bg_k1 = 0.20
       d2_bg_k2 = 0.15
       kord_tm = -11
       kord_mt =  11
       kord_wz =  11
       kord_tr =  11
       hydrostatic = .F.
       phys_hydrostatic = .F.
       use_hydro_pressure = .F.
       beta = 0.
       a_imp = 1.
       p_fac = 0.1
       k_split  = $k_split_nest[$counter]
       n_split  = $n_split_nest[$counter]

       nwat = 6 
       na_init = $na_init
       d_ext = 0.0
       dnats = 2
       fv_sg_adj = 200
       d2_bg = 0.
       nord =  2
       dddmp = 0.1
       d4_bg = 0.12 
       vtdm4 = 0.02
       delt_max = 0.002
       ke_bg = 0.
       do_vort_damp = .true.
       external_ic = $external_ic
       nggps_ic = $nggps_ic
       mountain = $mountain
       ncep_ic = .F.
       d_con = 0
       hord_mt = 6
       hord_vt = 6
       hord_tm = 6
       hord_dp = 6
       hord_tr = -5
       lim_fac = 3.0
       adjust_dry_mass = .F.
       consv_te = 0.0
       do_sat_adj = .F.
       do_inline_mp = .T.
       consv_am = .F.
       fill = .T.
       dwind_2d = .F.
       print_freq = $print_freq
       warm_start = $warm_start
       no_dycore = $no_dycore
       !z_tracer = .T.
       !fill = .T.
!       write_3d_diags = .T.

       twowaynest = $twoway[$counter] 
       nestupdate = 7

       full_zs_filter = .F.

/


 &coupler_nml
       months = $months
       days  = $days
       hours = $hours
       minutes = $minutes
       seconds = $seconds
       dt_atmos = $dt_atmos
       dt_ocean = $dt_atmos
       current_date =  $curr_date
       calendar = 'julian'
       memuse_verbose = .false.
       atmos_nthreads = $nthreads
       use_hyper_thread = $hyperthread
/

 &external_ic_nml 
       filtered_terrain = .T.
       levp = $ncep_levs
       gfs_dwinds = .T.
       checker_tr = .F.
       nt_checker = 0
/

 &gfs_physics_nml
       fhzero         = $fhzer
       ldiag3d        = .false.
       fhcyc          = $fhcyc
       nst_anl        = .true.
       use_ufo        = .true.
       pre_rad        = .false.
       ncld           = 5
       zhao_mic       = .false.
       pdfcld         = .true. !Enabled---ljz
       fhswr          = 1200.
       fhlwr          = 1200.
       ialb           = 1
       iems           = 1
       IAER           = 111
       ico2           = 2
       isubc_sw       = 2
       isubc_lw       = 2
       isol           = 2
       lwhtr          = .true.
       swhtr          = .true.
       cnvgwd         = .false.
       shal_cnv       = .true.
       cal_pre        = .false.
       redrag         = .true.
       dspheat        = .true.
       hybedmf        = .f.
       random_clds    = .false.
       trans_trac     = .true.
       cnvcld         = .false.
       imfshalcnv     = 2
       imfdeepcnv     = 2
       cdmbgwd        = 3.5, 0.25
       prslrd0        = 0.
       ivegsrc        = 1
       isot           = 1
       debug          = .false.
       do_deep        = .true.
       xkzminv        = 1.0
       do_ocean       = .t. ! problem??
       ysupbl         = .false.
       !satmedmf       = .true.
       !isatmedmf      = 1
       cloud_gfdl     = .true. !Enabled---ljz                                                                                 
       do_inline_mp   = .true.
       xkzminv        = 1.0  ! restored
       xkzm_h         = 0.01 ! LJZ/SJL suggestion
       xkzm_m         = 0.01 
       gwd_p_crit     = 50.e2
       do_z0_hwrf17_hwonly = .true.
/


 &ocean_nml ! 201907: from SHiELD 2019 RT
     mld_option       = "obs"
     ocean_option     = "MLM" ! Ocean mixed layer model or SOM
     restore_method   = 2
     mld_obs_ratio    = 1.
     use_old_mlm      = .true. ! use the MLM similar to WRF
     stress_ratio     = 0.75   ! how much of actual wind stress is applied to ocean
     Gam              = 0.05   ! temperature lapse rate
     use_rain_flux    = .true. ! use rainfall induced cooling flux
     do_mld_restore   = .true.
     sst_restore_tscale = 15.
     mld_restore_tscale = 5.   ! 2019: more realistic value; does nothing without do_mld_restore
     start_lat        = -45.
     end_lat          = 45.
     eps_day          = 10.
 /

&gfdl_mp_nml
       sedi_transport = .true.
       do_sedi_w = .true.
       do_sedi_heat = .false.
       disp_heat = .true.
       rad_snow = .true.
       rad_graupel = .true.
       rad_rain = .true.
       const_vi = .F.
       const_vs = .F.
       const_vg = .F.
       const_vr = .F.
       vi_fac = 1.0 ! for non-constant
       vi_max = 1.0  ! increased
       vs_max = 6.0  ! increased
       vg_max = 12. ! increased
       vr_max = 12. ! increased
       qi_lim = 2. ! old Fast MP
       prog_ccn = .false.
       do_qa = .true.
       !do_sat_adj = .F.
       tau_l2v = 180
       tau_v2l =  22.5
       tau_g2v = 900.
       rthresh = 10.0e-6  ! This is a key parameter for cloud water ! use 10 for shallow conv
       dw_land  = 0.16
       dw_ocean = 0.10
       ql_gen = 1.0e-3
       ql_mlt = 1.0e-3
       qi0_crt = 7.5e-5    ! Increased for very high resolution
       qs0_crt = 1.0e-2 ! reduce snow --> graupel AC
       tau_i2s = 1000.   !ice to snow autoconversion time
       c_psaci = 0.05   ! Increased
       c_pgacs = 0.2 ! reduced rain --> graupel accretion
       c_cracw = 0.75
       rh_inc = 0.30
       rh_inr = 0.30
       rh_ins = 0.30
       ccn_l = 300.
       ccn_o = 100.
       use_ppm = .T.
       use_ccn = .true.
       z_slope_liq = .true.
       z_slope_ice = .true.
       fix_negative = .true.
       icloud_f = 0
       !do_cld_adj = .true.
       !f_dq_p = 3.0
/


 &cld_eff_rad_nml
       qmin = 1.0e-12
       beta = 1.22
       rewflag = 1
       reiflag = 5
       rewmin = 5.0
       rewmax = 15.0
       reimin = 10.0
       reimax = 150.0
       rermin = 15.0
       rermax = 10000.0
       resmin = 150.0
       resmax = 10000.0
       liq_ice_combine = .false.


  &interpolator_nml
       interp_method = 'conserve_great_circle'
/

&namsfc
       FNGLAC   = "$FIX/global_glacier.2x2.grb",
       FNMXIC   = "$FIX/global_maxice.2x2.grb",
       FNTSFC   = "$FIX/RTGSST.1982.2012.monthly.clim.grb",
       FNSNOC   = "$FIX/global_snoclim.1.875.grb",
       FNZORC   = "igbp",
       FNALBC   = "$FIX/global_snowfree_albedo.bosu.t1534.3072.1536.rg.grb",
       FNALBC2  = "$FIX/global_albedo4.1x1.grb",
       FNAISC   = "$FIX/CFSR.SEAICE.1982.2012.monthly.clim.grb",
       FNTG3C   = "$FIX/global_tg3clim.2.6x1.5.grb",
       FNVEGC   = "$FIX/global_vegfrac.0.144.decpercent.grb",
       FNVETC   = "$FIX/global_vegtype.igbp.t1534.3072.1536.rg.grb",
       FNSOTC   = "$FIX/global_soiltype.statsgo.t1534.3072.1536.rg.grb",
       FNSMCC   = "$FIX/global_soilmgldas.t1534.3072.1536.grb",
       FNMSKH   = "$FIX/seaice_newland.grb",
       FNTSFA   = "",
       FNACNA   = "",
       FNSNOA   = "",
       FNVMNC   = "$FIX/global_shdmin.0.144x0.144.grb",
       FNVMXC   = "$FIX/global_shdmax.0.144x0.144.grb",
       FNSLPC   = "$FIX/global_slope.1x1.grb",
       FNABSC   = "$FIX/global_mxsnoalb.uariz.t1534.3072.1536.rg.grb",
       LDEBUG   =.false.,
       FSMCL(2) = 99999
       FSMCL(3) = 99999
       FSMCL(4) = 99999
       FTSFS    = 90
       FAISS    = 99999
       FSNOL    = 99999
       FSICL    = 99999
       FTSFL    = 99999,
       FAISL    = 99999,
       FVETL    = 99999,
       FSOTL    = 99999,
       FvmnL    = 99999,
       FvmxL    = 99999,
       FSLPL    = 99999,
       FABSL    = 99999,
       FSNOS    = 99999,
       FSICS    = 99999,
/

!&namsfc
!       FNGLAC   = "$FIXDIR/global_glacier.2x2.grb",
!       FNMXIC   = "$FIXDIR/global_maxice.2x2.grb",
!       FNTSFC   = "$FIXDIR/RTGSST.1982.2012.monthly.clim.grb",
!       FNSNOC   = "$FIXDIR/global_snoclim.1.875.grb",
!       FNZORC   = "igbp",
!       FNALBC   = "$FIX_sfc/${CRES}.snowfree_albedo.tile1.nc",
!       !FNALBC   = "$FIX_sfc/${CRES}.snowfree_albedo.tileX.nc",
!       !FNALBC2  = "$FIX_sfc/${CRES}.facsf.tile1.nc",
!       FNALBC2  = "$FIX_sfc/${CRES}.facsf.tileX.nc",
!       FNAISC   = "$FIXDIR/CFSR.SEAICE.1982.2012.monthly.clim.grb",
!       FNTG3C   = "$FIX_sfc/${CRES}.substrate_temperature.tile1.nc",
!       FNVEGC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNVETC   = "$FIX_sfc/${CRES}.vegetation_type.tile1.nc",
!       FNSOTC   = "$FIX_sfc/${CRES}.soil_type.tile1.nc",
!       !FNTG3C   = "$FIX_sfc/${CRES}.substrate_temperature.tileX.nc",
!       !FNVEGC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNVETC   = "$FIX_sfc/${CRES}.vegetation_type.tileX.nc",
!       !FNSOTC   = "$FIX_sfc/${CRES}.soil_type.tileX.nc",
!       FNSMCC   = "$FIXDIR/global_soilmgldas.t1534.3072.1536.grb",
!       FNMSKH   = "$FIXDIR/seaice_newland.grb",
!       FNTSFA   = "",
!       FNACNA   = "",
!       FNSNOA   = "",
!       FNVMNC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNVMXC   = "$FIX_sfc/${CRES}.vegetation_greenness.tile1.nc",
!       FNSLPC   = "$FIX_sfc/${CRES}.slope_type.tile1.nc",
!       FNABSC   = "$FIX_sfc/${CRES}.maximum_snow_albedo.tile1.nc",
!       !FNVMNC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNVMXC   = "$FIX_sfc/${CRES}.vegetation_greenness.tileX.nc",
!       !FNSLPC   = "$FIX_sfc/${CRES}.slope_type.tileX.nc",
!       !FNABSC   = "$FIX_sfc/${CRES}.maximum_snow_albedo.tileX.nc",
!       FNMLDC   = "$MLDFIX",
!       LDEBUG   =.false.,
!       FSMCL(2) = 99999
!       FSMCL(3) = 99999
!       FSMCL(4) = 99999
!       FTSFS    = 90
!       FAISS    = 99999
!       FSNOL    = 99999
!       FSICL    = 99999
!       FTSFL    = 99999,
!       FAISL    = 99999,
!       FVETL    = 99999,
!       FSOTL    = 99999,
!       FvmnL    = 99999,
!       FvmxL    = 99999,
!       FSLPL    = 99999,
!       FABSL    = 99999,
!       FSNOS    = 99999,
!       FSICS    = 99999,
!/
EOF




end














# run the executable
sleep 1

${run_cmd} | tee fms.out

# if model crashes, move restart files back.
if ( $? != 0 || `grep Main fms.out | wc -l ` != 1 ) then
  if ( $irun > 1 ) then
    mv ./INPUT/*.res* ./RESTART/
    mv ./INPUT/phy_data* ./RESTART/
    mv ./INPUT/sfc_data* ./RESTART/
  endif
  exit
endif

set irun = `expr $irun + 1`

# to avoid possibly strange behavior due to customized command
alias ls ls

# just organize the generated data without transfering to archive
if ($NO_SEND == "no_send") then
  cd $WORKDIR/rundir

  set begindate = `$TIME_STAMP -bhf digital`
  set enddate = `$TIME_STAMP -ehf digital`
  
  if ( $begindate == "" ) set begindate = tmp`date '+%j%H%M%S'`
  if ( $enddate == "" ) set enddate = tmp`date '+%j%H%M%S'`
  
  mkdir -p $WORKDIR/ascii/$begindate
  mv *.out *.results *.nml *_table $WORKDIR/ascii/$begindate

  mkdir -p $WORKDIR/history/$begindate
  mv *.nc* $WORKDIR/history/$begindate

  mkdir -p $WORKDIR/restart/$enddate
  mv RESTART/* $WORKDIR/restart/$enddate                                               
  ln -sf $WORKDIR/restart/$enddate/* RESTART/   

else

#########################################################################
# generate date for file names
########################################################################

  set begindate = `$TIME_STAMP -bhf digital`
  if ( $begindate == "" ) set begindate = tmp`date '+%j%H%M%S'`

  set enddate = `$TIME_STAMP -ehf digital`
  if ( $enddate == "" ) set enddate = tmp`date '+%j%H%M%S'`
  set fyear = `echo $enddate | cut -c -4`

  cd $WORKDIR/rundir
  cat time_stamp.out

########################################################################
# save ascii output files
########################################################################

  if ( ! -d $WORKDIR/ascii ) mkdir $WORKDIR/ascii
  if ( ! -d $WORKDIR/ascii ) then
    echo "ERROR: $WORKDIR/ascii is not a directory."
    exit 1
  endif

  foreach out (`ls *.out *.results *.nml *_table`)
    mv $out $begindate.$out
  end

  tar cvf - *\.out *\.results *\.nml *_table | gzip -c > $WORKDIR/ascii/$begindate.ascii_out.tgz

  sbatch --export=source=$WORKDIR/ascii/$begindate.ascii_out.tgz,destination=gfdl:$gfdl_archive/ascii/$begindate.ascii_out.tgz,extension=null,type=ascii --output=$HOME/STDOUT/%x.o%j $SEND_FILE


########################################################################
# move restart files
########################################################################

  cd $WORKDIR

  if ( ! -d $WORKDIR/restart ) mkdir -p $WORKDIR/restart

  if ( ! -d $WORKDIR/restart ) then
    echo "ERROR: $WORKDIR/restart is not a directory."
    exit
  endif

  find $WORKDIR/rundir/RESTART -iname '*.res*' > $WORKDIR/rundir/file.restart.list.txt
  set resfiles     = `wc -l $WORKDIR/rundir/file.restart.list.txt | awk '{print $1}'`

  if ( $resfiles > 0 ) then

    set dateDir = $WORKDIR/restart/$enddate
    set restart_file = $dateDir

    set list = `ls -C1 $WORKDIR/rundir/RESTART`
#  if ( $irun < $segmentsPerJob ) then
#    rm -r $workDir/INPUT/*.res*
#    foreach index ($list)
#      cp $workDir/RESTART/$index $workDir/INPUT/$index
#    end
#  endif

    if ( ! -d $dateDir ) mkdir -p $dateDir

    if ( ! -d $dateDir ) then
      echo "ERROR: $dateDir is not a directory."
      exit
    endif

    foreach index ($list)
      mv $WORKDIR/rundir/RESTART/$index $restart_file/$index
    end


    ln -sf $restart_file/* $WORKDIR/rundir/RESTART/
    #sbatch --export=source=$WORKDIR/restart/$enddate,destination=gfdl:$gfdl_archive/restart/$enddate,extension=tar,type=restart --output=$HOME/STDOUT/%x.o%j $SEND_FILE


  endif


########################################################################
# move history files
########################################################################

  cd $WORKDIR

  if ( ! -d $WORKDIR/history ) mkdir -p $WORKDIR/history
  if ( ! -d $WORKDIR/history ) then
    echo "ERROR: $WORKDIR/history is not a directory."
    exit 1
  endif

  set dateDir = $WORKDIR/history/$begindate
  if ( ! -d  $dateDir ) mkdir $dateDir
  if ( ! -d  $dateDir ) then
    echo "ERROR: $dateDir is not a directory."
    exit 1
  endif

  find $WORKDIR/rundir -maxdepth 1 -type f -regex '.*.nc'      -exec mv {} $dateDir \;
  find $WORKDIR/rundir -maxdepth 1 -type f -regex '.*.nc.....' -exec mv {} $dateDir \;

  cd $WORKDIR/rundir

  sbatch --export=source=$WORKDIR/history/$begindate,destination=gfdl:$gfdl_archive/history/$begindate,extension=tar,type=history --output=$HOME/STDOUT/%x.o%j $SEND_FILE

endif


if ( $irun <= $nruns ) then
  echo "resubmitting... "                                                                                                     
  cd ${SLURM_SUBMIT_DIR}
  set SCRIPT = `scontrol show job $SLURM_JOBID | awk -F= '/Command=/{print $2}'`
  sbatch --export=ALL,irun=$irun,DATE=$DATE --job-name=rs.${DATE}.$irun $SCRIPT
endif

