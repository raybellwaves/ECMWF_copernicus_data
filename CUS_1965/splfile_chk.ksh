lit the netcdf files

filesl=448832860 # Need to know minimum size

# Setup file to capture files didn't create
rm -rf wrongncfiles.ksh
echo "#!/bin/ksh" > wrongncfiles.ksh
chmod u+x wrongncfiles.ksh

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do
         for ensemble in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 ; do
            ensemblesave=`expr ${ensemble} + 1`

            files=`ls -la ens${ensemblesave}/X.${year}${month}01.10${var}.nc | awk '{ print $5}'`
               if [ ${files} -lt ${filesl} ] ; then
                  echo "rm -rf ens${ensemblesave}/X.${year}${month}01.10${var}.nc" >> wrongncfiles.ksh
               fi

         # End ensemble loop
         done
      # End var loop   
      done
   # End month loop
   done
# End year loop
done 
