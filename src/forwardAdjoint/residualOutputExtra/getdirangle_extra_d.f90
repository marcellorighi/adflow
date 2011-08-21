   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.4 (r3375) - 10 Feb 2010 15:08
   !
   !  Differentiation of getdirangle in forward (tangent) mode:
   !   variations   of useful results: alpha beta
   !   with respect to varying inputs: alpha beta freestreamaxis
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          getDirAngle.f90                                 *
   !     * Author:        Andre C. Marta,C.A.(Sandy) Mader                *
   !     * Starting date: 10-25-2005                                      *
   !     * Last modified: 06-13-2008                                      *
   !     *                                                                *
   !     ******************************************************************
   !
   SUBROUTINE GETDIRANGLE_EXTRA_D(freestreamaxis, freestreamaxisd, liftaxis&
   &  , liftindex, alpha, alphad, beta, betad)
   USE CONSTANTS
   IMPLICIT NONE
   !print *,'end get angle'
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Convert the wind axes to angle of attack and side slip angle.  *
   !     * The direction angles alpha and beta are computed given the     *
   !     * components of the wind direction vector (freeStreamAxis), the  *
   !     * lift direction vector (liftAxis) and assuming that the         *
   !     * body direction (xb,yb,zb) is in the default ijk coordinate     *
   !     * system. The rotations are determined by first determining      *
   !     * whether the lift is primarily in the j or k direction and then *
   !     * determining the angles accordingly.                            *
   !     * direction vector:                                              *
   !     *   1) Rotation about the zb or yb -axis: alpha clockwise (CW)   *
   !     *      (xb,yb,zb) -> (x1,y1,z1)                                  *
   !     *                                                                *
   !     *   2) Rotation about the yl or z1 -axis: beta counter-clockwise *
   !     *      (CCW) (x1,y1,z1) -> (xw,yw,zw)                            *
   !     *                                                                *
   !     *    input arguments:                                            *
   !     *       freeStreamAxis = wind vector in body axes                *
   !     *       liftAxis       = lift direction vector in body axis      *       
   !     *    output arguments:                                           *
   !     *       alpha    = angle of attack in radians                    *
   !     *       beta     = side slip angle in radians                    *
   !     *                                                                *
   !     ******************************************************************
   !
   !
   !     Subroutine arguments.
   !
   !      real(kind=realType), intent(in)  :: xw, yw, zw
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: freestreamaxis
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: freestreamaxisd
   REAL(kind=realtype), DIMENSION(3), INTENT(IN) :: liftaxis
   REAL(kind=realtype), INTENT(OUT) :: alpha, beta
   REAL(kind=realtype), INTENT(OUT) :: alphad, betad
   INTEGER(kind=inttype), INTENT(OUT) :: liftindex
   !
   !     Local variables.
   !
   REAL(kind=realtype) :: rnorm
   REAL(kind=realtype) :: rnormd
   INTEGER(kind=inttype) :: flowindex, i
   REAL(kind=realtype), DIMENSION(3) :: freestreamaxisnorm
   REAL(kind=realtype), DIMENSION(3) :: freestreamaxisnormd
   INTEGER(kind=inttype), DIMENSION(1) :: temp
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   INTRINSIC ATAN2
   INTRINSIC MAXLOC
   INTRINSIC SQRT
   INTRINSIC ASIN
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Begin execution.                                               *
   !     *                                                                *
   !     ******************************************************************
   !
   !print *,'input',freeStreamAxis,liftAxis,liftIndex,alpha,beta
   ! Check that the dominant free stream direction is x 
   !print *,'in get angle'
   temp = MAXLOC(freestreamaxis)
   flowindex = temp(1)
   IF (flowindex .NE. 1) CALL TERMINATE('getDirAngle', &
   &                                  'Dominant Flow not in +ve x direction'&
   &                                   )
   !print *,'flow Index'
   ! Determine the dominant lift direction
   temp = MAXLOC(liftaxis)
   !print *,'temp',temp,temp(1)
   liftindex = temp(1)
   ! Normalize the freeStreamDirection vector.
   !print *,'liftIndex1'
   arg1d = 2*freestreamaxis(1)*freestreamaxisd(1) + 2*freestreamaxis(2)*&
   &    freestreamaxisd(2) + 2*freestreamaxis(3)*freestreamaxisd(3)
   arg1 = freestreamaxis(1)**2 + freestreamaxis(2)**2 + freestreamaxis(3)&
   &    **2
   IF (arg1 .EQ. 0.0) THEN
   rnormd = 0.0
   ELSE
   rnormd = arg1d/(2.0*SQRT(arg1))
   END IF
   rnorm = SQRT(arg1)
   freestreamaxisnormd = 0.0
   DO i=1,3
   freestreamaxisnormd(i) = (freestreamaxisd(i)*rnorm-freestreamaxis(i)&
   &      *rnormd)/rnorm**2
   freestreamaxisnorm(i) = freestreamaxis(i)/rnorm
   END DO
   !print *,'liftIndex',liftIndex
   IF (liftindex .EQ. 2) THEN
   ! different coordinate system for aerosurf
   ! Wing is in z- direction
   ! Compute angle of attack alpha.
   alphad = freestreamaxisnormd(2)/SQRT(1.0-freestreamaxisnorm(2)**2)
   alpha = ASIN(freestreamaxisnorm(2))
   ! Compute side-slip angle beta.
   betad = -((freestreamaxisnormd(3)*freestreamaxisnorm(1)-&
   &      freestreamaxisnormd(1)*freestreamaxisnorm(3))/(freestreamaxisnorm(&
   &      3)**2+freestreamaxisnorm(1)**2))
   beta = -ATAN2(freestreamaxisnorm(3), freestreamaxisnorm(1))
   ELSE IF (liftindex .EQ. 3) THEN
   ! Wing is in y- direction
   ! Compute angle of attack alpha.
   alphad = freestreamaxisnormd(3)/SQRT(1.0-freestreamaxisnorm(3)**2)
   alpha = ASIN(freestreamaxisnorm(3))
   ! Compute side-slip angle beta.
   betad = (freestreamaxisnormd(2)*freestreamaxisnorm(1)-&
   &      freestreamaxisnormd(1)*freestreamaxisnorm(2))/(freestreamaxisnorm(&
   &      2)**2+freestreamaxisnorm(1)**2)
   beta = ATAN2(freestreamaxisnorm(2), freestreamaxisnorm(1))
   ELSE
   CALL TERMINATE('getDirAngle', 'Invalid Lift Direction')
   END IF
   END SUBROUTINE GETDIRANGLE_EXTRA_D