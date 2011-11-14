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
! This version solves a parabolic equation by a second order backward
! difference scheme to illustrate how to implement multiple old solutions
! via a coupled system.  See README.bdf2 for an explanation.
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
use phaml_user_mod
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

real(my_real) :: u_old, v_old
!----------------------------------------------------

!----------------------------------------------------
! Begin executable code

cxx = 0.0_my_real; cxx(1,1) = 1.0_my_real
cyy = 0.0_my_real; cyy(1,1) = 1.0_my_real
c   = 0.0_my_real
c(1,1) = 3.0_my_real/(2.0_my_real*deltat)
c(2,2) = 1.0_my_real

call phaml_evaluate_old(x,y,u_old,comp=1)
call phaml_evaluate_old(x,y,v_old,comp=2)

rs(1) = (2.0_my_real*u_old - 0.5_my_real*v_old)/deltat
rs(2) = u_old

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
use phaml_user_mod
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Dummy arguments

real(my_real), intent(in) :: x,y
integer, intent(in) :: bmark
integer, intent(out) :: itype(:)
real(my_real), intent(out) :: c(:,:),rs(:)
!----------------------------------------------------
! Local variables

!----------------------------------------------------
! Begin executable code

! Dirichlet boundary conditions

c = 0.0_my_real

select case (bmark)

   case (1)
      itype = DIRICHLET
      rs = 1.0e-2_my_real

   case (2,3,4,5,6,7,8)
      itype = NATURAL
      rs = 0.0_my_real

   case default
      print *,"ERROR -- bad boundary mark in bconds"
      stop

end select

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

! With BDF2, using the same function for the initial condition of both
! components makes the first step be like backward Euler with a time step
! 3/2 times bigger

iconds = 10*exp(-25*((x-.5_my_real)**2+(y-.5_my_real)**2)) + &
         .01_my_real*exp(-100*(x**2+y**2))

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

!----------------------------------------------------
! Begin executable code

trues = huge(0.0_my_real)

end function trues

!        ------
function truexs(x,y,comp,eigen) ! real (my_real)
!        ------

!----------------------------------------------------
! This is the x derivative of the true solution of the differential
! equation, if known.
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
real (my_real) :: truexs
!----------------------------------------------------

!----------------------------------------------------
! Begin executable code

truexs = huge(0.0_my_real)

end function truexs

!        ------
function trueys(x,y,comp,eigen) ! real (my_real)
!        ------

!----------------------------------------------------
! This is the y derivative of the true solution of the differential
! equation, if known.
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
real (my_real) :: trueys
!----------------------------------------------------

!----------------------------------------------------
! Begin executable code

trueys = huge(0.0_my_real)

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

! Dummy version, assume infinitely differentiable everywhere.

regularity = huge(0.0_my_real)

end function regularity
