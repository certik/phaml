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
! This file contains the main program supplied by the user.
!
! This version solves a parabolic equation.  See README.parabolic for
! a description of the implicit time stepping scheme.
!
!----------------------------------------------------

!       ------------
program phaml_master
!       ------------

!----------------------------------------------------
! This is the main program.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use global
use phaml
use phaml_user_mod
use message_passing
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Local variables:

integer :: nproc,nelem
real(my_real) :: finalt
type(phaml_solution_type) :: soln

!----------------------------------------------------
! Begin executable code

kappa = 1.0_my_real
print *,"problem parameter kappa (for example, 1.0)?"
read *,kappa

nelem = 100
print *,"number of elements for the grid (for example, 1000)?"
read *,nelem

finalt = 10.0_my_real
print *,"final time (for example, 10.0)?"
read *,finalt

deltat = .01_my_real
print *,"time step (for example, .01)?"
read *,deltat

nproc = 1
!print *,"number of processors?"
!read *,nproc

! create the phaml_solution variables

t = 0.0_my_real
call phaml_create(soln,nproc,update_umod=.true.,system_size=2, &
!                  spawn_form=DEBUG_SLAVE,debug_command="gdb", &
                  draw_grid_who = MASTER)

! Undocumented feature of PHAML; tell the graphics process to use a fixed
! vertical scale, instead of scaling to the size of the function being plotted.
! This is a secret -- don't tell anyone!

call phaml_send(soln%procs,graphics_proc(soln%procs),(/21,-1/),2, &
                (/0.0_my_real/),0,101)

! set the initial condition

call phaml_solve_pde(soln,                      &
                     max_elem=nelem,            &
                     task=SET_INITIAL,          &
                     error_estimator=INITIAL_CONDITION, &
                     print_header_who=NO_ONE,   &
                     print_trailer_who=NO_ONE,  &
                     draw_grid_when=FINAL)

! give time to adjust the graphics view

print *,"adjust graphics view and press return"
read *

! solve the equation until the final time is reached.

do
   t = t + deltat
   if (t > finalt) exit
   print *,"time = ",t
   call update_usermod(soln)
   call phaml_copy_soln_to_old(soln)
   call phaml_solve_pde(soln,                    &
                        max_refsolveloop=1,      &
                        refterm=KEEP_NELEM,      &
                        max_elem=nelem,          &
!                        solver=MUMPS_NONSYM_SOLVER, &
                        solver=LAPACK_INDEFINITE_SOLVER, &
                        draw_grid_when=FINAL ,   &
                        print_error_who=MASTER,  &
                        print_error_when=PHASES, &
                        print_error_what=LINF_ERR, &
                        print_header_who=NO_ONE, &
                        print_trailer_who=NO_ONE)
end do

print *,"press return to terminate program"
read *

call phaml_destroy(soln)

end program phaml_master
