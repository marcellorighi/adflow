!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade - Version 2.2 (r1239) - Wed 28 Jun 2006 04:59:55 PM CEST
!  
!  Differentiation of getsurfacenormalscouplingadj in reverse (adjoint) mode:
!   gradient, with respect to input variables: xadj
!   of linear combination of output variables: skadj sjadj siadj
!                normadj
!
!      ******************************************************************
!      *                                                                *
!      * File:          getSurfaceNormalsAdj.f90                        *
!      * Author:        Edwin van der Weide                             *
!      *                Seongim Choi                                    *
!      * Starting date: 12-18-2007                                      *
!      * Last modified: 12-18-2007                                      *
!      *                                                                *
!      ******************************************************************
!
SUBROUTINE GETSURFACENORMALSCOUPLINGADJ_B(xadj, xadjb, siadj, siadjb, &
&  sjadj, sjadjb, skadj, skadjb, normadj, normadjb, iibeg, iiend, jjbeg&
&  , jjend, mm, level, nn, sps, righthanded)
  USE bctypes
  USE blockpointers
  USE communication
  IMPLICIT NONE
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iibeg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: iiend
  INTEGER(KIND=INTTYPE), INTENT(IN) :: jjbeg
  INTEGER(KIND=INTTYPE), INTENT(IN) :: jjend
  INTEGER(KIND=INTTYPE), INTENT(IN) :: level
  INTEGER(KIND=INTTYPE), INTENT(IN) :: mm
  INTEGER(KIND=INTTYPE), INTENT(IN) :: nn
  REAL(KIND=REALTYPE) :: normadj(iibeg:iiend, jjbeg:jjend, 3), normadjb(&
&  iibeg:iiend, jjbeg:jjend, 3)
  LOGICAL, INTENT(IN) :: righthanded
  REAL(KIND=REALTYPE) :: siadj(2, iibeg:iiend, jjbeg:jjend, 3), siadjb(2&
&  , iibeg:iiend, jjbeg:jjend, 3)
  REAL(KIND=REALTYPE) :: sjadj(iibeg:iiend, 2, jjbeg:jjend, 3), sjadjb(&
&  iibeg:iiend, 2, jjbeg:jjend, 3)
  REAL(KIND=REALTYPE) :: skadj(iibeg:iiend, jjbeg:jjend, 2, 3), skadjb(&
&  iibeg:iiend, jjbeg:jjend, 2, 3)
  INTEGER(KIND=INTTYPE), INTENT(IN) :: sps
  REAL(KIND=REALTYPE), DIMENSION(0:ie, 0:je, 0:ke, 3), INTENT(IN) :: &
&  xadj
  REAL(KIND=REALTYPE) :: xadjb(0:ie, 0:je, 0:ke, 3)
  INTEGER :: branch, ierr
  INTEGER(KIND=INTTYPE) :: i, ii, j, jj, k, kk, l, m, n
  REAL(KIND=REALTYPE) :: ss(iibeg:iiend, jjbeg:jjend, 3), ssb(iibeg:&
&  iiend, jjbeg:jjend, 3)
  REAL(KIND=REALTYPE) :: tempb11, tempb12, tempb13, tempb14, tempb15, &
&  tempb16
  REAL(KIND=REALTYPE) :: tempb, tempb0, tempb1, tempb2, tempb3, tempb4
  REAL(KIND=REALTYPE) :: tempb10, tempb5, tempb6, tempb7, tempb8, tempb9
  REAL(KIND=REALTYPE) :: v1(3), v12(3), v1b(3), v2(3), v22(3), v2b(3)
  REAL(KIND=REALTYPE) :: fact, factb, mult, tempb17, xp, xpb, yp, ypb, &
&  zp, zpb
  INTRINSIC SQRT
!
!
!      ******************************************************************
!      *                                                                *
!      * boundarySurfaceNormals computes the outward normals of the     *
!      * boundary subfaces at the given time instance and the given     *
!      * multi grid level.                                              *
!      *                                                                *
!      ******************************************************************
!
! ie,je,ke,il,jl,kl
!
!      Subroutine arguments.
!
!       real(kind=realType), dimension(1:2,iiBeg:iiEnd,jjBeg:jjEnd,3), intent(out) :: siAdj
!       real(kind=realType), dimension(iiBeg:iiEnd,1:2,jjBeg:jjEnd,3), intent(out) :: sjAdj
!       real(kind=realType), dimension(iiBeg:iiEnd,jjBeg:jjEnd,1:2,3), intent(out) :: skAdj
!       real(kind=realType), dimension(iiBeg:iiEnd,jjBeg:jjEnd,3), intent(out) :: normAdj
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
!      **************************************************************
!      *                                                            *
!      * Computation of the face normals in i-, j- and k-direction. *
!      * Formula's are valid for a right handed block; for a left   *
!      * handed block the correct orientation is obtained via fact. *
!      * The normals point in the direction of increasing index.    *
!      * The absolute value of fact is 0.5, because the cross       *
!      * product of the two diagonals is twice the normal vector.   *
!      *                                                            *
!      * Note that also the normals of the first level halo cells   *
!      * are computed. These are needed for the viscous fluxes.     *
!      *                                                            *
!      **************************************************************
!
! Set the factor in the surface normals computation. For a
! left handed block this factor is negative, such that the
! normals still point in the direction of increasing index.
! The formulae used later on assume a right handed block
! and fact is used to correct this for a left handed block,
! as well as the scaling factor of 0.5
  IF (righthanded) THEN
    fact = half
    CALL PUSHINTEGER4(0)
  ELSE
    fact = -half
    CALL PUSHINTEGER4(1)
  END IF
  SELECT CASE  (bcfaceid(mm)) 
  CASE (imin) 
    DO k=jjbeg,jjend
      CALL PUSHINTEGER4(n)
      n = k - 1
      DO j=iibeg,iiend
        CALL PUSHINTEGER4(m)
        m = j - 1
        DO i=1,1
! to get siAdj(1,:,:,3)
          IF (i .EQ. 1) THEN
            CALL PUSHINTEGER4(ii)
            ii = 1
            CALL PUSHINTEGER4(1)
          ELSE
            CALL PUSHINTEGER4(0)
          END IF
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, n, 1) - xadj(i, m, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, n, 2) - xadj(i, m, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, n, 3) - xadj(i, m, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(i, j, k, 1) - xadj(i, m, n, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(i, j, k, 2) - xadj(i, m, n, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(i, j, k, 3) - xadj(i, m, n, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          siadj(ii, j, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          siadj(ii, j, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          siadj(ii, j, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(1)
  CASE (imax) 
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', ii,j,k,siAdj(ii,j,k,1)-si(i,j,k,1),siAdj(ii,j,k,2)-si(i,j,k,2),siAdj(ii,j,k,
!3)-si(i,j,k,3)                
    DO k=jjbeg,jjend
      CALL PUSHINTEGER4(n)
      n = k - 1
      DO j=iibeg,iiend
        CALL PUSHINTEGER4(m)
        m = j - 1
        DO i=il,il
! to get siAdj(2,:,:,3)
          IF (i .EQ. il) THEN
            CALL PUSHINTEGER4(ii)
            ii = 2
            CALL PUSHINTEGER4(1)
          ELSE
            CALL PUSHINTEGER4(0)
          END IF
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, n, 1) - xadj(i, m, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, n, 2) - xadj(i, m, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, n, 3) - xadj(i, m, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(i, j, k, 1) - xadj(i, m, n, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(i, j, k, 2) - xadj(i, m, n, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(i, j, k, 3) - xadj(i, m, n, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          siadj(ii, j, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          siadj(ii, j, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          siadj(ii, j, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(2)
  CASE (jmin) 
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', ii,j,k,siAdj(ii,j,k,1)-si(i,j,k,1),siAdj(ii,j,k,2)-si(i,j,k,2),siAdj(ii,j,k,
!3)-si(i,j,k,3)                
! Projected areas of cell faces in the j direction.
    DO k=jjbeg,jjend
      CALL PUSHINTEGER4(n)
      n = k - 1
      DO j=1,1
! to get sjAdj(:,1,:,:)
        IF (j .EQ. 1) THEN
          CALL PUSHINTEGER4(jj)
          jj = 1
          CALL PUSHINTEGER4(1)
        ELSE
          CALL PUSHINTEGER4(0)
        END IF
        DO i=iibeg,iiend
          CALL PUSHINTEGER4(l)
          l = i - 1
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, n, 1) - xadj(l, j, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, n, 2) - xadj(l, j, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, n, 3) - xadj(l, j, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(l, j, n, 1) - xadj(i, j, k, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(l, j, n, 2) - xadj(i, j, k, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(l, j, n, 3) - xadj(i, j, k, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          sjadj(i, jj, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          sjadj(i, jj, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          sjadj(i, jj, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(3)
  CASE (jmax) 
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', &
!i,jj,k,sjAdj(i,jj,k,1)-sj(i,j,k,1),sjAdj(i,jj,k,2)-sj(i,j,k,2),sjAdj(i,jj,k,3)-sj(i,j,k,3)                 
! Projected areas of cell faces in the j direction.
    DO k=jjbeg,jjend
      CALL PUSHINTEGER4(n)
      n = k - 1
      DO j=jl,jl
! to get sjAdj(:,1:2:,:,3)
        IF (j .EQ. jl) THEN
          CALL PUSHINTEGER4(jj)
          jj = 2
          CALL PUSHINTEGER4(1)
        ELSE
          CALL PUSHINTEGER4(0)
        END IF
        DO i=iibeg,iiend
          CALL PUSHINTEGER4(l)
          l = i - 1
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, n, 1) - xadj(l, j, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, n, 2) - xadj(l, j, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, n, 3) - xadj(l, j, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(l, j, n, 1) - xadj(i, j, k, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(l, j, n, 2) - xadj(i, j, k, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(l, j, n, 3) - xadj(i, j, k, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          sjadj(i, jj, k, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          sjadj(i, jj, k, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          sjadj(i, jj, k, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(4)
  CASE (kmin) 
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', &
!i,jj,k,sjAdj(i,jj,k,1)-sj(i,j,k,1),sjAdj(i,jj,k,2)-sj(i,j,k,2),sjAdj(i,jj,k,3)-sj(i,j,k,3)                 
! Projected areas of cell faces in the k direction.
    DO k=1,1
! to get skAdj(:,::,1:2,3)
      IF (k .EQ. 1) THEN
        CALL PUSHINTEGER4(kk)
        kk = 1
        CALL PUSHINTEGER4(1)
      ELSE
        CALL PUSHINTEGER4(0)
      END IF
      DO j=jjbeg,jjend
        CALL PUSHINTEGER4(m)
        m = j - 1
        DO i=iibeg,iiend
          CALL PUSHINTEGER4(l)
          l = i - 1
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, k, 1) - xadj(l, m, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, k, 2) - xadj(l, m, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, k, 3) - xadj(l, m, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(l, j, k, 1) - xadj(i, m, k, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(l, j, k, 2) - xadj(i, m, k, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(l, j, k, 3) - xadj(i, m, k, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          skadj(i, j, kk, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          skadj(i, j, kk, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          skadj(i, j, kk, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(5)
  CASE (kmax) 
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', &
!i,j,kk,skAdj(i,j,kk,1)-sk(i,j,k,1),skAdj(i,j,kk,2)-sk(i,j,k,2),skAdj(i,j,kk,3)-sk(i,j,k,3)                
! Projected areas of cell faces in the k direction.
    DO k=kl,kl
! to get skAdj(:,::,1:2,3)
      IF (k .EQ. kl) THEN
        CALL PUSHINTEGER4(kk)
        kk = 2
        CALL PUSHINTEGER4(1)
      ELSE
        CALL PUSHINTEGER4(0)
      END IF
      DO j=jjbeg,jjend
        CALL PUSHINTEGER4(m)
        m = j - 1
        DO i=iibeg,iiend
          CALL PUSHINTEGER4(l)
          l = i - 1
          CALL PUSHREAL8(v1(1))
! Determine the two diagonal vectors of the face.
          v1(1) = xadj(i, j, k, 1) - xadj(l, m, k, 1)
          CALL PUSHREAL8(v1(2))
          v1(2) = xadj(i, j, k, 2) - xadj(l, m, k, 2)
          CALL PUSHREAL8(v1(3))
          v1(3) = xadj(i, j, k, 3) - xadj(l, m, k, 3)
          CALL PUSHREAL8(v2(1))
          v2(1) = xadj(l, j, k, 1) - xadj(i, m, k, 1)
          CALL PUSHREAL8(v2(2))
          v2(2) = xadj(l, j, k, 2) - xadj(i, m, k, 2)
          CALL PUSHREAL8(v2(3))
          v2(3) = xadj(l, j, k, 3) - xadj(i, m, k, 3)
! The face normal, which is the cross product of the two
! diagonal vectors times fact; remember that fact is
! either -0.5 or 0.5.
          skadj(i, j, kk, 1) = fact*(v1(2)*v2(3)-v1(3)*v2(2))
          skadj(i, j, kk, 2) = fact*(v1(3)*v2(1)-v1(1)*v2(3))
          skadj(i, j, kk, 3) = fact*(v1(1)*v2(2)-v1(2)*v2(1))
        END DO
      END DO
    END DO
    CALL PUSHINTEGER4(6)
  CASE DEFAULT
    CALL PUSHINTEGER4(0)
  END SELECT
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi ', &
!i,j,kk,skAdj(i,j,kk,1)-sk(i,j,k,1),skAdj(i,j,kk,2)-sk(i,j,k,2),skAdj(i,j,kk,3)-sk(i,j,k,3)                
! Determine the block face on which this subface is located
! and set ss and mult accordingly.
  SELECT CASE  (bcfaceid(mm)) 
  CASE (imin) 
    mult = -one
    ss(:, :, :) = siadj(1, :, :, :)
    CALL PUSHINTEGER4(1)
  CASE (imax) 
    mult = one
! which was si(il,:,:,:)
    ss(:, :, :) = siadj(2, :, :, :)
    CALL PUSHINTEGER4(2)
  CASE (jmin) 
    mult = -one
    ss(:, :, :) = sjadj(:, 1, :, :)
    CALL PUSHINTEGER4(3)
  CASE (jmax) 
    mult = one
! which was sj(:,jl,:,:)
    ss(:, :, :) = sjadj(:, 2, :, :)
    CALL PUSHINTEGER4(4)
  CASE (kmin) 
    mult = -one
    ss(:, :, :) = skadj(:, :, 1, :)
    CALL PUSHINTEGER4(5)
  CASE (kmax) 
    mult = one
! which was sk(:,:,kl,:)
    ss(:, :, :) = skadj(:, :, 2, :)
    CALL PUSHINTEGER4(6)
  CASE DEFAULT
    CALL PUSHINTEGER4(0)
  END SELECT
!       do k=1,ke
!          do j=1,je
!             do i=1,2
! to get siAdj(1:2,:,:,3)
!                if(i==1)  ii=1
!                if(i==il) ii=2
!if(myID==0.and.sps==1) write(*,'(a5,3i5,3e)')'hi2 ',ii,j,k,siAdj(ii,j,k,1),siAdj(ii,j,k,2),siAdj(ii,j,k,3)                
!             enddo
!          enddo
!       enddo
! Loop over the boundary faces of the subface.
  DO j=jjbeg,jjend
    DO i=iibeg,iiend
      CALL PUSHREAL8(xp)
! Compute the inverse of the length of the normal vector
! and possibly correct for inward pointing.
      xp = ss(i, j, 1)
      CALL PUSHREAL8(yp)
      yp = ss(i, j, 2)
      CALL PUSHREAL8(zp)
      zp = ss(i, j, 3)
      CALL PUSHREAL8(fact)
      fact = SQRT(xp*xp + yp*yp + zp*zp)
      IF (fact .GT. zero) THEN
        CALL PUSHREAL8(fact)
        fact = mult/fact
        CALL PUSHINTEGER4(1)
      ELSE
        CALL PUSHINTEGER4(0)
      END IF
    END DO
  END DO
  ssb(iibeg:iiend, jjbeg:jjend, 1:3) = 0.0
  DO j=jjend,jjbeg,-1
    DO i=iiend,iibeg,-1
      factb = zp*normadjb(i, j, 3)
      zpb = fact*normadjb(i, j, 3)
      normadjb(i, j, 3) = 0.0
      factb = factb + yp*normadjb(i, j, 2)
      ypb = fact*normadjb(i, j, 2)
      normadjb(i, j, 2) = 0.0
      factb = factb + xp*normadjb(i, j, 1)
      xpb = fact*normadjb(i, j, 1)
      normadjb(i, j, 1) = 0.0
      CALL POPINTEGER4(branch)
      IF (.NOT.branch .LT. 1) THEN
        CALL POPREAL8(fact)
        factb = -(mult*factb/fact**2)
      END IF
      CALL POPREAL8(fact)
      tempb17 = factb/(2.0*SQRT(xp**2+yp**2+zp**2))
      xpb = xpb + 2*xp*tempb17
      ypb = ypb + 2*yp*tempb17
      zpb = zpb + 2*zp*tempb17
      CALL POPREAL8(zp)
      ssb(i, j, 3) = ssb(i, j, 3) + zpb
      CALL POPREAL8(yp)
      ssb(i, j, 2) = ssb(i, j, 2) + ypb
      CALL POPREAL8(xp)
      ssb(i, j, 1) = ssb(i, j, 1) + xpb
    END DO
  END DO
  CALL POPINTEGER4(branch)
  IF (branch .LT. 4) THEN
    IF (branch .LT. 2) THEN
      IF (.NOT.branch .LT. 1) siadjb(1, :, :, :) = siadjb(1, :, :, :) + &
&          ssb(:, :, :)
    ELSE IF (branch .LT. 3) THEN
      siadjb(2, :, :, :) = siadjb(2, :, :, :) + ssb(:, :, :)
    ELSE
      sjadjb(:, 1, :, :) = sjadjb(:, 1, :, :) + ssb(:, :, :)
    END IF
  ELSE IF (branch .LT. 6) THEN
    IF (branch .LT. 5) THEN
      sjadjb(:, 2, :, :) = sjadjb(:, 2, :, :) + ssb(:, :, :)
    ELSE
      skadjb(:, :, 1, :) = skadjb(:, :, 1, :) + ssb(:, :, :)
    END IF
  ELSE
    skadjb(:, :, 2, :) = skadjb(:, :, 2, :) + ssb(:, :, :)
  END IF
  CALL POPINTEGER4(branch)
  IF (branch .LT. 4) THEN
    IF (branch .LT. 2) THEN
      IF (branch .LT. 1) THEN
        xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
      ELSE
        xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
        v1b(1:3) = 0.0
        v2b(1:3) = 0.0
        DO k=jjend,jjbeg,-1
          DO j=iiend,iibeg,-1
            DO i=1,1,-1
              tempb = fact*siadjb(ii, j, k, 3)
              v1b(1) = v1b(1) + v2(2)*tempb
              v2b(2) = v2b(2) + v1(1)*tempb
              v1b(2) = v1b(2) - v2(1)*tempb
              siadjb(ii, j, k, 3) = 0.0
              tempb0 = fact*siadjb(ii, j, k, 2)
              v2b(1) = v2b(1) + v1(3)*tempb0 - v1(2)*tempb
              v1b(3) = v1b(3) + v2(1)*tempb0
              v1b(1) = v1b(1) - v2(3)*tempb0
              siadjb(ii, j, k, 2) = 0.0
              tempb1 = fact*siadjb(ii, j, k, 1)
              v2b(3) = v2b(3) + v1(2)*tempb1 - v1(1)*tempb0
              v1b(2) = v1b(2) + v2(3)*tempb1
              v1b(3) = v1b(3) - v2(2)*tempb1
              v2b(2) = v2b(2) - v1(3)*tempb1
              siadjb(ii, j, k, 1) = 0.0
              CALL POPREAL8(v2(3))
              xadjb(i, j, k, 3) = xadjb(i, j, k, 3) + v2b(3)
              xadjb(i, m, n, 3) = xadjb(i, m, n, 3) - v2b(3)
              v2b(3) = 0.0
              CALL POPREAL8(v2(2))
              xadjb(i, j, k, 2) = xadjb(i, j, k, 2) + v2b(2)
              xadjb(i, m, n, 2) = xadjb(i, m, n, 2) - v2b(2)
              v2b(2) = 0.0
              CALL POPREAL8(v2(1))
              xadjb(i, j, k, 1) = xadjb(i, j, k, 1) + v2b(1)
              xadjb(i, m, n, 1) = xadjb(i, m, n, 1) - v2b(1)
              v2b(1) = 0.0
              CALL POPREAL8(v1(3))
              xadjb(i, j, n, 3) = xadjb(i, j, n, 3) + v1b(3)
              xadjb(i, m, k, 3) = xadjb(i, m, k, 3) - v1b(3)
              v1b(3) = 0.0
              CALL POPREAL8(v1(2))
              xadjb(i, j, n, 2) = xadjb(i, j, n, 2) + v1b(2)
              xadjb(i, m, k, 2) = xadjb(i, m, k, 2) - v1b(2)
              v1b(2) = 0.0
              CALL POPREAL8(v1(1))
              xadjb(i, j, n, 1) = xadjb(i, j, n, 1) + v1b(1)
              xadjb(i, m, k, 1) = xadjb(i, m, k, 1) - v1b(1)
              v1b(1) = 0.0
              CALL POPINTEGER4(branch)
              IF (.NOT.branch .LT. 1) CALL POPINTEGER4(ii)
            END DO
            CALL POPINTEGER4(m)
          END DO
          CALL POPINTEGER4(n)
        END DO
      END IF
    ELSE IF (branch .LT. 3) THEN
      xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
      v1b(1:3) = 0.0
      v2b(1:3) = 0.0
      DO k=jjend,jjbeg,-1
        DO j=iiend,iibeg,-1
          DO i=il,il,-1
            tempb2 = fact*siadjb(ii, j, k, 3)
            v1b(1) = v1b(1) + v2(2)*tempb2
            v2b(2) = v2b(2) + v1(1)*tempb2
            v1b(2) = v1b(2) - v2(1)*tempb2
            siadjb(ii, j, k, 3) = 0.0
            tempb3 = fact*siadjb(ii, j, k, 2)
            v2b(1) = v2b(1) + v1(3)*tempb3 - v1(2)*tempb2
            v1b(3) = v1b(3) + v2(1)*tempb3
            v1b(1) = v1b(1) - v2(3)*tempb3
            siadjb(ii, j, k, 2) = 0.0
            tempb4 = fact*siadjb(ii, j, k, 1)
            v2b(3) = v2b(3) + v1(2)*tempb4 - v1(1)*tempb3
            v1b(2) = v1b(2) + v2(3)*tempb4
            v1b(3) = v1b(3) - v2(2)*tempb4
            v2b(2) = v2b(2) - v1(3)*tempb4
            siadjb(ii, j, k, 1) = 0.0
            CALL POPREAL8(v2(3))
            xadjb(i, j, k, 3) = xadjb(i, j, k, 3) + v2b(3)
            xadjb(i, m, n, 3) = xadjb(i, m, n, 3) - v2b(3)
            v2b(3) = 0.0
            CALL POPREAL8(v2(2))
            xadjb(i, j, k, 2) = xadjb(i, j, k, 2) + v2b(2)
            xadjb(i, m, n, 2) = xadjb(i, m, n, 2) - v2b(2)
            v2b(2) = 0.0
            CALL POPREAL8(v2(1))
            xadjb(i, j, k, 1) = xadjb(i, j, k, 1) + v2b(1)
            xadjb(i, m, n, 1) = xadjb(i, m, n, 1) - v2b(1)
            v2b(1) = 0.0
            CALL POPREAL8(v1(3))
            xadjb(i, j, n, 3) = xadjb(i, j, n, 3) + v1b(3)
            xadjb(i, m, k, 3) = xadjb(i, m, k, 3) - v1b(3)
            v1b(3) = 0.0
            CALL POPREAL8(v1(2))
            xadjb(i, j, n, 2) = xadjb(i, j, n, 2) + v1b(2)
            xadjb(i, m, k, 2) = xadjb(i, m, k, 2) - v1b(2)
            v1b(2) = 0.0
            CALL POPREAL8(v1(1))
            xadjb(i, j, n, 1) = xadjb(i, j, n, 1) + v1b(1)
            xadjb(i, m, k, 1) = xadjb(i, m, k, 1) - v1b(1)
            v1b(1) = 0.0
            CALL POPINTEGER4(branch)
            IF (.NOT.branch .LT. 1) CALL POPINTEGER4(ii)
          END DO
          CALL POPINTEGER4(m)
        END DO
        CALL POPINTEGER4(n)
      END DO
    ELSE
      xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
      v1b(1:3) = 0.0
      v2b(1:3) = 0.0
      DO k=jjend,jjbeg,-1
        DO j=1,1,-1
          DO i=iiend,iibeg,-1
            tempb5 = fact*sjadjb(i, jj, k, 3)
            v1b(1) = v1b(1) + v2(2)*tempb5
            v2b(2) = v2b(2) + v1(1)*tempb5
            v1b(2) = v1b(2) - v2(1)*tempb5
            sjadjb(i, jj, k, 3) = 0.0
            tempb6 = fact*sjadjb(i, jj, k, 2)
            v2b(1) = v2b(1) + v1(3)*tempb6 - v1(2)*tempb5
            v1b(3) = v1b(3) + v2(1)*tempb6
            v1b(1) = v1b(1) - v2(3)*tempb6
            sjadjb(i, jj, k, 2) = 0.0
            tempb7 = fact*sjadjb(i, jj, k, 1)
            v2b(3) = v2b(3) + v1(2)*tempb7 - v1(1)*tempb6
            v1b(2) = v1b(2) + v2(3)*tempb7
            v1b(3) = v1b(3) - v2(2)*tempb7
            v2b(2) = v2b(2) - v1(3)*tempb7
            sjadjb(i, jj, k, 1) = 0.0
            CALL POPREAL8(v2(3))
            xadjb(l, j, n, 3) = xadjb(l, j, n, 3) + v2b(3)
            xadjb(i, j, k, 3) = xadjb(i, j, k, 3) - v2b(3)
            v2b(3) = 0.0
            CALL POPREAL8(v2(2))
            xadjb(l, j, n, 2) = xadjb(l, j, n, 2) + v2b(2)
            xadjb(i, j, k, 2) = xadjb(i, j, k, 2) - v2b(2)
            v2b(2) = 0.0
            CALL POPREAL8(v2(1))
            xadjb(l, j, n, 1) = xadjb(l, j, n, 1) + v2b(1)
            xadjb(i, j, k, 1) = xadjb(i, j, k, 1) - v2b(1)
            v2b(1) = 0.0
            CALL POPREAL8(v1(3))
            xadjb(i, j, n, 3) = xadjb(i, j, n, 3) + v1b(3)
            xadjb(l, j, k, 3) = xadjb(l, j, k, 3) - v1b(3)
            v1b(3) = 0.0
            CALL POPREAL8(v1(2))
            xadjb(i, j, n, 2) = xadjb(i, j, n, 2) + v1b(2)
            xadjb(l, j, k, 2) = xadjb(l, j, k, 2) - v1b(2)
            v1b(2) = 0.0
            CALL POPREAL8(v1(1))
            xadjb(i, j, n, 1) = xadjb(i, j, n, 1) + v1b(1)
            xadjb(l, j, k, 1) = xadjb(l, j, k, 1) - v1b(1)
            v1b(1) = 0.0
            CALL POPINTEGER4(l)
          END DO
          CALL POPINTEGER4(branch)
          IF (.NOT.branch .LT. 1) CALL POPINTEGER4(jj)
        END DO
        CALL POPINTEGER4(n)
      END DO
    END IF
  ELSE IF (branch .LT. 6) THEN
    IF (branch .LT. 5) THEN
      xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
      v1b(1:3) = 0.0
      v2b(1:3) = 0.0
      DO k=jjend,jjbeg,-1
        DO j=jl,jl,-1
          DO i=iiend,iibeg,-1
            tempb8 = fact*sjadjb(i, jj, k, 3)
            v1b(1) = v1b(1) + v2(2)*tempb8
            v2b(2) = v2b(2) + v1(1)*tempb8
            v1b(2) = v1b(2) - v2(1)*tempb8
            sjadjb(i, jj, k, 3) = 0.0
            tempb9 = fact*sjadjb(i, jj, k, 2)
            v2b(1) = v2b(1) + v1(3)*tempb9 - v1(2)*tempb8
            v1b(3) = v1b(3) + v2(1)*tempb9
            v1b(1) = v1b(1) - v2(3)*tempb9
            sjadjb(i, jj, k, 2) = 0.0
            tempb10 = fact*sjadjb(i, jj, k, 1)
            v2b(3) = v2b(3) + v1(2)*tempb10 - v1(1)*tempb9
            v1b(2) = v1b(2) + v2(3)*tempb10
            v1b(3) = v1b(3) - v2(2)*tempb10
            v2b(2) = v2b(2) - v1(3)*tempb10
            sjadjb(i, jj, k, 1) = 0.0
            CALL POPREAL8(v2(3))
            xadjb(l, j, n, 3) = xadjb(l, j, n, 3) + v2b(3)
            xadjb(i, j, k, 3) = xadjb(i, j, k, 3) - v2b(3)
            v2b(3) = 0.0
            CALL POPREAL8(v2(2))
            xadjb(l, j, n, 2) = xadjb(l, j, n, 2) + v2b(2)
            xadjb(i, j, k, 2) = xadjb(i, j, k, 2) - v2b(2)
            v2b(2) = 0.0
            CALL POPREAL8(v2(1))
            xadjb(l, j, n, 1) = xadjb(l, j, n, 1) + v2b(1)
            xadjb(i, j, k, 1) = xadjb(i, j, k, 1) - v2b(1)
            v2b(1) = 0.0
            CALL POPREAL8(v1(3))
            xadjb(i, j, n, 3) = xadjb(i, j, n, 3) + v1b(3)
            xadjb(l, j, k, 3) = xadjb(l, j, k, 3) - v1b(3)
            v1b(3) = 0.0
            CALL POPREAL8(v1(2))
            xadjb(i, j, n, 2) = xadjb(i, j, n, 2) + v1b(2)
            xadjb(l, j, k, 2) = xadjb(l, j, k, 2) - v1b(2)
            v1b(2) = 0.0
            CALL POPREAL8(v1(1))
            xadjb(i, j, n, 1) = xadjb(i, j, n, 1) + v1b(1)
            xadjb(l, j, k, 1) = xadjb(l, j, k, 1) - v1b(1)
            v1b(1) = 0.0
            CALL POPINTEGER4(l)
          END DO
          CALL POPINTEGER4(branch)
          IF (.NOT.branch .LT. 1) CALL POPINTEGER4(jj)
        END DO
        CALL POPINTEGER4(n)
      END DO
    ELSE
      xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
      v1b(1:3) = 0.0
      v2b(1:3) = 0.0
      DO k=1,1,-1
        DO j=jjend,jjbeg,-1
          DO i=iiend,iibeg,-1
            tempb11 = fact*skadjb(i, j, kk, 3)
            v1b(1) = v1b(1) + v2(2)*tempb11
            v2b(2) = v2b(2) + v1(1)*tempb11
            v1b(2) = v1b(2) - v2(1)*tempb11
            skadjb(i, j, kk, 3) = 0.0
            tempb12 = fact*skadjb(i, j, kk, 2)
            v2b(1) = v2b(1) + v1(3)*tempb12 - v1(2)*tempb11
            v1b(3) = v1b(3) + v2(1)*tempb12
            v1b(1) = v1b(1) - v2(3)*tempb12
            skadjb(i, j, kk, 2) = 0.0
            tempb13 = fact*skadjb(i, j, kk, 1)
            v2b(3) = v2b(3) + v1(2)*tempb13 - v1(1)*tempb12
            v1b(2) = v1b(2) + v2(3)*tempb13
            v1b(3) = v1b(3) - v2(2)*tempb13
            v2b(2) = v2b(2) - v1(3)*tempb13
            skadjb(i, j, kk, 1) = 0.0
            CALL POPREAL8(v2(3))
            xadjb(l, j, k, 3) = xadjb(l, j, k, 3) + v2b(3)
            xadjb(i, m, k, 3) = xadjb(i, m, k, 3) - v2b(3)
            v2b(3) = 0.0
            CALL POPREAL8(v2(2))
            xadjb(l, j, k, 2) = xadjb(l, j, k, 2) + v2b(2)
            xadjb(i, m, k, 2) = xadjb(i, m, k, 2) - v2b(2)
            v2b(2) = 0.0
            CALL POPREAL8(v2(1))
            xadjb(l, j, k, 1) = xadjb(l, j, k, 1) + v2b(1)
            xadjb(i, m, k, 1) = xadjb(i, m, k, 1) - v2b(1)
            v2b(1) = 0.0
            CALL POPREAL8(v1(3))
            xadjb(i, j, k, 3) = xadjb(i, j, k, 3) + v1b(3)
            xadjb(l, m, k, 3) = xadjb(l, m, k, 3) - v1b(3)
            v1b(3) = 0.0
            CALL POPREAL8(v1(2))
            xadjb(i, j, k, 2) = xadjb(i, j, k, 2) + v1b(2)
            xadjb(l, m, k, 2) = xadjb(l, m, k, 2) - v1b(2)
            v1b(2) = 0.0
            CALL POPREAL8(v1(1))
            xadjb(i, j, k, 1) = xadjb(i, j, k, 1) + v1b(1)
            xadjb(l, m, k, 1) = xadjb(l, m, k, 1) - v1b(1)
            v1b(1) = 0.0
            CALL POPINTEGER4(l)
          END DO
          CALL POPINTEGER4(m)
        END DO
        CALL POPINTEGER4(branch)
        IF (.NOT.branch .LT. 1) CALL POPINTEGER4(kk)
      END DO
    END IF
  ELSE
    xadjb(0:ie, 0:je, 0:ke, 1:3) = 0.0
    v1b(1:3) = 0.0
    v2b(1:3) = 0.0
    DO k=kl,kl,-1
      DO j=jjend,jjbeg,-1
        DO i=iiend,iibeg,-1
          tempb14 = fact*skadjb(i, j, kk, 3)
          v1b(1) = v1b(1) + v2(2)*tempb14
          v2b(2) = v2b(2) + v1(1)*tempb14
          v1b(2) = v1b(2) - v2(1)*tempb14
          skadjb(i, j, kk, 3) = 0.0
          tempb15 = fact*skadjb(i, j, kk, 2)
          v2b(1) = v2b(1) + v1(3)*tempb15 - v1(2)*tempb14
          v1b(3) = v1b(3) + v2(1)*tempb15
          v1b(1) = v1b(1) - v2(3)*tempb15
          skadjb(i, j, kk, 2) = 0.0
          tempb16 = fact*skadjb(i, j, kk, 1)
          v2b(3) = v2b(3) + v1(2)*tempb16 - v1(1)*tempb15
          v1b(2) = v1b(2) + v2(3)*tempb16
          v1b(3) = v1b(3) - v2(2)*tempb16
          v2b(2) = v2b(2) - v1(3)*tempb16
          skadjb(i, j, kk, 1) = 0.0
          CALL POPREAL8(v2(3))
          xadjb(l, j, k, 3) = xadjb(l, j, k, 3) + v2b(3)
          xadjb(i, m, k, 3) = xadjb(i, m, k, 3) - v2b(3)
          v2b(3) = 0.0
          CALL POPREAL8(v2(2))
          xadjb(l, j, k, 2) = xadjb(l, j, k, 2) + v2b(2)
          xadjb(i, m, k, 2) = xadjb(i, m, k, 2) - v2b(2)
          v2b(2) = 0.0
          CALL POPREAL8(v2(1))
          xadjb(l, j, k, 1) = xadjb(l, j, k, 1) + v2b(1)
          xadjb(i, m, k, 1) = xadjb(i, m, k, 1) - v2b(1)
          v2b(1) = 0.0
          CALL POPREAL8(v1(3))
          xadjb(i, j, k, 3) = xadjb(i, j, k, 3) + v1b(3)
          xadjb(l, m, k, 3) = xadjb(l, m, k, 3) - v1b(3)
          v1b(3) = 0.0
          CALL POPREAL8(v1(2))
          xadjb(i, j, k, 2) = xadjb(i, j, k, 2) + v1b(2)
          xadjb(l, m, k, 2) = xadjb(l, m, k, 2) - v1b(2)
          v1b(2) = 0.0
          CALL POPREAL8(v1(1))
          xadjb(i, j, k, 1) = xadjb(i, j, k, 1) + v1b(1)
          xadjb(l, m, k, 1) = xadjb(l, m, k, 1) - v1b(1)
          v1b(1) = 0.0
          CALL POPINTEGER4(l)
        END DO
        CALL POPINTEGER4(m)
      END DO
      CALL POPINTEGER4(branch)
      IF (.NOT.branch .LT. 1) CALL POPINTEGER4(kk)
    END DO
  END IF
  CALL POPINTEGER4(branch)
END SUBROUTINE GETSURFACENORMALSCOUPLINGADJ_B
