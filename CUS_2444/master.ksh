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
fi
if [[ ${model} == lfpw ]];then
    longmodel=System5
fi
if [[ ${model} == lfpw ]];then
    longmodel=System4
fi

# Switches for different parts of the code (only run one at time for sanity checks)
getrawdata=0
convertgrib=1
splitncfile=0

if [[ ${getrawdata} -eq 1 ]];then
    mkdir -p raw_files
    cd raw_files

    # Download the data
    wget ${ddir}/sst_${model}.grib

    # Grab the mars download script for reference
    wget ${ddir}CUS-2444-MARS-request-sst-${model}.mars
fi

if [[ ${convertgrib} -eq 1 ]];then
    mkdir -p ncfiles
    cd ncfiles

    # For GloSea5, Need to add -T as got error message:
    #ECCODES ERROR   :  Wrong number of fields
    #ECCODES ERROR   :  File contains 20352 GRIBs, 20352 left in internal description, 7840 in request
    #ECCODES ERROR   :  The fields are not considered distinct!
    #ECCODES ERROR   :  Hint: This may be due to several fields having the same validity time.
    #ECCODES ERROR   :  Try using the -T option (Do not use time of validity)
    grib_to_netcdf -T -R 18500101 -o sst_${longmodel}.nc ${wdir}/raw_files/sst_${model}.grib 
fi

if [[ ${splitncfile} -eq 1 ]];then
    # Split the files into yearly and ensemble files
    cd ncfiles

    if [[ ${model} == egrr ]];then
        for i in {1..12};do
            mkdir -p ens${i}
        done

        # The years in the file are...
    fi
fi
    


