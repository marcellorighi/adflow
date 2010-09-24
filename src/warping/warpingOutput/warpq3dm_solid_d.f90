!        Generated by TAPENADE     (INRIA, Tropics team)
!  Tapenade 3.3 (r3163) - 09/25/2009 09:03
!
!  Differentiation of warpq3dm_solid in forward (tangent) mode:
!   variations  of output variables: dfacei dfacej dfacek xyz
!   with respect to input variables: s0 xyz0 dfacei dfacej dfacek
!                xyz
SUBROUTINE WARPQ3DM_SOLID_D(il, jl, kl, i1, i2, j1, j2, k1, k2, xyz0, &
&  xyz0d, s0, s0d, dfacei, dfaceid, dfacej, dfacejd, dfacek, dfacekd, xyz&
&  , xyzd)
  USE PRECISION
  IMPLICIT NONE
!     ******************************************************************
!     *   WARPQ3DM perturbs the interior of one face of one block of a *
!     *   multiblock grid structure given perturbed edges of that face,*
!     *   which is indicated by one pair of equal index arguments.     *
!     *   (E.g.: I2 = I1 means a face in the J/K subspace.)            *
!     *                                                                *
!     *   The two-stage algorithm uses an intermediate perturbation to *
!     *   account for any corner motion, involving edges derived from  *
!     *   the original edges, then a second perturbation to account    *
!     *   for any differences between the intermediate edges and the   *
!     *   specified new edges.                                         *
!     *                                                                *
!     *   The perturbed edges should be input as edges of the desired  *
!     *   output face.  The original relative arc-length increments in *
!     *   each index direction should also be input.  See PARAM3DM for *
!     *   setting them up in preparation for multiple perturbations.   *
!     *                                                                *
!     *   11/29/95  D.Saunders  Adaptation of WARPQ3D for specialized  *
!     *                         WARP-BLK used by FLO107-MB.            *
!     *   04/04/96      "       DELQ3DM does stage 1 only now (all     *
!     *                         that WARP-BLK needs).                  *
!     *   12/11/08  C.A.Mader   Converted to *.f90                     *
!     *                                                                *
!     *   David Saunders/James Reuther, NASA Ames Research Center, CA. *
!     ******************************************************************
!IMPLICIT REAL*8 (A-H,O-Z) ! Take out when all compilers have a switch
!     Arguments.
! I  Grid array dimensions.
  INTEGER(kind=inttype) :: il, jl, kl
! I  Define active face,
  INTEGER(kind=inttype) :: i1, i2, j1, j2, k1, k2
!    one pair being equal.
! I  Base face coordinates in
  REAL(kind=realtype) :: xyz0(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: xyz0d(3, 0:il+1, 0:jl+1, 0:kl+1)
!    appropriate places
! I  Base normalized arc-lengths
  REAL(kind=realtype) :: s0(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: s0d(3, 0:il+1, 0:jl+1, 0:kl+1)
! S  For face perturbations; e.g.,
  REAL(kind=realtype) :: dfacei(3, jl, kl)
  REAL(kind=realtype) :: dfaceid(3, jl, kl)
!    DFACEI(1:3,1:JL,1:KL) =
  REAL(kind=realtype) :: dfacej(3, il, kl)
  REAL(kind=realtype) :: dfacejd(3, il, kl)
!    dX, dY, dZ for an I face, etc.
  REAL(kind=realtype) :: dfacek(3, il, jl)
  REAL(kind=realtype) :: dfacekd(3, il, jl)
!I/O Grid coordinates: new edges
  REAL(kind=realtype) :: xyz(3, 0:il+1, 0:jl+1, 0:kl+1)
  REAL(kind=realtype) :: xyzd(3, 0:il+1, 0:jl+1, 0:kl+1)
!    of a face in; full new face
!    out
!     Local constants.
  REAL(kind=realtype) :: one
  PARAMETER (one=1.e+0)
!     Local variables.
  INTEGER(kind=inttype) :: i, j, k
  REAL(kind=realtype) :: wtj2, wtj1, wtk2, wtk1, wti2, wti1, deli, delj&
&  , delk
  REAL(kind=realtype) :: wtj2d, wtj1d, wtk2d, wtk1d, wti2d, wti1d, delid&
&  , deljd, delkd
!     Execution.
!     ----------
!     Stage 1:
!     Handle any corner motion by generating an intermediate face with
!     the final corners but otherwise derived from the original edges.
!     Actually, just set up the appropriate face perturbations.
  CALL DELQ3DM_SOLID_D(il, jl, kl, i1, i2, j1, j2, k1, k2, xyz0, xyz0d, &
&                 s0, s0d, dfacei, dfaceid, dfacej, dfacejd, dfacek, &
&                 dfacekd, xyz, xyzd)
!     Stage 2:
!     Set up the perturbations from the intermediate edges to the final
!     edges, then interpolate them into the interior points.
  IF (i1 .EQ. i2) THEN
! I plane case:
    i = i1
!        J = 1 and JL edge perturbations:
    DO k=2,kl-1
      dfaceid(1, 1, k) = xyzd(1, i, 1, k) - xyz0d(1, i, 1, k) - dfaceid(&
&        1, 1, k)
      dfacei(1, 1, k) = xyz(1, i, 1, k) - xyz0(1, i, 1, k) - dfacei(1, 1&
&        , k)
      dfaceid(2, 1, k) = xyzd(2, i, 1, k) - xyz0d(2, i, 1, k) - dfaceid(&
&        2, 1, k)
      dfacei(2, 1, k) = xyz(2, i, 1, k) - xyz0(2, i, 1, k) - dfacei(2, 1&
&        , k)
      dfaceid(3, 1, k) = xyzd(3, i, 1, k) - xyz0d(3, i, 1, k) - dfaceid(&
&        3, 1, k)
      dfacei(3, 1, k) = xyz(3, i, 1, k) - xyz0(3, i, 1, k) - dfacei(3, 1&
&        , k)
      dfaceid(1, jl, k) = xyzd(1, i, jl, k) - xyz0d(1, i, jl, k) - &
&        dfaceid(1, jl, k)
      dfacei(1, jl, k) = xyz(1, i, jl, k) - xyz0(1, i, jl, k) - dfacei(1&
&        , jl, k)
      dfaceid(2, jl, k) = xyzd(2, i, jl, k) - xyz0d(2, i, jl, k) - &
&        dfaceid(2, jl, k)
      dfacei(2, jl, k) = xyz(2, i, jl, k) - xyz0(2, i, jl, k) - dfacei(2&
&        , jl, k)
      dfaceid(3, jl, k) = xyzd(3, i, jl, k) - xyz0d(3, i, jl, k) - &
&        dfaceid(3, jl, k)
      dfacei(3, jl, k) = xyz(3, i, jl, k) - xyz0(3, i, jl, k) - dfacei(3&
&        , jl, k)
    END DO
!        K = 1 and KL edge perturbations:
    DO j=2,jl-1
      dfaceid(1, j, 1) = xyzd(1, i, j, 1) - xyz0d(1, i, j, 1) - dfaceid(&
&        1, j, 1)
      dfacei(1, j, 1) = xyz(1, i, j, 1) - xyz0(1, i, j, 1) - dfacei(1, j&
&        , 1)
      dfaceid(2, j, 1) = xyzd(2, i, j, 1) - xyz0d(2, i, j, 1) - dfaceid(&
&        2, j, 1)
      dfacei(2, j, 1) = xyz(2, i, j, 1) - xyz0(2, i, j, 1) - dfacei(2, j&
&        , 1)
      dfaceid(3, j, 1) = xyzd(3, i, j, 1) - xyz0d(3, i, j, 1) - dfaceid(&
&        3, j, 1)
      dfacei(3, j, 1) = xyz(3, i, j, 1) - xyz0(3, i, j, 1) - dfacei(3, j&
&        , 1)
      dfaceid(1, j, kl) = xyzd(1, i, j, kl) - xyz0d(1, i, j, kl) - &
&        dfaceid(1, j, kl)
      dfacei(1, j, kl) = xyz(1, i, j, kl) - xyz0(1, i, j, kl) - dfacei(1&
&        , j, kl)
      dfaceid(2, j, kl) = xyzd(2, i, j, kl) - xyz0d(2, i, j, kl) - &
&        dfaceid(2, j, kl)
      dfacei(2, j, kl) = xyz(2, i, j, kl) - xyz0(2, i, j, kl) - dfacei(2&
&        , j, kl)
      dfaceid(3, j, kl) = xyzd(3, i, j, kl) - xyz0d(3, i, j, kl) - &
&        dfaceid(3, j, kl)
      dfacei(3, j, kl) = xyz(3, i, j, kl) - xyz0(3, i, j, kl) - dfacei(3&
&        , j, kl)
    END DO
!        Interior points: accumulate the (independent) contributions.
    DO k=2,kl-1
      DO j=2,jl-1
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        deljd = wtj1d*dfacei(1, 1, k) + wtj1*dfaceid(1, 1, k) + wtj2d*&
&          dfacei(1, jl, k) + wtj2*dfaceid(1, jl, k)
        delj = wtj1*dfacei(1, 1, k) + wtj2*dfacei(1, jl, k)
        delkd = wtk1d*dfacei(1, j, 1) + wtk1*dfaceid(1, j, 1) + wtk2d*&
&          dfacei(1, j, kl) + wtk2*dfaceid(1, j, kl)
        delk = wtk1*dfacei(1, j, 1) + wtk2*dfacei(1, j, kl)
        xyzd(1, i, j, k) = xyz0d(1, i, j, k) + dfaceid(1, j, k) + deljd &
&          + delkd
        xyz(1, i, j, k) = xyz0(1, i, j, k) + dfacei(1, j, k) + delj + &
&          delk
        deljd = wtj1d*dfacei(2, 1, k) + wtj1*dfaceid(2, 1, k) + wtj2d*&
&          dfacei(2, jl, k) + wtj2*dfaceid(2, jl, k)
        delj = wtj1*dfacei(2, 1, k) + wtj2*dfacei(2, jl, k)
        delkd = wtk1d*dfacei(2, j, 1) + wtk1*dfaceid(2, j, 1) + wtk2d*&
&          dfacei(2, j, kl) + wtk2*dfaceid(2, j, kl)
        delk = wtk1*dfacei(2, j, 1) + wtk2*dfacei(2, j, kl)
        xyzd(2, i, j, k) = xyz0d(2, i, j, k) + dfaceid(2, j, k) + deljd &
&          + delkd
        xyz(2, i, j, k) = xyz0(2, i, j, k) + dfacei(2, j, k) + delj + &
&          delk
        deljd = wtj1d*dfacei(3, 1, k) + wtj1*dfaceid(3, 1, k) + wtj2d*&
&          dfacei(3, jl, k) + wtj2*dfaceid(3, jl, k)
        delj = wtj1*dfacei(3, 1, k) + wtj2*dfacei(3, jl, k)
        delkd = wtk1d*dfacei(3, j, 1) + wtk1*dfaceid(3, j, 1) + wtk2d*&
&          dfacei(3, j, kl) + wtk2*dfaceid(3, j, kl)
        delk = wtk1*dfacei(3, j, 1) + wtk2*dfacei(3, j, kl)
        xyzd(3, i, j, k) = xyz0d(3, i, j, k) + dfaceid(3, j, k) + deljd &
&          + delkd
        xyz(3, i, j, k) = xyz0(3, i, j, k) + dfacei(3, j, k) + delj + &
&          delk
      END DO
    END DO
  ELSE IF (j1 .EQ. j2) THEN
! J plane case:
    j = j1
!        I = 1 and IL edge perturbations:
    DO k=2,kl-1
      dfacejd(1, 1, k) = xyzd(1, 1, j, k) - xyz0d(1, 1, j, k) - dfacejd(&
&        1, 1, k)
      dfacej(1, 1, k) = xyz(1, 1, j, k) - xyz0(1, 1, j, k) - dfacej(1, 1&
&        , k)
      dfacejd(2, 1, k) = xyzd(2, 1, j, k) - xyz0d(2, 1, j, k) - dfacejd(&
&        2, 1, k)
      dfacej(2, 1, k) = xyz(2, 1, j, k) - xyz0(2, 1, j, k) - dfacej(2, 1&
&        , k)
      dfacejd(3, 1, k) = xyzd(3, 1, j, k) - xyz0d(3, 1, j, k) - dfacejd(&
&        3, 1, k)
      dfacej(3, 1, k) = xyz(3, 1, j, k) - xyz0(3, 1, j, k) - dfacej(3, 1&
&        , k)
      dfacejd(1, il, k) = xyzd(1, il, j, k) - xyz0d(1, il, j, k) - &
&        dfacejd(1, il, k)
      dfacej(1, il, k) = xyz(1, il, j, k) - xyz0(1, il, j, k) - dfacej(1&
&        , il, k)
      dfacejd(2, il, k) = xyzd(2, il, j, k) - xyz0d(2, il, j, k) - &
&        dfacejd(2, il, k)
      dfacej(2, il, k) = xyz(2, il, j, k) - xyz0(2, il, j, k) - dfacej(2&
&        , il, k)
      dfacejd(3, il, k) = xyzd(3, il, j, k) - xyz0d(3, il, j, k) - &
&        dfacejd(3, il, k)
      dfacej(3, il, k) = xyz(3, il, j, k) - xyz0(3, il, j, k) - dfacej(3&
&        , il, k)
    END DO
!        K = 1 and KL edge perturbations:
    DO i=2,il-1
      dfacejd(1, i, 1) = xyzd(1, i, j, 1) - xyz0d(1, i, j, 1) - dfacejd(&
&        1, i, 1)
      dfacej(1, i, 1) = xyz(1, i, j, 1) - xyz0(1, i, j, 1) - dfacej(1, i&
&        , 1)
      dfacejd(2, i, 1) = xyzd(2, i, j, 1) - xyz0d(2, i, j, 1) - dfacejd(&
&        2, i, 1)
      dfacej(2, i, 1) = xyz(2, i, j, 1) - xyz0(2, i, j, 1) - dfacej(2, i&
&        , 1)
      dfacejd(3, i, 1) = xyzd(3, i, j, 1) - xyz0d(3, i, j, 1) - dfacejd(&
&        3, i, 1)
      dfacej(3, i, 1) = xyz(3, i, j, 1) - xyz0(3, i, j, 1) - dfacej(3, i&
&        , 1)
      dfacejd(1, i, kl) = xyzd(1, i, j, kl) - xyz0d(1, i, j, kl) - &
&        dfacejd(1, i, kl)
      dfacej(1, i, kl) = xyz(1, i, j, kl) - xyz0(1, i, j, kl) - dfacej(1&
&        , i, kl)
      dfacejd(2, i, kl) = xyzd(2, i, j, kl) - xyz0d(2, i, j, kl) - &
&        dfacejd(2, i, kl)
      dfacej(2, i, kl) = xyz(2, i, j, kl) - xyz0(2, i, j, kl) - dfacej(2&
&        , i, kl)
      dfacejd(3, i, kl) = xyzd(3, i, j, kl) - xyz0d(3, i, j, kl) - &
&        dfacejd(3, i, kl)
      dfacej(3, i, kl) = xyz(3, i, j, kl) - xyz0(3, i, j, kl) - dfacej(3&
&        , i, kl)
    END DO
!        Interior points: accumulate the (independent) contributions.
    DO k=2,kl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        wtk2d = s0d(3, i, j, k)
        wtk2 = s0(3, i, j, k)
        wtk1d = -wtk2d
        wtk1 = one - wtk2
        delid = wti1d*dfacej(1, 1, k) + wti1*dfacejd(1, 1, k) + wti2d*&
&          dfacej(1, il, k) + wti2*dfacejd(1, il, k)
        deli = wti1*dfacej(1, 1, k) + wti2*dfacej(1, il, k)
        delkd = wtk1d*dfacej(1, i, 1) + wtk1*dfacejd(1, i, 1) + wtk2d*&
&          dfacej(1, i, kl) + wtk2*dfacejd(1, i, kl)
        delk = wtk1*dfacej(1, i, 1) + wtk2*dfacej(1, i, kl)
        xyzd(1, i, j, k) = xyz0d(1, i, j, k) + dfacejd(1, i, k) + delid &
&          + delkd
        xyz(1, i, j, k) = xyz0(1, i, j, k) + dfacej(1, i, k) + deli + &
&          delk
        delid = wti1d*dfacej(2, 1, k) + wti1*dfacejd(2, 1, k) + wti2d*&
&          dfacej(2, il, k) + wti2*dfacejd(2, il, k)
        deli = wti1*dfacej(2, 1, k) + wti2*dfacej(2, il, k)
        delkd = wtk1d*dfacej(2, i, 1) + wtk1*dfacejd(2, i, 1) + wtk2d*&
&          dfacej(2, i, kl) + wtk2*dfacejd(2, i, kl)
        delk = wtk1*dfacej(2, i, 1) + wtk2*dfacej(2, i, kl)
        xyzd(2, i, j, k) = xyz0d(2, i, j, k) + dfacejd(2, i, k) + delid &
&          + delkd
        xyz(2, i, j, k) = xyz0(2, i, j, k) + dfacej(2, i, k) + deli + &
&          delk
        delid = wti1d*dfacej(3, 1, k) + wti1*dfacejd(3, 1, k) + wti2d*&
&          dfacej(3, il, k) + wti2*dfacejd(3, il, k)
        deli = wti1*dfacej(3, 1, k) + wti2*dfacej(3, il, k)
        delkd = wtk1d*dfacej(3, i, 1) + wtk1*dfacejd(3, i, 1) + wtk2d*&
&          dfacej(3, i, kl) + wtk2*dfacejd(3, i, kl)
        delk = wtk1*dfacej(3, i, 1) + wtk2*dfacej(3, i, kl)
        xyzd(3, i, j, k) = xyz0d(3, i, j, k) + dfacejd(3, i, k) + delid &
&          + delkd
        xyz(3, i, j, k) = xyz0(3, i, j, k) + dfacej(3, i, k) + deli + &
&          delk
      END DO
    END DO
  ELSE IF (k1 .EQ. k2) THEN
! K plane case:
    k = k1
!        I = 1 and IL edge perturbations:
    DO j=2,jl-1
      dfacekd(1, 1, j) = xyzd(1, 1, j, k) - xyz0d(1, 1, j, k) - dfacekd(&
&        1, 1, j)
      dfacek(1, 1, j) = xyz(1, 1, j, k) - xyz0(1, 1, j, k) - dfacek(1, 1&
&        , j)
      dfacekd(2, 1, j) = xyzd(2, 1, j, k) - xyz0d(2, 1, j, k) - dfacekd(&
&        2, 1, j)
      dfacek(2, 1, j) = xyz(2, 1, j, k) - xyz0(2, 1, j, k) - dfacek(2, 1&
&        , j)
      dfacekd(3, 1, j) = xyzd(3, 1, j, k) - xyz0d(3, 1, j, k) - dfacekd(&
&        3, 1, j)
      dfacek(3, 1, j) = xyz(3, 1, j, k) - xyz0(3, 1, j, k) - dfacek(3, 1&
&        , j)
      dfacekd(1, il, j) = xyzd(1, il, j, k) - xyz0d(1, il, j, k) - &
&        dfacekd(1, il, j)
      dfacek(1, il, j) = xyz(1, il, j, k) - xyz0(1, il, j, k) - dfacek(1&
&        , il, j)
      dfacekd(2, il, j) = xyzd(2, il, j, k) - xyz0d(2, il, j, k) - &
&        dfacekd(2, il, j)
      dfacek(2, il, j) = xyz(2, il, j, k) - xyz0(2, il, j, k) - dfacek(2&
&        , il, j)
      dfacekd(3, il, j) = xyzd(3, il, j, k) - xyz0d(3, il, j, k) - &
&        dfacekd(3, il, j)
      dfacek(3, il, j) = xyz(3, il, j, k) - xyz0(3, il, j, k) - dfacek(3&
&        , il, j)
    END DO
!        J = 1 and JL edge perturbations:
    DO i=2,il-1
      dfacekd(1, i, 1) = xyzd(1, i, 1, k) - xyz0d(1, i, 1, k) - dfacekd(&
&        1, i, 1)
      dfacek(1, i, 1) = xyz(1, i, 1, k) - xyz0(1, i, 1, k) - dfacek(1, i&
&        , 1)
      dfacekd(2, i, 1) = xyzd(2, i, 1, k) - xyz0d(2, i, 1, k) - dfacekd(&
&        2, i, 1)
      dfacek(2, i, 1) = xyz(2, i, 1, k) - xyz0(2, i, 1, k) - dfacek(2, i&
&        , 1)
      dfacekd(3, i, 1) = xyzd(3, i, 1, k) - xyz0d(3, i, 1, k) - dfacekd(&
&        3, i, 1)
      dfacek(3, i, 1) = xyz(3, i, 1, k) - xyz0(3, i, 1, k) - dfacek(3, i&
&        , 1)
      dfacekd(1, i, jl) = xyzd(1, i, jl, k) - xyz0d(1, i, jl, k) - &
&        dfacekd(1, i, jl)
      dfacek(1, i, jl) = xyz(1, i, jl, k) - xyz0(1, i, jl, k) - dfacek(1&
&        , i, jl)
      dfacekd(2, i, jl) = xyzd(2, i, jl, k) - xyz0d(2, i, jl, k) - &
&        dfacekd(2, i, jl)
      dfacek(2, i, jl) = xyz(2, i, jl, k) - xyz0(2, i, jl, k) - dfacek(2&
&        , i, jl)
      dfacekd(3, i, jl) = xyzd(3, i, jl, k) - xyz0d(3, i, jl, k) - &
&        dfacekd(3, i, jl)
      dfacek(3, i, jl) = xyz(3, i, jl, k) - xyz0(3, i, jl, k) - dfacek(3&
&        , i, jl)
    END DO
!        Interior points: accumulate the (independent) contributions.
    DO j=2,jl-1
      DO i=2,il-1
        wti2d = s0d(1, i, j, k)
        wti2 = s0(1, i, j, k)
        wti1d = -wti2d
        wti1 = one - wti2
        wtj2d = s0d(2, i, j, k)
        wtj2 = s0(2, i, j, k)
        wtj1d = -wtj2d
        wtj1 = one - wtj2
        delid = wti1d*dfacek(1, 1, j) + wti1*dfacekd(1, 1, j) + wti2d*&
&          dfacek(1, il, j) + wti2*dfacekd(1, il, j)
        deli = wti1*dfacek(1, 1, j) + wti2*dfacek(1, il, j)
        deljd = wtj1d*dfacek(1, i, 1) + wtj1*dfacekd(1, i, 1) + wtj2d*&
&          dfacek(1, i, jl) + wtj2*dfacekd(1, i, jl)
        delj = wtj1*dfacek(1, i, 1) + wtj2*dfacek(1, i, jl)
        xyzd(1, i, j, k) = xyz0d(1, i, j, k) + dfacekd(1, i, j) + delid &
&          + deljd
        xyz(1, i, j, k) = xyz0(1, i, j, k) + dfacek(1, i, j) + deli + &
&          delj
        delid = wti1d*dfacek(2, 1, j) + wti1*dfacekd(2, 1, j) + wti2d*&
&          dfacek(2, il, j) + wti2*dfacekd(2, il, j)
        deli = wti1*dfacek(2, 1, j) + wti2*dfacek(2, il, j)
        deljd = wtj1d*dfacek(2, i, 1) + wtj1*dfacekd(2, i, 1) + wtj2d*&
&          dfacek(2, i, jl) + wtj2*dfacekd(2, i, jl)
        delj = wtj1*dfacek(2, i, 1) + wtj2*dfacek(2, i, jl)
        xyzd(2, i, j, k) = xyz0d(2, i, j, k) + dfacekd(2, i, j) + delid &
&          + deljd
        xyz(2, i, j, k) = xyz0(2, i, j, k) + dfacek(2, i, j) + deli + &
&          delj
        delid = wti1d*dfacek(3, 1, j) + wti1*dfacekd(3, 1, j) + wti2d*&
&          dfacek(3, il, j) + wti2*dfacekd(3, il, j)
        deli = wti1*dfacek(3, 1, j) + wti2*dfacek(3, il, j)
        deljd = wtj1d*dfacek(3, i, 1) + wtj1*dfacekd(3, i, 1) + wtj2d*&
&          dfacek(3, i, jl) + wtj2*dfacekd(3, i, jl)
        delj = wtj1*dfacek(3, i, 1) + wtj2*dfacek(3, i, jl)
        xyzd(3, i, j, k) = xyz0d(3, i, j, k) + dfacekd(3, i, j) + delid &
&          + deljd
        xyz(3, i, j, k) = xyz0(3, i, j, k) + dfacek(3, i, j) + deli + &
&          delj
      END DO
    END DO
  END IF
END SUBROUTINE WARPQ3DM_SOLID_D
