!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of bcsymmforcecouplingadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: padj wadj normadj
!   of linear combination of output variables: padj wadj normadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          bcSymmAdj.f90                                   *
!      * Author:        Edwin van der Weide,C.A.(Sandy) Mader           *
!      * Starting date: 04-17-2008                                      *
!      * Last modified: 06-12-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE BCSYMMFORCECOUPLINGADJ_B(secondhalo, wadj, wadjb, padj, padjb&
&  , normadj, normadjb, nn, iibeg, iiend, jjbeg, jjend, i2beg, i2end, &
&  j2beg, j2end)
  USE bctypes
  USE blockpointers, ONLY : ie, ib, il, je, jb, jl, ke, kb, kl, nbocos&
&  , gamma, bcfaceid, bctype, bcdata
  USE constants
  USE flowvarrefstate
  USE iteration
  IMPLICIT NONE
  INTEGER(KIND=INTTYPE), INTENT(IN) :: i2beg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: i2end
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iibeg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iiend
  INTEGER(KIND=INTTYPE), INTENT(IN) :: j2beg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: j2end
  INTEGER(KIND=INTTYPE), INTENT(IN) :: jjbeg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: jjend
  INTEGER(KIND=INTTYPE) :: nn
  REAL(KIND=REALTYPE) :: normadj(iibeg:iiend, jjbeg:jjend, 3), normadjb(&
&  iibeg:iiend, jjbeg:jjend, 3)
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb), INTENT(IN) :: padj
  REAL(KIND=REALTYPE) :: padjb(0:ib, 0:jb, 0:kb)
  LOGICAL, INTENT(IN) :: secondhalo
  REAL(KIND=REALTYPE), DIMENSION(0:ib, 0:jb, 0:kb, nw), INTENT(IN) :: &
&  wadj
  REAL(KIND=REALTYPE) :: wadjb(0:ib, 0:jb, 0:kb, nw)
  INTEGER :: branch
  REAL(KIND=REALTYPE) :: gamma1(iibeg:iiend, jjbeg:jjend), gamma2(iibeg:&
&  iiend, jjbeg:jjend)
  INTEGER(KIND=INTTYPE) :: icbeg, icend, jcbeg, jcend
  INTEGER(KIND=INTTYPE) :: i, j, l
  REAL(KIND=REALTYPE) :: padj0(iibeg:iiend, jjbeg:jjend), padj0b(iibeg:&
&  iiend, jjbeg:jjend), padj1(iibeg:iiend, jjbeg:jjend), padj1b(iibeg:&
&  iiend, jjbeg:jjend)
  REAL(KIND=REALTYPE) :: padj2(iibeg:iiend, jjbeg:jjend), padj2b(iibeg:&
&  iiend, jjbeg:jjend), padj3(iibeg:iiend, jjbeg:jjend), padj3b(iibeg:&
&  iiend, jjbeg:jjend)
  REAL(KIND=REALTYPE) :: revadj1(iibeg:iiend, jjbeg:jjend), revadj2(&
&  iibeg:iiend, jjbeg:jjend)
  REAL(KIND=REALTYPE) :: revadj(0:ib, 0:jb, 0:kb), rlvadj(0:ib, 0:jb, 0:&
&  kb)
  REAL(KIND=REALTYPE) :: rlvadj1(iibeg:iiend, jjbeg:jjend), rlvadj2(&
&  iibeg:iiend, jjbeg:jjend)
  REAL(KIND=REALTYPE) :: nnx, nnxb, nny, nnyb, nnz, nnzb, tempb, tempb0&
&  , vn, vnb
  REAL(KIND=REALTYPE) :: wadj0(iibeg:iiend, jjbeg:jjend, nw), wadj0b(&
&  iibeg:iiend, jjbeg:jjend, nw), wadj1(iibeg:iiend, jjbeg:jjend, nw), &
&  wadj1b(iibeg:iiend, jjbeg:jjend, nw)
  REAL(KIND=REALTYPE) :: wadj2(iibeg:iiend, jjbeg:jjend, nw), wadj2b(&
&  iibeg:iiend, jjbeg:jjend, nw), wadj3(iibeg:iiend, jjbeg:jjend, nw), &
&  wadj3b(iibeg:iiend, jjbeg:jjend, nw)
!
!      ******************************************************************
!      *                                                                *
!      * bcSymmAdj applies the symmetry boundary conditions to a single *
!      * cell stencil.
!      * It is assumed that the pointers in blockPointers are already   *
!      * set to the correct block on the correct grid level.            *
!      *                                                                *
!      * In case also the second halo must be set the loop over the     *
!      * boundary subfaces is executed twice. This is the only correct  *
!      * way in case the block contains only 1 cell between two         *
!      * symmetry planes, i.e. a 2D problem.                            *
!      *                                                                *
!      ******************************************************************
!
!nw
!nt1mg,nt2mg
!
!      Subroutine arguments.
!
!       integer(kind=intType) :: iCell, jCell, kCell
!!$  real(kind=realType), dimension(-2:2,-2:2,-2:2,nw), &
!!$       intent(in) :: wAdj
!!$  real(kind=realType), dimension(-2:2,-2:2,-2:2),intent(in) :: pAdj
!!$  real(kind=realType), dimension(nBocos,-2:2,-2:2,3), intent(in) :: normAdj
!
!      Local variables.
!
!!$  real(kind=realType), dimension(-2:2,-2:2,nw) :: wAdj0, wAdj1
!!$  real(kind=realType), dimension(-2:2,-2:2,nw) :: wAdj2, wAdj3
!!$  real(kind=realType), dimension(-2:2,-2:2)    :: pAdj0, pAdj1
!!$  real(kind=realType), dimension(-2:2,-2:2)    :: pAdj2, pAdj3
!!$
!!$  real(kind=realType), dimension(-2:2,-2:2,-2:2)::rlvAdj, revAdj
!!$  real(kind=realType), dimension(-2:2,-2:2)::rlvAdj1, rlvAdj2
!!$  real(kind=realType), dimension(-2:2,-2:2)::revAdj1, revAdj2
!!$
!!$  integer(kind=intType) ::iCell, jCell,kCell
!!$  integer(kind=intType) ::isbeg,jsbeg,ksbeg,isend,jsend,ksend
!!$  integer(kind=intType) ::ibbeg,jbbeg,kbbeg,ibend,jbend,kbend
!!$  integer(kind=intType) ::icbeg,jcbeg,kcbeg,icend,jcend,kcend
!!$  integer(kind=intType) :: iOffset, jOffset, kOffset
!!$  logical :: computeBC
!!$!
!!$!      Interfaces
!!$!
!!$       interface
!!$         subroutine setBcPointers(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
!!$                                  rev1, rev2, offset)
!!$           use blockPointers
!!$           implicit none
!!$
!!$           integer(kind=intType), intent(in) :: nn, offset
!!$           real(kind=realType), dimension(:,:,:), pointer :: ww1, ww2
!!$           real(kind=realType), dimension(:,:),   pointer :: pp1, pp2
!!$           real(kind=realType), dimension(:,:),   pointer :: rlv1, rlv2
!!$           real(kind=realType), dimension(:,:),   pointer :: rev1, rev2
!!$         end subroutine setBcPointers
!!$       end interface
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
!!$  ! Set the value of kk; kk == 0 means only single halo, kk == 1
!!$  ! double halo.
!!$
!!$  kk = 0
!!$  if( secondHalo ) kk = 1
!!$
!!$  ! Loop over the number of times the halo computation must be done.
!!$
!!$  nHalo: do mm=0,kk
! Loop over the boundary condition subfaces of this block.
!!$     bocos: do nn=1,nBocos
!!$
!!$        call checkOverlapAdj(nn,icell,jcell,kcell,isbeg,jsbeg,&
!!$            ksbeg,isend,jsend,ksend,ibbeg,jbbeg,kbbeg,ibend,jbend,kbend,&
!!$            computeBC)
!!$        !(nn,icell,jcell,kcell,isbeg,jsbeg,&
!!$        !     ksbeg,isend,jsend,ksend,ibbeg,jbbeg,kbbeg,ibend,jbend,kbend,&
!!$        !     computeBC)
!!$
!!$
!!$        if (computeBC) then
! Check for symmetry boundary condition.
  IF (bctype(nn) .EQ. symm) THEN
    icbeg = iibeg
    icend = iiend
    jcbeg = jjbeg
    jcend = jjend
!!$             ! Nullify the pointers, because some compilers require that.
!!$
!!$             nullify(ww1, ww2, pp1, pp2, rlv1, rlv2, rev1, rev2)
!!$              ! Set the pointers to the correct subface.
!!$              call setBcPointers(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
!!$                                rev1, rev2, mm)
!Copy the states and other parameters to subfaces
    CALL EXTRACTBCSTATESFORCECOUPLINGADJ(nn, wadj, padj, wadj0, wadj1, &
&                                   wadj2, wadj3, padj0, padj1, padj2, &
&                                   padj3, rlvadj, revadj, rlvadj1, &
&                                   rlvadj2, revadj1, revadj2, iibeg, &
&                                   jjbeg, iiend, jjend, secondhalo)
! Set the additional pointers for gamma1 and gamma2.
! Loop over the generic subface to set the state in the
! halo cells.
!!$             do j=BCData(nn)%jcBeg, BCData(nn)%jcEnd
!!$               do i=BCData(nn)%icBeg, BCData(nn)%icEnd
    DO j=jcbeg,jcend
      DO i=icbeg,icend
        CALL PUSHREAL8(nnx)
! Store the three components of the unit normal a
! bit easier.
!BCData(nn)%norm(i,j,1)
        nnx = normadj(i, j, 1)
        CALL PUSHREAL8(nny)
!BCData(nn)%norm(i,j,2)
        nny = normadj(i, j, 2)
        CALL PUSHREAL8(nnz)
!BCData(nn)%norm(i,j,3)
        nnz = normadj(i, j, 3)
        CALL PUSHREAL8(vn)
! Determine twice the normal velocity component,
! which must be substracted from the donor velocity
! to obtain the halo velocity.
        vn = two*(wadj2(i, j, ivx)*nnx+wadj2(i, j, ivy)*nny+wadj2(i, j, &
&          ivz)*nnz)
! Determine the flow variables in the halo cell.
        IF (secondhalo) THEN
          CALL PUSHREAL8(vn)
          vn = two*(wadj3(i, j, ivx)*nnx+wadj3(i, j, ivy)*nny+wadj3(i, j&
&            , ivz)*nnz)
! Determine the flow variables in the halo cell.
          CALL PUSHINTEGER4(2)
        ELSE
          CALL PUSHINTEGER4(1)
        END IF
      END DO
    END DO
    CALL REPLACEBCSTATESFORCECOUPLINGADJ_B(nn, wadj0, wadj0b, wadj1, &
&                                     wadj1b, wadj2, wadj3, padj0, &
&                                     padj0b, padj1, padj1b, padj2, &
&                                     padj3, rlvadj1, rlvadj2, revadj1, &
&                                     revadj2, wadj, wadjb, padj, padjb&
&                                     , rlvadj, revadj, iibeg, jjbeg, &
&                                     iiend, jjend, secondhalo)
    padj2b(iibeg:iiend, jjbeg:jjend) = 0.0
    padj3b(iibeg:iiend, jjbeg:jjend) = 0.0
    wadj2b(iibeg:iiend, jjbeg:jjend, 1:nw) = 0.0
    wadj3b(iibeg:iiend, jjbeg:jjend, 1:nw) = 0.0
    DO j=jcend,jcbeg,-1
      DO i=icend,icbeg,-1
        CALL POPINTEGER4(branch)
        IF (branch .LT. 2) THEN
          nnxb = 0.0
          nnyb = 0.0
          nnzb = 0.0
        ELSE
          padj3b(i, j) = padj3b(i, j) + padj0b(i, j)
          padj0b(i, j) = 0.0
          DO l=nt2mg,nt1mg,-1
            wadj3b(i, j, l) = wadj3b(i, j, l) + wadj0b(i, j, l)
            wadj0b(i, j, l) = 0.0
          END DO
          wadj3b(i, j, irhoe) = wadj3b(i, j, irhoe) + wadj0b(i, j, irhoe&
&            )
          wadj0b(i, j, irhoe) = 0.0
          wadj3b(i, j, ivz) = wadj3b(i, j, ivz) + wadj0b(i, j, ivz)
          vnb = -(nnz*wadj0b(i, j, ivz))
          nnzb = -(vn*wadj0b(i, j, ivz))
          wadj0b(i, j, ivz) = 0.0
          wadj3b(i, j, ivy) = wadj3b(i, j, ivy) + wadj0b(i, j, ivy)
          vnb = vnb - nny*wadj0b(i, j, ivy)
          nnyb = -(vn*wadj0b(i, j, ivy))
          wadj0b(i, j, ivy) = 0.0
          wadj3b(i, j, ivx) = wadj3b(i, j, ivx) + wadj0b(i, j, ivx)
          vnb = vnb - nnx*wadj0b(i, j, ivx)
          tempb0 = two*vnb
          nnxb = wadj3(i, j, ivx)*tempb0 - vn*wadj0b(i, j, ivx)
          wadj0b(i, j, ivx) = 0.0
          wadj3b(i, j, irho) = wadj3b(i, j, irho) + wadj0b(i, j, irho)
          wadj0b(i, j, irho) = 0.0
          CALL POPREAL8(vn)
          wadj3b(i, j, ivx) = wadj3b(i, j, ivx) + nnx*tempb0
          wadj3b(i, j, ivy) = wadj3b(i, j, ivy) + nny*tempb0
          nnyb = nnyb + wadj3(i, j, ivy)*tempb0
          wadj3b(i, j, ivz) = wadj3b(i, j, ivz) + nnz*tempb0
          nnzb = nnzb + wadj3(i, j, ivz)*tempb0
        END IF
        padj2b(i, j) = padj2b(i, j) + padj1b(i, j)
        padj1b(i, j) = 0.0
        DO l=nt2mg,nt1mg,-1
          wadj2b(i, j, l) = wadj2b(i, j, l) + wadj1b(i, j, l)
          wadj1b(i, j, l) = 0.0
        END DO
        wadj2b(i, j, irhoe) = wadj2b(i, j, irhoe) + wadj1b(i, j, irhoe)
        wadj1b(i, j, irhoe) = 0.0
        wadj2b(i, j, ivz) = wadj2b(i, j, ivz) + wadj1b(i, j, ivz)
        vnb = -(nnz*wadj1b(i, j, ivz))
        nnzb = nnzb - vn*wadj1b(i, j, ivz)
        wadj1b(i, j, ivz) = 0.0
        wadj2b(i, j, ivy) = wadj2b(i, j, ivy) + wadj1b(i, j, ivy)
        vnb = vnb - nny*wadj1b(i, j, ivy)
        nnyb = nnyb - vn*wadj1b(i, j, ivy)
        wadj1b(i, j, ivy) = 0.0
        wadj2b(i, j, ivx) = wadj2b(i, j, ivx) + wadj1b(i, j, ivx)
        vnb = vnb - nnx*wadj1b(i, j, ivx)
        tempb = two*vnb
        nnxb = nnxb + wadj2(i, j, ivx)*tempb - vn*wadj1b(i, j, ivx)
        wadj1b(i, j, ivx) = 0.0
        wadj2b(i, j, irho) = wadj2b(i, j, irho) + wadj1b(i, j, irho)
        wadj1b(i, j, irho) = 0.0
        CALL POPREAL8(vn)
        wadj2b(i, j, ivx) = wadj2b(i, j, ivx) + nnx*tempb
        wadj2b(i, j, ivy) = wadj2b(i, j, ivy) + nny*tempb
        nnyb = nnyb + wadj2(i, j, ivy)*tempb
        wadj2b(i, j, ivz) = wadj2b(i, j, ivz) + nnz*tempb
        nnzb = nnzb + wadj2(i, j, ivz)*tempb
        CALL POPREAL8(nnz)
        normadjb(i, j, 3) = normadjb(i, j, 3) + nnzb
        CALL POPREAL8(nny)
        normadjb(i, j, 2) = normadjb(i, j, 2) + nnyb
        CALL POPREAL8(nnx)
        normadjb(i, j, 1) = normadjb(i, j, 1) + nnxb
      END DO
    END DO
    CALL EXTRACTBCSTATESFORCECOUPLINGADJ_B(nn, wadj, wadjb, padj, padjb&
&                                     , wadj0, wadj0b, wadj1, wadj1b, &
&                                     wadj2, wadj2b, wadj3, wadj3b, &
&                                     padj0, padj0b, padj1, padj1b, &
&                                     padj2, padj2b, padj3, padj3b, &
&                                     rlvadj, revadj, rlvadj1, rlvadj2, &
&                                     revadj1, revadj2, iibeg, jjbeg, &
&                                     iiend, jjend, secondhalo)
  END IF
END SUBROUTINE BCSYMMFORCECOUPLINGADJ_B
