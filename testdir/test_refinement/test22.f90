program phaml_master
use phaml
implicit none
type(phaml_solution_type) :: soln
call phaml_create(soln,nproc=4)
call phaml_solve_pde(soln,print_grid_when=PHASES,print_grid_who=MASTER, &
                     print_error_when=PHASES,print_error_who=MASTER, &
                     print_error_what=ENERGY_LINF_L2_ERR, &
                     print_errest_what=ENERGY_LINF_L2_ERREST, &
                     max_eq=1000,error_estimator=LOCAL_PROBLEM_H)
call phaml_destroy(soln)
end program phaml_master
