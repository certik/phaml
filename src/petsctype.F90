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

module petsc_type_mod

!----------------------------------------------------
! This module contains a data structure to hold the PETSc form of a
! matrix.  It is not in the linsys_type module because of the reliance
! on a preprocessor, which I do not want to require if PETSc is not used.
!----------------------------------------------------

use global
use hash_mod
use hash_eq_mod

implicit none
private
public petsc_matrix_type, petsc_options, petsc_dummy

!----------------------------------------------------
! The PETSc include files.  Note the use of preprocessor #include instead of
! the Fortran include statement, because the include files contain
! preprocessor directives.

! At PETSc 3.1 petsc.h was changed to just include the other .h's, so we
! no longer need the others (in fact, they causes duplicate declarations)

#include "include/petscversion.h"
#include "include/finclude/petsc.h"
#if (PETSC_VERSION_MAJOR < 3 || (PETSC_VERSION_MAJOR == 3 && PETSC_VERSION_MINOR == 0))
#include "include/finclude/petscvec.h"
#include "include/finclude/petscmat.h"
#include "include/finclude/petscksp.h"
#include "include/finclude/petscpc.h"
#endif

!----------------------------------------------------

type petsc_matrix_type
   Mat :: A
   Vec :: b
   integer :: my_own_eq, my_total_eq, global_eq, my_global_low, my_global_hi
   logical(small_logical), pointer :: iown(:)
   integer, pointer :: petsc_index(:)
   type(hash_table_eq), pointer :: eq_hash
end type petsc_matrix_type

type petsc_options
   real(kind(0.0d0)) :: petsc_richardson_damping_factor
   real(kind(0.0d0)) :: petsc_chebychev_emin
   real(kind(0.0d0)) :: petsc_chebychev_emax
   real(kind(0.0d0)) :: petsc_rtol
   real(kind(0.0d0)) :: petsc_atol
   real(kind(0.0d0)) :: petsc_dtol
   real(kind(0.0d0)) :: petsc_sor_omega
   real(kind(0.0d0)) :: petsc_eisenstat_omega
   integer :: petsc_gmres_max_steps
   integer :: petsc_maxits
   integer :: petsc_ilu_levels
   integer :: petsc_icc_levels
   integer :: petsc_sor_its
   integer :: petsc_sor_lits
   integer :: petsc_asm_overlap
   logical :: petsc_eisenstat_nodiagscaling
end type petsc_options

type(petsc_options), parameter :: petsc_dummy = petsc_options(0.0d0, 0.0d0, &
   0.0d0, 0.0d0, 0.0d0, 0.0d0, 0.0d0, 0.0d0, 0, 0, 0, 0, 0, 0, 0, .false.)

end module petsc_type_mod
