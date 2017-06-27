#!/bin/ksh
#
# Convert the files to NetCDF
#
# Check the contents of the grib file by doing grib_ls X.grib
# Requires EcCodes (https://software.ecmwf.int/wiki/display/ECC/ecCodes+Home)

# counter
fileref=0

for ensemble in {1..14}; do
   mkdir -p ens${ensemble}
done 

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do

         rm -rf batch_files/file_${fileref}.ksh
         echo "#!/bin/ksh" > batch_files/file_${fileref}.ksh
         chmod u+x batch_files/file_${fileref}.ksh
         echo "grib_to_netcdf -R 18500101 -o LFPWs5.${year}${month}01.10${var}.nc LFPWs5.${year}${month}01.10${var}.grib" >> batch_files/file_${fileref}.ksh

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
         if [[ ! -f X.${year}${month}01.10${var}.nc ]]; then
            echo "creating file X.${year}${month}01.10${var}.nc"
            bsub < batch_files/file_${fileref}_submit.sh
            gettingafile=1
            let fileref=$fileref+1
         else
            echo "file X.${year}${month}01.10${var}.nc exists"
            if [[ ${gettingafile} -ne 1 ]];then
               gettingafile=0
            fi
         fi

      # End var loop   
      done
   # End month loop
   done
# End year loop
done 
