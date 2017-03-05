#!/usr/bin/env tcsh

# may need to update the links to libraries here 
# http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compilation_tutorial.php

# Using chmod u+x scriptname make the script executable.


# compiler tests
which gfortran
which cpp
which gcc
gcc --version

# make Build directory
mkdir ~/Build_WRF

# make test directory
mkdir ~/TESTS

# start test- should get a success message for each on in turn
cd TESTS
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_tests.tar
tar -xf Fortran_C_tests.tar
gfortran TEST_1_fortran_only_fixed.f
./a.out

gfortran TEST_2_fortran_only_free.f90
./a.out

gcc TEST_3_c_only.c
./a.out

gcc -c -m64 TEST_4_fortran+c_c.c
gfortran -c -m64 TEST_4_fortran+c_f.f90
gfortran -m64 TEST_4_fortran+c_f.o TEST_4_fortran+c_c.o
./a.out

./TEST_csh.csh

./TEST_perl.pl

./TEST_sh.sh


# store libraries
cd ~/Build_WRF
mkdir LIBRARIES
cd LIBRARIES

# download libraries into LIBRARIES dir
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/mpich-3.0.4.tar.gz
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/netcdf-4.1.3.tar.gz
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/libpng-1.2.50.tar.gz
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/zlib-1.2.7.tar.gz


#set paths USE TCSH
setenv DIR ~/Build_WRF/LIBRARIES
setenv CC gcc
setenv CXX g++
setenv FC gfortran
setenv FCFLAGS -m64
setenv F77 gfortran
setenv FFLAGS -m64

# compile netcdf use BASH
tar xzvf netcdf-4.1.3.tar.gz
cd netcdf-4.1.3
./configure --prefix=$DIR/netcdf --disable-dap --disable-netcdf-4 --disable-shared
sudo make
sudo make install
setenv PATH $DIR/netcdf/bin:$PATH
setenv NETCDF $DIR/netcdf
cd .. 

# compile mpich
tar xzvf mpich-3.0.4.tar.gz
cd mpich-3.0.4
./configure --prefix=$DIR/mpich
sudo make
sudo make install
setenv PATH $DIR/mpich/bin:$PATH
cd ..

# compile zlib
setenv LDFLAGS -L$DIR/grib2/lib
setenv CPPFLAGS -I$DIR/grib2/include
tar xzvf zlib-1.2.7.tar.gz
cd zlib-1.2.7
./configure --prefix=$DIR/grib2
sudo make
sudo make install
cd .. 

# compile libpng
tar xzvf libpng-1.2.50.tar.gz
cd libpng-1.2.50
./configure --prefix=$DIR/grib2
sudo make
sudo make install
cd ..

# compile jasper
tar xzvf jasper-1.900.1.tar.gz
cd jasper-1.900.1
./configure --prefix=$DIR/grib2
sudo make
sudo make install
cd ..

######
# test the libraries
cd ~/TESTS
wget -nc http://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/Fortran_C_NETCDF_MPI_tests.tar
tar -xf Fortran_C_NETCDF_MPI_tests.tar

# test 1
cp ${NETCDF}/include/netcdf.inc .
gfortran -c 01_fortran+c+netcdf_f.f
gcc -c 01_fortran+c+netcdf_c.c
gfortran 01_fortran+c+netcdf_f.o 01_fortran+c+netcdf_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
./a.out

# test 2
cp ${NETCDF}/include/netcdf.inc .
mpif90 -c 02_fortran+c+netcdf+mpi_f.f
mpicc -c 02_fortran+c+netcdf+mpi_c.c
mpif90 02_fortran+c+netcdf+mpi_f.o 02_fortran+c+netcdf+mpi_c.o -L${NETCDF}/lib -lnetcdff -lnetcdf
mpirun 
./a.out

# Download WRF
cd ~/Build_WRF
wget -nc http://www2.mmm.ucar.edu/wrf/src/WRFV3.8.1.TAR.gz
gunzip WRFV3.8.1.TAR.gz
tar -xf WRFV3.8.1.TAR

# get WRF-Chem
cd ~/Build_WRF/WRFV3
wget -nc http://www2.mmm.ucar.edu/wrf/src/WRFV3-Chem-3.8.1.TAR.gz
gunzip WRFV3-Chem-3.8.1.TAR.gz
tar -xf WRFV3-Chem-3.8.1.TAR

# set wrfchem specific environments
# http://irina.eas.gatech.edu/hwrf927123/WRF_Chem_Users_guide.pdf
setenv WRF_EM_CORE 1
setenv WRF_NMM_CORE 0
setenv WRF_CHEM 1

# compile WRF
cd WRFV3
./configure
./compile em_real >& log.compile 

# test exes have been created
ls -ls main/*.exe

# download WPS
cd ~/Build_WRF
wget -nc http://www2.mmm.ucar.edu/wrf/src/WPSV3.8.1.TAR.gz
gunzip WPSV3.8.1.TAR.gz
tar -xf WPSV3.8.1.TAR

# compile WPS
cd WPS
./clean
setenv JASPERLIB $DIR/grib2/lib
setenv JASPERINC $DIR/grib2/include
./configure
./compile >& log.compile

# test exes have been created
ls -ls *.exe


# download basic geography data
cd ~/Build_WRF
mkdir WPS_GEOG
wget -nc http://www2.mmm.ucar.edu/wrf/src/wps_files/geog_minimum.tar.bz2
# had to use a different unzip command to open the bz2 file, the tutorial says its a gz file
tar -xvfj geog.tar
geog_data_path = ´~/Build_WRF/WPS_GEOG´

# get some test met data
mkdir ~/Build_WRF/Data
cd ~/Build_WRF/Data
wget -nc ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2017012400/gfs.t00z.pgrb2.0p50.f000
wget -nc ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2017012400/gfs.t00z.pgrb2.0p50.f006
wget -nc ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2017012400/gfs.t00z.pgrb2.0p50.f012
wget -nc ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.2017012400/gfs.t00z.pgrb2.0p50.f018


# run WPS
# if the domain wizard was used copy the namelist into the WPS folder.
cd ~/WRF/WPS

# assuming the namelist.wps file is up to date run geogrid
./geogrid.exe >& log.geogrid
# link to grib data from gfs
./link_grib.csh ~/WRF/Data/*
# link to vtable
ln -sf ungrib/Variable_Tables/Vtable.GFS Vtable
# run ungrib
./ungrib.exe >& log.ungrib
# run metgrid
./metgrid.exe >& log.metgrid

#run WRF
cd ../WRFV3/run
ln -sf ../../WPS/met_em* .
mpirun -np 1 ./real.exe


# WRF-Chem emissions data ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/
# WRF-Chem tutorials and useful looking namelists etc (also MOZART, MEGAN data)
cd ~/WRF/WRFV3/chem
mkdir emissions
wget -nc ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/global_emissions_v3_24aug2015.tar.gz
wget -nc ftp://aftp.fsl.noaa.gov/divisions/taq/global_emissions/prep_chem_sources_v1.5_24aug2015.tar.gz


