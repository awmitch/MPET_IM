function stop = min_output(params, optimValues, state)
	global opt_data;
    global bisect_data;
    global sim_struct;

    if opt_data.funccount ~= 1
    	disp(['==================DONE ITERATION=================='])
    end
	stop = false;

	params = params.*opt_data.ref_list;

	if optimValues.fval ~= Inf
		optimValues.fval = optimValues.fval*opt_data.ref_J;
	end 

	kill_flag = simplex_push(optimValues.procedure);
	if kill_flag == 1
        stop = true;
        opt_data.min_params = params;
    	opt_data.min_optimValues = optimValues;
    	save([char(opt_data.directories(2)) '/sim_outputs/opt_data.mat'],'opt_data')
    	if opt_data.valid == 1
    		disp('Final validation difference:')
    		fprintf('%5.3f\n',params./opt_data.var_orig);
			fprintf('Avg = %5.3f\n',mean(abs(params./opt_data.var_orig-1)));
    	end
    end
	switch state
		case 'init'
			if opt_data.init_noise ~= 0
				disp(['Initial perturbation:'])
				fprintf('%5.3f\n',opt_data.rand_vals);
				fprintf('Avg = %5.3f\n',mean(abs(opt_data.rand_vals-1)));
				if opt_data.funccount == 1 && (optimValues.fval == Inf || optimValues.fval == NaN)
					stop = true
				end
			end
	    case 'iter'
	    	fprintf('Total time elapsed:%5.2f min\n',etime(datevec(datestr(now)),datevec(opt_data.start_time))/60);
	    	fprintf('Matlab time fraction:%5.3f\n',1-sum(opt_data.run_t)/etime(datevec(datestr(now)),datevec(opt_data.start_time)));
	    	fprintf('func-count:%d\n',optimValues.funccount);
	        fprintf('iteration:%d\n',optimValues.iteration);
	        fprintf('Min J = %5.3e\n',optimValues.fval);
	        prev_itr = opt_data.funccount;
	        [tf, opt_data.funccount]=ismember(params,opt_data.domain,'rows');
	        fprintf('opt_ID:%d\n',opt_data.funccount);

	        opt_data.optimValues.params = params;
	        opt_data.opt_vals = [opt_data.opt_vals optimValues];
	        opt_data.opt_ID = opt_data.funccount;
	        
	        opt_data.funccount_list = [opt_data.funccount_list opt_data.funccount];
	        opt_data.funccount = prev_itr;    	
	end
	diary off
	diary on

end