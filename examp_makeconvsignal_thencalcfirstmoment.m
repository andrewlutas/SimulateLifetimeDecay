% Parameters for the biexponential decay and IRF
A1 = 0.8;
B1 = 0.2;
tau1 = .6;    % ns
tau2 = 2.1;    % ns
sigma = 0.4; % IRF standard deviation in ns
num_bins = 1024; % Total number of bins
time_range = [-4, 25]; % Time range from -4 to 25 ns
start_time_shift = 12.5; % Start time for the second decay

% Example time and decay signal (convolved_signal)
[t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift);

% Define start time for the second decay
start_time = 12.5;

% Calculate the first moment from the specified start time
M = calculate_first_moment(t, convolved_signal, start_time);

