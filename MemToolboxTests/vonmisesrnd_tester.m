clear all;

%% compare speeds of randvonmises and vonmisesrnd
% requires jv10 and circ_stats toolboxes

% preferences
mu = 0;
kappa = 1;
orders = 6; % how many orders of magnitude to test
runs = 10;

% testing
for run = 1:runs
	run
	for i = 0:orders
		%tic; randvonmises(10^i, mu, kappa); t1(run, i+1) = toc;
		tic; vonmisesrnd(mu, kappa, [1, 10^i]); t2(run, i+1) = toc;
		%tic; circ_vmrnd(mu, kappa, 10^i); t3(run, i+1) = toc;
		tic; randraw('vonmises', [0, kappa], 10^i); t4(run, i+1) = toc;
	end
end

% plot the results
h = figure;
%loglog(10.^[0:orders], mean(t1), '-k')
loglog(10.^[0:orders], mean(t2), '-r')
hold
%loglog(10.^[0:orders], mean(t3), '-g')
loglog(10.^[0:orders], mean(t4), '-b')
xlabel('number of generated pseudorandom values')
ylabel('time (s)')