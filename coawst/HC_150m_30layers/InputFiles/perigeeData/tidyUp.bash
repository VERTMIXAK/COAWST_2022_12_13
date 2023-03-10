#!/bin/bash
if [ -f "scpDone.txt" ]
then
	echo "begin tidyUp.bash"

	source /import/home/jgpender/.runROMSintel

#	Do the experiment name up front to make sure the timing's right

	exptDate=`cat scpDone.txt`
	exptName=HC_150m_$exptDate

	baseDir="/import/c1/VERTMIX/jgpender/coawst/HC_150m_30layers/"
	cp -R $baseDir/Experiments/HC_150m_template $baseDir/Experiments/$exptName



# there are 14 files but the counting begins at zero
    
	nMax=13 
	fileList=( "HIS1.nc" "HIS2.nc" "HIS3.nc" "HIS4.nc" "HIS5.nc" "rivers.nc" "lwrad_down.nc" "Pair.nc" "Qair.nc" "rain.nc" "swrad.nc" "Tair.nc" "Uwind.nc" "Vwind.nc" )
	varList=(  "dum"     "dum"     "dum"     "dum"     "dum"     "dum"       "lwrad_down"    "Pair"    "Qair"    "rain"    "swrad"    "Tair"    "Uwind"    "Vwind" )
	timeList=( "ocean_time" "ocean_time" "ocean_time" "river_time" "lrf_time" "pair_time" "qair_time" "rain_time" "srf_time" "tair_time"  "wind_time" "wind_time")



# convert the timestamps to days since 1900
	
	for ii in `seq 0 $nMax`
	do
		echo ${fileList[$ii] } ${timeList[$ii]}
		ncatted -O -a units,${timeList[$ii]},o,c,"days since 1900-01-01 00:00:00" ${fileList[$ii]}
	done

	source /import/home/jgpender/.runPycnal
    for ii in `seq 0 $nMax`
    do
        echo ${fileList[$ii] } ${timeList[$ii]}
		python settime.py ${fileList[$ii] } ${timeList[$ii]}
    done




#	The IC/BC scripts don't need the lon/lat fields, so generate the IC/BC files now

	cd $baseDir/InputFiles/BC_IC_HC/ini_wetDry
	echo "should be in IC directory" 
	pwd

	\rm *.nc
	ncks -O -d ocean_time,0 $baseDir/InputFiles/perigeeData/HIS1.nc HISstart.nc
	python make_weight_files.py
	python ini.py
	echo "should see IC file"
	ls -l

	cd $baseDir/InputFiles/BC_IC_HC
	echo "should be in BC directory" `pwd`
	\rm *.nc
	mv $baseDir/InputFiles/perigeeData/HIS*.nc .
	
	echo "start BC"
	python bryDaily1.py &
    python bryDaily2.py &
    python bryDaily3.py &
    python bryDaily4.py &
    python bryDaily5.py &

	wait
	echo "should see BC files"
	ls -l
	echo "end BC"


#	Make the river forcing file

	echo "starting river"
	cd $baseDir/InputFiles/Runoff
	\rm river*
	mv $baseDir/InputFiles/perigeeData/rivers.nc riversLO.nc
	pwd
	ls
    module purge
    module load matlab/R2013a
	matlab -nodisplay -nosplash < fixRiver.m



#   The surface forcing files do need the lat/lon fields, so add them now


    cd ../perigeeData

    for ii in `seq 4 $nMax`
    do
      	echo ${fileList[$ii] } ${timeList[$ii]}
        ncrename -O -d eta_rho,lat -d xi_rho,lon ${fileList[$ii]}
        ncatted -O -a  coordinates,${varList[$ii]},a,c,"lon lat" ${fileList[$ii]}
    done

    matlab -nodisplay -nosplash < addLatLon.m

	echo " "
	echo "done with all the file creation"




#	Move files


	mv *.nc 													$baseDir/Experiments/$exptName/forcing
	mv ../Runoff/rivers.nc										$baseDir/Experiments/$exptName/forcing
	mv ../BC_IC_HC/ini_wetDry/HISstart_HC_150mMEWetDry.nc 		$baseDir/Experiments/$exptName/forcing/HC_ic.nc
    mv ../BC_IC_HC/HIS?.nc  	 								$baseDir/Experiments/$exptName/forcing/

    ncrcat -O ../BC_IC_HC/HIS*bdry.nc  							$baseDir/Experiments/$exptName/forcing/HC_bdry.nc
	mv scpDone.txt												$baseDir/Experiments/$exptName/forcing			


#	Run ROMS
	cd $baseDir/Experiments/$exptName

	mv HC_template.sbat "HC_$exptDate.sbat"

	source /import/home/jgpender/.runROMSintel
	sbatch *sbat





fi
