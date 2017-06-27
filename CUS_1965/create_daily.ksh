#!/bin/ksh
#
# Average the 6 hourly data into daily data

ddir='/projects/rsmas/kirtman/rxb826/DATA/X/sfcuv/'
odir='/projects/rsmas/kirtman/rxb826/DATA/X/sfcuv_daily/'

# counter
fileref=0

for ensemble in {1..14}; do
   mkdir -p ens${ensemble}
done 

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 ; do
      for var in u v ; do
         for ensemble in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ; do

            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh

            # Number of points in file is 861 (215 days)

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

            # Loop over days. 861 points in 214 days
            for i in {0..214} ; do
               # Indicies
               point1=`expr $i \* 4`
               point2=`expr $point1 + 3`
               echo "ncks -O -d time,${point1},${point2} ${ddir}ens${ensemble}/X.${year}${month}01.10${var}.nc ${odir}ens${ensemble}/tmp_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
               # Average the time points
               echo "ncra -O ${odir}ens${ensemble}/tmp_${year}${month}${var}.nc ${odir}ens${ensemble}/tmp2_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
               # The average time of the 00, 06, 12 and 18 file is 09 so subtract 09 (0.375) from the time value
               if [[ ${i} -lt 10 ]];then
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${year}${month}${var}.nc ${odir}ens${ensemble}/day00${i}_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
               elif [[ ${i} -gt 9 && ${i} -lt 100 ]];then
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${year}${month}${var}.nc ${odir}ens${ensemble}/day0${i}_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
               else
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${year}${month}${var}.nc ${odir}ens${ensemble}/day${i}_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
               fi
               echo "rm -rf ${odir}ens${ensemble}/tmp_${year}${month}${var}.nc ${odir}ens${ensemble}/tmp2_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
            done

            # Concat daily files into a yearly file
            echo "ncrcat -O ${odir}ens${ensemble}/day???_${year}${month}${var}.nc ${odir}ens${ensemble}/${var}10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "rm -rf ${odir}ens${ensemble}/day***_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/%J.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:15" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh 

            # Check that the file hasn't been created
            if [[ ! -f ${odir}ens${ensemble}/uv10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ]]; then
               echo "creating file ${odir}ens${ensemble}/${var}10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc"
               bsub < batch_files/file_${fileref}_submit.sh
               gettingafile=1
               let fileref=$fileref+1
            else
               echo "file ${odir}ens${ensemble}/${var}10_day_X_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc exists"
               if [[ ${gettingafile} -ne 1 ]];then
                  gettingafile=0
               fi
            fi    


            #exit 0
         # End ensemble loop
         done
      # End var loop   
      done
   # End month loop
   done
# End year loop
done  
