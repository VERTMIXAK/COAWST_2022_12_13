function [x,y,amp,phase]=get_coeff(Model,type,cons);
%=========================================================================
% function to extract amplitude and phase grids from
% a model ModName (OTIS format) calculated on bathymetry grid
% Gridname
%
% usage:
% [x,y,amp,phase]=get_coeff(Model,type,cons);
% PARAMETERS
%
% INPUT
% Model - control file name for a tidal model, consisting of lines
%         <elevation file name>
%         <transport file name>
%         <grid file name>
%         <function to convert lat,lon to x,y>
% 4th line is given only for models on cartesian grid (in km)
% All model files should be provided in OTIS format
% type - one of 'z','u','v' (velocities),'U','V' (transports)
% cons - tidal constituent given as char*
%
% output:
% amp - amplituide (m, m^2/s or cm/s for z, U/V, u/v type)
% phase - phase degrees GMT
% x,y - grid coordinates
%
% sample call:
% [x,y,amp,phase]=get_coeff('DATA/Model_Ross_prior','z','k1');
%
% See also: "extract_hc"  for extracting the harmonic coefficients
%                         for all constituents at a specific (lat, lon).
%
%           "ellipse"     for getting ellipse parameters for a
%                         specified (lat, lon) and specified constituent.
%
%           "get_ellipse" for extracting full-grid maps of ellipse
%                         parameters (umaj, umin, inc, G_phase).
%
% Written by:   Lana Erofeeva (OSU): serofeeva@coas.oregonstate.edu
% Modified by:  Laurie Padman (ESR): padman@esr.org
%               September 29, 2004
%
%========================================================================

if(type(1:1)=='z');
    k=1;
else
    k=2;
end
[ModName,GridName,Fxy_ll]=rdModFile(Model,k);
[Flag]=checkTypeName(ModName,GridName,type);
if(Flag>0);
    return
end
[ll_lims,hz,mz,iob]=grd_in(GridName);
[n,m]=size(hz);
[x,y]=XY(ll_lims,n,m);
stx=x(2)-x(1);
sty=y(2)-y(1);
conList=rd_con(ModName);
[nc,dum]=size(conList);
cons=deblank(lower(cons));
bcon=deblank(cons(end:-1:1));
cons=bcon(end:-1:1);
lc=length(cons);
k0=0;
for k=1:nc
    if(cons==conList(k,1:lc));
        ic=k;
    else
        k0=k0+1;
    end
end
if(k0==nc);
    fprintf('No constituent %s in %s\n',cons,ModName);
    return
end
if(type=='z');
    [z,th_lim,ph_lim]=h_in(ModName,ic);
    [nn,mm]=size(z);
    if nn~=n | mm~=m,TMDcrash(n,m,nn,mm);
        return;
    end
    amp=abs(z);
    phase=atan2(-imag(z),real(z))*180/pi;
    phase(find(phase<0))=phase(find(phase<0))+360;
else
    [U,V,th_lim,ph_lim]=u_in(ModName,ic);
    [nn,mm]=size(U);
    if(nn~=n | mm~=m);
        TMDcrash(n,m,nn,mm);
        return;
    end
    [hu,hv]=Huv(hz);
    if(type=='u' | type=='U');
        x=x-stx/2;
        amp=abs(U);
        if(type=='u');
            amp=amp./max(hu,10)*100;
        end
        phase=atan2(-imag(U),real(U))*180/pi;
        phase(find(phase<0))=phase(find(phase<0))+360;
    else
        y=y-sty/2;
        amp=abs(V);
        if(type=='v');
            amp=amp./max(hv,10)*100;
        end
        phase=atan2(-imag(V),real(V))*180/pi;
        phase(find(phase<0))=phase(find(phase<0))+360;
    end
end
return
