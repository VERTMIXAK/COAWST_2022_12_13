#include "cppdefs.h"

      MODULE vegetation_drag_mod

#if defined VEGETATION && defined VEG_DRAG
!
!svn $Id: vegetation_drag.F 429 2015-05-26 10:10:26Z arango $
!======================================================================!
!  Copyright (c) 2002-2019 The ROMS/TOMS Group                         !
!    Licensed under a MIT/X style license           Hernan G. Arango   !
!    See License_ROMS.txt                   Alexander F. Shchepetkin   !
!==================================================== John C. Warner ==!
!==================================================== Neil K. Ganju  ==!
!==================================================== Alexis Beudin  ==!
!==================================================Tarandeep S. Kalra==!
!                                                                      !
!  This routine computes the vegetation (posture-dependent) drag       !
!  for rhs3d.F                                                         !
!                                                                      !  
!  References:                                                         !
!                                                                      !
!  Luhar M., and H. M. Nepf (2011), Flow-induced reconfiguration of    !
!  buoyant and flexible aquatic vegetation, Limnology and Oceanography,!
!   56(6): 2003-2017.                                                  !
!                                                                      !
!======================================================================!
!                                                                      !
      implicit none

      PRIVATE
      PUBLIC  :: vegetation_drag_cal

      CONTAINS
!
!***********************************************************************
      SUBROUTINE vegetation_drag_cal (ng, tile)
!***********************************************************************
!
      USE mod_param
      USE mod_stepping
      USE mod_grid
      USE mod_ocean
      USE mod_vegarr
!
      integer, intent(in) :: ng, tile
!
!  Local variable declarations.
!
# include "tile.h"
!
# ifdef PROFILE
      CALL wclock_on (ng, iNLM, 16)
# endif
      CALL vegetation_drag_tile  (ng, tile,                             &
     &                        LBi, UBi, LBj, UBj,                       &
     &                        IminS, ImaxS, JminS, JmaxS,               &
     &                        nrhs(ng),                                 & 
     &                        GRID(ng) % Hz,                            &
     &                        OCEAN(ng) % u,                            &
     &                        OCEAN(ng) % v,                            &
     &                        VEG(ng) % plant,                          &
# ifdef VEG_FLEX
     &                        VEG(ng) % bend,                           &
# endif
# if defined MARSH_DYNAMICS && defined MARSH_RETREAT
     &                        VEG(ng) % marsh_mask,                     &
# endif
     &                        VEG(ng) % ru_loc_veg,                     &
     &                        VEG(ng) % rv_loc_veg,                     &
     &                        VEG(ng) % ru_veg,                         &
     &                        VEG(ng) % rv_veg,                         & 
     &                        VEG(ng) % step2d_uveg,                    &
     &                        VEG(ng) % step2d_vveg,                    & 
     &                        VEG(ng) % Lveg)

# ifdef PROFILE
      CALL wclock_off (ng, iNLM, 16)
# endif
      RETURN
      END SUBROUTINE vegetation_drag_cal
!
!***********************************************************************
      SUBROUTINE vegetation_drag_tile  (ng, tile,                       &
     &                              LBi, UBi, LBj, UBj,                 &
     &                              IminS, ImaxS, JminS, JmaxS,         &
     &                              nrhs,                               & 
     &                              Hz,                                 &
     &                              u, v,                               &
     &                              plant,                              &
# ifdef VEG_FLEX
     &                              bend,                               &
# endif
# if defined MARSH_DYNAMICS && defined MARSH_RETREAT
     &                              marsh_mask,                         &
# endif
     &                              ru_loc_veg, rv_loc_veg,             &
     &                              ru_veg, rv_veg,                     &
     &                              step2d_uveg, step2d_vveg,           &
     &                              Lveg)
!***********************************************************************
!
      USE mod_param
      USE mod_scalars
      USE mod_vegetation
      USE mod_vegarr
      USE bc_3d_mod, ONLY: bc_r3d_tile
      USE exchange_2d_mod
      USE exchange_3d_mod
# ifdef DISTRIBUTE
      USE mp_exchange_mod, ONLY : mp_exchange2d,                       &
     &                            mp_exchange3d, mp_exchange4d
# endif
!
!  Imported variable declarations.
!
      integer, intent(in) :: ng, tile
      integer, intent(in) :: LBi, UBi, LBj, UBj
      integer, intent(in) :: IminS, ImaxS, JminS, JmaxS
      integer, intent(in) :: nrhs
!
# ifdef ASSUMED_SHAPE
      real(r8), intent(in) :: Hz(LBi:,LBj:,:)
      real(r8), intent(in) :: u(LBi:,LBj:,:,:)
      real(r8), intent(in) :: v(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: plant(LBi:,LBj:,:,:)
#  ifdef VEG_FLEX
      real(r8), intent(inout) :: bend(LBi:,LBj:,:)
#  endif
# if defined MARSH_DYNAMICS && defined MARSH_RETREAT
      real(r8), intent(inout) :: marsh_mask(LBi:,LBj:)
# endif
      real(r8), intent(inout) :: ru_loc_veg(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: rv_loc_veg(LBi:,LBj:,:,:)
      real(r8), intent(inout) :: ru_veg(LBi:,LBj:,:)
      real(r8), intent(inout) :: rv_veg(LBi:,LBj:,:)
      real(r8), intent(inout) :: step2d_uveg(LBi:,LBj:)
      real(r8), intent(inout) :: step2d_vveg(LBi:,LBj:)
      real(r8), intent(inout) :: Lveg(LBi:,LBj:,:)
# else
      real(r8), intent(in) :: Hz(LBi:UBi,LBj:UBj,N(ng))
      real(r8), intent(in) :: u(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(in) :: v(LBi:UBi,LBj:UBj,N(ng),2)
      real(r8), intent(inout) :: plant(LBi:UBi,LBj:UBj,NVEG,NVEGP)
#  ifdef VEG_FLEX
      real(r8), intent(inout) :: bend(LBi:UBi,LBj:UBj,N(ng),NVEG)
#  endif
# if defined MARSH_DYNAMICS && defined MARSH_RETREAT 
      real(r8), intent(inout) :: marsh_mask(LBi:UBi,LBj:UBj)
# endif
      real(r8), intent(inout) ::                                        &
    &               ru_loc_veg(LBi:UBi,LBj:UBj,N(ng),NVEG),             &
    &               rv_loc_veg(LBi:UBi,LBj:UBj,N(ng),NVEG)
      real(r8), intent(inout) :: ru_veg(LBi:UBi,LBj:UBj,N(ng))
      real(r8), intent(inout) :: rv_veg(LBi:UBi,LBj:UBj,N(ng))
      real(r8), intent(inout) :: step2d_uveg(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: step2d_vveg(LBi:UBi,LBj:UBj)
      real(r8), intent(inout) :: Lveg(LBi:UBi,LBj:UBj,N(ng))
# endif
!
!  Local variable declarations.
!
      integer :: i, j, k, ivpr, iveg
! 
      real(r8), parameter :: one_third  = 1.0_r8/3.0_r8
      real(r8), parameter :: one_twelfth  = 1.0_r8/12.0_r8
      real(r8), parameter :: Inival  = 0.0_r8 
      real(r8), parameter :: min_eps = 1.0E-12_r8
      real(r8), parameter :: max_eps = 1.0E12_r8
      real(r8) :: cff, inv_cff1, cff1, cff2, cff3, cff4, Hz_inverse
      real(r8) :: cff5, cff6
      real(r8) :: sma, buoy, Umag, Ca, cflex
      real(r8) :: Lveg_loc, plant_height_eff
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS,0:N(ng)) :: dab
      real(r8), dimension(IminS:ImaxS,JminS:JmaxS) :: wrk
!
# include "set_bounds.h"
!
!-----------------------------------------------------------------------
!  Resistance imposed on the flow by vegetation.
!-----------------------------------------------------------------------
!
      dab=Inival
      ru_veg=Inival
      rv_veg=Inival
      Lveg=Inival
!
# ifdef WET_DRY
!
!  Set limiting factor for drag force. The drag force is adjusted
!  to not change the direction of momentum.  It only should slow down
!  to zero. The value of 0.75 is arbitrary limitation assigment
!  (same as for bottom stress).
!
      cff=0.75_r8/dt(ng)
# endif
!
# if defined MARSH_DYNAMICS && defined MARSH_RETREAT 
      DO ivpr=1,NVEGP
        DO iveg=1,NVEG
          DO j=Jstr,Jend
            DO i=Istr,Iend
              plant(i,j,iveg,pdens)=plant(i,j,iveg,pdens)*             &
     &                              marsh_mask(i,j)            
              plant(i,j,iveg,phght)=plant(i,j,iveg,phght)*             &
     &                              marsh_mask(i,j)            
              plant(i,j,iveg,pthck)=plant(i,j,iveg,pthck)*             &
     &                              marsh_mask(i,j)            
              plant(i,j,iveg,pdiam)=plant(i,j,iveg,pdiam)*             &
     &                              marsh_mask(i,j)            
            END DO
          END DO
        END DO
      END DO
# endif 
!
      VEG_LOOP: DO iveg=1,NVEG
        K_LOOP: DO k=1,N(ng)
          DO j=JstrV-1,Jend
            DO i=IstrU-1,Iend
!
# ifdef VEG_FLEX
!
! Flexible vegetation
!
! Second moment of area
! 
              sma=(plant(i,j,iveg,pdiam)*                               &
     &             plant(i,j,iveg,pthck)**3.0_r8)*(one_twelfth)
!
! Avoid division by zero
!
              cff1=MAX( (E_veg(iveg,ng)*sma), min_eps)
              inv_cff1=1.0_r8/cff1 
!
! Buoyancy parameter
!
              buoy=(rhow-veg_massdens(iveg,ng))*g*plant(i,j,iveg,pdiam)*&
     &              plant(i,j,iveg,pthck)*                              &
     &              plant(i,j,iveg,phght)**3.0_r8*inv_cff1 
!
! Current speed at rho points
!
              cff2=0.5_r8*(u(i,j,k,nrhs)+u(i+1,j,k,nrhs))
              cff3=0.5_r8*(v(i,j,k,nrhs)+v(i,j+1,k,nrhs))
              Umag=SQRT(cff2*cff2+cff3*cff3)
!
! Cauchy number
!
              Ca=0.5_r8*rhow*Cd_veg(iveg,ng)*plant(i,j,iveg,pdiam)*     &
     &           Umag**2.0_r8*plant(i,j,iveg,phght)**3.0_r8*inv_cff1
!
! Avoid infinity in Cauchy's number 
!
              cff4=MIN(Ca**-1.5_r8, max_eps)
!
! Denominator for cflex calculation
!             
              cff5=1.0_r8+(cff4*(8.0_r8+buoy**(1.5_r8)))
!
! Avoid infinity in Cauchy's number 
!
              cff6=MIN(Ca**(-one_third), max_eps) 
!
! set a minimum for cflex to be 1 , cflex will exceed 1 if Ca<0.7290
! but don't allow those values 
!
              cflex=1.0_r8-((1.0_r8-0.9_r8*cff6)/(cff5))
              cflex=MIN(cflex, 1.0_r8)
!
! Effective blade length
!
              plant_height_eff=cflex*plant(i,j,iveg,phght)
!
! Blade bending angle
!
              bend(i,j,iveg)=ACOS(cflex**one_third)*rad2deg
# else
!
! For stiff vegetation
!
              plant_height_eff=plant(i,j,iveg,phght)
# endif
!
! Select the grid cell (full or part) within the canopy layer
!
              dab(i,j,k)=dab(i,j,k-1)+Hz(i,j,k)
              Hz_inverse=1.0_r8/Hz(i,j,k)
              cff1=MIN((dab(i,j,k)-plant_height_eff)*Hz_inverse,1.0_r8)
              Lveg_loc=MIN(1.0_r8-cff1,1.0_r8)
!
! Prepare drag term (at rho points)
!       
              wrk(i,j)=0.5_r8*cd_veg(iveg,ng)*plant(i,j,iveg,pdiam)*    &
     &                 plant(i,j,iveg,pdens)*Hz(i,j,k)*Lveg_loc
!
! Store Lveg_loc for all vegetation types
!
              Lveg(i,j,k)=Lveg_loc+Lveg(i,j,k)
            END DO
          END DO
!
! Exchange boundary data 
!
      IF (EWperiodic(ng).or.NSperiodic(ng)) THEN
        CALL exchange_r2d_tile (ng, tile,                               &
     &                          LBi, UBi, LBj, UBj,                     &
     &                          wrk)
      ENDIF

!
        CALL mp_exchange2d (ng, tile, iNLM, 1,                          &
     &                    LBi, UBi, LBj, UBj,                           &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    wrk(:,:)) 
!
! Compute friction force (at cell faces)
!
          DO j=Jstr,Jend
            DO i=IstrU,Iend
              cff1=0.25_r8*(v(i  ,j  ,k,nrhs)+                          &
     &                      v(i  ,j+1,k,nrhs)+                          &
     &                      v(i-1,j  ,k,nrhs)+                          &
     &                      v(i-1,j+1,k,nrhs))
              cff2=SQRT(u(i,j,k,nrhs)*u(i,j,k,nrhs)+cff1*cff1)
              cff3=u(i,j,k,nrhs)*cff2
              ru_loc_veg(i,j,k,iveg)=0.5_r8*(wrk(i-1,j)+wrk(i,j))*cff3
!
!  Add the ru_iveg from this veg type to another veg type
!  which can be there at the same point (i,j,k)
!  Alexis's comment: not confident in what is happening when
!                     multiple vegetation types are concomitant
!
              ru_veg(i,j,k)=ru_loc_veg(i,j,k,iveg)+ru_veg(i,j,k)

!
# ifdef WET_DRY
              cff4=cff*0.5_r8*(Hz(i-1,j,k)+Hz(i,j,k))
              ru_veg(i,j,k)=SIGN(1.0_r8, ru_veg(i,j,k))*                &
     &                           MIN(ABS(ru_veg(i,j,k)),                &
     &                               ABS(u(i,j,k,nrhs))*cff4)
# endif
!
            END DO
          END DO
!
          DO j=JstrV,Jend
            DO i=Istr,Iend
              cff1=0.25_r8*(u(i  ,j  ,k,nrhs)+                          &
     &                      u(i+1,j  ,k,nrhs)+                          &
     &                      u(i  ,j-1,k,nrhs)+                          &
     &                      u(i+1,j-1,k,nrhs))
              cff2=SQRT(cff1*cff1+v(i,j,k,nrhs)*v(i,j,k,nrhs))
              cff3=v(i,j,k,nrhs)*cff2
              rv_loc_veg(i,j,k,iveg)=0.5_r8*(wrk(i,j-1)+wrk(i,j))*cff3
!
!   Add the rv_iveg from this veg type to another veg type
!   which can be there at the same point (i,j,k)
!
              rv_veg(i,j,k)=rv_loc_veg(i,j,k,iveg)+rv_veg(i,j,k)

!
# ifdef WET_DRY
              cff4=cff*0.5_r8*(Hz(i,j-1,k)+Hz(i,j,k))
              rv_veg(i,j,k)=SIGN(1.0_r8, rv_veg(i,j,k))*                &
     &                           MIN(ABS(rv_veg(i,j,k)),                &
     &                               ABS(v(i,j,k,nrhs))*cff4)
# endif
!
            END DO
          END DO
        END DO K_LOOP
      END DO VEG_LOOP
!
! Exchange boundary data 
!
      IF (EWperiodic(ng).or.NSperiodic(ng)) THEN
        DO iveg=1,NVEG
          CALL exchange_u3d_tile (ng, tile,                             &
     &                          LBi, UBi, LBj, UBj, 1, N(ng),           &
     &                          ru_loc_veg(:,:,:,iveg))
          CALL exchange_v3d_tile (ng, tile,                             &
     &                          LBi, UBi, LBj, UBj, 1, N(ng),           &
     &                          rv_loc_veg(:,:,:,iveg))
        END DO 
        CALL exchange_u3d_tile (ng, tile,                               &
     &                          LBi, UBi, LBj, UBj, 1, N(ng),           &
     &                          ru_veg(:,:,:))
        CALL exchange_v3d_tile (ng, tile,                               &
     &                          LBi, UBi, LBj, UBj, 1, N(ng),           &
     &                          rv_veg(:,:,:))
      END IF
!
#  if defined MARSH_DYNAMICS && defined MARSH_RETREAT 
      DO ivpr=1,NVEGP
        CALL bc_r3d_tile (ng, tile,                                     &
     &                          LBi, UBi, LBj, UBj, 1, NVEG,            &
     &                          plant(:,:,:,ivpr))
      END DO
#  endif
!
# ifdef DISTRIBUTE
!
      CALL mp_exchange4d (ng, tile, iNLM, 2,                            &
     &                    LBi, UBi, LBj, UBj, 1, N(ng), 1, NVEG,        &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    ru_loc_veg(:,:,:,:),                          &
     &                    rv_loc_veg(:,:,:,:))
!
      CALL mp_exchange3d (ng, tile, iNLM, 2,                            &
     &                    LBi, UBi, LBj, UBj, 1, N(ng),                 &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    ru_veg, rv_veg)
! 
#  if defined MARSH_DYNAMICS && defined MARSH_RETREAT 
      CALL mp_exchange4d (ng, tile, iNLM, 1,                            &
     &                    LBi, UBi, LBj, UBj, 1, NVEG, 1, NVEGP,        &
     &                    NghostPoints,                                 &
     &                    EWperiodic(ng), NSperiodic(ng),               &
     &                    plant(:,:,:,:))
#  endif
# endif
!
!-----------------------------------------------------------------------
!  Add in resistance imposed on the flow by the vegetation (3D->2D).
!  Changes feedback in Nonlinear/step2d_LF_AM3.F
!-----------------------------------------------------------------------
!
      DO j=Jstr,Jend
        DO i=IstrU,Iend
          cff=0.5_r8*(Hz(i-1,j,1)+Hz(i,j,1))
          cff2=cff*ru_veg(i,j,1)
          DO k=2,N(ng)
            cff=0.5_r8*(Hz(i-1,j,k)+Hz(i,j,k))
            cff2=cff2+cff*ru_veg(i,j,k)
          END DO
          step2d_uveg(i,j)=cff2
        END DO
      END DO
!
      DO i=Istr,Iend
        DO j=JstrV,Jend
          cff=0.5_r8*(Hz(i,j-1,1)+Hz(i,j,1))
          cff2=cff*rv_veg(i,j,1)
          DO k=2,N(ng)
            cff=0.5_r8*(Hz(i,j-1,k)+Hz(i,j,k))
            cff2=cff2+cff*rv_veg(i,j,k)
          END DO
          step2d_vveg(i,j)=cff2
        END DO
      END DO
!
      RETURN
      END SUBROUTINE vegetation_drag_tile
#endif
      END MODULE vegetation_drag_mod
