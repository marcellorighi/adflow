!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of etotarrayforcecouplingadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: p u etot
!   of linear combination of output variables: p etot
!
!      ******************************************************************
!      *                                                                *
!      * File:          etotArrayAdj.f90                              *
!      * Author:        Edwin van der Weide, C.A.(Sandy) Mader          *
!      * Starting date: 04-25-2008                                      *
!      * Last modified: 04-25-2008                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE ETOTARRAYFORCECOUPLINGADJ_B(rho, u, ub, v, w, p, pb, k, etot&
&  , etotb, correctfork, kk)
  USE constants
  IMPLICIT NONE
  LOGICAL, INTENT(IN) :: correctfork
  INTEGER(KIND=INTTYPE), INTENT(IN) :: kk
  REAL(KIND=REALTYPE) :: etot(kk), etotb(kk)
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: k
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: p
  REAL(KIND=REALTYPE) :: pb(kk)
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: rho
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: u
  REAL(KIND=REALTYPE) :: ub(kk)
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: v
  REAL(KIND=REALTYPE), DIMENSION(kk), INTENT(IN) :: w
  INTEGER(KIND=INTTYPE) :: i
!
!      ******************************************************************
!      *                                                                *
!      * EtotArray computes the total energy from the given density,    *
!      * velocity and presssure for the given kk elements of the arrays.*
!      * First the internal energy per unit mass is computed and after  *
!      * that the kinetic energy is added as well the conversion to     *
!      * energy per unit volume.                                        *
!      *                                                                *
!      ******************************************************************
!
!
!      Subroutine arguments.
!
!!$       real(kind=realType), dimension(*), intent(in)  :: rho, p, k
!!$       real(kind=realType), dimension(*), intent(in)  :: u, v, w
!!$       real(kind=realType), dimension(*), intent(out) :: etot
!
!      Local variables.
!
!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
! Compute the internal energy for unit mass.
  CALL EINTARRAYFORCECOUPLINGADJ(rho, p, k, etot, correctfork, kk)
  ub(1:kk) = 0.0
  DO i=kk,1,-1
    ub(i) = ub(i) + rho(i)*half*2*u(i)*etotb(i)
    etotb(i) = rho(i)*etotb(i)
  END DO
  CALL EINTARRAYFORCECOUPLINGADJ_B(rho, p, pb, k, etot, etotb, &
&                             correctfork, kk)
END SUBROUTINE ETOTARRAYFORCECOUPLINGADJ_B
