function str = gen_system()
global sim_struct
global opt_data

str = sprintf('params_system_%d.cfg',opt_data.funccount);
str2 = sprintf('params_electrode_%d.cfg',opt_data.funccount);
fileID = fopen(strcat(char(opt_data.directories(2)),strcat('configs/',str)),'w');

% Default parameters for simulating graphite in 1D using the 2-layer
% CHR model.
% See params_electrodes.cfg for parameter explanations.

fprintf(fileID,'[Sim Params]\n');
fprintf(fileID,'profileType = CC\n');

fprintf(fileID,'Crate = %e\n',sim_struct.sys_inputs.Crate);
fprintf(fileID,'Vmax = %e\n',sim_struct.sys_inputs.Vmax);
fprintf(fileID,'Vmin = %e\n',sim_struct.sys_inputs.Vmin);
fprintf(fileID,'capFrac = %e\n',26*sim_struct.sys_inputs.Crate);
%fprintf(fileID,'capFrac = %e\n',0.9);
fprintf(fileID,'Vset = %e\n',sim_struct.sys_inputs.Vset);
fprintf(fileID,'segments = [(0.3, 0.4),(-0.5, 0.1)]\n');
fprintf(fileID,'tramp = %e\n',sim_struct.sys_inputs.tramp);
fprintf(fileID,'prevDir = false\n');
fprintf(fileID,'tend = %d\n',sim_struct.sys_inputs.tend);
fprintf(fileID,'tsteps = %d\n',sim_struct.sys_inputs_n.tsteps);
fprintf(fileID,'relTol = %e\n',sim_struct.sys_inputs_n.relTol);
fprintf(fileID,'absTol = %e\n',sim_struct.sys_inputs_n.absTol);
fprintf(fileID,'T = %e\n',sim_struct.sys_inputs.T_ref);
fprintf(fileID,'randomSeed = true\n');
fprintf(fileID,'seed = %d\n',sim_struct.sys_inputs_n.seed);
fprintf(fileID,'Rser = %e\n',sim_struct.sys_inputs.Rser);
fprintf(fileID,'Nvol_c = %d\n',sim_struct.sys_inputs_n.Nvol.c);
fprintf(fileID,'Nvol_s = %d\n',sim_struct.sys_inputs_n.Nvol.s);
fprintf(fileID,'Nvol_a = %d\n',sim_struct.sys_inputs_n.Nvol.a);
fprintf(fileID,'Npart_c = %d\n',sim_struct.sys_inputs_n.Npart.c);
fprintf(fileID,'Npart_a = %d\n',sim_struct.sys_inputs_n.Npart.a);

fprintf(fileID,'[Electrodes]\n');
fprintf(fileID,'cathode = %s\n',str2);
fprintf(fileID,'anode = %s\n',str2);
fprintf(fileID,'k0_foil = %e\n',sim_struct.sys_inputs.k0_foil);
fprintf(fileID,'Rfilm_foil = %e\n',sim_struct.sys_inputs.Rfilm_foil);

fprintf(fileID,'[Particles]\n');
fprintf(fileID,'mean_c = %e\n',sim_struct.sys_inputs.psd_mean.c);
fprintf(fileID,'stddev_c = %e\n',sim_struct.sys_inputs.psd_stddev.c);
fprintf(fileID,'mean_a = %e\n',sim_struct.sys_inputs.psd_mean.a);
fprintf(fileID,'stddev_a = %e\n',sim_struct.sys_inputs.psd_stddev.a);
fprintf(fileID,'cs0_c = %e\n',sim_struct.sys_inputs_n.cs0.c);
fprintf(fileID,'cs0_a = %e\n',sim_struct.sys_inputs_n.cs0.a);

fprintf(fileID,'[Conductivity]\n');
fprintf(fileID,'simBulkCond_c = true\n');
fprintf(fileID,'simBulkCond_a = false\n');
fprintf(fileID,'sigma_s_c = %e\n',sim_struct.sys_inputs.sigma_s.c);
fprintf(fileID,'sigma_s_a = 5\n');
fprintf(fileID,'simPartCond_c = false\n');
fprintf(fileID,'simPartCond_a = false\n');
fprintf(fileID,'G_mean_c = %e\n',sim_struct.sys_inputs.G_mean.c);
fprintf(fileID,'G_stddev_c = %e\n',sim_struct.sys_inputs.G_stddev.c);
fprintf(fileID,'G_mean_a = %e\n',sim_struct.sys_inputs.G_mean.a);
fprintf(fileID,'G_stddev_a = %e\n',sim_struct.sys_inputs.G_stddev.a);

fprintf(fileID,'[Geometry]\n');
fprintf(fileID,'L_c = %e\n',sim_struct.sys_inputs.L.c);
fprintf(fileID,'L_a = %e\n',sim_struct.sys_inputs.L.a);
fprintf(fileID,'L_s = %e\n',sim_struct.sys_inputs.L.s);
fprintf(fileID,'P_L_c = %e\n',sim_struct.sys_inputs_n.P_L.c);
fprintf(fileID,'P_L_a = %e\n',sim_struct.sys_inputs_n.P_L.a);
fprintf(fileID,'poros_c = %e\n',sim_struct.sys_inputs_n.poros.c);
fprintf(fileID,'poros_a = %e\n',sim_struct.sys_inputs_n.poros.a);
fprintf(fileID,'poros_s = %e\n',sim_struct.sys_inputs_n.poros.s);
fprintf(fileID,'BruggExp_c = %e\n',sim_struct.sys_inputs_n.BruggExp.c);
fprintf(fileID,'BruggExp_a = %e\n',sim_struct.sys_inputs_n.BruggExp.a);
fprintf(fileID,'BruggExp_s = %e\n',sim_struct.sys_inputs_n.BruggExp.s);

fprintf(fileID,'[Electrolyte]\n');
fprintf(fileID,'c0 = %e\n',sim_struct.sys_inputs.c0);
fprintf(fileID,'zp = %d\n',sim_struct.sys_inputs_n.zp);
fprintf(fileID,'zm = %d\n',sim_struct.sys_inputs_n.zm);
fprintf(fileID,'nup = %d\n',sim_struct.sys_inputs_n.nup);
fprintf(fileID,'num = %d\n',sim_struct.sys_inputs_n.num);
fprintf(fileID,'elyteModelType = SM\n');
fprintf(fileID,'SMset = valoen_reimers\n');
fprintf(fileID,'n = 1\n');
fprintf(fileID,'sp = %d\n',sim_struct.sys_inputs_n.sp);
fprintf(fileID,'Dp = %e\n',sim_struct.sys_inputs.Dp);
fprintf(fileID,'Dm = %e\n',sim_struct.sys_inputs.Dm);

fclose(fileID);
end