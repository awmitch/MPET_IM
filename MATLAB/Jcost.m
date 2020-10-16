function J_c = Jcost()
    global sim_struct
    global opt_data

    Nv = double(sim_struct.sys_inputs_n.Nvol.c);
	t_sim = sim_struct.sim_data.phi_applied_times*sim_struct.sys_inputs.td/3600;
	cs_sim = zeros(length(eval(sprintf("sim_struct.sim_data.partTrodecvol%dpart0_cbar'", 0))),sim_struct.sys_inputs_n.Nvol.c);
	for i=0:sim_struct.sys_inputs_n.Nvol.c-1
	    cs_sim(:,i+1) = eval(sprintf("sim_struct.sim_data.partTrodecvol%dpart0_cbar'", i));
	end
	if length(t_sim) > 10
		cs_sim = cs_sim(6:5:51,:);
		t_sim = t_sim(6:5:51);
	end
	if length(opt_data.cmp_data.t) > 10
		opt_data.cmp_data.cs = opt_data.cmp_data.cs(6:5:51,:);
		opt_data.cmp_data.t = opt_data.cmp_data.t(6:5:51);
	end

    if Nv > 6
		cs_sim_temp = cs_sim';
		n = Nv/6;
		subs_ind = repmat(1:6,[n,1]);
		subs_ind = subs_ind(:);
		cs_sim = zeros(6,10);
		for nr = 1:10
			cs_sim(:,nr) = accumarray(subs_ind,cs_sim_temp(:,nr),[],@mean);
		end
		cs_sim = cs_sim';
	end
	I= sum((opt_data.cmp_data.cs' - cs_sim').^2)/size(cs_sim,2);
	J_c = trapz(opt_data.cmp_data.t, I)/(2*opt_data.cmp_data.t(end));
end
