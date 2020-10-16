function J_v = Vcost()
    global sim_struct;
    global opt_data;
	
	Vstd = -(sim_struct.sys_inputs.k*sim_struct.sys_inputs.Tref/sim_struct.sys_inputs.e)*(sim_struct.sys_inputs_n.phiRef.c-sim_struct.sys_inputs_n.phiRef.a);
	V_sim =  Vstd - (sim_struct.sys_inputs.k*sim_struct.sys_inputs.Tref/sim_struct.sys_inputs.e).*sim_struct.sim_data.phi_applied(1:end-1);

	c_sim = sim_struct.sys_inputs.Crate*sim_struct.sim_data.phi_applied_times(1:end-1)*sim_struct.sys_inputs.td/3600+sim_struct.sys_inputs_n.cs0.c;

	if length(opt_data.cmp_data.V) > length(V_sim)
		V_exp = interp1(opt_data.cmp_data.c,opt_data.cmp_data.V,c_sim);
		c_exp = c_sim;
	else
		V_exp = opt_data.cmp_data.V;
		c_exp = opt_data.cmp_data.c;
	end

	J_v = sum((V_exp-V_sim).^2)/(2*length(sim_struct.sim_data.phi_applied_times(1:end-1)));
end
