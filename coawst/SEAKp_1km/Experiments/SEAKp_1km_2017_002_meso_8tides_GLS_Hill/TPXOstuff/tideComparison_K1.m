clear;
warning('off','all');   % JGP the warning messages were driving me nutz
%----------------------------------------
% load tpxo ellipses
%----------------------------------------
%Note that OTIS screws up x & y convention. x(j) is the column  x index, y(i) is the row index:
base = '/import/VERTMIXFS/jgpender/ROMS/OTIS_DATA/';
ufile=[base,'u_tpxo9.v1'];
gfile=[base,'grid_tpxo9'];
mfile=[base,'Model_tpxo9.v1'];

% ufile=[base,'u_tpxo7.2'];
% gfile=[base,'grid_tpxo7.2'];
% mfile=[base,'Model_tpxo7.2'];

[~,dum] = unix('ls ../*.nc');  model.gfile = dum(1:end-1)
[~,dum] =  unix('ls ../netcdfOutput_days032_060/*_his_* | head -1'); model.HISfile = dum(1:end-1)

grid = roms_get_grid(model.gfile,model.HISfile,0,1);

tpxomodel='~/archROMS/OTIS_DATA/Model_tpxo9.v1';

done('section 1')

%% Here is the stuff you want to edit

[~,dum] = unix('ls ../netcdfOutput_days032_060 | tail -1 | cut -d "_" -f1');model.file_prefix = [dum(1:end-1),'_']
model.file_suffix = '';

% SEAK footprint - this is to size the TPXO stuff
lon0 = 220; lon1 = 230;
lat0 = 53;  lat1 = 60;
hskip = 4;   %!!!!!!!!!!!!!! JGP -  this was hskip = 4

myTide = 'K1';
% Single tidal component
consts = {lower(myTide)};%{'m2','s2','n2','k2','o1','p1','k1'}


% make a custom mask_rho based on a new D_min
D_min   = 100;
model.h = nc_varget(model.gfile,'h');
mask_rho = nc_varget(model.gfile,'mask_rho');
% fig(1);clf;pcolor(model.h);shading flat;colorbar
% fig(2);clf;pcolor(mask_rho);shading flat;colorbar
mask_rho(model.h < D_min) = 0; mask_rho(mask_rho == 0) = nan;%mask_rho=mask_rho(2:end-1,2:end-1);
fig(3);clf;pcolor(mask_rho);shading flat;colorbar
done('section 2')

%% Archive zeta, ubar and vbar in their own file if not already done.
if ~exist( ['./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'])
    disp(['!ncrcat -v zeta -O ','../netcdfOutput_days032_060/',model.file_prefix,'his2_*.nc ','./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'])
    eval(['!ncrcat -v zeta -O ','../netcdfOutput_days032_060/',model.file_prefix,'his2_*.nc ','./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'])
%     eval(['!ncrcat -v zeta -d ocean_time,0 -O ','../netcdfOutput/',model.file_prefix,'his_*001.nc ','./',model.file_prefix,'his',model.file_suffix,'_zeta.nc'])
    done('writing zeta')
    eval(['!ncrcat -v ubar -O ','../netcdfOutput_days032_060/',model.file_prefix,'his2_*.nc ','./',model.file_prefix,'his2',model.file_suffix,'_ubar.nc'])
%     eval(['!ncrcat -v ubar -d ocean_time,0 -O ','../netcdfOutput/',model.file_prefix,'his_*001.nc ','./',model.file_prefix,'his',model.file_suffix,'_ubar.nc'])
    done('writing ubar')
    eval(['!ncrcat -v vbar                 -O ','../netcdfOutput_days032_060/',model.file_prefix,'his2_*.nc ','./',model.file_prefix,'his2',model.file_suffix,'_vbar.nc'])
%     eval(['!ncrcat -v vbar -d ocean_time,0 -O ','../netcdfOutput/',model.file_prefix,'his_*001.nc ','./',model.file_prefix,'his',model.file_suffix,'_vbar.nc'])
    done('writing vbar')
    
%     eval('!ncrcat -O palau_his_zeta.nc palau_his2_zeta.nc palau_his2_zeta.nc');
%     eval('!ncrcat -O palau_his_ubar.nc palau_his2_ubar.nc palau_his2_ubar.nc');
%     eval('!ncrcat -O palau_his_vbar.nc palau_his2_vbar.nc palau_his2_vbar.nc');
    
    
    
end

eval(['outfile =  ''','./',model.file_prefix,num2str(lon0),'_',num2str(lon1),'_',num2str(lat0),'_',num2str(lat1),'_',num2str(hskip),'_',myTide,'.mat'''])

%% Do the tidal analysis (if it's not already done)

if ~exist(outfile)
    
    % TPXO stuff
    [tpxo.lon,tpxo.lat,tpxo.amp_zeta,tpxo.pha_zeta]=tmd_get_coeff(mfile,'z',myTide);
    [tpxo.lon,tpxo.lat,tpxo.amp_ubar,tpxo.pha_ubar]=tmd_get_coeff(mfile,'u',myTide);
    [tpxo.lon,tpxo.lat,tpxo.amp_vbar,tpxo.pha_vbar]=tmd_get_coeff(mfile,'v',myTide);done('loading tpxo')
    
    tpxo.amp_zeta(tpxo.amp_zeta==0) = nan;
    tpxo.amp_ubar(tpxo.amp_ubar==0) = nan;
    tpxo.amp_vbar(tpxo.amp_vbar==0) = nan;
    tpxo.pha_zeta(tpxo.pha_zeta==0) = nan;
    tpxo.pha_ubar(tpxo.pha_ubar==0) = nan;
    tpxo.pha_vbar(tpxo.pha_vbar==0) = nan;
    tpxo.amp_ubar = tpxo.amp_ubar/100;
    tpxo.amp_vbar = tpxo.amp_vbar/100;    
    
    % ROMS stuff. It seems silly to take a subset of my own domain but I
    % guess this is the easiest way to get my footprint to match the TPXO
    % footprint.
    
    tmplon2D=nc_varget(model.gfile,'lon_rho');
    tmplon=tmplon2D(1,:);
    tmplat2D=nc_varget(model.gfile,'lat_rho');
    tmplat=tmplat2D(:,1);
    idx = find(tmplon>=lon0&tmplon<=lon1); model.idx = idx;
    jdx = find(tmplat>=lat0&tmplat<=lat1); model.jdx = jdx;
    
    
    % Get the area differentials for Harper's figure of merit.
    %   Try to do this right. Even if lat and lon are on a perfectly
    %   rectilinear grid, this means dx and dy will vary. If it's a
    %   telescoping grid then this is all the more true.
    %   roms_get_grid has given me x_rho, y_psi, etc etc
    
%     X  = grid.x_rho(1:hskip:end,1:hskip:end);
%     Y  = grid.y_rho(1:hskip:end,1:hskip:end);
%     dX = X(:,2:end) - X(:,1:end-1);
%     dY = Y(2:end,:) - Y(1:end-1,:);
%     model.dA = dX(1:end-1,:) .* dY(:,1:end-1);
    X  = grid.x_rho(jdx(1:hskip:end),idx(1:hskip:end));
    Y  = grid.y_rho(jdx(1:hskip:end),idx(1:hskip:end));
    dX = X(:,2:end) - X(:,1:end-1);
    dY = Y(2:end,:) - Y(1:end-1,:);
    model.dA = dX(1:end-1,:) .* dY(:,1:end-1);
    
    % get the area area up to the proper size by duplicating the last row
    % and column
    [dumy,dumx]=size(model.dA);
    dum=zeros(dumy+1,dumx+1);
    dum(1:end-1,1:end-1) = model.dA;
    dum(end,1:end-1) = model.dA(end,:);
    dum(1:end-1,end) = model.dA(:,end);
    dum(end,end) = model.dA(end,end);
    model.dA = dum;
    
    model.lat = tmplat(jdx(1:hskip:end));
    model.lon = tmplon(idx(1:hskip:end));  
    
    model.lat2D = tmplat2D(jdx(1:hskip:end),idx(1:hskip:end));
    model.lon2D = tmplon2D(jdx(1:hskip:end),idx(1:hskip:end));
    model.mask_rho  = mask_rho(jdx(1:hskip:end),idx(1:hskip:end));
%     model.mask_rho  = mask_rho(1:hskip:end,1:hskip:end);
    
    % Interpolate the relevant part of the TPXO data onto the ROMS xy grid.
    % Also, convert from cm/s to m/s.
    
    idxs = find(tpxo.lon>=min(model.lon2D(:))&tpxo.lon<=max(model.lon2D(:))); tpxo.idxs = [min(idxs)-1,idxs,max(idxs)+1]; %tpxo.idxs=idxs;
    jdxs = find(tpxo.lat>=min(model.lat2D(:))&tpxo.lat<=max(model.lat2D(:))); tpxo.jdxs = [min(jdxs)-1,jdxs,max(jdxs)+1]; %tpxo.jdxs=jdxs;
    
    tpxo.amp_zeta_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_zeta(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    tpxo.pha_zeta_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_zeta(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    tpxo.amp_ubar_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_ubar(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    tpxo.pha_ubar_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_ubar(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    tpxo.amp_vbar_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_vbar(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    tpxo.pha_vbar_BB = interp2(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_vbar(tpxo.jdxs,tpxo.idxs),model.lon,model.lat);
    
    % Load in zeta, then filter with the enlarged land mask
    % Note that Harper isn't loading in the very edge of zeta so it's sized
    % smaller by 2 elements in each direction.
    zeta = nc_varget(['./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'],'zeta',[0,jdx(1)-1,idx(1)-1],ceil([-1,length(model.lat),length(model.lon)]),[1,hskip,hskip]);
    % zetasmoo=nan*zeta;
    [nt,ny,nx] = size(zeta);
    for tt = 1:nt
        zeta(tt,:,:) = sq(zeta(tt,:,:)) .* model.mask_rho;
    end;
    done('zeta')
    
    % Load in ubar and vbar, then filter with the enlarged land mask. Ubar is on the
    % ugrid which is a leetle bit bigger than the rho grid, but if I use
    % Harper's limits in the nc_varget call I'll end up with a properly sized
    % array. Same with vbar and the v grid.
    ubar = nc_varget(['./',model.file_prefix,'his2',model.file_suffix,'_ubar.nc'],'ubar',[0,jdx(1)-1,idx(1)-1],ceil([-1,length(model.lat),length(model.lon)]),[1,hskip,hskip]);
    vbar = nc_varget(['./',model.file_prefix,'his2',model.file_suffix,'_vbar.nc'],'vbar',[0,jdx(1)-1,idx(1)-1],ceil([-1,length(model.lat),length(model.lon)]),[1,hskip,hskip]);
    for tt = 1:nt
        ubar(tt,:,:) = sq(ubar(tt,:,:)) .* model.mask_rho;
        vbar(tt,:,:) = sq(vbar(tt,:,:)) .* model.mask_rho;
    end;
    done('ubar and vbar')
    
    
    
    
    
    % for tdx = 1:length(zeta(:,1,1))
    % % zetasmoo(tdx,:,:) = lowpassconv(sq(zeta(tdx,:,:)),hskip*2,hskip*2,1);
    % end;done('done smoothing zeta')
    NX = length(model.lon);
    NY = length(model.lat);
    % times = datenum(1900,1,1,1,0,nc_varget([model.exp1,model.exp2,'TPXOstuff/',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'],'ocean_time'));datestr(times(1:3))
%     times = datenum(1900,1,1,1,0,nc_varget(['./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc'],'ocean_time'));datestr(times(1:3))
    
% times are in millenium days
    times=roms_get_date(['./',model.file_prefix,'his2',model.file_suffix,'_zeta.nc']);datestr(times(1:3))
 
    % the default time interval is supposed to be 1 hour, but it doesn't
    % hurt cover ones bases
    tInterval = round( (times(2)-times(1)) *24*1000 )/1000;
    
    
   
%% zeta section
    
    model.amp_zeta=nan*ones(NY,NX);model.pha_zeta=model.amp_zeta;
    for jdx = 1:NY
        disp([num2str(jdx),' of ',num2str(NY),' zeta'])
        for idx = 1:NX;
            dat = sq(zeta(:,jdx,idx));
            if find(1-isnan(dat))
                [name,freq,tidecon,zout] =t_tide2(dat,'start',times(1),'interval',tInterval);
                % find the correct tide
                bingo=[];
                for tdx = 1:length(name);
                    tmpname = name(tdx,1:length(myTide));
                    if strcmp(tmpname,myTide)
                        bingo=tdx;
                    end
                end
                model.amp_zeta(jdx,idx)=tidecon(bingo,1);
                model.pha_zeta(jdx,idx)=tidecon(bingo,3);
                
%                 [prediction,conList]=tmd_tide_pred(tpxomodel,times,model.lat(jdx),model.lon(idx),'z',[1]);
%                 fig(99);clf;
%                 dat - mean(dat);plot(ans(1:end));hold on;
%                 plot(prediction(1:end),'r');
%                 
%                 aaa=5;
                
            end
        end
    end
 


%     deltaPhase = mod(2*3.14159*24*freq(bingo)*midTime,360)
%     tpxo.pha_zeta_BB = mod( tpxo.pha_zeta_BB - deltaPhase,360);   
    
%% ubar section
    
    model.amp_ubar=nan*ones(NY,NX);model.pha_ubar=model.amp_ubar;
    for jdx = 1:NY
        disp([num2str(jdx),' of ',num2str(NY),' ubar'])
        for idx = 1:NX;
            dat = ubar(:,jdx,idx);
            if find(1-isnan(dat))
                [name,freq,tidecon,zout] =t_tide2(ubar    (:,jdx,idx),'start',times(1),'interval',tInterval);
                % find the correct tide
                bingo=[];
                for tdx = 1:length(name);
                    tmpname = name(tdx,1:length(myTide));
                    if strcmp(tmpname,myTide)
                        bingo=tdx;
                    end
                end
                model.amp_ubar(jdx,idx)=tidecon(bingo,1);
                model.pha_ubar(jdx,idx)=tidecon(bingo,3);
            end
        end
    end

%     deltaPhase = mod(2*3.14159*24*freq(bingo)*midTime,360)
%     tpxo.pha_ubar_BB = mod( tpxo.pha_ubar_BB - deltaPhase,360);    
    
%% vbar section
    
    model.amp_vbar=nan*ones(NY,NX);model.pha_vbar=model.amp_vbar;
    for jdx = 1:NY
        disp([num2str(jdx),' of ',num2str(NY),' vbar'])
        for idx = 1:NX;
            dat = vbar(:,jdx,idx);
            if find(1-isnan(dat))
                [name,freq,tidecon,zout] =t_tide2(vbar    (:,jdx,idx),'start',times(1),'interval',tInterval);
                % find the correct tide
                bingo=[];
                for tdx = 1:length(name);
                    tmpname = name(tdx,1:length(myTide));
                    if strcmp(tmpname,myTide)
                        bingo=tdx;
                    end
                end
                model.amp_vbar(jdx,idx)=tidecon(bingo,1);
                model.pha_vbar(jdx,idx)=tidecon(bingo,3);
            end
        end
    end
    
%     deltaPhase = mod(2*3.14159*24*freq(bingo)*midTime,360)
%     tpxo.pha_vbar_BB = mod( tpxo.pha_vbar_BB - deltaPhase,360);
    
%% Harper's figure of merit
    
    % It'd be nice if I could put an image into these scripts. A picture's
    % worth a thousand words....
    % Anyhoo, it looks like the square root of
    %
    %   <  doubleIntegralOverArea(zeta_roms - zeta_tpxo)^2  >
    % The area differential
    %   dA = dx dy
    % is constant for this particular grid, but I want to write this up so that
    % it works on one of the telescoping grids. Assuming I've dont this
    % correctly, I have the area differential sized the same as zeta_roms and
    % zeta_tpxo.
    
    % size(model.amp_zeta)
    % size(tpxo.amp_zeta_BB)
    % size(model.mask_rho)
    % size(model.mask_rho)
    
    num=(model.amp_zeta - tpxo.amp_zeta_BB).^2 .*model.dA.*model.mask_rho;
    den=model.dA.*model.mask_rho;
    model.D_zeta = sqrt( nansum(num(:))/nansum(den(:)) )
    
    num=(model.amp_ubar - tpxo.amp_ubar_BB).^2 .*model.dA.*model.mask_rho;
    den=model.dA.*model.mask_rho;
    model.D_ubar = sqrt( nansum(num(:))/nansum(den(:)) )
    
    num=(model.amp_vbar - tpxo.amp_vbar_BB).^2 .*model.dA.*model.mask_rho;
    den=model.dA.*model.mask_rho;
    model.D_vbar = sqrt( nansum(num(:))/nansum(den(:)) )
    
    % sqrt(sum(ans(:))/sum(model.dA(:)))
    % fig(99);pcolor(ans);shading flat;colorbar
    
    %%
    eval(['save ',outfile,' model tpxo'])
    disp(['save ',outfile,' model tpxo'])
else
    disp(['loading ',outfile])
    load(outfile)
end



%%  JGP plots take place here

% unix('\rm -r figures');
unix('mkdir figures');


%% Zeta tides

ampLim = [0,.7];
phaLim = [240,280];
xLim = [220 226.5];
yLim = [53.5 58.5];

figure(1);clf;
subplot(2,2,1);  myMean = nanmean(model.amp_zeta(:));
pcolor(model.lon2D,model.lat2D,model.amp_zeta);shading flat;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,model.amp_zeta,[0:.05:1],'LineColor','Black','Showtext','on')
title( ['ROMS - ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;


subplot(2,2,2)
pcolor(model.lon2D,model.lat2D,model.pha_zeta);shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,model.pha_zeta,[0:30:345],'LineColor','Black','Showtext','on')
title(['ROMS - ',myTide,' phase']);colorbar

subplot(2,2,3);
tpxo.amp_zeta_BB; myMean=nanmean(ans(:));
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_zeta(tpxo.jdxs,tpxo.idxs));shading flat;
% imagesc(model.lon,model.lat,tpxo.amp_zeta_BB);axis xy;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.amp_zeta_BB,[0:.05:1],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;


subplot(2,2,4)
% imagesc(model.lon,model.lat,tpxo.pha_zeta_BB );axis xy;
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_zeta(tpxo.jdxs,tpxo.idxs));shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.pha_zeta_BB ,[0:30:360],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' phase']);colorbar

suptitle(['Zeta    D=',num2str(model.D_zeta)])
print(['figures/Zeta_',myTide,'tides'],'-djpeg');

%% Ubar tides

ampLim = [0,.1];
phaLim = [0,300];

figure(2);clf;
subplot(2,2,1);  myMean = nanmean(model.amp_ubar(:));
pcolor(model.lon2D,model.lat2D, model.amp_ubar);shading flat;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,model.amp_ubar,[0:.05:1],'LineColor','Black','Showtext','on')
title( ['ROMS - ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;

subplot(2,2,2)
pcolor(model.lon2D,model.lat2D,model.pha_ubar);shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,model.pha_ubar,[0:30:345],'LineColor','Black','Showtext','on')
title(['ROMS - ',myTide,' phase']);colorbar

subplot(2,2,3); tpxo.amp_ubar_BB; myMean=nanmean(ans(:));
% imagesc(model.lon,model.lat,tpxo.amp_ubar_BB);axis xy;
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_ubar(tpxo.jdxs,tpxo.idxs));shading flat;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.amp_ubar_BB,[0:.05:1],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;

subplot(2,2,4)
% imagesc(model.lon,model.lat,tpxo.pha_ubar_BB);axis xy;
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_ubar(tpxo.jdxs,tpxo.idxs));shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.pha_ubar_BB,[0:30:360],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' phase']);colorbar

suptitle(['Ubar    D=',num2str(model.D_ubar)])
print(['figures/Ubar_',myTide,'tides'],'-djpeg');

%% Vbar tides

ampLim = [0,.05];
phaLim = [100,365];

figure(3);clf;
subplot(2,2,1);  myMean =  nanmean(model.amp_vbar(:));
pcolor(model.lon2D,model.lat2D,  model.amp_vbar);shading flat;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,model.amp_vbar,[0:.05:1],'LineColor','Black','Showtext','on')
title(['ROMS - ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;

subplot(2,2,2)
pcolor(model.lon2D,model.lat2D,model.pha_vbar);shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,model.pha_vbar,[0:30:345],'LineColor','Black','Showtext','on')
title(['ROMS - ',myTide,' phase']);colorbar

subplot(2,2,3); tpxo.amp_vbar_BB; myMean=nanmean(ans(:));
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.amp_vbar(tpxo.jdxs,tpxo.idxs));shading flat;
% imagesc(model.lon,model.lat,tpxo.amp_vbar_BB);axis xy;
caxis(ampLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.amp_vbar_BB,[0:.05:1],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' amp (mean=',num2str( myMean ),')']);colorbar;

subplot(2,2,4)
% imagesc(model.lon,model.lat,tpxo.pha_vbar_BB);axis xy;
pcolor(tpxo.lon(tpxo.idxs),tpxo.lat(tpxo.jdxs),tpxo.pha_vbar(tpxo.jdxs,tpxo.idxs));shading flat;
caxis(phaLim);
rect;hold on
% contour(model.lon,model.lat,tpxo.pha_vbar_BB,[0:30:360],'LineColor','Black','Showtext','on')
title(['TPXO, ',myTide,' phase']);colorbar

suptitle(['Vbar    D=',num2str(model.D_vbar)])
print(['figures/Vbar_',myTide,'tides'],'-djpeg');


