# ECMWF_copernicus_data
Scripts to download and manipulate data obtained from ECMWF for a specific project

1. Download raw grib files: get_data_grib.ksh
2. Convert the grib files to NetCDF: convert_grib.ksh
3. Check the NetCDF files are the same size: file_chk.ksh
4. Seperate the ensemble data in the NetCDF files: split_ncfiles.ksh
5. Check the individual ensemble NetCDF files are the same size: splfile_chk.ksh
6. Make sure the individual ensemble NetCDF files are not full of rubbish: file_chk_py.ksh
