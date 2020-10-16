function load_exp()
    global sim_struct;
    global opt_data;
	
	Nv = double(sim_struct.sys_inputs_n.Nvol.c);
	Vstd = -(sim_struct.sys_inputs.k*sim_struct.sys_inputs.Tref/sim_struct.sys_inputs.e)*(sim_struct.sys_inputs_n.phiRef.c-sim_struct.sys_inputs_n.phiRef.a);
	if opt_data.valid == 0	
		exp_filename = sprintf('%sdata/V_exp.csv',opt_data.directories(1));
		exp_data = load(exp_filename);
		opt_data.cmp_data.c  = exp_data(:,1);
		opt_data.cmp_data.V = exp_data(:,2);

	    exp_filename = sprintf('%sdata/OCV_exp.csv',opt_data.directories(1));
		exp_data = load(exp_filename);
		opt_data.cmp_data.c_OCV  = exp_data(:,1);
		opt_data.cmp_data.V_OCV = exp_data(:,2);

		exp_filename = sprintf('%sdata/cs_exp.csv',opt_data.directories(1));
		exp_data = load(exp_filename);
		opt_data.cmp_data.t  = exp_data(1,:);
		opt_data.cmp_data.cs = exp_data(2:end,:)';
		opt_data.cmp_data.cs = fliplr(opt_data.cmp_data.cs/sim_struct.cath_inputs.csmax);
	elseif opt_data.valid == 1
		exp_filename = sprintf('%ssim_outputs/valid_dir/output_data.mat', opt_data.directories(2));
		exp_data = load(exp_filename);
		opt_data.cmp_data.c = sim_struct.sys_inputs.Crate*exp_data.phi_applied_times(1:end-1)*sim_struct.sys_inputs.td/3600+sim_struct.sys_inputs_n.cs0.c;
		opt_data.cmp_data.V =  Vstd - (sim_struct.sys_inputs.k*sim_struct.sys_inputs.Tref/sim_struct.sys_inputs.e).*exp_data.phi_applied(1:end-1);
		opt_data.cmp_data.t = exp_data.phi_applied_times*sim_struct.sys_inputs.td/3600;
		opt_data.cmp_data.cs = zeros(length(eval(sprintf("exp_data.partTrodecvol%dpart0_cbar'", 0))),Nv);
		for i=0:Nv-1
	    	opt_data.cmp_data.cs(:,i+1) = eval(sprintf("exp_data.partTrodecvol%dpart0_cbar'", i));
		    if opt_data.valid_noise ~= 0 
		    	opt_data.cmp_data.cs(:,i+1) = opt_data.cmp_data.cs(:,i+1).*(normrnd(1,opt_data.valid_noise,size(opt_data.cmp_data.cs(:,i+1))));
		    end
		    	
		end
		opt_data.cmp_data.cs = opt_data.cmp_data.cs(6:5:51,:);
		opt_data.cmp_data.t = opt_data.cmp_data.t(6:5:51);
		if size(opt_data.cmp_data.cs,2) > 6
			cs_temp = opt_data.cmp_data.cs';
			n = size(opt_data.cmp_data.cs,2)/6;
			subs_ind = repmat(1:6,[n,1]);
			subs_ind = subs_ind(:);
			opt_data.cmp_data.cs = zeros(6,10);
			for nr = 1:10
				opt_data.cmp_data.cs(:,nr) = accumarray(subs_ind,cs_temp(:,nr),[],@mean);
			end
			opt_data.cmp_data.cs = opt_data.cmp_data.cs';
		end
	end
	opt_data.cmp_data.x = sim_struct.sys_inputs.L.s+(sim_struct.sys_inputs.L.c/6)*(3/6:6/6:6-3/6);

end
