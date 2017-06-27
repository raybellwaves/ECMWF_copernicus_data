1. Download raw grib files: get_data_grib.ksh
2. Convert the grib files to NetCDF: convert_grib.ksh
3. Check the NetCDF files are the same size: file_chk.ksh
4. Seperate the ensemble data in the NetCDF files: split_ncfiles.ksh
5. Check the individual ensemble NetCDF files are the same size: splfile_chk.ksh
6. Make sure the individual ensemble NetCDF files are not full of rubbish: file_chk_py.ksh
7. Average the 6 hourly data into daily data: create_daily.ksh (this needs to be updated using python Pandas and xarray)
8. Combine the u and v variables from the daily data: combine_data.ksh
