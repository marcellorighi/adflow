   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of gridvelocitiesfinelevel_block in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *sfacei *sfacej *s *sfacek
   !   with respect to varying inputs: veldirfreestream machgrid *x
   !                *si *sj *sk gammainf pinf timeref rhoinf
   !   Plus diff mem management of: sfacei:in sfacej:in s:in sfacek:in
   !                x:in si:in sj:in sk:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          gridVelocities.f90                              *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 02-23-2004                                     *
   !      * Last modified: 06-28-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE GRIDVELOCITIESFINELEVEL_BLOCK_D(useoldcoor, t, sps)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * gridVelocitiesFineLevel computes the grid velocities for       *
   !      * the cell centers and the normal grid velocities for the faces  *
   !      * of moving blocks for the currently finest grid, i.e.           *
   !      * groundLevel. The velocities are computed at time t for         *
   !      * spectral mode sps. If useOldCoor is .true. the velocities      *
   !      * are determined using the unsteady time integrator in           *
   !      * combination with the old coordinates; otherwise the analytic   *
   !      * form is used.                                                  *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS_D
   USE CGNSGRID
   USE FLOWVARREFSTATE
   USE INPUTMOTION
   USE INPUTUNSTEADY
   USE ITERATION
   USE INPUTPHYSICS
   USE INPUTTSSTABDERIV
   USE MONITOR
   USE COMMUNICATION
   IMPLICIT NONE
   !
   !      Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: sps
   LOGICAL, INTENT(IN) :: useoldcoor
   REAL(kind=realtype), DIMENSION(*), INTENT(IN) :: t
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: nn, mm
   INTEGER(kind=inttype) :: i, j, k, ii, iie, jje, kke
   REAL(kind=realtype) :: oneover4dt, oneover8dt
   REAL(kind=realtype) :: oneover4dtd, oneover8dtd
   REAL(kind=realtype) :: velxgrid, velygrid, velzgrid, ainf
   REAL(kind=realtype) :: velxgridd, velygridd, velzgridd, ainfd
   REAL(kind=realtype) :: velxgrid0, velygrid0, velzgrid0
   REAL(kind=realtype) :: velxgrid0d, velygrid0d, velzgrid0d
   REAL(kind=realtype), DIMENSION(3) :: sc, xc, xxc
   REAL(kind=realtype), DIMENSION(3) :: scd, xcd, xxcd
   REAL(kind=realtype), DIMENSION(3) :: rotcenter, rotrate
   REAL(kind=realtype), DIMENSION(3) :: rotrated
   REAL(kind=realtype), DIMENSION(3) :: rotationpoint
   REAL(kind=realtype), DIMENSION(3, 3) :: rotationmatrix, &
   & derivrotationmatrix
   REAL(kind=realtype), DIMENSION(3, 3) :: derivrotationmatrixd
   REAL(kind=realtype) :: tnew, told
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: sface
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: sfaced
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: xx, ss
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: xxd, ssd
   REAL(kind=realtype), DIMENSION(:, :, :, :), POINTER :: xxold
   INTEGER(kind=inttype) :: liftindex
   REAL(kind=realtype) :: alpha, beta, intervalmach, alphats, &
   & alphaincrement, betats, betaincrement
   REAL(kind=realtype) :: alphad, betad, alphatsd, betatsd
   REAL(kind=realtype), DIMENSION(3) :: veldir
   REAL(kind=realtype), DIMENSION(3) :: veldird
   REAL(kind=realtype), DIMENSION(3) :: refdirection
   !Function Definitions
   REAL(kind=realtype) :: TSALPHA, TSBETA, TSMACH
   INTRINSIC SQRT
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Compute the mesh velocity from the given mesh Mach number.
   ! vel{x,y,z}Grid0 is the ACTUAL velocity you want at the
   ! geometry. 
   arg1d = ((gammainfd*pinf+gammainf*pinfd)*rhoinf-gammainf*pinf*rhoinfd)&
   &   /rhoinf**2
   arg1 = gammainf*pinf/rhoinf
   IF (arg1 .EQ. 0.0_8) THEN
   ainfd = 0.0_8
   ELSE
   ainfd = arg1d/(2.0*SQRT(arg1))
   END IF
   ainf = SQRT(arg1)
   velxgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldirfreestream(1)) - &
   &   ainf*machgrid*veldirfreestreamd(1)
   velxgrid0 = ainf*machgrid*(-veldirfreestream(1))
   velygrid0d = -((ainfd*machgrid+ainf*machgridd)*veldirfreestream(2)) - &
   &   ainf*machgrid*veldirfreestreamd(2)
   velygrid0 = ainf*machgrid*(-veldirfreestream(2))
   velzgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldirfreestream(3)) - &
   &   ainf*machgrid*veldirfreestreamd(3)
   velzgrid0 = ainf*machgrid*(-veldirfreestream(3))
   ! Compute the derivative of the rotation matrix and the rotation
   ! point; needed for velocity due to the rigid body rotation of
   ! the entire grid. It is assumed that the rigid body motion of
   ! the grid is only specified if there is only 1 section present.
   CALL DERIVATIVEROTMATRIXRIGID_D(derivrotationmatrix, &
   &                           derivrotationmatrixd, rotationpoint, t(1))
   !compute the rotation matrix to update the velocities for the time
   !spectral stability derivative case...
   IF (tsstability) THEN
   ! Determine the time values of the old and new time level.
   ! It is assumed that the rigid body rotation of the mesh is only
   ! used when only 1 section is present.
   tnew = timeunsteady + timeunsteadyrestart
   told = tnew - t(1)
   IF ((tspmode .OR. tsqmode) .OR. tsrmode) THEN
   ! Compute the rotation matrix of the rigid body rotation as
   ! well as the rotation point; the latter may vary in time due
   ! to rigid body translation.
   CALL ROTMATRIXRIGIDBODY(tnew, told, rotationmatrix, &
   &                          rotationpoint)
   velxgrid0d = rotationmatrix(1, 1)*velxgrid0d + rotationmatrix(1, 2&
   &       )*velygrid0d + rotationmatrix(1, 3)*velzgrid0d
   velxgrid0 = rotationmatrix(1, 1)*velxgrid0 + rotationmatrix(1, 2)*&
   &       velygrid0 + rotationmatrix(1, 3)*velzgrid0
   velygrid0d = rotationmatrix(2, 1)*velxgrid0d + rotationmatrix(2, 2&
   &       )*velygrid0d + rotationmatrix(2, 3)*velzgrid0d
   velygrid0 = rotationmatrix(2, 1)*velxgrid0 + rotationmatrix(2, 2)*&
   &       velygrid0 + rotationmatrix(2, 3)*velzgrid0
   velzgrid0d = rotationmatrix(3, 1)*velxgrid0d + rotationmatrix(3, 2&
   &       )*velygrid0d + rotationmatrix(3, 3)*velzgrid0d
   velzgrid0 = rotationmatrix(3, 1)*velxgrid0 + rotationmatrix(3, 2)*&
   &       velygrid0 + rotationmatrix(3, 3)*velzgrid0
   ELSE IF (tsalphamode) THEN
   ! get the baseline alpha and determine the liftIndex
   CALL GETDIRANGLE_D(veldirfreestream, veldirfreestreamd, &
   &                  liftdirection, liftindex, alpha, alphad, beta, betad)
   !Determine the alpha for this time instance
   alphaincrement = TSALPHA(degreepolalpha, coefpolalpha, &
   &       degreefouralpha, omegafouralpha, coscoeffouralpha, &
   &       sincoeffouralpha, t(1))
   alphatsd = alphad
   alphats = alpha + alphaincrement
   !Determine the grid velocity for this alpha
   refdirection(:) = zero
   refdirection(1) = one
   veldird = 0.0_8
   CALL GETDIRVECTOR_D(refdirection, alphats, alphatsd, beta, betad, &
   &                   veldir, veldird, liftindex)
   !do I need to update the lift direction and drag direction as well?
   !set the effictive grid velocity for this time interval
   velxgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(1)) - ainf*&
   &       machgrid*veldird(1)
   velxgrid0 = ainf*machgrid*(-veldir(1))
   velygrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(2)) - ainf*&
   &       machgrid*veldird(2)
   velygrid0 = ainf*machgrid*(-veldir(2))
   velzgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(3)) - ainf*&
   &       machgrid*veldird(3)
   velzgrid0 = ainf*machgrid*(-veldir(3))
   ELSE IF (tsbetamode) THEN
   ! get the baseline alpha and determine the liftIndex
   CALL GETDIRANGLE_D(veldirfreestream, veldirfreestreamd, &
   &                  liftdirection, liftindex, alpha, alphad, beta, betad)
   !Determine the alpha for this time instance
   betaincrement = TSBETA(degreepolbeta, coefpolbeta, &
   &       degreefourbeta, omegafourbeta, coscoeffourbeta, sincoeffourbeta&
   &       , t(1))
   betatsd = betad
   betats = beta + betaincrement
   !Determine the grid velocity for this alpha
   refdirection(:) = zero
   refdirection(1) = one
   veldird = 0.0_8
   CALL GETDIRVECTOR_D(refdirection, alpha, alphad, betats, betatsd, &
   &                   veldir, veldird, liftindex)
   !do I need to update the lift direction and drag direction as well?
   !set the effictive grid velocity for this time interval
   velxgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(1)) - ainf*&
   &       machgrid*veldird(1)
   velxgrid0 = ainf*machgrid*(-veldir(1))
   velygrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(2)) - ainf*&
   &       machgrid*veldird(2)
   velygrid0 = ainf*machgrid*(-veldir(2))
   velzgrid0d = -((ainfd*machgrid+ainf*machgridd)*veldir(3)) - ainf*&
   &       machgrid*veldird(3)
   velzgrid0 = ainf*machgrid*(-veldir(3))
   ELSE IF (tsmachmode) THEN
   !determine the mach number at this time interval
   intervalmach = TSMACH(degreepolmach, coefpolmach, &
   &       degreefourmach, omegafourmach, coscoeffourmach, sincoeffourmach&
   &       , t(1))
   !set the effective grid velocity
   velxgrid0d = -((ainfd*(intervalmach+machgrid)+ainf*machgridd)*&
   &       veldirfreestream(1)) - ainf*(intervalmach+machgrid)*&
   &       veldirfreestreamd(1)
   velxgrid0 = ainf*(intervalmach+machgrid)*(-veldirfreestream(1))
   velygrid0d = -((ainfd*(intervalmach+machgrid)+ainf*machgridd)*&
   &       veldirfreestream(2)) - ainf*(intervalmach+machgrid)*&
   &       veldirfreestreamd(2)
   velygrid0 = ainf*(intervalmach+machgrid)*(-veldirfreestream(2))
   velzgrid0d = -((ainfd*(intervalmach+machgrid)+ainf*machgridd)*&
   &       veldirfreestream(3)) - ainf*(intervalmach+machgrid)*&
   &       veldirfreestreamd(3)
   velzgrid0 = ainf*(intervalmach+machgrid)*(-veldirfreestream(3))
   ELSE IF (tsaltitudemode) THEN
   CALL TERMINATE('gridVelocityFineLevel', &
   &                 'altitude motion not yet implemented...')
   ELSE
   CALL TERMINATE('gridVelocityFineLevel', &
   &                 'Not a recognized Stability Motion')
   END IF
   END IF
   IF (blockismoving) THEN
   ! Determine the situation we are having here.
   IF (useoldcoor) THEN
   !
   !            ************************************************************
   !            *                                                          *
   !            * The velocities must be determined via a finite           *
   !            * difference formula using the coordinates of the old      *
   !            * levels.                                                  *
   !            *                                                          *
   !            ************************************************************
   !
   ! Set the coefficients for the time integrator and store
   ! the inverse of the physical nonDimensional time step,
   ! divided by 4 and 8, a bit easier.
   CALL SETCOEFTIMEINTEGRATOR()
   oneover4dtd = fourth*timerefd/deltat
   oneover4dt = fourth*timeref/deltat
   oneover8dtd = half*oneover4dtd
   oneover8dt = half*oneover4dt
   sd = 0.0_8
   scd = 0.0_8
   !
   !            ************************************************************
   !            *                                                          *
   !            * Grid velocities of the cell centers, including the       *
   !            * 1st level halo cells.                                    *
   !            *                                                          *
   !            ************************************************************
   !
   ! Loop over the cells, including the 1st level halo's.
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   ! The velocity of the cell center is determined
   ! by a finite difference formula. First store
   ! the current coordinate, multiplied by 8 and
   ! coefTime(0) in sc.
   scd(1) = coeftime(0)*(xd(i-1, j-1, k-1, 1)+xd(i, j-1, k-1, 1&
   &             )+xd(i-1, j, k-1, 1)+xd(i, j, k-1, 1)+xd(i-1, j-1, k, 1)+&
   &             xd(i, j-1, k, 1)+xd(i-1, j, k, 1)+xd(i, j, k, 1))
   sc(1) = (x(i-1, j-1, k-1, 1)+x(i, j-1, k-1, 1)+x(i-1, j, k-1&
   &             , 1)+x(i, j, k-1, 1)+x(i-1, j-1, k, 1)+x(i, j-1, k, 1)+x(i&
   &             -1, j, k, 1)+x(i, j, k, 1))*coeftime(0)
   scd(2) = coeftime(0)*(xd(i-1, j-1, k-1, 2)+xd(i, j-1, k-1, 2&
   &             )+xd(i-1, j, k-1, 2)+xd(i, j, k-1, 2)+xd(i-1, j-1, k, 2)+&
   &             xd(i, j-1, k, 2)+xd(i-1, j, k, 2)+xd(i, j, k, 2))
   sc(2) = (x(i-1, j-1, k-1, 2)+x(i, j-1, k-1, 2)+x(i-1, j, k-1&
   &             , 2)+x(i, j, k-1, 2)+x(i-1, j-1, k, 2)+x(i, j-1, k, 2)+x(i&
   &             -1, j, k, 2)+x(i, j, k, 2))*coeftime(0)
   scd(3) = coeftime(0)*(xd(i-1, j-1, k-1, 3)+xd(i, j-1, k-1, 3&
   &             )+xd(i-1, j, k-1, 3)+xd(i, j, k-1, 3)+xd(i-1, j-1, k, 3)+&
   &             xd(i, j-1, k, 3)+xd(i-1, j, k, 3)+xd(i, j, k, 3))
   sc(3) = (x(i-1, j-1, k-1, 3)+x(i, j-1, k-1, 3)+x(i-1, j, k-1&
   &             , 3)+x(i, j, k-1, 3)+x(i-1, j-1, k, 3)+x(i, j-1, k, 3)+x(i&
   &             -1, j, k, 3)+x(i, j, k, 3))*coeftime(0)
   ! Loop over the older levels to complete the
   ! finite difference formula.
   DO ii=1,noldlevels
   sc(1) = sc(1) + (xold(ii, i-1, j-1, k-1, 1)+xold(ii, i, j-&
   &               1, k-1, 1)+xold(ii, i-1, j, k-1, 1)+xold(ii, i, j, k-1, &
   &               1)+xold(ii, i-1, j-1, k, 1)+xold(ii, i, j-1, k, 1)+xold(&
   &               ii, i-1, j, k, 1)+xold(ii, i, j, k, 1))*coeftime(ii)
   sc(2) = sc(2) + (xold(ii, i-1, j-1, k-1, 2)+xold(ii, i, j-&
   &               1, k-1, 2)+xold(ii, i-1, j, k-1, 2)+xold(ii, i, j, k-1, &
   &               2)+xold(ii, i-1, j-1, k, 2)+xold(ii, i, j-1, k, 2)+xold(&
   &               ii, i-1, j, k, 2)+xold(ii, i, j, k, 2))*coeftime(ii)
   sc(3) = sc(3) + (xold(ii, i-1, j-1, k-1, 3)+xold(ii, i, j-&
   &               1, k-1, 3)+xold(ii, i-1, j, k-1, 3)+xold(ii, i, j, k-1, &
   &               3)+xold(ii, i-1, j-1, k, 3)+xold(ii, i, j-1, k, 3)+xold(&
   &               ii, i-1, j, k, 3)+xold(ii, i, j, k, 3))*coeftime(ii)
   END DO
   ! Divide by 8 delta t to obtain the correct
   ! velocities.
   sd(i, j, k, 1) = scd(1)*oneover8dt + sc(1)*oneover8dtd
   s(i, j, k, 1) = sc(1)*oneover8dt
   sd(i, j, k, 2) = scd(2)*oneover8dt + sc(2)*oneover8dtd
   s(i, j, k, 2) = sc(2)*oneover8dt
   sd(i, j, k, 3) = scd(3)*oneover8dt + sc(3)*oneover8dtd
   s(i, j, k, 3) = sc(3)*oneover8dt
   END DO
   END DO
   END DO
   sfaceid = 0.0_8
   sfacejd = 0.0_8
   sfacekd = 0.0_8
   !
   !            ************************************************************
   !            *                                                          *
   !            * Normal grid velocities of the faces.                     *
   !            *                                                          *
   !            ************************************************************
   !
   ! Loop over the three directions.
   loopdir:DO mm=1,3
   ! Set the upper boundaries depending on the direction.
   SELECT CASE  (mm) 
   CASE (1_intType) 
   ! normals in i-direction
   iie = ie
   jje = je
   kke = ke
   CASE (2_intType) 
   ! normals in j-direction
   iie = je
   jje = ie
   kke = ke
   CASE (3_intType) 
   ! normals in k-direction
   iie = ke
   jje = ie
   kke = je
   END SELECT
   !
   !              **********************************************************
   !              *                                                        *
   !              * Normal grid velocities in generalized i-direction.     *
   !              * Mm == 1: i-direction                                   *
   !              * mm == 2: j-direction                                   *
   !              * mm == 3: k-direction                                   *
   !              *                                                        *
   !              **********************************************************
   !
   DO i=0,iie
   ! Set the pointers for the coordinates, normals and
   ! normal velocities for this generalized i-plane.
   ! This depends on the value of mm.
   SELECT CASE  (mm) 
   CASE (1_intType) 
   ! normals in i-direction
   xxd => xd(i, :, :, :)
   xx => x(i, :, :, :)
   xxold => xold(:, i, :, :, :)
   ssd => sid(i, :, :, :)
   ss => si(i, :, :, :)
   sfaced => sfaceid(i, :, :)
   sface => sfacei(i, :, :)
   CASE (2_intType) 
   ! normals in j-direction
   xxd => xd(:, i, :, :)
   xx => x(:, i, :, :)
   xxold => xold(:, :, i, :, :)
   ssd => sjd(:, i, :, :)
   ss => sj(:, i, :, :)
   sfaced => sfacejd(:, i, :)
   sface => sfacej(:, i, :)
   CASE (3_intType) 
   ! normals in k-direction
   xxd => xd(:, :, i, :)
   xx => x(:, :, i, :)
   xxold => xold(:, :, :, i, :)
   ssd => skd(:, :, i, :)
   ss => sk(:, :, i, :)
   sfaced => sfacekd(:, :, i)
   sface => sfacek(:, :, i)
   END SELECT
   ! Loop over the k and j-direction of this
   ! generalized i-face. Note that due to the usage of
   ! the pointers xx and xxOld an offset of +1 must be
   ! used in the coordinate arrays, because x and xOld
   ! originally start at 0 for the i, j and k indices.
   DO k=1,kke
   DO j=1,jje
   ! The velocity of the face center is determined
   ! by a finite difference formula. First store
   ! the current coordinate, multiplied by 4 and
   ! coefTime(0) in sc.
   scd(1) = coeftime(0)*(xxd(j+1, k+1, 1)+xxd(j, k+1, 1)+xxd(&
   &               j+1, k, 1)+xxd(j, k, 1))
   sc(1) = coeftime(0)*(xx(j+1, k+1, 1)+xx(j, k+1, 1)+xx(j+1&
   &               , k, 1)+xx(j, k, 1))
   scd(2) = coeftime(0)*(xxd(j+1, k+1, 2)+xxd(j, k+1, 2)+xxd(&
   &               j+1, k, 2)+xxd(j, k, 2))
   sc(2) = coeftime(0)*(xx(j+1, k+1, 2)+xx(j, k+1, 2)+xx(j+1&
   &               , k, 2)+xx(j, k, 2))
   scd(3) = coeftime(0)*(xxd(j+1, k+1, 3)+xxd(j, k+1, 3)+xxd(&
   &               j+1, k, 3)+xxd(j, k, 3))
   sc(3) = coeftime(0)*(xx(j+1, k+1, 3)+xx(j, k+1, 3)+xx(j+1&
   &               , k, 3)+xx(j, k, 3))
   ! Loop over the older levels to complete the
   ! finite difference.
   DO ii=1,noldlevels
   sc(1) = sc(1) + coeftime(ii)*(xxold(ii, j+1, k+1, 1)+&
   &                 xxold(ii, j, k+1, 1)+xxold(ii, j+1, k, 1)+xxold(ii, j&
   &                 , k, 1))
   sc(2) = sc(2) + coeftime(ii)*(xxold(ii, j+1, k+1, 2)+&
   &                 xxold(ii, j, k+1, 2)+xxold(ii, j+1, k, 2)+xxold(ii, j&
   &                 , k, 2))
   sc(3) = sc(3) + coeftime(ii)*(xxold(ii, j+1, k+1, 3)+&
   &                 xxold(ii, j, k+1, 3)+xxold(ii, j+1, k, 3)+xxold(ii, j&
   &                 , k, 3))
   END DO
   ! Determine the dot product of sc and the normal
   ! and divide by 4 deltaT to obtain the correct
   ! value of the normal velocity.
   sfaced(j, k) = scd(1)*ss(j, k, 1) + sc(1)*ssd(j, k, 1) + &
   &               scd(2)*ss(j, k, 2) + sc(2)*ssd(j, k, 2) + scd(3)*ss(j, k&
   &               , 3) + sc(3)*ssd(j, k, 3)
   sface(j, k) = sc(1)*ss(j, k, 1) + sc(2)*ss(j, k, 2) + sc(3&
   &               )*ss(j, k, 3)
   sfaced(j, k) = sfaced(j, k)*oneover4dt + sface(j, k)*&
   &               oneover4dtd
   sface(j, k) = sface(j, k)*oneover4dt
   END DO
   END DO
   END DO
   END DO loopdir
   ELSE
   !
   !            ************************************************************
   !            *                                                          *
   !            * The velocities must be determined analytically.          *
   !            *                                                          *
   !            ************************************************************
   !
   ! Store the rotation center and determine the
   ! nonDimensional rotation rate of this block. As the
   ! reference length is 1 timeRef == 1/uRef and at the end
   ! the nonDimensional velocity is computed.
   j = nbkglobal
   rotcenter = cgnsdoms(j)%rotcenter
   rotrated = cgnsdoms(j)%rotrate*timerefd
   rotrate = timeref*cgnsdoms(j)%rotrate
   velxgridd = velxgrid0d
   velxgrid = velxgrid0
   velygridd = velygrid0d
   velygrid = velygrid0
   velzgridd = velzgrid0d
   velzgrid = velzgrid0
   sd = 0.0_8
   xcd = 0.0_8
   xxcd = 0.0_8
   scd = 0.0_8
   !
   !            ************************************************************
   !            *                                                          *
   !            * Grid velocities of the cell centers, including the       *
   !            * 1st level halo cells.                                    *
   !            *                                                          *
   !            ************************************************************
   !
   ! Loop over the cells, including the 1st level halo's.
   DO k=1,ke
   DO j=1,je
   DO i=1,ie
   ! Determine the coordinates of the cell center,
   ! which are stored in xc.
   xcd(1) = eighth*(xd(i-1, j-1, k-1, 1)+xd(i, j-1, k-1, 1)+xd(&
   &             i-1, j, k-1, 1)+xd(i, j, k-1, 1)+xd(i-1, j-1, k, 1)+xd(i, &
   &             j-1, k, 1)+xd(i-1, j, k, 1)+xd(i, j, k, 1))
   xc(1) = eighth*(x(i-1, j-1, k-1, 1)+x(i, j-1, k-1, 1)+x(i-1&
   &             , j, k-1, 1)+x(i, j, k-1, 1)+x(i-1, j-1, k, 1)+x(i, j-1, k&
   &             , 1)+x(i-1, j, k, 1)+x(i, j, k, 1))
   xcd(2) = eighth*(xd(i-1, j-1, k-1, 2)+xd(i, j-1, k-1, 2)+xd(&
   &             i-1, j, k-1, 2)+xd(i, j, k-1, 2)+xd(i-1, j-1, k, 2)+xd(i, &
   &             j-1, k, 2)+xd(i-1, j, k, 2)+xd(i, j, k, 2))
   xc(2) = eighth*(x(i-1, j-1, k-1, 2)+x(i, j-1, k-1, 2)+x(i-1&
   &             , j, k-1, 2)+x(i, j, k-1, 2)+x(i-1, j-1, k, 2)+x(i, j-1, k&
   &             , 2)+x(i-1, j, k, 2)+x(i, j, k, 2))
   xcd(3) = eighth*(xd(i-1, j-1, k-1, 3)+xd(i, j-1, k-1, 3)+xd(&
   &             i-1, j, k-1, 3)+xd(i, j, k-1, 3)+xd(i-1, j-1, k, 3)+xd(i, &
   &             j-1, k, 3)+xd(i-1, j, k, 3)+xd(i, j, k, 3))
   xc(3) = eighth*(x(i-1, j-1, k-1, 3)+x(i, j-1, k-1, 3)+x(i-1&
   &             , j, k-1, 3)+x(i, j, k-1, 3)+x(i-1, j-1, k, 3)+x(i, j-1, k&
   &             , 3)+x(i-1, j, k, 3)+x(i, j, k, 3))
   ! Determine the coordinates relative to the
   ! center of rotation.
   xxcd(1) = xcd(1)
   xxc(1) = xc(1) - rotcenter(1)
   xxcd(2) = xcd(2)
   xxc(2) = xc(2) - rotcenter(2)
   xxcd(3) = xcd(3)
   xxc(3) = xc(3) - rotcenter(3)
   ! Determine the rotation speed of the cell center,
   ! which is omega*r.
   scd(1) = rotrated(2)*xxc(3) + rotrate(2)*xxcd(3) - rotrated(&
   &             3)*xxc(2) - rotrate(3)*xxcd(2)
   sc(1) = rotrate(2)*xxc(3) - rotrate(3)*xxc(2)
   scd(2) = rotrated(3)*xxc(1) + rotrate(3)*xxcd(1) - rotrated(&
   &             1)*xxc(3) - rotrate(1)*xxcd(3)
   sc(2) = rotrate(3)*xxc(1) - rotrate(1)*xxc(3)
   scd(3) = rotrated(1)*xxc(2) + rotrate(1)*xxcd(2) - rotrated(&
   &             2)*xxc(1) - rotrate(2)*xxcd(1)
   sc(3) = rotrate(1)*xxc(2) - rotrate(2)*xxc(1)
   ! Determine the coordinates relative to the
   ! rigid body rotation point.
   xxcd(1) = xcd(1)
   xxc(1) = xc(1) - rotationpoint(1)
   xxcd(2) = xcd(2)
   xxc(2) = xc(2) - rotationpoint(2)
   xxcd(3) = xcd(3)
   xxc(3) = xc(3) - rotationpoint(3)
   ! Determine the total velocity of the cell center.
   ! This is a combination of rotation speed of this
   ! block and the entire rigid body rotation.
   sd(i, j, k, 1) = scd(1) + velxgridd + derivrotationmatrixd(1&
   &             , 1)*xxc(1) + derivrotationmatrix(1, 1)*xxcd(1) + &
   &             derivrotationmatrixd(1, 2)*xxc(2) + derivrotationmatrix(1&
   &             , 2)*xxcd(2) + derivrotationmatrixd(1, 3)*xxc(3) + &
   &             derivrotationmatrix(1, 3)*xxcd(3)
   s(i, j, k, 1) = sc(1) + velxgrid + derivrotationmatrix(1, 1)&
   &             *xxc(1) + derivrotationmatrix(1, 2)*xxc(2) + &
   &             derivrotationmatrix(1, 3)*xxc(3)
   sd(i, j, k, 2) = scd(2) + velygridd + derivrotationmatrixd(2&
   &             , 1)*xxc(1) + derivrotationmatrix(2, 1)*xxcd(1) + &
   &             derivrotationmatrixd(2, 2)*xxc(2) + derivrotationmatrix(2&
   &             , 2)*xxcd(2) + derivrotationmatrixd(2, 3)*xxc(3) + &
   &             derivrotationmatrix(2, 3)*xxcd(3)
   s(i, j, k, 2) = sc(2) + velygrid + derivrotationmatrix(2, 1)&
   &             *xxc(1) + derivrotationmatrix(2, 2)*xxc(2) + &
   &             derivrotationmatrix(2, 3)*xxc(3)
   sd(i, j, k, 3) = scd(3) + velzgridd + derivrotationmatrixd(3&
   &             , 1)*xxc(1) + derivrotationmatrix(3, 1)*xxcd(1) + &
   &             derivrotationmatrixd(3, 2)*xxc(2) + derivrotationmatrix(3&
   &             , 2)*xxcd(2) + derivrotationmatrixd(3, 3)*xxc(3) + &
   &             derivrotationmatrix(3, 3)*xxcd(3)
   s(i, j, k, 3) = sc(3) + velzgrid + derivrotationmatrix(3, 1)&
   &             *xxc(1) + derivrotationmatrix(3, 2)*xxc(2) + &
   &             derivrotationmatrix(3, 3)*xxc(3)
   END DO
   END DO
   END DO
   sfaceid = 0.0_8
   sfacejd = 0.0_8
   sfacekd = 0.0_8
   !
   !            ************************************************************
   !            *                                                          *
   !            * Normal grid velocities of the faces.                     *
   !            *                                                          *
   !            ************************************************************
   !
   ! Loop over the three directions.
   loopdirection:DO mm=1,3
   ! Set the upper boundaries depending on the direction.
   SELECT CASE  (mm) 
   CASE (1_intType) 
   ! Normals in i-direction
   iie = ie
   jje = je
   kke = ke
   CASE (2_intType) 
   ! Normals in j-direction
   iie = je
   jje = ie
   kke = ke
   CASE (3_intType) 
   ! Normals in k-direction
   iie = ke
   jje = ie
   kke = je
   END SELECT
   !
   !              **********************************************************
   !              *                                                        *
   !              * Normal grid velocities in generalized i-direction.     *
   !              * mm == 1: i-direction                                   *
   !              * mm == 2: j-direction                                   *
   !              * mm == 3: k-direction                                   *
   !              *                                                        *
   !              **********************************************************
   !
   DO i=0,iie
   ! Set the pointers for the coordinates, normals and
   ! normal velocities for this generalized i-plane.
   ! This depends on the value of mm.
   SELECT CASE  (mm) 
   CASE (1_intType) 
   ! normals in i-direction
   xxd => xd(i, :, :, :)
   xx => x(i, :, :, :)
   ssd => sid(i, :, :, :)
   ss => si(i, :, :, :)
   sfaced => sfaceid(i, :, :)
   sface => sfacei(i, :, :)
   CASE (2_intType) 
   ! normals in j-direction
   xxd => xd(:, i, :, :)
   xx => x(:, i, :, :)
   ssd => sjd(:, i, :, :)
   ss => sj(:, i, :, :)
   sfaced => sfacejd(:, i, :)
   sface => sfacej(:, i, :)
   CASE (3_intType) 
   ! normals in k-direction
   xxd => xd(:, :, i, :)
   xx => x(:, :, i, :)
   ssd => skd(:, :, i, :)
   ss => sk(:, :, i, :)
   sfaced => sfacekd(:, :, i)
   sface => sfacek(:, :, i)
   END SELECT
   ! Loop over the k and j-direction of this generalized
   ! i-face. Note that due to the usage of the pointer
   ! xx an offset of +1 must be used in the coordinate
   ! array, because x originally starts at 0 for the
   ! i, j and k indices.
   DO k=1,kke
   DO j=1,jje
   ! Determine the coordinates of the face center,
   ! which are stored in xc.
   xcd(1) = fourth*(xxd(j+1, k+1, 1)+xxd(j, k+1, 1)+xxd(j+1, &
   &               k, 1)+xxd(j, k, 1))
   xc(1) = fourth*(xx(j+1, k+1, 1)+xx(j, k+1, 1)+xx(j+1, k, 1&
   &               )+xx(j, k, 1))
   xcd(2) = fourth*(xxd(j+1, k+1, 2)+xxd(j, k+1, 2)+xxd(j+1, &
   &               k, 2)+xxd(j, k, 2))
   xc(2) = fourth*(xx(j+1, k+1, 2)+xx(j, k+1, 2)+xx(j+1, k, 2&
   &               )+xx(j, k, 2))
   xcd(3) = fourth*(xxd(j+1, k+1, 3)+xxd(j, k+1, 3)+xxd(j+1, &
   &               k, 3)+xxd(j, k, 3))
   xc(3) = fourth*(xx(j+1, k+1, 3)+xx(j, k+1, 3)+xx(j+1, k, 3&
   &               )+xx(j, k, 3))
   ! Determine the coordinates relative to the
   ! center of rotation.
   xxcd(1) = xcd(1)
   xxc(1) = xc(1) - rotcenter(1)
   xxcd(2) = xcd(2)
   xxc(2) = xc(2) - rotcenter(2)
   xxcd(3) = xcd(3)
   xxc(3) = xc(3) - rotcenter(3)
   ! Determine the rotation speed of the face center,
   ! which is omega*r.
   scd(1) = rotrated(2)*xxc(3) + rotrate(2)*xxcd(3) - &
   &               rotrated(3)*xxc(2) - rotrate(3)*xxcd(2)
   sc(1) = rotrate(2)*xxc(3) - rotrate(3)*xxc(2)
   scd(2) = rotrated(3)*xxc(1) + rotrate(3)*xxcd(1) - &
   &               rotrated(1)*xxc(3) - rotrate(1)*xxcd(3)
   sc(2) = rotrate(3)*xxc(1) - rotrate(1)*xxc(3)
   scd(3) = rotrated(1)*xxc(2) + rotrate(1)*xxcd(2) - &
   &               rotrated(2)*xxc(1) - rotrate(2)*xxcd(1)
   sc(3) = rotrate(1)*xxc(2) - rotrate(2)*xxc(1)
   ! Determine the coordinates relative to the
   ! rigid body rotation point.
   xxcd(1) = xcd(1)
   xxc(1) = xc(1) - rotationpoint(1)
   xxcd(2) = xcd(2)
   xxc(2) = xc(2) - rotationpoint(2)
   xxcd(3) = xcd(3)
   xxc(3) = xc(3) - rotationpoint(3)
   ! Determine the total velocity of the cell face.
   ! This is a combination of rotation speed of this
   ! block and the entire rigid body rotation.
   scd(1) = scd(1) + velxgridd + derivrotationmatrixd(1, 1)*&
   &               xxc(1) + derivrotationmatrix(1, 1)*xxcd(1) + &
   &               derivrotationmatrixd(1, 2)*xxc(2) + derivrotationmatrix(&
   &               1, 2)*xxcd(2) + derivrotationmatrixd(1, 3)*xxc(3) + &
   &               derivrotationmatrix(1, 3)*xxcd(3)
   sc(1) = sc(1) + velxgrid + derivrotationmatrix(1, 1)*xxc(1&
   &               ) + derivrotationmatrix(1, 2)*xxc(2) + &
   &               derivrotationmatrix(1, 3)*xxc(3)
   scd(2) = scd(2) + velygridd + derivrotationmatrixd(2, 1)*&
   &               xxc(1) + derivrotationmatrix(2, 1)*xxcd(1) + &
   &               derivrotationmatrixd(2, 2)*xxc(2) + derivrotationmatrix(&
   &               2, 2)*xxcd(2) + derivrotationmatrixd(2, 3)*xxc(3) + &
   &               derivrotationmatrix(2, 3)*xxcd(3)
   sc(2) = sc(2) + velygrid + derivrotationmatrix(2, 1)*xxc(1&
   &               ) + derivrotationmatrix(2, 2)*xxc(2) + &
   &               derivrotationmatrix(2, 3)*xxc(3)
   scd(3) = scd(3) + velzgridd + derivrotationmatrixd(3, 1)*&
   &               xxc(1) + derivrotationmatrix(3, 1)*xxcd(1) + &
   &               derivrotationmatrixd(3, 2)*xxc(2) + derivrotationmatrix(&
   &               3, 2)*xxcd(2) + derivrotationmatrixd(3, 3)*xxc(3) + &
   &               derivrotationmatrix(3, 3)*xxcd(3)
   sc(3) = sc(3) + velzgrid + derivrotationmatrix(3, 1)*xxc(1&
   &               ) + derivrotationmatrix(3, 2)*xxc(2) + &
   &               derivrotationmatrix(3, 3)*xxc(3)
   ! Store the dot product of grid velocity sc and
   ! the normal ss in sFace.
   sfaced(j, k) = scd(1)*ss(j, k, 1) + sc(1)*ssd(j, k, 1) + &
   &               scd(2)*ss(j, k, 2) + sc(2)*ssd(j, k, 2) + scd(3)*ss(j, k&
   &               , 3) + sc(3)*ssd(j, k, 3)
   sface(j, k) = sc(1)*ss(j, k, 1) + sc(2)*ss(j, k, 2) + sc(3&
   &               )*ss(j, k, 3)
   END DO
   END DO
   END DO
   END DO loopdirection
   END IF
   ELSE
   sfaceid = 0.0_8
   sfacejd = 0.0_8
   sd = 0.0_8
   sfacekd = 0.0_8
   END IF
   END SUBROUTINE GRIDVELOCITIESFINELEVEL_BLOCK_D
