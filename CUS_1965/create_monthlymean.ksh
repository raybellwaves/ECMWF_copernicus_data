#!/bin/ksh
# Create monthly means
# There are times where the monthly mean files aren't created whilst running the WW3 script
#
# 5/6/17

export model=GloSea5
export ww3region=Atl_${model}
export wdir=/projects/rsmas/kirtman/rxb826/WW3exps/${ww3region}/ # Update this every time
export exeventdir=${wdir}filelist/ # List of yearly files

#export icarr=(oct nov dec)
#export icnumarr=(10 11 12)
export icarr=(oct)
export icnumarr=(10)

# Area of analyses
lonw=260.0
lone=30.0
lats=0.0
latn=80.0
regionname=NAtl

#export vararr=(uv ws10)
export vararr=(uv)

# Remove batch_files and logs
rm batch_files/*
rm logs/*

# counter
fileref=0

# Loop over ensembles
for i in {1..12} ; do
#for i in {9..12} ; do
   ensnum=$i

   # Loop over initial conditions
   nicnum=${#icnumarr[@]}
   let nicnum=$nicnum-1
   for j in {0..${nicnum}} ; do
      initialcondition=${icarr[$j]}
      initialconditionnum=${icnumarr[$j]}

      # Loop over variables
      nvar=${#vararr[@]}
      let nvarnum=$nvar-1
      for k in {0..${nvarnum}} ; do
         var=${vararr[$k]}

         # Loop over filelist
         while read lineyear; do

            export tmp=`echo $lineyear | awk -F'_' '{print $9}'`
            export startdate=${tmp:0:8}
            export startyear=${startdate:0:4}
            export startmon=${startdate:4:2}
            export startday=${startdate:6:2}
            export enddate=${tmp:9:8}  

            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh 

            if [[ ${var} == ws10 ]];then
               # Sometimes the wind speed file is not created
               echo "ncap2 -O -s 'ws10=sqrt(u10^2 + v10^2)' ${model}_ens${ensnum}_${startdate}_${enddate}_uv_0_ATL.nc ${model}_ens${ensnum}_${startdate}_${enddate}_ws10_0_ATL.nc" >> batch_files/file_${fileref}.ksh
               # Extract wind speed
               echo "ncks -O -v ws10 ${model}_ens${ensnum}_${startdate}_${enddate}_ws10_0_ATL.nc ${model}_ens${ensnum}_${startdate}_${enddate}_ws10_0_ATL.nc" >> batch_files/file_${fileref}.ksh
            fi

            # Check if the file is global or regional 
            echo "ncdump -h ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc > file_ens${ensnum}_${startdate}_${enddate}_${var}_header.txt" >> batch_files/file_${fileref}.ksh
            # Grab the lat in the dimensions
            echo 'latline=`egrep "lat = " file_ens'${ensnum}'_'${startdate}'_'${enddate}'_'${var}'_header.txt | head -1`' >> batch_files/file_${fileref}.ksh
            # Grab between '= ' and ' ;'
            echo 'latval=`echo ${latline} | grep -o -P '"'"'(?<== ).*(?= ;)'"'"'`' >> batch_files/file_${fileref}.ksh
            echo "if [[ "'${latval}'" -lt 181 ]];then" >> batch_files/file_${fileref}.ksh
            echo "   regionalfile=1" >> batch_files/file_${fileref}.ksh
            echo "else" >> batch_files/file_${fileref}.ksh
            echo "   regionalfile=0" >> batch_files/file_${fileref}.ksh
            echo "fi" >> batch_files/file_${fileref}.ksh

            echo "point1=0" >> batch_files/file_${fileref}.ksh
            if [[ ${startmon} == 10 ]];then
               echo "let tmp2=`date +%s -d ${startyear}1031`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point2=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point1},${point2} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_1_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point3=${point2}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear}1130`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point4=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point3},${point4} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_2_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point5=${point4}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear}1231`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point6=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point5},${point6} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_3_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point7=${point6}+1' >> batch_files/file_${fileref}.ksh
               let startyear2=${startyear}+1
               echo "let tmp2=`date +%s -d ${startyear2}0131`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point8=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point7},${point8} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_4_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point9=${point8}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0228`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point10=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point9},${point10} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_5_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point11=${point10}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0331`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point12=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point11},${point12} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_6_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point13=${point12}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0430`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point14=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point13},${point14} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_7_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point15=${point14}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0531`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point16=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point15},${point16} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_8_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            fi
            if [[ ${startmon} == 11 ]];then
               echo "let tmp2=`date +%s -d ${startyear}1130`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point2=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point1},${point2} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_1_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point3=${point2}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear}1231`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point4=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point3},${point4} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_2_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point5=${point4}+1' >> batch_files/file_${fileref}.ksh
               let startyear2=${startyear}+1
               echo "let tmp2=`date +%s -d ${startyear2}0131`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point6=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point5},${point6} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_3_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point7=${point6}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0228`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point8=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point7},${point8} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_4_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point9=${point8}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0331`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point10=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point9},${point10} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_5_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point11=${point10}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0430`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point12=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point11},${point12} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_6_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point13=${point12}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0531`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point14=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point13},${point14} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_7_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point15=${point14}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0630`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point16=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point15},${point16} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_8_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            fi
            if [[ ${startmon} == 12 ]];then
               echo "let tmp2=`date +%s -d ${startyear}1231`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point2=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point1},${point2} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_1_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point3=${point2}+1' >> batch_files/file_${fileref}.ksh
               let startyear2=${startyear}+1
               echo "let tmp2=`date +%s -d ${startyear2}0131`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point4=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point3},${point4} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_2_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point5=${point4}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0228`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point6=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point5},${point6} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_3_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point7=${point6}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0331`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point8=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point7},${point8} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_4_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point9=${point8}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0430`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point10=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point9},${point10} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_5_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point11=${point10}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0531`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point12=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point11},${point12} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_6_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point13=${point12}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0630`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point14=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point13},${point14} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_7_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
               echo 'let point15=${point14}+1' >> batch_files/file_${fileref}.ksh
               echo "let tmp2=`date +%s -d ${startyear2}0731`-`date +%s -d ${startdate}`" >> batch_files/file_${fileref}.ksh
               echo 'let point16=${tmp2}/86400' >> batch_files/file_${fileref}.ksh
               echo 'ncks -O -d time,${point15},${point16} '"${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL.nc tmp_8_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            fi

            # Average these
            echo "ncra -O tmp_1_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_01_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_2_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_02_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_3_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_03_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_4_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_04_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_5_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_05_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_6_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_06_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_7_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_07_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncra -O tmp_8_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_08_avg_${var}_${ensnum}_${startdate}_${enddate}.nc" >> batch_files/file_${fileref}.ksh
            # Concat them
            echo "ncrcat -O tmp_??_avg_${var}_${ensnum}_${startdate}_${enddate}.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL_monthlymean.nc" >> batch_files/file_${fileref}.ksh

            # Extract region
            echo "if [[ "'${regionalfile}'" -eq 0 ]];then" >> batch_files/file_${fileref}.ksh
            echo "   ncks -O -d lon,${lonw},${lone} -d lat,${lats},${latn} ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL_monthlymean.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_monthlymean.nc" >> batch_files/file_${fileref}.ksh
            echo "else" >> batch_files/file_${fileref}.ksh
            echo "   ncks -O -d lat,${lats},${latn} ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_ATL_monthlymean.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_monthlymean.nc" >> batch_files/file_${fileref}.ksh
            echo "fi" >> batch_files/file_${fileref}.ksh

            # Extract DJF and average
            if [[ ${startmon} == 10 ]];then
               echo "ncks -O -d time,2,4 ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_monthlymean.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJF.nc" >> batch_files/file_${fileref}.ksh
            fi
            if [[ ${startmon} == 11 ]];then
               echo "ncks -O -d time,1,3 ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_monthlymean.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJF.nc" >> batch_files/file_${fileref}.ksh
            fi
            if [[ ${startmon} == 12 ]];then
               echo "ncks -O -d time,0,2 ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_monthlymean.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJF.nc" >> batch_files/file_${fileref}.ksh
            fi
            echo "ncra -O ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJF.nc ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc" >> batch_files/file_${fileref}.ksh

            echo "rm -rf tmp_1_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_1_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_2_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_2_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_3_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_3_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_4_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_4_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_5_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_5_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_6_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_6_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_7_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_7_avg_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_8_${var}_${ensnum}_${startdate}_${enddate}.nc tmp_8_avg_${var}_${ensnum}_${startdate}_${enddate}.nc file_ens${ensnum}_${startdate}_${enddate}_${var}_header.txt" >> batch_files/file_${fileref}.ksh  

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/%J.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:15" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

            # Check that the combined file hasn't been created
            if [[ ! -f ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc ]]; then
               echo "creating file ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc"
               bsub < batch_files/file_${fileref}_submit.sh
               let fileref=$fileref+1
            else
               echo "file ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc exists"
               # For an unknown reason some DJFmean files have 360 lon. Delete these
               ncdump -h ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc > file_${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean_header.txt
               # Grab the lon in the dimensions
               lonline=`egrep "lon = " file_${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean_header.txt | head -1`
               # Grab between '= ' and ' ;'
               lonval=`echo ${lonline} | grep -o -P '(?<== ).*(?= ;)'`
               if [[ ${lonval} -eq 360 ]];then
                  rm -rf ${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean.nc
               fi
               rm -rf file_${model}_ens${ensnum}_${startdate}_${enddate}_${var}_0_${regionname}_DJFmean_header.txt
            fi
            # End loop over files
            done < ${exeventdir}filelist_ens${ensnum}_${initialcondition}_ic.txt
         # End variable loop
         done
      # End initial condition loop
   done
   # End ensemble loop
done
