function J = min_cost(params)
	global sim_struct;
	global opt_data;	
	domain = [];
	disp('------------------NEW SIMULATION------------------')
	%fprintf('%8s\n',opt_data.var_str);
	fprintf([repmat('%5.3f ', 1, size(params,2)-1), '%5.3f\n'],params.');
	params = params.*opt_data.ref_list;
	for index=1:length(opt_data.var_list)
		eval(sprintf('%s = %e;',opt_data.var_list{index},params(index)));
	end
	fprintf([repmat('%5.3e ', 1, size(params,2)-1), '%5.3e\n'],params.');
	opt_data.domain = [opt_data.domain; params];
	opt_data.trans_t = sim_struct.sys_inputs.psd_mean.c * sim_struct.sys_inputs.psd_mean.c / sim_struct.cath_inputs.D;
	opt_data.rxn_t = sim_struct.sys_inputs.e*sim_struct.cath_inputs.rho_s*sim_struct.sys_inputs.psd_mean.c/sim_struct.cath_inputs.k0;
	opt_data.inter_width = sqrt(sim_struct.cath_inputs.kappa / (sim_struct.cath_inputs.rho_s * sim_struct.cath_inputs.Omga));
	sim_struct.cath_inputs.disc = (1/2) * opt_data.inter_width;
	fprintf('Interface Width = %5.3e m\n',opt_data.inter_width);
	fprintf('Reaction Time = %5.3f hrs\n',opt_data.rxn_t / 3600);
	fprintf('Species Transport Time = %5.3f hrs\n',opt_data.trans_t / 3600);
	fprintf('Damköhler # = %5.3f\n',opt_data.trans_t / opt_data.rxn_t);
	start_run = datevec(datestr(now));

	kill_flag = run_sim();
	prev_itr = opt_data.funccount;

	end_run = datevec(datestr(now));
	fprintf('Runtime:%5.2f min\n',etime(end_run,start_run)/60);
	if (exist([char(opt_data.directories(2)) 'sim_outputs/sim_output_' num2str(opt_data.funccount) '/run_info.txt'])==0)
		final_time = 0;
	else 
		opt_data.stop_flag = 0;
		load_sim(opt_data.funccount);
		if opt_data.stop_flag ~= 1
			final_time = round(sim_struct.sim_data.phi_applied_times(end)*sim_struct.sys_inputs.td);
		else
			final_time = 0;
		end

	end
	if (final_time < 25*3600)
		disp(['FAILED: Final time unreached ' num2str(opt_data.funccount)])
		J_c = Inf;
		J_v = Inf;
		J = Inf;
	else
		disp(['SUCCESS: Completed simulation ' num2str(opt_data.funccount)])
		J_c = Jcost();
		J_v = Vcost();
		J = opt_data.rho_cost*J_v + (1-opt_data.rho_cost)*J_c;
		if opt_data.ref_J == 0
			opt_data.ref_J = J;
		end
		J = J/opt_data.ref_J;

		fprintf('J_c = %5.3e\n',J_c);
		fprintf('J_V = %5.3e\n',J_v);
		fprintf('J = %5.3f\n',J);
	end
	opt_data.funccount = prev_itr;

	params = params./opt_data.ref_list;

	opt_data.itr_par = [opt_data.itr_par; params];
	opt_data.itr_J = [opt_data.itr_J J];

	opt_data.Jcost = [opt_data.Jcost J*opt_data.ref_J];
	opt_data.c_cost = [opt_data.c_cost J_c];
	opt_data.V_cost = [opt_data.V_cost J_v];
	opt_data.tf = [opt_data.tf final_time];
	opt_data.run_t = [opt_data.run_t etime(end_run,start_run)];
	
end
