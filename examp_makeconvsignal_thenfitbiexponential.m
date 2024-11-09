% Parameters for the biexponential decay and IRF
A1 = 0.7;
B1 = 0.3;
tau1 = .6;    % ns
tau2 = 2.1;    % ns
sigma = 0.2; % IRF standard deviation in ns
num_bins = 1024; % Total number of bins
time_range = [-4, 25]; % Time range from -4 to 25 ns
start_time_shift = 12.5; % Start time for the second decay

% 1. Generate the convolved signal
[t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift);

% 2. Define start time for fitting (e.g., fitting the decay starting from 12.5 ns)
start_time = 12.5; % ns

start_time = 12.5;  % Start time for fitting
tau1_fixed = .6;     % Fixed tau1
tau2_fixed = 2.1;     % Fixed tau2
[A_fit, B_fit, tau1_fit, tau2_fit] = fit_biexponential(t, convolved_signal, start_time, tau1_fixed, tau2_fixed);

% Display the fitted parameters
fprintf('Fitted Biexponential Parameters:\n');
fprintf('A = %.4f\n', A_fit);
fprintf('B = %.4f\n', B_fit);
fprintf('Tau1 = %.4f ns\n', tau1_fit);
fprintf('Tau2 = %.4f ns\n', tau2_fit);

% Plot the convolved signal and overlay the biexponential fit result
figure;
plot(t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
hold on;

% Generate and plot the biexponential fit starting from start_time
t_fit = t(t >= start_time); % Time vector starting from the fit start time
biexp_fit = A_fit * exp(-(t_fit - start_time) / tau1_fit) + B_fit * exp(-(t_fit - start_time) / tau2_fit); % Biexponential fit curve
plot(t_fit, biexp_fit, 'r--', 'DisplayName', 'Biexponential Fit');
xlabel('Time (ns)');
ylabel('Amplitude');
title('Convolved Signal and Biexponential Fit');
legend;
hold off;
