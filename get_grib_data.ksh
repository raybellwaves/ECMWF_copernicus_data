#!/bin/ksh
#
# Get data provided to me by Copernicus
# X denotes things to change
#
# MM/DD/YY

ddir=ftp://ftp.ecmwf.int/pub/copsup/CUS-XXXX/X/

mkdir -p batch_files

# counter
fileref=0

for year in {1993..2011}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do

         rm -rf batch_files/file_${fileref}.ksh
         echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
         chmod u+x batch_files/file_${fileref}.ksh
         echo "wget ${ddir}X.${year}${month}01.10${var}.grib" >> batch_files/file_${fileref}.ksh

         # Submit script
         rm -rf batch_files/file_${fileref}_submit.sh
         echo "#BSUB -o logs/%J.out" >> batch_files/file_${fileref}_submit.sh 
         echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh 
         echo "#BSUB -W 2:00" >> batch_files/file_${fileref}_submit.sh 
         echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
         echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
         echo "#" >> batch_files/file_${fileref}_submit.sh
         echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh  

         # Check that the file hasn't been downloaded
         if [[ ! -f X.${year}${month}01.10${var}.grib ]]; then
            echo "creating file X.${year}${month}01.10${var}.grib"
            bsub < batch_files/file_${fileref}_submit.sh
            gettingafile=1
            let fileref=$fileref+1
         else
            echo "file X.${year}${month}01.10${var}.grib exists"
            if [[ ${gettingafile} -ne 1 ]];then
               gettingafile=0
            fi
         fi

         # I can only download ~15 files at a times.
         # Put in a sleep command as not to skip files
         # Use remainder operator (also known as modulo operator). if number / 14 gives 0 do this only if a job(s) are sumbitted
         if [[ ${fileref} -ne 0 ]];then
            if [[ ${gettingafile} -eq 1 ]];then
               if [[ $((${fileref}%14)) -eq 0 ]];then 
                  sleep 120m # From wall clock time in submit file
               fi
            fi
         fi
      
      # End var loop   
      done
   # End month loop
   done
# End year loop
done 
