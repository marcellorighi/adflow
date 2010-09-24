!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of replacebcstatesforcesadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: padj0 padj1 padj
!                wadj wadj0 wadj1
!   of linear combination of output variables: padj wadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          replaceBCStatesForcesAdj.f90                    *
!      * Author:        C.A.(Sandy) Mader                               *
!      * Starting date: 04-17-2008                                      *
!      * Last modified: 06-09-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE REPLACEBCSTATESFORCESADJ_B(mm, wadj0, wadj0b, wadj1, wadj1b, &
&  wadj2, wadj3, padj0, padj0b, padj1, padj1b, padj2, padj3, rlvadj1, &
&  rlvadj2, revadj1, revadj2, wadj, wadjb, padj, padjb, rlvadj, revadj, &
&  icbeg, jcbeg, icend, jcend, secondhalo)
  USE bctypes
  USE blockpointers, ONLY : ie, ib, je, jb, ke, kb, nbocos, bcfaceid, &
&  bctype, bcdata
  USE flowvarrefstate
  IMPLICIT NONE
  INTEGER(KIND=INTTYPE) :: icbeg, icend, jcbeg, jcend
  INTEGER(KIND=INTTYPE), INTENT(IN) :: mm
  REAL(KIND=REALTYPE) :: padj0(icbeg:icend, jcbeg:jcend), padj0b(icbeg:&
&  icend, jcbeg:jcend), padj1(icbeg:icend, jcbeg:jcend), padj1b(icbeg:&
&  icend, jcbeg:jcend)
  REAL(KIND=REALTYPE) :: padj2(icbeg:icend, jcbeg:jcend), padj3(icbeg:&
&  icend, jcbeg:jcend)
  REAL(KIND=REALTYPE) :: padj(0:ib, 0:jb, 0:kb), padjb(0:ib, 0:jb, 0:kb)
  REAL(KIND=REALTYPE) :: revadj1(icbeg:icend, jcbeg:jcend), revadj2(&
&  icbeg:icend, jcbeg:jcend)
  REAL(KIND=REALTYPE) :: revadj(0:ib, 0:jb, 0:kb), rlvadj(0:ib, 0:jb, 0:&
&  kb)
  REAL(KIND=REALTYPE) :: rlvadj1(icbeg:icend, jcbeg:jcend), rlvadj2(&
&  icbeg:icend, jcbeg:jcend)
  LOGICAL, INTENT(IN) :: secondhalo
  REAL(KIND=REALTYPE) :: wadj(0:ib, 0:jb, 0:kb, nw), wadjb(0:ib, 0:jb, 0&
&  :kb, nw)
  REAL(KIND=REALTYPE) :: wadj0(icbeg:icend, jcbeg:jcend, nw), wadj0b(&
&  icbeg:icend, jcbeg:jcend, nw), wadj1(icbeg:icend, jcbeg:jcend, nw), &
&  wadj1b(icbeg:icend, jcbeg:jcend, nw)
  REAL(KIND=REALTYPE) :: wadj2(icbeg:icend, jcbeg:jcend, nw), wadj3(&
&  icbeg:icend, jcbeg:jcend, nw)
  INTEGER(KIND=INTTYPE) :: i, j, k, l
!      modules
!!$       real(kind=realType), dimension(-2:2,-2:2,nw),intent(in) :: wAdj0, wAdj1
!!$       real(kind=realType), dimension(-2:2,-2:2,nw),intent(in) :: wAdj2, wAdj3
!!$       real(kind=realType), dimension(-2:2,-2:2),intent(in)    :: pAdj0, pAdj1
!!$       real(kind=realType), dimension(-2:2,-2:2),intent(in)    :: pAdj2, pAdj3
!!$
!!$       real(kind=realType), dimension(-2:2,-2:2,-2:2,nw),intent(inout) :: wAdj
!!$       real(kind=realType), dimension(-2:2,-2:2,-2:2),intent(inout) :: pAdj
!!$       real(kind=realType), dimension(-2:2,-2:2,-2:2)::rlvAdj, revAdj
!!$       real(kind=realType), dimension(-2:2,-2:2)::rlvAdj1, rlvAdj2
!!$       real(kind=realType), dimension(-2:2,-2:2)::revAdj1, revAdj2
!logical :: secondHalo
! Copy the information back to the original arrays wAdj and pAdj.
  SELECT CASE  (bcfaceid(mm)) 
  CASE (imin) 
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(1, icbeg:icend, jcbeg:&
&        jcend)
      padjb(1, icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(0, icbeg:icend, jcbeg:&
&        jcend)
      padjb(0, icbeg:icend, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(1, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(1, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(0, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(0, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(0, icbeg:icend, jcbeg:&
&        jcend)
      padjb(0, icbeg:icend, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(0, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(0, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE (imax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(ib-1, icbeg:icend, jcbeg:&
&        jcend)
      padjb(ib-1, icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(ib, icbeg:icend, jcbeg:&
&        jcend)
      padjb(ib, icbeg:icend, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(ib-1, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(ib-1, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(ib, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(ib, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(ib, icbeg:icend, jcbeg:&
&        jcend)
      padjb(ib, icbeg:icend, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(ib, icbeg:icend, &
&        jcbeg:jcend, 1:nw)
      wadjb(ib, icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE (jmin) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, 1, jcbeg:&
&        jcend)
      padjb(icbeg:icend, 1, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, 0, jcbeg:&
&        jcend)
      padjb(icbeg:icend, 0, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, 1, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, 1, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, 0, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, 0, jcbeg:jcend, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, 0, jcbeg:&
&        jcend)
      padjb(icbeg:icend, 0, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, 0, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, 0, jcbeg:jcend, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE (jmax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jb-1, jcbeg:&
&        jcend)
      padjb(icbeg:icend, jb-1, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jb, jcbeg:&
&        jcend)
      padjb(icbeg:icend, jb, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jb-1, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, jb-1, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jb, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, jb, jcbeg:jcend, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jb, jcbeg:&
&        jcend)
      padjb(icbeg:icend, jb, jcbeg:jcend) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jb, &
&        jcbeg:jcend, 1:nw)
      wadjb(icbeg:icend, jb, jcbeg:jcend, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE (kmin) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , 1)
      padjb(icbeg:icend, jcbeg:jcend, 1) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , 0)
      padjb(icbeg:icend, jcbeg:jcend, 0) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, 1, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, 1, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, 0, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, 0, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , 0)
      padjb(icbeg:icend, jcbeg:jcend, 0) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, 0, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, 0, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE (kmax) 
!===========================================================
    IF (secondhalo) THEN
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , kb-1)
      padjb(icbeg:icend, jcbeg:jcend, kb-1) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , kb)
      padjb(icbeg:icend, jcbeg:jcend, kb) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, kb-1, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, kb-1, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, kb, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, kb, 1:nw) = 0.0
    ELSE
      padj1b(icbeg:icend, jcbeg:jcend) = 0.0
      padj1b(icbeg:icend, jcbeg:jcend) = padjb(icbeg:icend, jcbeg:jcend&
&        , kb)
      padjb(icbeg:icend, jcbeg:jcend, kb) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
      wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = wadjb(icbeg:icend, jcbeg:&
&        jcend, kb, 1:nw)
      wadjb(icbeg:icend, jcbeg:jcend, kb, 1:nw) = 0.0
      padj0b(icbeg:icend, jcbeg:jcend) = 0.0
      wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    END IF
  CASE DEFAULT
    padj0b(icbeg:icend, jcbeg:jcend) = 0.0
    padj1b(icbeg:icend, jcbeg:jcend) = 0.0
    wadj0b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
    wadj1b(icbeg:icend, jcbeg:jcend, 1:nw) = 0.0
  END SELECT
END SUBROUTINE REPLACEBCSTATESFORCESADJ_B
