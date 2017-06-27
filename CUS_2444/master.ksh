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

wdir=`pwd`

cusnum=2444
ddir=ftp://ftp.ecmwf.int/pub/copsup/CUS-${cusnum}/

if [[ ${model} == egrr ]];then
    longmodel=GloSea5
    nens=12 # This can vary based on itialtial conditions
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
converttodegc=1
seasonalavg=0

if [[ ${getrawdata} -eq 1 ]];then
    mkdir -p raw_files
    cd raw_files

    # Download the data
    wget ${ddir}/sst_${model}.grib

    # Grab the mars download script for reference
    wget ${ddir}CUS-2444-MARS-request-sst-${model}.mars
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
            echo "grib_copy -w dataDate=${year}${month}01 ${wdir}/raw_files/sst_${model}.grib ${longmodel}.${year}${month}.sst.grb" >> batch_files/file_${fileref}.ksh

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
                echo "creating file ${longmodel}.${year}${month}.sst.grb"
                bsub < batch_files/file_${fileref}_submit.sh
                let fileref=$fileref+1
            else
                echo "file ${longmodel}.${year}${month}.sst.grb exists"
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
            echo "grib_to_netcdf -R 18500101 -o ${longmodel}.${year}${month}.sst.nc ${wdir}/files/${longmodel}.${year}${month}.sst.grb" >> batch_files/file_${fileref}.ksh

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
            if [[ ! -f ${longmodel}.${year}${month}.sst.nc ]]; then
                echo "creating file ${longmodel}.${year}${month}.sst.nc"
                bsub < batch_files/file_${fileref}_submit.sh
                let fileref=$fileref+1
            else
                echo "file ${longmodel}.${year}${month}.sst.nc exists"
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
                echo "ncks -O -d number,${ensembleextract} ${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh
                # Remove ensemble dimension
                echo "ncwa -O -a number ens${ens}/${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh
                echo "ncks -O -x -v number ens${ens}/${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh
                # Make latitude -90-90 as currently is 90--90
                echo "ncpdq -O -a -latitude ens${ens}/${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh

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
                    echo "creating file ens${ens}/${longmodel}.${year}${month}.sst.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ens${ens}/${longmodel}.${year}${month}.sst.nc exists"
                fi
            done
        done
    done
fi

if [[ ${convertto360181} -eq 1 ]];then
    mkdir -p sst_monthly_360x181
    cd sst_monthly_360x181
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
                echo "cdo remapbil,batch_files/mygrid_1deg ${wdir}/ncfiles/ens${ens}/${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh

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
                if [[ ! -f ens${ens}/${longmodel}.${year}${month}.sst.nc ]]; then
                    echo "creating file ens${ens}/${longmodel}.${year}${month}.sst.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ens${ens}/${longmodel}.${year}${month}.sst.nc exists"
                fi
            done
        done
    done
fi

if [[ ${converttodegc} -eq 1 ]];then

    cd sst_monthly_360x181

    # counter
    fileref=0
    for year in {1994..2010}; do
        for month in 10 11 12; do
            for ens in {1..${nens}};do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                echo "ncap2 -O -s sst=sst-273.15 ens${ens}/${longmodel}.${year}${month}.sst.nc ens${ens}/${longmodel}.${year}${month}.sst.nc" >> batch_files/file_${fileref}.ksh 
                echo 'ncatted -O -a units,sst,o,c,"degress C" ens'${ens}'/'${longmodel}'.'${year}${month}'.sst.nc' 'ens'${ens}'/'${longmodel}'.'${year}${month}'.sst.nc' >> batch_files/file_${fileref}.ksh 

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
                ncdump -h ens${ens}/${longmodel}.${year}${month}.sst.nc > header.txt
                linechk=`egrep "sst:units = " header.txt | head -1`
                # Grab between '= ' and ' ;'
                chkval=`echo ${linechk} | grep -oP '(?<== ).*?(?= ;)'`
                if [[ ${chkval} == '"K"'  ]]; then
                    echo "changing units of ens${ens}/${longmodel}.${year}${month}.sst.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "units of ens${ens}/${longmodel}.${year}${month}.sst.nc already changed"
                fi
            done
        done
    done
fi


if [[ ${seasonalavg} -eq 1 ]];then
    mkdir -p sst_seasonal_360x181
    cd sst_seasonal_360x181
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

