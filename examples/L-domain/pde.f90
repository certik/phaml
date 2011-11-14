!---------------------------------------------------------------------!
!                                PHAML                                !
!                                                                     !
! The Parallel Hierarchical Adaptive MultiLevel code for solving      !
! linear elliptic partial differential equations of the form          !
! (PUx)x + (QUy)y + RU = F on 2D polygonal domains with mixed         !
! boundary conditions, and eigenvalue problems where F is lambda*U.   !
!                                                                     !
! PHAML is public domain software.  It was produced as part of work   !
! done by the U.S. Government, and is not subject to copyright in     !
! the United States.                                                  !
!                                                                     !
!     William F. Mitchell                                             !
!     Applied and Computational Mathematics Division                  !
!     National Institute of Standards and Technology                  !
!     william.mitchell@nist.gov                                       !
!     http://math.nist.gov/phaml                                      !
!                                                                     !
!---------------------------------------------------------------------!

!----------------------------------------------------
! This file contains the user supplied external subroutines that define
! the PDE(s) to be solved, and other required external subroutines.
!   pdecoefs bconds boundary_point boundary_npiece boundary_param iconds trues
!   truexs trueys update_usermod phaml_integral_kernel
!
! This version illustrates a singularity on an L shaped domain.
!----------------------------------------------------

!          --------
subroutine pdecoefs(x,y,cxx,cxy,cyy,cx,cy,c,rs)
!          --------

!----------------------------------------------------
! This subroutine returns the coefficient and right hand side of the PDE
! at the point (x,y)
!
! The PDE is
!
!    -( cxx(x,y) * u  )  -( cyy(x,y) * u  ) + c(x,y) * u = rs(x,y)
!                   x  x                y  y
!
! For eigenvalue problems, the right hand side is lambda * u * rs(x,y)
!
! cxy, cx and cy are not currently used and should not be set.  They are
! for future expansion.
!
! NOTE: BE CAREFUL TO GET THE SIGNS RIGHT
! e.g. cxx=cyy=1 means rs=-(uxx+uyy)
!
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
real(my_real), intent(out) :: cxx(:,:),cxy(:,:),cyy(:,:),cx(:,:),cy(:,:), &
                              c(:,:),rs(:)
!----------------------------------------------------

!----------------------------------------------------
! Local variables

!----------------------------------------------------

!----------------------------------------------------
! Begin executable code

cxx(1,1) = 1.0_my_real
cyy(1,1) = 1.0_my_real
c(1,1) = 0.0_my_real
rs(1) = 0.0_my_real

cxy=0; cx=0; cy=0

end subroutine pdecoefs

!          ------
subroutine bconds(x,y,bmark,itype,c,rs)
!          ------

!----------------------------------------------------
! This subroutine returns the boundary conditions at the point (x,y).
!
! Each boundary condition is either
!
!    u = rs(x,y) or  u  + c(x,y)*u = rs(x,y)
!                     n
!
! itype indicates which type of condition applies to each point, using
! symbolic constants from module phaml.  It is DIRICHLET for the first
! condition, NATURAL for the second condition with c==0, and MIXED for
! the second condition with c/=0.
!
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: bmark
integer, intent(out) :: itype(:)
real(my_real), intent(out) :: c(:,:),rs(:)
!----------------------------------------------------

!----------------------------------------------------
! Non-module procedures used are:

interface

   function trues(x,y,comp,eigen) ! real (my_real)
   use phaml
   real (my_real), intent(in) :: x,y
   integer, intent(in) :: comp,eigen
   real (my_real) :: trues
   end function trues

end interface

!----------------------------------------------------
! Local variables

!----------------------------------------------------

!----------------------------------------------------
! Begin executable code

! Dirichlet boundary conditions

itype = DIRICHLET
c = 0.0_my_real
rs(1) = trues(x,y,1,1)

end subroutine bconds

!        ------
function iconds(x,y,comp,eigen)
!        ------

!----------------------------------------------------
! This routine returns the initial condition for a time dependent problem.
! It can also be used for the initial guess for a nonlinear problem, or
! systems of equations solved by sucessive substitution.
! comp,eigen is which solution to use from a coupled system of PDEs or multiple
! eigenvectors from an eigenvalue problem, and is ignored in this example.
! For problems where there are no initial conditions, it is a dummy.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: comp,eigen
real(my_real) :: iconds

!----------------------------------------------------
! Begin executable code

iconds = 0.0_my_real

end function iconds

!        -----
function trues(x,y,comp,eigen) ! real (my_real)
!        -----

!----------------------------------------------------
! This is the true solution of the differential equation, if known.
! comp,eigen is which solution to use from a coupled system of PDEs or multiple
! eigenvectors from an eigenvalue problem, and is ignored in this example.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: comp,eigen
real (my_real) :: trues
!----------------------------------------------------
! Local variables

real (my_real) :: r,theta1
!----------------------------------------------------
! Begin executable code

! singularity at the origin, reflecting the reentrant corner

r = sqrt(x*x+y*y)
theta1 = atan2(y,x)
if (theta1 < 0.0_my_real) theta1 = theta1 + 8.0_my_real*atan(1.0_my_real)
trues = r**(2.0_my_real/3.0_my_real)*sin(2.0_my_real*theta1/3.0_my_real)

end function trues

!        -----
function truexs(x,y,comp,eigen) ! real (my_real)
!        -----

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: comp,eigen
real (my_real) :: truexs
!----------------------------------------------------
! Local variables

real (my_real) :: r,theta1,c
!----------------------------------------------------
! Begin executable code

! singularity at the origin, reflecting the reentrant corner

r = sqrt(x*x+y*y)
theta1 = atan2(y,x)
if (theta1 < 0.0_my_real) theta1 = theta1 + 8.0_my_real*atan(1.0_my_real)
c = 2.0_my_real/3.0_my_real
truexs = c*r**(c-2)*(x*sin(c*theta1) - y*cos(c*theta1))

end function truexs

!        -----
function trueys(x,y,comp,eigen) ! real (my_real)
!        -----

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: comp,eigen
real (my_real) :: trueys
!----------------------------------------------------
! Local variables

real (my_real) :: r,theta1,c
!----------------------------------------------------
! Begin executable code

! singularity at the origin, reflecting the reentrant corner

r = sqrt(x*x+y*y)
theta1 = atan2(y,x)
if (theta1 < 0.0_my_real) theta1 = theta1 + 8.0_my_real*atan(1.0_my_real)
c = 2.0_my_real/3.0_my_real
trueys = c*r**(c-2)*(y*sin(c*theta1) + x*cos(c*theta1))

end function trueys

!          --------------
subroutine boundary_point(ipiece,s,x,y)
!          --------------

!----------------------------------------------------
! This routine defines the boundary of the domain.  It returns the point
! (x,y) with parameter s on piece ipiece.
! If boundary_npiece <= 0 it is a dummy and the domain is given by triangle
! data files.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

integer, intent(in) :: ipiece
real(my_real), intent(in) :: s
real(my_real), intent(out) :: x,y

!----------------------------------------------------
! Begin executable code

! Dummy version

x = 0.0_my_real
y = 0.0_my_real

end subroutine boundary_point

!        ---------------
function boundary_npiece(hole)
!        ---------------

!----------------------------------------------------
! This routine gives the number of pieces in the boundary definition.
! If boundary_npiece <= 0 the domain is given by triangle data files.
!----------------------------------------------------

!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

integer, intent(in) :: hole
integer :: boundary_npiece
!----------------------------------------------------
! Begin executable code

boundary_npiece = 0

end function boundary_npiece

!          --------------
subroutine boundary_param(start,finish)
!          --------------

!----------------------------------------------------
! This routine gives the range of parameter values for each piece of the
! boundary.
! If boundary_npiece <= 0 it is a dummy and the domain is given by triangle
! data files.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(out) :: start(:), finish(:)
!----------------------------------------------------
! Begin executable code

! Dummy version

start = 0.0_my_real
finish = 0.0_my_real

end subroutine boundary_param

!          --------------
subroutine update_usermod(phaml_solution)
!          --------------

use phaml
type(phaml_solution_type), intent(in) :: phaml_solution

! Dummy version.  See examples/elliptic/usermod.f90 for a functional example.

end subroutine update_usermod

!        ---------------------
function phaml_integral_kernel(kernel,x,y)
!        ---------------------

use phaml
integer, intent(in) :: kernel
real(my_real), intent(in) :: x,y
real(my_real) :: phaml_integral_kernel

! Identity function

phaml_integral_kernel = 1.0

end function phaml_integral_kernel

!        ----------
function regularity(x,y)
!        ----------

use phaml
real(my_real), intent(in) :: x(3),y(3)
real(my_real) :: regularity

! This function gives a priori knowledge about the regularity (a.k.a.
! smoothness) of the solution to guide the selection between h and p
! refinement in the APRIORI hp-adaptive strategy.

! In theory, this routine should return the largest value of m such that,
! within the triangle whose vertices are given in (x,y), the solution is in
! the Hilbert space H^m, i.e. it has m continuous derivatives.  For
! multicomponent solutions, it should return the worst (i.e. smallest)
! such m among the components.

! In practice, it can be used to guide refinement in other a priori known
! trouble areas, such as sharp peaks, boundary layers and wave fronts.  The
! actual use is that p refinement is performed if the current degree of the
! triangle given by (x,y) is less than the returned value, and h refinement
! is performed otherwise.

! Hint: you can determine if a point (s,t) is inside a triangle by computing
! the barycentric coordinates of the point and verifying that all three are
! nonnegative, as follows:
!  det = x(1)*(y(2)-y(3))+x(2)*(y(3)-y(1))+x(3)*(y(1)-y(2))
!  zeta(1) = (s*(y(2)-y(3)) + t*(x(3)-x(2)) + (x(2)*y(3)-x(3)*y(2)))/det
!  zeta(2) = (s*(y(3)-y(1)) + t*(x(1)-x(3)) + (x(3)*y(1)-x(1)*y(3)))/det
!  zeta(3) = (s*(y(1)-y(2)) + t*(x(2)-x(1)) + (x(1)*y(2)-x(2)*y(1)))/det
!  if (all(zeta >= -1000*epsilon(0.0_my_real))) then
!     the point (s,t) is in the triangle
!  else
!     the point (s,t) is not in the triangle
!  endif
! In the comparison we use a value slightly less than 0 to account for
! roundoff errors.

! For the L domain, there is a singularity at the reentrant corner with
! regularity 2/3.  Since the reentrant corner (0,0) is a vertex, we just
! need to see if one of the vertices is the origin.

if (any(x == 0.0_my_real .and. y == 0.0_my_real)) then
   regularity = 1 + 2.0_my_real/3.0_my_real
else
   regularity = huge(0.0_my_real)
endif

end function regularity
