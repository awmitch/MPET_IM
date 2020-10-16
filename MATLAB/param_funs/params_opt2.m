function params_opt2()
	global sim_struct
	global opt_data

	opt_data.var_list = {%'sim_struct.cath_inputs.kappa' 
				'sim_struct.cath_inputs.k0'
				'sim_struct.cath_inputs.D'
				'sim_struct.sys_inputs.k0_foil' 
				'sim_struct.cath_inputs.Omga' 
				'sim_struct.cath_inputs.Omgb' 
				'sim_struct.cath_inputs.Omgc' 
				'sim_struct.cath_inputs.gamma_side'
				'sim_struct.sys_inputs.sigma_s.c'
				};
	opt_data.CHR = 2; %CHR = 1 or = 2
	sim_struct.timeout = 600;
	
	opt_data.ftol = 1e-3;
	opt_data.xtol = 1e-2;
	opt_data.num_restarts = 0;
	opt_data.rho_sweep = 0;
	opt_data.rho_cost = 0;
	opt_data.rho_delta = 0.1*opt_data.num_restarts;
	%J = rho*J_v + (1-rho)*J_c;

	opt_data.valid = 0;
	opt_data.valid_dir = '';
	opt_data.valid_noise = 0;
	%standard deviation of noise added to validation data 
	opt_data.init_noise = 0;
	%standard deviation of noise added to inital point
	rng('shuffle')

end
