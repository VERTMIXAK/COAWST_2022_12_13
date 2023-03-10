#!/bin/bash

\rm *.nc

today=`date "+%Y-%m-%d"`
#today=`date --date="2020-01-01" "+%Y-%m-%d"`

echo $today
todayP1=`date --date="$today +1 day" "+%Y-%m-%d"`
echo $todayP1
todayP2=`date --date="$today +2 day" "+%Y-%m-%d"`
echo $todayP2
todayP3=`date --date="$today +3 day" "+%Y-%m-%d"`
echo $todayP3


# build argument for 3-day data download

part1='http://pae-paha.pacioos.hawaii.edu/thredds/ncss/pacioos/roms_native/mari/ROMS_CNMI_Regional_Ocean_Model_Native_Grid_best.ncd?'
part2='var=ubar&var=vbar&var=zeta&var=salt&var=temp&var=u&var=v&north=17&west=141&east=148&south=11&disableProjSubset=on&horizStride=1&time_start='

part3='T00%3A00%3A00Z&time_end='

part4a='-01-08T21%3A00%3A00Z&timeStride=1&vertCoord=&addLatLon=true'
part4b='-01-08T00%3A00%3A00Z&timeStride=1&vertCoord=&addLatLon=true'

echo "myURL is " $part1$part2$today$part3$todayP3$part4

wget -O source1.nc $part1$part2$today$part3$today$part4a
ncks --mk_rec_dmn time -O source1.nc source1.nc

exit


wget -O source2.nc $part1$part2$todayP1$part3$todayP1$part4a
ncks --mk_rec_dmn time -O source2.nc source2.nc

wget -O source3.nc $part1$part2$todayP2$part3$todayP3$part4b
ncks --mk_rec_dmn time -O source3.nc source3.nc

ncrcat source?.nc now.nc

# change organization of data within the file

#\cp now.nc now.nc_BAK1

bash fixUHfields.bash

#\cp now.nc now.nc_BAK2

bash fixUHdimensions.bash

#\cp now.nc now.nc_BAK3

module purge
module load matlab/R2013a
matlab -nodisplay -nosplash < fixMask.m


#\cp now.nc now.nc_BAK4

source ~/.runROMSintel

# move file to BC/IC directory

\rm /import/c1/VERTMIX/jgpender/coawst/GUAMBinner_1km/InputFiles/BC_IC_UH/ini/*.nc
\rm /import/c1/VERTMIX/jgpender/coawst/GUAMBinner_1km/InputFiles/BC_IC_UH/*.nc


mv now.nc /import/c1/VERTMIX/jgpender/coawst/GUAMBinner_1km/InputFiles/BC_IC_UH/BCsource.nc
cd /import/c1/VERTMIX/jgpender/coawst/GUAMBinner_1km/InputFiles/BC_IC_UH/ini

ncks -d ocean_time,0 ../BCsource.nc ICsource.nc

# create IC file

source ~/.runPycnal

python make_weight_files.py
python ini.py

# create BC file

cd ..
python make_bdry_file.py


