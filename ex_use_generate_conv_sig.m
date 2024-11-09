% Parameters for the biexponential decay and IRF
A1 = 0.7;
B1 = 0.3;
tau1 = 1;    % ns
tau2 = 3;    % ns
sigma = 0.1; % IRF standard deviation in ns
num_bins = 1024; % Total number of bins
time_range = [-4, 25]; % Time range from -4 to 25 ns
start_time_shift = 12.5; % Start time for the second decay

% Generate the convolved signal and plot with underlying biexponentials
[t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift);

