function load_sim(itr)
    global opt_data;
    global sim_struct;

	if ~isnumeric(itr)
        directory = sprintf('%ssim_outputs/%s/',opt_data.directories(2),itr);
        pickle = sprintf('python3 pickle2mat.py %s/sim_outputs/%s/',opt_data.directories(2),itr);
    else
        directory = sprintf('%ssim_outputs/sim_output_%d/',opt_data.directories(2),itr);
        pickle = sprintf('python3 pickle2mat.py %ssim_outputs/sim_output_%d/',opt_data.directories(2),itr);
    end
    sys_inputs_filename = sprintf('%sinput_dict_system_dD.mat',directory);
	sys_inputs_n_filename = sprintf('%sinput_dict_system_ndD.mat',directory);
	cath_inputs_filename = sprintf('%sinput_dict_c_dD.mat',directory);
	sim_data_filename = sprintf('%soutput_data.mat',directory);
    try
        sys_inputs = load(sys_inputs_filename);
    catch ME
        system(pickle);
    end
    try
        sys_inputs = load(sys_inputs_filename);
    catch ME
        opt_data.stop_flag = 1;
        disp(['Load pickle Failed:' num2str(itr)])
        return
    end
    sys_inputs_n = load(sys_inputs_n_filename);
    cath_inputs = load(cath_inputs_filename);
    try
        sim_data = load(sim_data_filename);
    catch ME
        opt_data.stop_flag = 1;
        disp(['Load MAT Failed:' num2str(itr)])
        return
    end
    try
    	sim_struct.sys_inputs = sys_inputs.sys_inputs;
    	sim_struct.sys_inputs_n = sys_inputs_n.sys_inputs_n;
    	sim_struct.cath_inputs = cath_inputs.cath_inputs;
    catch ME
        sim_struct.sys_inputs = sys_inputs;
        sim_struct.sys_inputs_n = sys_inputs_n;
        sim_struct.cath_inputs = cath_inputs;
    end
    
	sim_struct.sim_data = sim_data;

    for index = 1:length(opt_data.var_list)
        if opt_data.funccount == 0
            try
                eval(sprintf('%s = %s;',opt_data.var_list{index},opt_data.init_p0(index)));
            end
        end
        if opt_data.init_noise ~= 0 && opt_data.funccount == 0
            rand_num = normrnd(1,opt_data.init_noise);
            try
                opt_data.var_orig = [opt_data.var_orig eval(opt_data.var_list{index})];
            catch ME
                opt_data.var_orig = [eval(opt_data.var_list{index})];
            end
            if rand_num <= 0
                rand_num = 2-rand_num;
            end
            eval(sprintf('%s = %s*rand_num;',opt_data.var_list{index},opt_data.var_list{index}));
            try
                opt_data.rand_vals = [opt_data.rand_vals rand_num];
            catch ME
                opt_data.rand_vals = [rand_num];
            end
        end
    end
end
