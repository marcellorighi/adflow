!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of vectorrotation in reverse (adjoint) mode:
!   gradient, with respect to input variables: x y z angle
!   of linear combination of output variables: xp yp angle zp
!
!     ******************************************************************
!     *                                                                *
!     * File:          vectorRotation.f90                              *
!     * Author:        Andre C. Marta                                  *
!     * Starting date: 06-23-2006                                      *
!     * Last modified: 07-28-2006                                      *
!     *                                                                *
!     ******************************************************************
!
SUBROUTINE VECTORROTATION_B(xp, xpb, yp, ypb, zp, zpb, iaxis, angle, &
&  angleb, x, xb, y, yb, z, zb)
  USE precision
  IMPLICIT NONE
  REAL(KIND=REALTYPE), INTENT(IN) :: angle
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iaxis
  REAL(KIND=REALTYPE), INTENT(IN) :: x
  REAL(KIND=REALTYPE), INTENT(IN) :: y
  REAL(KIND=REALTYPE), INTENT(IN) :: z
  REAL(KIND=REALTYPE) :: angleb, xb, yb, zb
  REAL(KIND=REALTYPE) :: xp, xpb, yp, ypb, zp, zpb
  INTRINSIC COS, SIN
!
!     ****************************************************************
!     *                                                              *
!     * vectorRotation rotates a given vector with respect to a      *
!     * specified axis by a given angle.                             *
!     *                                                              *
!     *    input arguments:                                          *
!     *       iaxis      = rotation axis (1-x, 2-y, 3-z)             *
!     *       angle      = rotation angle (measured ccw in radians)  *
!     *       x, y, z    = coordinates in original system            *
!     *    output arguments:                                         *
!     *       xp, yp, zp = coordinates in rotated system             *
!     *                                                              *
!     ****************************************************************
!
!
!     Subroutine arguments.
!
!
!     ******************************************************************
!     *                                                                *
!     * Begin execution                                                *
!     *                                                                *
!     ******************************************************************
!
! rotation about specified axis by specified angle
  SELECT CASE  (iaxis) 
  CASE (1) 
    xb = xpb
    angleb = angleb + (z*COS(angle)-y*SIN(angle))*ypb + (-(z*SIN(angle))&
&      -y*COS(angle))*zpb
    yb = COS(angle)*ypb - SIN(angle)*zpb
    zb = SIN(angle)*ypb + COS(angle)*zpb
  CASE (2) 
    angleb = angleb + (-(z*COS(angle))-x*SIN(angle))*xpb + (x*COS(angle)&
&      -z*SIN(angle))*zpb
    xb = COS(angle)*xpb + SIN(angle)*zpb
    yb = ypb
    zb = COS(angle)*zpb - SIN(angle)*xpb
  CASE (3) 
    xb = COS(angle)*xpb - SIN(angle)*ypb
    yb = SIN(angle)*xpb + COS(angle)*ypb
    zb = zpb
    angleb = angleb + (y*COS(angle)-x*SIN(angle))*xpb + (-(x*COS(angle))&
&      -y*SIN(angle))*ypb
  END SELECT
END SUBROUTINE VECTORROTATION_B
