% Parameters for the biexponential decay and IRF
A1 = 0.7;
B1 = 0.3;
tau1 = .6;    % ns
tau2 = 2.1;    % ns
sigma = 0.1; % IRF standard deviation in ns
num_bins = 1024; % Total number of bins
time_range = [-4, 25]; % Time range from -4 to 25 ns
start_time_shift = 12.5; % Start time for the second decay

% 1. Generate the convolved signal
[t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift);

% 2. Define start time for fitting (e.g., fitting the decay starting from 12.5 ns)
start_time = 12.5; % ns

% 3. Perform a monoexponential fit on the convolved signal starting at the specified time
A_fixed = 1;       % Fix amplitude to 1
    % Perform monoexponential fit with fixed A
[A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time, A_fixed);

% Display the fitted parameters
fprintf('Fitted Monoexponential Parameters:\n');
fprintf('A = %.4f\n', A_fit);
fprintf('Tau = %.4f ns\n', tau_fit);

% 4. Plot the convolved signal and overlay the monoexponential fit result
figure;
plot(t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
hold on;

% Generate and plot the monoexponential fit starting from start_time
t_fit = t(t >= start_time); % Time vector starting from the fit start time
monoexp_fit = A_fit * exp(-(t_fit - start_time) / tau_fit); % Monoexponential fit curve
plot(t_fit, monoexp_fit, 'r--', 'DisplayName', 'Monoexponential Fit');
xlabel('Time (ns)');
ylabel('Amplitude');
title('Convolved Signal and Monoexponential Fit');
legend;
hold off;
