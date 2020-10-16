function str = gen_electrode()
global sim_struct
global opt_data

str2 = sprintf('params_electrode_%d.cfg',opt_data.funccount);
fileID = fopen(strcat(char(opt_data.directories(2)),strcat('configs/',str2)),'w');

% Default parameters for simulating graphite in 1D using the 2-layer
% CHR model.
% See params_electrodes.cfg for parameter explanations.

fprintf(fileID,'[Particles]\n');
if (opt_data.CHR == 1)
	fprintf(fileID,'type = CHR\n');
else
	fprintf(fileID,'type = CHR2\n');
end
fprintf(fileID,'discretization = %e\n',sim_struct.cath_inputs.disc);
fprintf(fileID,'shape = sphere\n');
fprintf(fileID,'thickness = %e\n',sim_struct.cath_inputs.thickness);

fprintf(fileID,'[Material]\n');
if (opt_data.CHR == 1)
	fprintf(fileID,'muRfunc = LiFePO4\n');
	%LiC6_1param
else
	fprintf(fileID,'muRfunc = LiC6\n');
end
fprintf(fileID,'OCV_flag = true\n');
fprintf(fileID,'logPad = false\n');
fprintf(fileID,'noise = false\n');
fprintf(fileID,'noise_prefac = 1e-6\n');
fprintf(fileID,'numnoise = 200\n');
fprintf(fileID,'Omega_a = %e\n',sim_struct.cath_inputs.Omga);
fprintf(fileID,'Omega_b = %e\n',sim_struct.cath_inputs.Omgb);
fprintf(fileID,'Omega_c = %e\n',sim_struct.cath_inputs.Omgc);
fprintf(fileID,'kappa = %e\n',sim_struct.cath_inputs.kappa);
fprintf(fileID,'B = %e\n',sim_struct.cath_inputs.B);
fprintf(fileID,'EvdW = %e\n',sim_struct.cath_inputs.EvdW);
fprintf(fileID,'rho_s = %e\n',sim_struct.cath_inputs.rho_s);
fprintf(fileID,'D = %e\n',sim_struct.cath_inputs.D);
fprintf(fileID,'Dfunc = lattice\n');
fprintf(fileID,'dgammadc = %e\n',sim_struct.cath_inputs.dgammadc);
fprintf(fileID,'cwet = 0.98\n');

fprintf(fileID,'[Reactions]\n');
fprintf(fileID,'rxnType = BV_mod01\n');
fprintf(fileID,'k0 = %e\n',sim_struct.cath_inputs.k0);
fprintf(fileID,'alpha = 0.5\n');
fprintf(fileID,'lambda = %e\n',sim_struct.cath_inputs.lambda);
fprintf(fileID,'Rfilm = %e\n',sim_struct.cath_inputs.Rfilm);
fprintf(fileID,'gamma_side = %e\n',sim_struct.cath_inputs.gamma_side);
fprintf(fileID,'side = %d\n',sim_struct.cath_inputs.side);
fclose(fileID);

str = gen_system();
end