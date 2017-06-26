#!/bin/ksh

filesl=1683089460 # lowest file size (bytes). Need to convert one manually first

# Setup file to capture files that didn't create
rm -rf wrongncfiles.ksh
echo "#!/bin/ksh" > wrongncfiles.ksh
chmod u+x wrongncfiles.ksh

for year in {1993..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do

         # Check for existence of file
         if [[ ! -f X.${year}${month}01.10${var}.nc ]]; then
            echo "rm -rf X.${year}${month}01.10${var}.nc" >> wrongncfiles.ksh
         else
            files=`ls -la LFPWs5.${year}${month}01.10${var}.nc | awk '{ print $5}'`
            if [[ ${files} -lt ${filesl} ]] ; then
               echo "rm -rf LFPWs5.${year}${month}01.10${var}.nc" >> wrongncfiles.ksh
            fi
         fi

      done
   done
done
