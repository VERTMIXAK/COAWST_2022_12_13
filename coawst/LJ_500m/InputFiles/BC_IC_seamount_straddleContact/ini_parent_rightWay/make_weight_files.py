import pycnal

srcgrd = pycnal.grid.get_ROMS_grid('LJ_500m_parent')
dstgrd = pycnal.grid.get_ROMS_grid('LJ_500m_parent_seamount')

pycnal.remapping.make_remap_grid_file(srcgrd)
pycnal.remapping.make_remap_grid_file(srcgrd,Cpos='u')
pycnal.remapping.make_remap_grid_file(srcgrd,Cpos='v')

pycnal.remapping.make_remap_grid_file(dstgrd)
pycnal.remapping.make_remap_grid_file(dstgrd,Cpos='u')
pycnal.remapping.make_remap_grid_file(dstgrd,Cpos='v')


type = ['rho','u','v']

for typ in type:
        grid1_file = 'remap_grid_LJ_500m_parent_'+str(typ)+'.nc'
        grid2_file = 'remap_grid_LJ_500m_parent_seamount_'+str(typ)+'.nc'
        interp_file1 = 'remap_weights_LJ_500m_parent_to_LJ_500m_parent_seamount_bilinear_'+str(typ)+'_to_'+str(typ)+'.nc'
        interp_file2 = 'remap_weights_LJ_500m_parent_seamount_to_LJ_500m_parent_bilinear_'+str(typ)+'_to_'+str(typ)+'.nc'
        map1_name = 'LJ_500m_parent to LJ_500m_parent_seamount Bilinear Mapping'
        map2_name = 'LJ_500m_parent_seamount to LJ_500m_parent Bilinear Mapping'
        num_maps = 1
        map_method = 'bilinear'
            
        print("Making "+str(interp_file1)+"...")
            
        pycnal.remapping.compute_remap_weights(grid1_file,grid2_file,\
                         interp_file1,interp_file2,map1_name,\
                         map2_name,num_maps,map_method)
