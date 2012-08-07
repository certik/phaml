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
! This is a simple example that just solves one linear elliptic pde.
!----------------------------------------------------

!       ------------
program phaml_master
!       ------------

!----------------------------------------------------
! This is the main program.
!----------------------------------------------------

!----------------------------------------------------
! Modules used are:

use phaml
!----------------------------------------------------

implicit none

!----------------------------------------------------
! Local variables

type(phaml_solution_type) :: soln
!----------------------------------------------------
! Begin executable code

call phaml_create(soln,nproc=1, &
!                  spawn_form=DEBUG_SLAVE,debug_command="idbc", &
                  draw_grid_who=NO_ONE)

call phaml_solve_pde(soln,                       &
                     max_vert=1000,              &
                     draw_grid_when=NEVER      , &
                     pause_after_phases=.false., &
                     print_grid_when=PHASES,     &
                     print_grid_who=MASTER,      &
                     print_time_when=FINAL,      &
                     print_time_who=MASTER,      &
                     print_error_when=PHASES,    &
                     print_error_what=ENERGY_LINF_L2_ERR,     &
                     print_errest_what=ENERGY_LINF_L2_ERREST, &
                     print_error_who=MASTER)

call phaml_destroy(soln)

end program phaml_master