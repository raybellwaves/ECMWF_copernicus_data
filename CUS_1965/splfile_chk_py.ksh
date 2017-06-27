#!/bin/ksh
#
# Check split the netcdf file into ensembles

# Setup file to capture files didn't create
rm -rf wrongncfiles.ksh
echo "#!/bin/ksh" > wrongncfiles.ksh
chmod u+x wrongncfiles.ksh

for year in {1994..2015}; do
   for month in 01 02 03 04 05 06 07 08 09 10 11 12 ; do
      for var in u v ; do
         for ensemble in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 ; do
            ensemblesave=`expr ${ensemble} + 1`

            rm -rf file.py
cat > file.py << EOF
import xarray as xr
import numpy as np
ds = xr.open_dataset('ens${ensemblesave}/X.${year}${month}01.10${var}.nc')
a = ds['${var}10']
a1 = a[0,0,0].values
if np.isnan(a1):
    with open('wrongncfiles.ksh','a') as f:
        print('rm -rf ens${ensemblesave}/X.${year}${month}01.10${var}.nc', file=f)
EOF
            python file.py
         # End ensemble loop
         done
      # End var loop   
      done
   # End month loop
   done
# End year loop
done 
