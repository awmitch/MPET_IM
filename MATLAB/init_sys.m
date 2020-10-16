function init_sys()
	global sim_struct
	global opt_data

	opt_data.funccount = 0;
	opt_data.domain = [];
	opt_data.funccount_list = [];
	opt_data.Jcost = [];
	opt_data.c_cost = [];
	opt_data.V_cost = [];
	opt_data.opt_vals = [];
	opt_data.tf = [];

	opt_data.run_t = [];
	opt_data.simplex_J = [];
	opt_data.simplex_par = [];
	opt_data.itr_J = [];
	opt_data.itr_par = [];

	opt_data.start_time = datestr(now);
	time_stamp = split(opt_data.start_time,' ');
	opt_data.directories(2) = [char(opt_data.directories(2)) time_stamp{1} '/'];
	if (exist(opt_data.directories(2))==0)
		make_day = ['mkdir' ' ' char(opt_data.directories(2))];
		system(make_day);
	end
	opt_data.directories(2) = [char(opt_data.directories(2)) time_stamp{2} '/'];
	
	make_time = ['mkdir' ' ' char(opt_data.directories(2)) '; '];
	make_out = ['mkdir' ' ' char(opt_data.directories(2)) 'sim_outputs; '];
	make_conf = ['mkdir' ' ' char(opt_data.directories(2)) 'configs; '];

	cp_conf = ['cp' ' ' char(opt_data.directories(1)) 'param_funs/' opt_data.param_fun ' ' char(opt_data.directories(2)) '; '];
	cp_init = ['cp' ' -R ' char(opt_data.directories(1)) 'sim_dirs/' opt_data.init_dir ' ' char(opt_data.directories(2)) 'sim_outputs/init_dir; '];
	if opt_data.valid == 1
		cp_init = [cp_init 'cp' ' -R ' char(opt_data.directories(1)) 'sim_dirs/' opt_data.valid_dir ' ' char(opt_data.directories(2)) 'sim_outputs/valid_dir; '];	
	end

	system([make_time make_out make_conf cp_conf cp_init]);

end