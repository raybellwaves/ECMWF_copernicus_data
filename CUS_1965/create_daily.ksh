#!/bin/ksh
#
# Average the 6 hourly data into daily data
# Adapted from /projects/rsmas/kirtman/rxb826/DATA/NMME/CFSV2/sfcuv_daily/create_daily.ksh
#
# 3/8/17

ddir='/projects/rsmas/kirtman/rxb826/DATA/MetOffice_GloSea5/sfcuv/'
odir='/projects/rsmas/kirtman/rxb826/DATA/MetOffice_GloSea5/sfcuv_daily/'

# counter
fileref=0

for ensemble in {1..12}; do
   mkdir -p ens${ensemble}
done 

for year in 2013 2014 2015; do
#for year in 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015; do
   for month in 01 02 10 11 12 ; do
   #for month in 01 ; do
      for var in u v ; do
      #for var in u ; do
         for ensemble in 1 2 3 4 5 6 7 8 9 10 11 12 ; do
         #for ensemble in 1 ; do

            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh

            # Number of points in file is 861 (215 days)

            year2=`expr $year + 1`

            if [[ ${ensemble} == 1 || ${ensemble} == 2 || ${ensemble} == 3 ]];then
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
                  elif [ `expr ${year}2 % 100` -eq 0 ];then
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
            fi

            if [[ ${ensemble} == 4 || ${ensemble} == 5 || ${ensemble} == 6 ]];then
               startdate=${year}${month}09
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
                     enddate=${year}0811
                  else
                     enddate=${year}0812
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
                     enddate=${year}0911
                  else
                     enddate=${year}0912
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
                     enddate=${year2}0511
                  else
                     enddate=${year2}0512
                  fi
               fi
               if [[ ${month} == 11 ]];then
                  if [ `expr ${year2} % 4` -ne 0 ]; then
                     leapyear=0
                  elif [ `expr ${year2} % 400` -eq 0 ]; then
                     leapyear=1
                  elif [ `expr ${year}2 % 100` -eq 0 ];then
                     leapyear=0
                  else
                     leapyear=1
                  fi
                  if [[ ${leapyear} -eq 0 ]];then
                     enddate=${year2}0611
                  else
                     enddate=${year2}0612
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
                     enddate=${year2}0711
                  else
                     enddate=${year2}0712
                  fi
               fi
            fi

            if [[ ${ensemble} == 7 || ${ensemble} == 8 || ${ensemble} == 9 ]];then
               startdate=${year}${month}17
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
                     enddate=${year}0819
                  else
                     enddate=${year}0820
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
                     enddate=${year}0919
                  else
                     enddate=${year}0920
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
                     enddate=${year2}0519
                  else
                     enddate=${year2}0520
                  fi
               fi
               if [[ ${month} == 11 ]];then
                  if [ `expr ${year2} % 4` -ne 0 ]; then
                     leapyear=0
                  elif [ `expr ${year2} % 400` -eq 0 ]; then
                     leapyear=1
                  elif [ `expr ${year}2 % 100` -eq 0 ];then
                     leapyear=0
                  else
                     leapyear=1
                  fi
                  if [[ ${leapyear} -eq 0 ]];then
                     enddate=${year2}0619
                  else
                     enddate=${year2}0620
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
                     enddate=${year2}0719
                  else
                     enddate=${year2}0720
                  fi
               fi
            fi

            if [[ ${ensemble} == 10 || ${ensemble} == 11 || ${ensemble} == 12 ]];then
               startdate=${year}${month}25
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
                     enddate=${year}0827
                  else
                     enddate=${year}0828
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
                     enddate=${year}0927
                  else
                     enddate=${year}0928
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
                     enddate=${year2}0527
                  else
                     enddate=${year2}0528
                  fi
               fi
               if [[ ${month} == 11 ]];then
                  if [ `expr ${year2} % 4` -ne 0 ]; then
                     leapyear=0
                  elif [ `expr ${year2} % 400` -eq 0 ]; then
                     leapyear=1
                  elif [ `expr ${year}2 % 100` -eq 0 ];then
                     leapyear=0
                  else
                     leapyear=1
                  fi
                  if [[ ${leapyear} -eq 0 ]];then
                     enddate=${year2}0627
                  else
                     enddate=${year2}0628
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
                     enddate=${year2}0727
                  else
                     enddate=${year2}0728
                  fi
               fi
            fi

            # Day 1 only has 06, 12 and 18
            echo "ncks -O -d time,0,2 ${ddir}ens${ensemble}/EGRRs12.${startdate}.10${var}.nc ${odir}ens${ensemble}/tmp_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh     
            # Average the time points
            echo "ncra -O ${odir}ens${ensemble}/tmp_${startdate}${var}.nc ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh  
            # The average time of 06, 12 and 18 is 12 so subtract 12 (0.5) from the time value
            echo "ncap2 -O -s 'time=time-0.5' ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc ${odir}ens${ensemble}/day000_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh

            # Loop over the rest of the days. x points is y days
            for i in {1..214} ; do
               # Indicies
               point1=`expr $i \* 4`
               point1=`expr $point1 - 1`
               point2=`expr $point1 + 3`
               echo "ncks -O -d time,${point1},${point2} ${ddir}ens${ensemble}/EGRRs12.${startdate}.10${var}.nc ${odir}ens${ensemble}/tmp_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
               # Average the time points
               echo "ncra -O ${odir}ens${ensemble}/tmp_${startdate}${var}.nc ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
               # The average time of the 00, 06, 12 and 18 file is 09 so subtract 09 (0.375) from the time value
               if [[ ${i} -lt 10 ]];then
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc ${odir}ens${ensemble}/day00${i}_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
               elif [[ ${i} -gt 9 && ${i} -lt 100 ]];then
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc ${odir}ens${ensemble}/day0${i}_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
               else
                  echo "ncap2 -O -s 'time=time-0.375' ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc ${odir}ens${ensemble}/day${i}_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
               fi
               echo "rm -rf ${odir}ens${ensemble}/tmp_${startdate}${var}.nc ${odir}ens${ensemble}/tmp2_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh
            done

            # Concat daily files into a yearly file
            echo "/nethome/rxb826/local/bin/ncrcat -O ${odir}ens${ensemble}/day???_${startdate}${var}.nc ${odir}ens${ensemble}/${var}10_day_GloSea5_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc" >> batch_files/file_${fileref}.ksh
            echo "rm -rf ${odir}ens${ensemble}/day***_${startdate}${var}.nc" >> batch_files/file_${fileref}.ksh

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/%J.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:10" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh 

            # Check that the combined file hasn't been created
            if [[ ! -f ${odir}ens${ensemble}/uv10_day_GloSea5_${year}${month}_r${ensemble}i1p1_${startdate}-${enddate}.nc ]]; then
               echo "creating file ${odir}ens${ensemble}/${var}10_day_GloSea5_${year}${month}_r${ensemble}i1p1_${startdate}_${enddate}.nc"
               bsub < batch_files/file_${fileref}_submit.sh
               gettingafile=1
               let fileref=$fileref+1
            else
               echo "file ${odir}ens${ensemble}/${var}10_day_GloSea5_${year}${month}_r${ensemble}i1p1_${startdate}_${enddate}.nc exists"
               if [[ ${gettingafile} -ne 1 ]];then
                  gettingafile=0
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
