import pycnal
import pycnal_toolbox

src_varname = ['zeta','temp','salt','u','v','ubar','vbar']
#src_varname = ['ubar','vbar','zeta','temp','salt','u','v']

# Change src_filename to your directory for the files containing variable data
src_filename = '../../BC_IC_flat/ini_parent/LJ_ic_parent.nc'
wts_file = "./remap_weights_LJ_500m_parent_to_LJ_500m_parent_seamount_bilinear_*"
src_grd = pycnal.grid.get_ROMS_grid('LJ_500m_parent')
dst_grd = pycnal.grid.get_ROMS_grid('LJ_500m_parent_seamount')
# Outfile is a parameter to allow you to place these created remap files in a different
# directory than the one that is default which is where the file came from.

print(' ')
print('in ini script')
print(' ')

dst_var = pycnal_toolbox.remapping(src_varname, src_filename,\
                                   wts_file,src_grd,dst_grd,rotate_uv=False)

print('done with ini')
