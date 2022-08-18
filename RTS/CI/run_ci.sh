#!/bin/sh -xe

for test in C* d*
do
  sbatch --account=gfdl_f ${test}
done
