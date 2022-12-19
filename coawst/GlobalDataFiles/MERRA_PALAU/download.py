import sys
import xarray as xr

url = sys.argv[1]
outFile = sys.argv[2]


#print('outfile  ',outFile)
#print('url      ',url)
#print(' ')

#url = u'http://etc/etc/hourly?varname[0:1:10][0:1:30]'
#print('ds part')
ds = xr.open_dataset(url, engine='netcdf4')  # or engine='pydap'
#print('dsToNetcdf part')
ds.to_netcdf(outFile)
