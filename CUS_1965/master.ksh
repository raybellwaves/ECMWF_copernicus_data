#!/bin/ksh
# /projects/rsmas/kirtman/rxb826/DATA/ECMWF_System4/master.ksh
#
# Get Copernisus data
# Copy this script along with master_submit.sh to each model directory
#
# cp master.ksh /projects/rsmas/kirtman/rxb826/DATA/MeteoFrance_System5/
#
# 6/28/17
# Don't forget pysource

# Comment out the line below for the right folder
#model=ECMFs4 # ECMWF_System4
model=LFPWs5 # MeteoFrance_System5

wdir=`pwd`

cusnum=1965
ddir=ftp://ftp.ecmwf.int/pub/copsup/CUS-${cusnum}/

if [[ ${model} == LFPWs5 ]];then
    ddir2=MeteoFranceSystem5Data    
    longmodel=System5
fi
if [[ ${model} == ECMFs4 ]];then
    ddir2=ECMWFSystem4Data
    longmodel=System4
fi

# Switches for different parts of the code (only run one at time for sanity checks)
getrawdata=0
extractenesmbles=1
convertgrib=0
createdaily=0
convertto360181=0
combineandrename=0

singlemonth=12 # Choose 10, 11 or 12

if [[ ${getrawdata} -eq 1 ]];then
    mkdir -p raw_files
    cd raw_files
    mkdir -p batch_files
    mkdir -p logs
    # counter
    fileref=0
    for year in {1994..2010}; do
        #for month in 10 11 12; do
        for month in ${singlemonth}; do
            for var in 10u 10v; do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                # Download the data
                echo "wget ${ddir}${ddir2}/${model}.${year}${month}01.${var}.grib" >> batch_files/file_${fileref}.ksh

                # Submit script
                rm -rf batch_files/file_${fileref}_submit.sh
                echo "#BSUB -o logs/file_${fileref}.out" > batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -e logs/file_${fileref}.err" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -W 1:30" >> batch_files/file_${fileref}_submit.sh 
                echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
                echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
                echo "#" >> batch_files/file_${fileref}_submit.sh
                echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

                # Check that the file hasn't been created
                if [[ ! -f ${model}.${year}${month}01.${var}.grib ]]; then
                    echo "downloading file ${model}.${year}${month}01.${var}.grib"
                    bsub < batch_files/file_${fileref}_submit.sh
                    gettingafile=1
                    let fileref=$fileref+1
                else
                    echo "file ${model}.${year}${month}01.${var}.grib exists"
                    gettingafile=0
                fi

                # I think it only allows a download of 15 files at a time
                # Use remainder operator (also known as modulo operator). if number / 6 gives 0 do this
                # Only if a job(s) are sumbitted
                if [[ ${fileref} -ne 0 ]];then
                    if [[ ${gettingafile} -eq 1 ]];then
                        if [[ $((${fileref}%14)) -eq 0 ]];then 
                            sleep 90m
                        fi
                    fi
                fi

            # End var loop   
            done
        # End month loop
        done
    # End year loop
    done 
fi

if [[ ${extractenesmbles} -eq 1 ]];then
    mkdir -p files
    cd files
    rm -rf wrongfiles.ksh
    echo "#!/bin/ksh" > wrongfiles.ksh
    chmod u+x wrongfiles.ksh
    for ensemble in {1..14}; do
        mkdir -p ens${ensemble}
    done 
    mkdir -p batch_files
    mkdir -p logs
    rm batch_files/*
    rm logs/*
    # counter
    fileref=0
    for year in {1994..2010}; do
        #for month in 10 11 12; do
        for month in ${singlemonth}; do
            if [[ ${month} == 10 ]];then
               minfsize=78783340
            fi
            if [[ ${month} == 11 ]];then
               minfsize=62609270
            fi
            if [[ ${month} == 12 ]];then
               minfsize=46956950
            fi
            for var in 10u 10v; do
                for ensemble in {1..14}; do
                    let ensembleref=$ensemble-1
                    rm -rf batch_files/file_${fileref}.ksh
                    echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                    chmod u+x batch_files/file_${fileref}.ksh
                    echo "grib_copy -w number=${ensembleref} ${wdir}/raw_files/${model}.${year}${month}01.${var}.grib ens${ensemble}/${model}.${year}${month}01.${var}.grib" >> batch_files/file_${fileref}.ksh

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
                    if [[ ! -f ens${ensemble}/${model}.${year}${month}01.${var}.grib ]]; then
                        echo "creating file ens${ensemble}/${model}.${year}${month}01.${var}.grib"
                        bsub < batch_files/file_${fileref}_submit.sh
                        let fileref=$fileref+1
                    else
                        echo "file ens${ensemble}/${model}.${year}${month}01.${var}.grib exists"
                        # Check file size
                        files=`ls -la ens${ensemble}/${model}.${year}${month}01.${var}.grib | awk '{ print $5}'`
                        if [[ ${files} -lt ${minfsize} ]] ; then
                           echo "rm -rf ens${ensemble}/${model}.${year}${month}01.${var}.grib" >> wrongfiles.ksh
                        fi
                    fi

                # End ensemble loop
                done
            # End var loop   
            done
        # End month loop
        done
    # End year loop
    done
fi

if [[ ${convertgrib} -eq 1 ]];then
    mkdir -p ncfiles
    cd ncfiles
    rm -rf wrongncfiles.ksh
    echo "#!/bin/ksh" > wrongncfiles.ksh
    chmod u+x wrongncfiles.ksh
    for ensemble in {1..14}; do
        mkdir -p ens${ensemble}
    done
    mkdir -p batch_files
    mkdir -p logs
    rm batch_files/*
    rm logs/*
    # counter
    fileref=0
    for year in {1994..2010}; do
        #for month in 10 11 12; do
        for month in ${singlemonth}; do
            if [[ ${month} == 10 ]];then
               minfsize=78718820
            fi
            if [[ ${month} == 11 ]];then
               minfsize=62558640
            fi
            if [[ ${month} == 12 ]];then
               minfsize=46919760
            fi 
            for var in 10u 10v; do
                if [[ ${var} == 10u ]];then
                    varname=u10
                fi
                if [[ ${var} == 10v ]];then
                    varname=v10
                fi
                for ensemble in {1..14}; do
                #for ensemble in 2; do
                    rm -rf batch_files/file_${fileref}.ksh
                    echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                    chmod u+x batch_files/file_${fileref}.ksh
                    echo "grib_to_netcdf -R 18500101 -o ens${ensemble}/${model}.${year}${month}01.${var}.nc ${wdir}/files/ens${ensemble}/${model}.${year}${month}01.${var}.grib" >> batch_files/file_${fileref}.ksh

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
                    if [[ ! -f ens${ensemble}/${model}.${year}${month}01.${var}.nc ]]; then
                        echo "creating file ens${ensemble}/${model}.${year}${month}01.${var}.nc"
                        bsub < batch_files/file_${fileref}_submit.sh
                        let fileref=$fileref+1
                    else
                        echo "file ens${ensemble}/${model}.${year}${month}01.${var}.nc exists"
                        # Check file size
                        files=`ls -la ens${ensemble}/${model}.${year}${month}01.${var}.nc | awk '{ print $5}'`
                        if [[ ${files} -lt ${minfsize} ]] ; then
                            echo "rm -rf ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> wrongncfiles.ksh
                        else
                            # Check that the data is not full of rubbish
                            rm -rf batch_files/file_${fileref}.py
                            rm -rf batch_files/file_${fileref}_isdud.txt
cat > batch_files/file_${fileref}.py << EOF
import xarray as xr
import numpy as np
ds = xr.open_dataset('ens${ensemble}/${model}.${year}${month}01.${var}.nc')
a = ds['${varname}']
a1 = a[-1,0,0].values
if np.isnan(a1):
    with open('batch_files/file_${fileref}_isdud.txt','w') as f:
        print('yes', file=f)
EOF
                            python batch_files/file_${fileref}.py
                            if [[ -f batch_files/file_${fileref}_isdud.txt ]];then
                                echo "rm -rf ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> wrongncfiles.ksh
                            fi
                            let fileref=$fileref+1
                        fi   
                    fi
                # End ensemble loop
                done
            # End var loop   
            done
        # End month loop
        done
    # End year loop
    done
fi

if [[ ${createdaily} -eq 1 ]];then
    mkdir -p ncfiles_daily
    cd ncfiles_daily
    rm -rf wrongncfiles.ksh
    echo "#!/bin/ksh" > wrongncfiles.ksh
    chmod u+x wrongncfiles.ksh
    for ensemble in {1..14}; do
        mkdir -p ens${ensemble}
    done
    mkdir -p batch_files
    mkdir -p logs
    rm batch_files/*
    rm logs/*
    # counter
    fileref=0
    for year in {1994..2010}; do
        #for month in 10 11 12; do
        for month in ${singlemonth}; do
            if [[ ${month} == 10 ]];then
               minfsize=78718820
            fi
            if [[ ${month} == 11 ]];then
               minfsize=62558640
            fi
            if [[ ${month} == 12 ]];then
               minfsize=46919760
            fi
            for var in 10u 10v; do
                for ensemble in {1..14}; do
                    rm -rf batch_files/file_${fileref}.ksh
                    echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                    chmod u+x batch_files/file_${fileref}.ksh
                    rm -rf batch_files/file_${fileref}.py
cat > batch_files/file_${fileref}.py << EOF
import xarray as xr
da = xr.open_dataarray('${wdir}/ncfiles/ens${ensemble}/${model}.${year}${month}01.${var}.nc')
long_name = da.attrs['long_name']
units = da.attrs['units']
daily_avg = da.resample('D', dim='time', how='mean')
daily_avg.attrs['long_name'] = long_name
daily_avg.attrs['units'] = units
daily_avg.to_netcdf(path='ens${ensemble}/${model}.${year}${month}01.${var}.nc', mode='w') 
EOF
                    echo "python batch_files/file_${fileref}.py" > batch_files/file_${fileref}.ksh
                    # Change the time back to days since 18500101
                    echo "cdo -setcalendar,standard ens${ensemble}/${model}.${year}${month}01.${var}.nc ens${ensemble}/${model}.tmp_${year}${month}01.${var}.nc" >> batch_files/file_${fileref}.ksh
                    echo "cdo setreftime,1850-01-01,00:00:00,days ens${ensemble}/${model}.tmp_${year}${month}01.${var}.nc ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> batch_files/file_${fileref}.ksh
                    echo "rm -rf ens${ensemble}/${model}.tmp_${year}${month}01.${var}.nc" >> batch_files/file_${fileref}.ksh

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
                    if [[ ! -f ens${ensemble}/${model}.${year}${month}01.${var}.nc ]]; then
                        echo "creating file ens${ensemble}/${model}.${year}${month}01.${var}.nc"
                        bsub < batch_files/file_${fileref}_submit.sh
                        let fileref=$fileref+1
                    else
                        echo "file ens${ensemble}/${model}.${year}${month}01.${var}.nc exists"
                        # Check file size
                        files=`ls -la ens${ensemble}/${model}.${year}${month}01.${var}.nc | awk '{ print $5}'`
                        if [[ ${files} -lt ${minfsize} ]] ; then
                            echo "rm -rf ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> wrongncfiles.ksh
                        fi
                    fi
                # End ensemble loop
                done
            # End var loop   
            done
        # End month loop
        done
    # End year loop
    done
fi

if [[ ${convertto360181} -eq 1 ]];then
    localdir=${wdir}/../sfcuv_daily_360x181
    cd ${localdir}
    rm -rf wrongncfiles.ksh
    echo "#!/bin/ksh" > wrongncfiles.ksh
    chmod u+x wrongncfiles.ksh
    for ensemble in {1..14}; do
        mkdir -p ens${ensemble}
    done
    mkdir -p batch_files
    mkdir -p logs
    rm batch_files/*
    rm logs/*

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
        #for month in 10 11 12; do
        for month in ${singlemonth}; do
            if [[ ${month} == 10 ]];then
               minfsize=78749910
            fi
            if [[ ${month} == 11 ]];then
               minfsize=62583310
            fi
            if [[ ${month} == 12 ]];then
               minfsize=46944670
            fi
            for var in 10u 10v; do
                for ensemble in {1..14}; do
                    rm -rf batch_files/file_${fileref}.ksh
                    echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                    chmod u+x batch_files/file_${fileref}.ksh
                    # Interpolate from 180x360 to 181x360
                    echo "cdo remapbil,batch_files/mygrid_1deg ${wdir}/ncfiles_daily/ens${ensemble}/${model}.${year}${month}01.${var}.nc ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> batch_files/file_${fileref}.ksh

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
                    if [[ ! -f ens${ensemble}/${model}.${year}${month}01.${var}.nc ]]; then
                        echo "creating file ens${ensemble}/${model}.${year}${month}01.${var}.nc"
                        bsub < batch_files/file_${fileref}_submit.sh
                        let fileref=$fileref+1
                    else
                        echo "file ens${ensemble}/${model}.${year}${month}01.${var}.nc exists"
                        # Check file size
                        files=`ls -la ens${ensemble}/${model}.${year}${month}01.${var}.nc | awk '{ print $5}'`
                        if [[ ${files} -lt ${minfsize} ]] ; then
                            echo "rm -rf ens${ensemble}/${model}.${year}${month}01.${var}.nc" >> wrongncfiles.ksh
                        fi
                    fi
                # End ensemble loop
                done
            # End var loop   
            done
        # End month loop
        done
    # End year loop
    done
fi

if [[ ${combineandrename} -eq 1 ]];then
    localdir=${wdir}/../sfcuv_daily_360x181
    cd ${localdir}
    rm -rf wrongncfiles.ksh
    echo "#!/bin/ksh" > wrongncfiles.ksh
    chmod u+x wrongncfiles.ksh
    for ensemble in {1..14}; do
        mkdir -p ens${ensemble}
    done
    mkdir -p batch_files
    mkdir -p logs
    rm batch_files/*
    rm logs/*

    # counter
    fileref=0
    for year in {1994..2010}; do
        year2=`expr $year + 1`
        if [ `expr ${year2} % 4` -ne 0 ]; then
            leapyear=0
        elif [ `expr ${year2} % 400` -eq 0 ]; then
            leapyear=1
        elif [ `expr ${year2} % 100` -eq 0 ];then
            leapyear=0
        else
            leapyear=1
        fi
        #for month in 10 11 12; do
        for month in ${singlemonth} ; do
            if [[ ${month} == 10 ]];then
               minfsize=178634440
            fi
            if [[ ${month} == 11 ]];then
               minfsize=155993760
            fi
            if [[ ${month} == 12 ]];then
               minfsize=131501704
            fi

            startdate=${year}${month}01
            for ensemble in {1..14}; do
             #for ensemble in 11 ; do
                rm -rf batch_files/file_${fileref}.ksh
                echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
                chmod u+x batch_files/file_${fileref}.ksh
                # Combine files
                echo "cp ens${ensemble}/${model}.${year}${month}01.10u.nc ens${ensemble}/${model}.${year}${month}01.10uv.nc" >> batch_files/file_${fileref}.ksh
                echo "ncks -A ens${ensemble}/${model}.${year}${month}01.10v.nc ens${ensemble}/${model}.${year}${month}01.10uv.nc" >> batch_files/file_${fileref}.ksh
                # Rename
                if [[ ${month} == 10 ]];then
                    if [[ ${leapyear} -eq 0 ]];then
                        enddate=${year2}0502
                    else
                        enddate=${year2}0503
                    fi
                fi
                if [[ ${month} == 11 ]];then
                    if [[ ${leapyear} -eq 0 ]];then
                        enddate=${year2}0602
                    else
                        enddate=${year2}0603
                    fi
                fi
                if [[ ${month} == 12 ]];then
                    if [[ ${leapyear} -eq 0 ]];then
                        enddate=${year2}0702
                    else
                        enddate=${year2}0703
                    fi
                fi
                echo "mv ens${ensemble}/${model}.${year}${month}01.10uv.nc ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
                
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
                if [[ ! -f ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ]]; then
                    echo "creating file ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc"
                    bsub < batch_files/file_${fileref}_submit.sh
                    let fileref=$fileref+1
                else
                    echo "file ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc exists"
                    # Check file size
                    files=`ls -la ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc | awk '{ print $5}'`
                    if [[ ${files} -lt ${minfsize} ]] ; then
                        echo "rm -rf ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> wrongncfiles.ksh
                    else
                        # Check that the data is not full of rubbish
                        rm -rf batch_files/file_${fileref}.py
                        rm -rf batch_files/file_${fileref}_isdud.txt
cat > batch_files/file_${fileref}.py << EOF
import xarray as xr
import numpy as np
ds = xr.open_dataset('ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc')
a = ds['u10']
a1 = a[-1,0,0].values
if np.isnan(a1):
    with open('batch_files/file_${fileref}_isdud.txt','w') as f:
        print('yes', file=f)
EOF
                        python batch_files/file_${fileref}.py
                        if [[ -f batch_files/file_${fileref}_isdud.txt ]];then
                            echo "rm -rf ens${ensemble}/uv10_day_${longmodel}_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> wrongncfiles.ksh
                        fi
                        let fileref=$fileref+1 
                    fi
                fi

            # End ensemble loop
            done
        # End month loop
        done
    # End year loop
    done
fi
