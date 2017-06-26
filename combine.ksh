#!/bin/ksh
#
# Combine the u and v data created in create_daily.ksh

ddir='/projects/rsmas/kirtman/rxb826/DATA/X/sfcuv_daily/'

# counter
fileref=0

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12; do
      for ensemble in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do

         rm -rf batch_files/file_${fileref}.ksh
         echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
         chmod u+x batch_files/file_${fileref}.ksh

         year2=`expr $year + 1`
         startdate=${year}${month}01

         if [[ ${month} == 01 ]];then
            if [ `expr ${year} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year}0803
            else
               enddate=${year}0804
            fi               
         fi

         if [[ ${month} == 02 ]];then
            if [ `expr ${year} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year}0903
            else
               enddate=${year}0904
            fi               
         fi

         if [[ ${month} == 03 ]];then
            enddate=${year}1001
         fi

         if [[ ${month} == 04 ]];then
            enddate=${year}1101
         fi

         if [[ ${month} == 05 ]];then
            enddate=${year}1201
         fi

         if [[ ${month} == 06 ]];then               
            enddate=${year2}0101
         fi

         if [[ ${month} == 07 ]];then
            enddate=${year2}0131
         fi

         if [[ ${month} == 08 ]];then
            if [ `expr ${year2} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year2} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year2} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year2}0302
            else
               enddate=${year2}0303
            fi
         fi

         if [[ ${month} == 09 ]];then
            if [ `expr ${year2} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year2} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year2} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year2}0402
            else
               enddate=${year2}0403
            fi              
         fi

         if [[ ${month} == 10 ]];then
            if [ `expr ${year2} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year2} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year2} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year2}0502
            else
               enddate=${year2}0503
            fi
         fi

         if [[ ${month} == 11 ]];then
            if [ `expr ${year2} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year2} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year2} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year2}0602
            else
               enddate=${year2}0603
            fi
         fi

         if [[ ${month} == 12 ]];then
            if [ `expr ${year2} % 4` -ne 0 ]; then
               leapyear=0
            elif [ `expr ${year2} % 400` -eq 0 ]; then
               leapyear=1
            elif [ `expr ${year2} % 100` -eq 0 ];then
               leapyear=0
            else
               leapyear=1
            fi
            if [[ ${leapyear} -eq 0 ]];then
               enddate=${year2}0702
            else
               enddate=${year2}0703
            fi
         fi

         # Copy variable
         echo "cp ${odir}ens${ensemble}/u10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
         echo "ncks -A ${odir}ens${ensemble}/v10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
         # Remove the U and V files
         echo "rm -rf ${odir}ens${ensemble}/u10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ${odir}ens${ensemble}/v10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
         # Calculate wind speed
         echo "ncap2 -O -s 'ws10=sqrt(u10^2 + v10^2)' ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc -v ${odir}ens${ensemble}/tmp_${ensemble}_${year}${month}_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
         # Extract ws10 from the file
         echo "ncks -O -v ws10 ${odir}ens${ensemble}/tmp_${ensemble}_${year}${month}_${startdate}-${enddate}.nc ${odir}ens${ensemble}/ws10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
         echo "rm -rf ${odir}ens${ensemble}/tmp_${ensemble}_${year}${month}_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh

         # Submit script
         rm -rf batch_files/file_${fileref}_submit.sh
         echo "#BSUB -o logs/%J.out" > batch_files/file_${fileref}_submit.sh 
         echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh
         echo "#BSUB -W 0:10" >> batch_files/file_${fileref}_submit.sh 
         echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
         echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
         echo "#" >> batch_files/file_${fileref}_submit.sh
         echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh

         # Check that the file hasn't been created
         if [[ ! -f ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ]]; then
            echo "creating file ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc"
            bsub < batch_files/file_${fileref}_submit.sh
            gettingafile=1
            let fileref=$fileref+1
         else
            echo "file ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc exists"
            if [[ ${gettingafile} -ne 1 ]];then
               gettingafile=0
            fi
         fi

      # End ensemble loop
      done
   # End month loop
   done
# End year loop
done
