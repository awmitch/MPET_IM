function kill_flag = simplex_push(procedure)
	global opt_data
	if opt_data.funccount == 1
		kill_flag = 0;
		opt_data.max_xtol = [];
		opt_data.max_ftol = [];
	else
		switch procedure 
			case 'initial simplex'
				opt_data.simplex_par = [opt_data.simplex_par; opt_data.itr_par];
				opt_data.simplex_J = [opt_data.simplex_J opt_data.itr_J];	
			case 'reflect'
				[tf,index] = ismember(max(opt_data.simplex_J),opt_data.simplex_J);
				opt_data.simplex_par(index,:) = opt_data.itr_par(1,:);
				opt_data.simplex_J(index) = opt_data.itr_J(1);
			case {'reflect','expand','contract outside','contract inside'}
				[tf,index] = ismember(max(opt_data.simplex_J),opt_data.simplex_J);
				opt_data.simplex_par(index,:) = opt_data.itr_par(2,:);
				opt_data.simplex_J(index) = opt_data.itr_J(2);
			case 'shrink'
				opt_data.simplex_par(2:end,:) = opt_data.itr_par(3:end,:);
				opt_data.simplex_J(2:end) = opt_data.itr_J(3:end);
		end

		opt_data.itr_par = [];
		opt_data.itr_J = [];
		[opt_data.simplex_J,simplex_order] = sort(opt_data.simplex_J);
		opt_data.simplex_par = opt_data.simplex_par(simplex_order,:);
		opt_data.max_xtol = [opt_data.max_xtol max(max(abs(opt_data.simplex_par(2:end,:)-opt_data.simplex_par(ones(1,length(opt_data.var_list)),:))))];
		opt_data.max_ftol = [opt_data.max_ftol max(abs(opt_data.simplex_J(1)-opt_data.simplex_J(2:end)))];
		fprintf('procedure: %s\n',procedure);
		%fprintf('%8s\n',opt_data.var_str);
		fprintf([repmat('%5.3f ', 1, size(opt_data.simplex_par,2)-1), '%5.3f\n'],opt_data.simplex_par.');
		fprintf('%5.3f\n',opt_data.simplex_J');
		fprintf('Max parameter difference:%5.3f\n',opt_data.max_xtol(end));
		fprintf('Max cost difference:%5.4f\n',opt_data.max_ftol(end));
		if opt_data.max_ftol(end) <= max(opt_data.ftol,10*eps(opt_data.simplex_J(1))) || opt_data.max_xtol(end) <= max(opt_data.xtol,10*eps(max(opt_data.simplex_par(:,1))))
			kill_flag = 1;
		else
			kill_flag = 0;
		end	
	end
end
