#!/bin/bash


######## GENERATE INIT FILES + NETCDF STATE FILE ########
if grep -q "-DUSE_PDAF" "/Users/shoale/PDAF-heart-ms_v3/PDAF_V2.0/make.arch/macos_gfortran_openmpi.h"; then
	sed -i '' 's/^CPP_DEFS = -DUSE_PDAF/CPP_DEFS = #-DUSE_PDAF/' "/Users/shoale/PDAF-heart-ms_v3/PDAF_V2.0/make.arch/macos_gfortran_openmpi.h"
fi
make clean
make model
./model -spinup 0
make clean
make model
./model -spinup 1


######## GENERATE ENSEMBLE AND OBSERVATIONS ########
cd tools
make clean
gfortran -c -o parser_no_mpi.o parser_no_mpi.F90
make all
./generate_ens -ens_size 4
./generate_obs -obs_choice 1


# ######## RUN ASSIMILATION ########
sed -i '' 's/^CPP_DEFS = #-DUSE_PDAF/CPP_DEFS = -DUSE_PDAF/' "/Users/shoale/PDAF-heart-ms_v3/PDAF_V2.0/make.arch/macos_gfortran_openmpi.h"
cd ..
make clean
make model_pdaf
mpirun -np 4 ./model_pdaf -dim_ens 4 -exp_type obs_spacing_exp -filter_type estkf -obs_type uniform
