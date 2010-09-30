   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
   !  
   !  Differentiation of computepressureadj in reverse (adjoint) mode:
   !   gradient, with respect to input variables: padj wadj
   !   of linear combination of output variables: padj wadj
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          computePressureAdj.f90                          *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-19-2006                                      *
   !      * Last modified: 03-20-2006                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE COMPUTEPRESSUREADJ_B(wadj, wadjb, padj, padjb, nn, level, sps&
   &  , sps2)
   USE flowvarrefstate
   USE inputphysics
   USE inputtimespectral
   IMPLICIT NONE
   INTEGER(KIND=INTTYPE) :: level, nn, sps, sps2
   REAL(KIND=REALTYPE) :: padj(-2:2, -2:2, -2:2, ntimeintervalsspectral)&
   &  , padjb(-2:2, -2:2, -2:2, ntimeintervalsspectral)
   REAL(KIND=REALTYPE), DIMENSION(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral), INTENT(IN) :: wadj
   REAL(KIND=REALTYPE) :: wadjb(-2:2, -2:2, -2:2, nw, &
   &  ntimeintervalsspectral)
   INTEGER(KIND=INTTYPE) :: i, j, k
   REAL(KIND=REALTYPE) :: tempb, tempb0
   REAL(KIND=REALTYPE) :: factk, gm1, v2, v2b
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Simple routine to compute the pressure from the variables w.   *
   !      * A calorically perfect gas, i.e. constant gamma, is assumed.    *
   !      *                                                                *
   !      ******************************************************************
   !
   !nIntervalTimespectral
   !
   !      Subroutine arguments
   !
   !
   !      Local variables
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   gm1 = gammaconstant - one
   ! Check the situation.
   IF (kpresent) THEN
   ! A separate equation for the turbulent kinetic energy is
   ! present. This variable must be taken into account.
   factk = five*third - gammaconstant
   DO k=-2,2
   DO j=-2,2
   DO i=-2,2
   CALL PUSHREAL8(v2)
   v2 = wadj(i, j, k, ivx, sps2)**2 + wadj(i, j, k, ivy, sps2)**2&
   &           + wadj(i, j, k, ivz, sps2)**2
   END DO
   END DO
   END DO
   DO k=2,-2,-1
   DO j=2,-2,-1
   DO i=2,-2,-1
   tempb = gm1*padjb(i, j, k, sps2)
   wadjb(i, j, k, irhoe, sps2) = wadjb(i, j, k, irhoe, sps2) + &
   &            tempb
   wadjb(i, j, k, irho, sps2) = wadjb(i, j, k, irho, sps2) + &
   &            factk*wadj(i, j, k, itu1, sps2)*padjb(i, j, k, sps2) - half&
   &            *v2*tempb
   v2b = -(half*wadj(i, j, k, irho, sps2)*tempb)
   wadjb(i, j, k, itu1, sps2) = wadjb(i, j, k, itu1, sps2) + &
   &            factk*wadj(i, j, k, irho, sps2)*padjb(i, j, k, sps2)
   padjb(i, j, k, sps2) = 0.0
   CALL POPREAL8(v2)
   wadjb(i, j, k, ivx, sps2) = wadjb(i, j, k, ivx, sps2) + 2*wadj&
   &            (i, j, k, ivx, sps2)*v2b
   wadjb(i, j, k, ivy, sps2) = wadjb(i, j, k, ivy, sps2) + 2*wadj&
   &            (i, j, k, ivy, sps2)*v2b
   wadjb(i, j, k, ivz, sps2) = wadjb(i, j, k, ivz, sps2) + 2*wadj&
   &            (i, j, k, ivz, sps2)*v2b
   END DO
   END DO
   END DO
   ELSE
   ! No separate equation for the turbulent kinetic enery.
   ! Use the standard formula.
   DO k=-2,2
   DO j=-2,2
   DO i=-2,2
   CALL PUSHREAL8(v2)
   v2 = wadj(i, j, k, ivx, sps2)**2 + wadj(i, j, k, ivy, sps2)**2&
   &           + wadj(i, j, k, ivz, sps2)**2
   END DO
   END DO
   END DO
   DO k=2,-2,-1
   DO j=2,-2,-1
   DO i=2,-2,-1
   tempb0 = gm1*padjb(i, j, k, sps2)
   wadjb(i, j, k, irhoe, sps2) = wadjb(i, j, k, irhoe, sps2) + &
   &            tempb0
   wadjb(i, j, k, irho, sps2) = wadjb(i, j, k, irho, sps2) - half&
   &            *v2*tempb0
   v2b = -(half*wadj(i, j, k, irho, sps2)*tempb0)
   padjb(i, j, k, sps2) = 0.0
   CALL POPREAL8(v2)
   wadjb(i, j, k, ivx, sps2) = wadjb(i, j, k, ivx, sps2) + 2*wadj&
   &            (i, j, k, ivx, sps2)*v2b
   wadjb(i, j, k, ivy, sps2) = wadjb(i, j, k, ivy, sps2) + 2*wadj&
   &            (i, j, k, ivy, sps2)*v2b
   wadjb(i, j, k, ivz, sps2) = wadjb(i, j, k, ivz, sps2) + 2*wadj&
   &            (i, j, k, ivz, sps2)*v2b
   END DO
   END DO
   END DO
   END IF
   END SUBROUTINE COMPUTEPRESSUREADJ_B
