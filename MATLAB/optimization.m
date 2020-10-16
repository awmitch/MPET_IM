function optimization(param_fun,init_dir)
	clear y Fs;
	clearvars -except param_fun init_dir;
	clearvars -global
	format shortG;
	global sim_struct;
	global opt_data;
	run(['./param_funs/' param_fun]);
	opt_data.param_fun = param_fun;
	opt_data.init_dir = init_dir;
	if opt_data.num_restarts ~= 0 && opt_data.rho_sweep == 1
		sweep.Jv = [];
		sweep.Jc = [];
		sweep.J = [];
		sweep.param = zeros(length(opt_data.var_list),opt_data.num_restarts+1);
	end	
	for reboot = 1:opt_data.num_restarts+1
		opt_data.directories = ["./"; %MATLAB folder
					"./"; %output data folder
					"./../"]; %mpet folder

		init_sys();
		if reboot == 1
			load_sim('init_dir');
			load_exp();
			sim_struct.cath_inputs.theta = 0.08847;
		end
		p0 = [];
		opt_data.ref_list = [];
		opt_data.ref_J = 0;
		for index=1:length(opt_data.var_list)
			eval(sprintf('p0 = [p0 %s];', opt_data.var_list{index}));
		end
		opt_data.ref_list = p0;
		p0 = p0./opt_data.ref_list;
		options = optimset('OutputFcn',@min_output);
		diary([char(opt_data.directories(2)) 'output.log'])
		if opt_data.num_restarts ~= 0 && opt_data.rho_sweep == 1
			if reboot ~= 1
				opt_data.rho_cost = opt_data.rho_cost + opt_data.rho_delta/(opt_data.num_restarts);
			end
			disp(['rho: ' num2str(opt_data.rho_cost)])
		end
		options.TolX = 0;
		options.TolFun = 0;
		[min_par,min_J,exitflag,output] = fminsearch(@min_cost,p0,options);
    	prev_itr = opt_data.funccount;
    	if prev_itr == 1
    		break;
    	end
    	[tf, opt_data.funccount]=ismember(opt_data.min_params,opt_data.domain,'rows');
    	out_name = sprintf('sim_output_%d',opt_data.funccount);
    	diary off;
   		if opt_data.num_restarts ~= 0 && opt_data.rho_sweep == 1
			sweep.Jc = [sweep.Jc opt_data.c_cost(opt_data.opt_ID)];
			sweep.Jv = [sweep.Jv opt_data.V_cost(opt_data.opt_ID)];
			sweep.J = [sweep.J opt_data.Jcost(opt_data.opt_ID)];
			for index=1:length(opt_data.var_list)
				sweep.param(index,reboot) = opt_data.min_params(index);
			end
		end
    	if reboot ~= opt_data.num_restarts+1
    		load_sim(opt_data.opt_ID);
		end
	end
end
