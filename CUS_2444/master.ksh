#!/bin/ksh
# /projects/rsmas/kirtman/rxb826/DATA/MetOffice_GloSea5/sst_monthly/master.ksh
#
# Get Copernisus data
# Copy this script along with master_submit.sh to each model directory and
# comment out the model of interest
# cp master.ksh master_submit.sh /projects/rsmas/kirtman/rxb826/DATA/ECMWF_System4/sst_monthly/
# cp master.ksh master_submit.sh /projects/rsmas/kirtman/rxb826/DATA/MeteoFrance_System5/sst_monthly/
#
# 6/27/17

# Comment out the line below for the right folder
model=egrr # MetOffice_GloSea5
#model=ecmf # ECMWF_System4
#model=lfpw # MeteoFrance_System5

var=sst
newvarname=sst

# Region 
lonw=0.0
lone=360.0
lats=-90.0
latn=90.0
regionname=global
# Seasonalaverage
savgname=DJFmean

wdir=`pwd`

cusnum=2444
ddir=ftp://ftp.ecmwf.int/pub/copsup/CUS-${cusnum}/

if [[ ${model} == egrr ]];then
    longmodel=GloSea5
    nens=12 # This can vary based on itialtial conditions
fi
if [[ ${model} == ecmf ]];then
    longmodel=System4
    nens=15
fi
if [[ ${model} == lfpw ]];then
    longmodel=System5
    nens=15
fi

# Switches for different parts of the code (only run one at time for sanity checks)
getrawdata=0
extractinitialconditions=0
convertgrib=0
splitensncfile=0
convertto360181=0
converttodegc=0
seasonalavg=1

if [[ ${getrawdata} -eq 1 ]];then
    mkdir -p raw_files
    cd raw_files

    # Download the data
    wget ${ddir}${var}_${model}.grib

    # Grab the mars download script for reference
    wget ${ddir}CUS-${cusnum}-MARS-request-${var}-${model}.mars
fi

if [[ ${extractinitialconditions} -eq 1 ]];then
    # do grib_ls raw_files/${var}_${model}.grib and immediately press ctrl+c to see data specifications
    mkdir -p files
    cd files  
    mkdir -p batch_files
    mkdir -p logs
    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh
            echo "grib_copy -w dataDate=${year}${month}01 ${wdir}/raw_files/${var}_${model}.grib ${longmodel}.${year}${month}.${var}.grb" >> batch_files/file_${fileref}.ksh

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:02" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

            # Check that the file hasn't been created
            if [[ ! -f ${longmodel}.${year}${month}.${var}.grb ]]; then
                echo "creating file ${longmodel}.${year}${month}.${var}.grb"
                bsub < batch_files/file_${fileref}_submit.sh
                let fileref=$fileref+1
            else
                echo "file ${longmodel}.${year}${month}.${var}.grb exists"
            fi
        done
    done
fi

if [[ ${convertgrib} -eq 1 ]];then
    mkdir -p ncfiles
    cd ncfiles
    mkdir -p batch_files
    mkdir -p logs
    rm -rf batch_files/*
    rm -rf logs/*
    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh
            echo "grib_to_netcdf -R 18500101 -o ${longmodel}.${year}${month}.sst.nc ${wdir}/files/${longmodel}.${year}${month}.${var}.grb" >> batch_files/file_${fileref}.ksh

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:02" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

            # Check that the file hasn't been created
            if [[ ! -f ${longmodel}.${year}${month}.${var}.nc ]]; then
                echo "creating file ${longmodel}.${year}${month}.${var}.nc"
                bsub < batch_files/file_${fileref}_submit.sh
                let fileref=$fileref+1
            else
                echo "file ${longmodel}.${year}${month}.${var}.nc exists"
            fi
        done
    done
fi

if [[ ${splitensncfile} -eq 1 ]];then
    # Split the files into yearly and ensemble files
    cd ncfiles
    rm -rf batch_files/*
    rm -rf logs/*

    # Do a ncdump on a netcdf file to see how many ensembles it has

    for i in {1..${nens}};do
        mkdir -p ens${i}
    done

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                ensembleextract=`expr ${i} - 1`

                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                # Extract ensemble
                echo "ncks -O -d number,${ensembleextract} ${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh
                # Remove ensemble dimension
                echo "ncwa -O -a number ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh
                echo "ncks -O -x -v number ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh
                # Make latitude -90-90 as currently is 90--90
                echo "ncpdq -O -a -latitude ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh

                # Submit script
                rm -rf batch_files/file_${fileref}_submit.sh
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 0:02" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

                # Check that the file hasn't been created
                if [[ ! -f ens${ens}/${longmodel}.${year}${month}.${var}.nc ]]; then
                    echo "creating file ens${ens}/${longmodel}.${year}${month}.${var}.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ens${ens}/${longmodel}.${year}${month}.${var}.nc exists"
                fi
            done
        done
    done
fi

if [[ ${convertto360181} -eq 1 ]];then
    mkdir -p ${var}_monthly_360x181
    cd ${var}_monthly_360x181
    mkdir -p batch_files
    mkdir -p logs

    for i in {1..${nens}};do
        mkdir -p ens${i}
    done

if [ ! -f batch_files/mygrid_1deg ];then
cat > batch_files/mygrid_1deg << EOF
gridtype = lonlat
xsize    = 360
ysize    = 181
xfirst   = 0.0
xinc     = 1
yfirst   = -90.0
yinc     = 1
EOF
fi

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                echo "cdo remapbil,batch_files/mygrid_1deg ${wdir}/ncfiles/ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh

                # Submit script
                rm -rf batch_files/file_${fileref}_submit.sh
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 0:01" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

                # Check that the file hasn't been created
                if [[ ! -f ens${ens}/${longmodel}.${year}${month}.${var}.nc ]]; then
                    echo "creating file ens${ens}/${longmodel}.${year}${month}.${var}.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ens${ens}/${longmodel}.${year}${month}.${var}.nc exists"
                fi
            done
        done
    done
fi

if [[ ${converttodegc} -eq 1 ]];then

    cd ${var}_monthly_360x181
    rm -rf batch_files/*
    rm -rf logs/*

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                echo "ncap2 -O -s 'sst=sst-273.15' ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh 
                echo 'ncatted -O -a units,sst,o,c,"degress C" ens'${ens}'/'${longmodel}'.'${year}${month}'.'${var}'.nc' 'ens'${ens}'/'${longmodel}'.'${year}${month}'.'${var}'.nc' >> batch_files/file_${fileref}.ksh 

                # Submit script
                rm -rf batch_files/file_${fileref}_submit.sh
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 0:01" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh
          
                # Check if the units are already degrees C
                ncdump -h ens${ens}/${longmodel}.${year}${month}.${var}.nc > header.txt
                linechk=`egrep "sst:units = " header.txt | head -1`
                # Grab between '= ' and ' ;'
                chkval=`echo ${linechk} | grep -oP '(?<== ).*?(?= ;)'`
                if [[ ${chkval} == '"K"'  ]]; then
                    echo "changing units of ens${ens}/${longmodel}.${year}${month}.${var}.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "units of ens${ens}/${longmodel}.${year}${month}.${var}.nc already changed"
                fi
            done
        done
    done
fi


if [[ ${seasonalavg} -eq 1 ]];then
    mkdir -p ${var}_seasonal_360x181
    cd ${var}_seasonal_360x181
    mkdir -p batch_files
    mkdir -p logs
    for i in {1..${nens}};do
        mkdir -p ens${i}
    done
    rm -rf batch_files/*
    rm -rf logs/*

    cd ..
    mkdir -p Regional_1deg_seasonal
    cd Regional_1deg_seasonal
    for i in {1..${nens}};do
        mkdir -p ens${i}
    done 

    cd ../${var}_seasonal_360x181  

    for i in {1..${nens}};do
        mkdir -p ens${i}
    done

    # counter
    fileref=0
    for year in {1994..2010}; do
        year2=`expr $year + 1`
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh

                if [[ ${savgname} == DJFmean ]];then
                    if [[ ${month} == 10 ]];then
                        point0=2
                        point1=4
                    fi
                    if [[ ${month} == 11 ]];then
                        point0=1
                        point1=3
                    fi
                    if [[ ${month} == 12 ]];then
                        point0=0
                        point1=2
                    fi

                    # Global file
                    echo "ncks -O -d time,${point0},${point1} ${wdir}/${var}_monthly_360x181/ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_DJF.nc" >> batch_files/file_${fileref}.ksh
                    # Average
                    echo "ncra -O ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_DJF.nc ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc" >> batch_files/file_${fileref}.ksh
                    # Update lon and lat names
                    echo "ncrename -O -d lon,longitude -d lat,latitude -v lon,longitude -v lat,latitude ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc" >> batch_files/file_${fileref}.ksh
                    # Add ensemble in
                    echo "ncap2 -s 'defdim("'"'ensemble'"'",1);ensemble[ensemble]="${ens}";ensemble@long_name="'"ensemble"'"'"" -O ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_tmp.nc"  >> batch_files/file_${fileref}.ksh
                    echo "mv ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_tmp.nc ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc"  >> batch_files/file_${fileref}.ksh
                
                    # Extract region
                    echo "ncks -O -d longitude,${lonw},${lone} -d latitude,${lats},${latn} ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}.nc ${wdir}/Regional_1deg_seasonal/ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_${regionname}.nc" >> batch_files/file_${fileref}.ksh
                fi

                # Submit script
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 0:02" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

                # Check that the file hasn't been created
                if [[ ! -f ${wdir}/Regional_1deg_seasonal/ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_${regionname}.nc ]]; then
                    echo "creating file ${wdir}/Regional_1deg_seasonal/ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_${regionname}.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ${wdir}/Regional_1deg_seasonal/ens${ens}/${longmodel}_ens${ens}_${month}ic_${year}-${year2}_${savgname}_${regionname}.nc exists"
                fi
            done
        done
    done
fi
