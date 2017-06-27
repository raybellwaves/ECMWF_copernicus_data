#!/bin/ksh
#
# Split the netcdf file into ensembles

# counter
fileref=0

# Need to know number of ensemlbes in file
for ensemble in {1..14}; do
   mkdir -p ens${ensemble}
done 

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do
         for ensemble in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 ; do
            ensemblesave=`expr ${ensemble} + 1`

            rm -rf batch_files/file_${fileref}.ksh
            echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
            chmod u+x batch_files/file_${fileref}.ksh
            echo "ncks -O -d number,${ensemble} X.${year}${month}01.10${var}.nc ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncwa -O -a number ens${ensemblesave}/X.${year}${month}01.10${var}.nc ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncks -O -x -v number ens${ensemblesave}/X.${year}${month}01.10${var}.nc ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> batch_files/file_${fileref}.ksh
            echo "ncpdq -O -a -latitude ens${ensemblesave}/X.${year}${month}01.10${var}.nc ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> batch_files/file_${fileref}.ksh
            echo "cdo setreftime,1850-01-01,00:00:00,days ens${ensemblesave}/X.${year}${month}01.10${var}.nc ens${ensemblesave}/tmp_${year}${month}${var}.nc" >> batch_files/file_${fileref}.ksh
            echo "mv ens${ensemblesave}/tmp_${year}${month}${var}.nc ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> batch_files/file_${fileref}.ksh

            # Submit script
            rm -rf batch_files/file_${fileref}_submit.sh
            echo "#BSUB -o logs/%J.out" > batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -e logs/%J.err" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -W 0:20" >> batch_files/file_${fileref}_submit.sh 
            echo "#BSUB -q general" >> batch_files/file_${fileref}_submit.sh
            echo "#BSUB -n 1" >> batch_files/file_${fileref}_submit.sh   
            echo "#" >> batch_files/file_${fileref}_submit.sh
            echo "batch_files/file_${fileref}.ksh" >> batch_files/file_${fileref}_submit.sh  

            # Check that the file hasn't been created
            if [[ ! -f ens${ensemblesave}/X.${year}${month}01.10${var}.nc ]]; then
               echo "creating file ens${ensemblesave}/X.${year}${month}01.10${var}.nc"
               bsub < batch_files/file_${fileref}_submit.sh
               gettingafile=1
               let fileref=$fileref+1
            else
               echo "file ens${ensemble}/X.${year}${month}01.10${var}.nc exists"
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
