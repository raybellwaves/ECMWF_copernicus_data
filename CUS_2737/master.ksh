#!/bin/ksh
# /projects/rsmas/kirtman/rxb826/DATA/MetOffice_GloSea5/mslp_monthly/master.ksh
#
# Get Copernisus data
# Copy this script along with master_submit.sh to each model directory and
# comment out the model of interest
# cp master.ksh master_submit.sh /projects/rsmas/kirtman/rxb826/DATA/ECMWF_System4/mslp_monthly/
# cp master.ksh master_submit.sh /projects/rsmas/kirtman/rxb826/DATA/MeteoFrance_System5/mslp_monthly/
#
# 6/27/17

# Comment out the line below for the right folder
model=egrr # MetOffice_GloSea5
#model=ecmf # ECMWF_System4
#model=lfpw # MeteoFrance_System5

var=msl

wdir=`pwd`

cusnum=2737
ddir=ftp://ftp.ecmwf.int/pub/copsup/CUS-${cusnum}/

if [[ ${model} == egrr ]];then
    longmodel=GloSea5
    nens=12 # This can vary based on initial conditions
fi
if [[ ${model} == lfpw ]];then
    longmodel=System5
fi
if [[ ${model} == lfpw ]];then
    longmodel=System4
fi

# Switches for different parts of the code (only run one at time for sanity checks)
getrawdata=0
extractinitialconditions=0
convertgrib=0
splitensncfile=0
convertto360181=0
converttohPa=1
seasonalavg=0

if [[ ${getrawdata} -eq 1 ]];then
    mkdir -p raw_files
    cd raw_files

    # Download the data
    wget ${ddir}${var}_${model}.grib

    # Grab the mars download script for reference
    wget ${ddir}CUS-${cusnum}-MARS-request-${var}-${model}.mars
fi

if [[ ${extractinitialconditions} -eq 1 ]];then
    # do grib_ls raw_files/sst_${model}.grib and immediately press ctrl+c to see data specifications
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
            if [[ ! -f ${longmodel}.${year}${month}.sst.grb ]]; then
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
    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh
            echo "grib_to_netcdf -R 18500101 -o ${longmodel}.${year}${month}.${var}.nc ${wdir}/files/${longmodel}.${year}${month}.${var}.grb" >> batch_files/file_${fileref}.ksh

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

    # Do an ncdump on a netcdf file to see how many ensembles it has

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
                if [[ ! -f ens${ens}/${longmodel}.${year}${month}.sst.nc ]]; then
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

if [[ ${converttohPa} -eq 1 ]];then

    cd ${var}_monthly_360x181
    firsttimeround=1

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                echo "ncap2 -O -s 'msl=msl/100' ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.${var}.nc" >> batch_files/file_${fileref}.ksh 
                echo 'ncatted -O -a units,msl,o,c,"hPa" ens'${ens}'/'${longmodel}'.'${year}${month}'.${var}.nc' 'ens'${ens}'/'${longmodel}'.'${year}${month}'.${var}.nc' >> batch_files/file_${fileref}.ksh
                echo "ncrename -O -v ${var},mslp ens${ens}/${longmodel}.${year}${month}.${var}.nc ens${ens}/${longmodel}.${year}${month}.mslp.nc" >> batch_files/file_${fileref}.ksh

                # Submit script
                rm -rf batch_files/file_${fileref}_submit.sh
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 0:01" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

                if [[ ${firsttimeround} -eq 1 ]];then
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1   
                else       
                    # Check if the units are already hPa
                    ncdump -h ens${ens}/${longmodel}.${year}${month}.mslp.nc > header.txt
                    linechk=`egrep "mslp:units = " header.txt | head -1`
                    # Grab between '= ' and ' ;'
                    chkval=`echo ${linechk} | grep -oP '(?<== ).*?(?= ;)'`
                    if [[ ${chkval} == '"Pa"'  ]]; then
                        echo "changing units of ens${ens}/${longmodel}.${year}${month}.mslp.nc"
                        bsub < batch_files/file_${fileref}_submit.sh
                        let fileref=$fileref+1
                    else
                        echo "units of ens${ens}/${longmodel}.${year}${month}.mslp.nc already changed"
                    fi
                fi
                exit 0
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

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh

            done
        done
    done
fi

