#include "cppdefs.h"
      MODULE tl_step2d_mod
#ifdef TANGENT
!
!svn $Id: tl_step2d.F 1054 2021-03-06 19:47:12Z arango $
!================================================== Hernan G. Arango ===
!  Copyright (c) 2002-2021 The ROMS/TOMS Group       Andrew M. Moore   !
!    Licensed under a MIT/X style license                              !
!    See License_ROMS.txt                                              !
!=======================================================================
!                                                                      !
!  This subroutine performs a fast (predictor or corrector) time-step  !
!  for the free-surface and 2D momentum tangent linear equations.      !
# ifdef SOLVE3D
!  It also calculates the time filtering variables over all fast-time  !
!  steps  to damp high frequency signals in 3D applications.           !
# endif
!                                                                      !
!=======================================================================
!
      implicit none
!
      PRIVATE
      PUBLIC  :: tl_step2d
!
      CONTAINS
!
# include "tl_step2d_LF_AM3.h"

#endif
      END MODULE tl_step2d_mod
