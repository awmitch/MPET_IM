function kill_flag = run_sim()
    global sim_struct;
    global opt_data;

	kill_flag = 0;
	
	opt_data.funccount = opt_data.funccount + 1;

	str = gen_electrode();
	history = dir([char(opt_data.directories(1)) 'history']);
	if sum([history(~ismember({history.name},{'.','..'})).isdir]) ~= 0
		del_hist = ['rm -r' ' ' char(opt_data.directories(1)) 'history'];
		system(del_hist);
	end
	if (exist([char(opt_data.directories(1)) 'sim_output']) > 0)
		del_out = ['rm -r' ' ' char(opt_data.directories(1)) 'sim_output'];
		system(del_out);
	end

	mpetrun = ['python3' ' ' char(opt_data.directories(3)) 'bin/mpetrun.py' ' ' char(opt_data.directories(2)) 'configs/' str ' ' '>' ' ' 'cmd_out.txt&'];
	[~,cmdout] = system(mpetrun);
	[~,PID] = system('pgrep python3;');

	timeout = 0;
	[~,w_prev] = system(['tail -n ',num2str(1),' ','cmd_out.txt;']);
	
	while 1
		[q,w] = system(['tail -n ',num2str(1),' ','cmd_out.txt;']);
		if strcmp(w,w_prev)
			timeout = timeout + 10;
		else
			timeout = 0;
		end
		[~,PID] = system('pgrep python3');
		if (timeout > sim_struct.timeout || size(PID,1) == 0)	
			if (size(PID,1) ~= 0)
				kill = ['kill ' PID];
				disp(kill)
				system(kill);
				kill_flag = 1;
			else
				pause(2)
			end
			break;
		end
		w_prev = w;
		pause(10)
	end	
	cmd_name = sprintf('cmd_out_%d.txt',opt_data.funccount);
	out_name = sprintf('sim_output_%d',opt_data.funccount);
	move = ['mv' ' -v ' char(opt_data.directories(1)) 'history/*' ' ' char(opt_data.directories(2)) 'sim_outputs/' out_name];
	system(move);
	move_cmd = ['mv' ' ' char(opt_data.directories(1)) 'cmd_out.txt' ' ' char(opt_data.directories(2)) 'sim_outputs/' out_name '/' cmd_name];
	system(move_cmd);
	if (exist([char(opt_data.directories(1)) 'sim_output']) > 0)
		pickle = sprintf('python3 pickle2mat.py %ssim_outputs/sim_output_%d/',opt_data.directories(2),opt_data.funccount);
		system(pickle);
	else
		pause(2)
	end
end