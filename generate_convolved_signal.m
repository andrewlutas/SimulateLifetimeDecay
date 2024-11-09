function [t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift)
    % generate_convolved_signal: Generates a convolved biexponential signal
    % with a Gaussian IRF and plots the underlying biexponential functions.
    %
    % Inputs:
    % - A1: Amplitude of the bound state for first decay
    % - B1: Amplitude of the unbound state for first decay
    % - tau1: Decay constant for bound state (ns)
    % - tau2: Decay constant for unbound state (ns)
    % - sigma: Standard deviation of the Gaussian IRF (ns)
    % - num_bins: Number of bins for the time vector
    % - time_range: Two-element vector [t_min, t_max] specifying time range (ns), default is [-4, 25]
    % - start_time_shift: Start time for the second decay (e.g., 12.5 ns)
    %
    % Outputs:
    % - t: Time vector for the signal
    % - convolved_signal: Convolved biexponential signal with IRF

    % Set default time range if not provided
    if nargin < 7 || isempty(time_range)
        time_range = [-4, 25]; % Default time range set to [-4, 25] ns
    end
    
    % Create time vector
    t = linspace(time_range(1), time_range(2), num_bins);
    dt = t(2) - t(1); % Calculate time step size

    % Define the first biexponential decay function
    f1 = A1 * exp(-t / tau1) + B1 * exp(-t / tau2);
    f1(t < 0) = 0; % Ensure no decay signal before time zero

    % Define the IRF centered at zero
    irf = exp(-t.^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi));

    % Perform convolution for the first decay
    g_full1 = conv(f1, irf, 'full'); % Full convolution to capture complete response

    % Define the time vector for the convolution result
    t_conv = (0:length(g_full1)-1) * dt + t(1); % Time vector for g_full
    trim_start1 = find(t_conv >= 0, 1); % Start index for t = 0
    g1 = g_full1(trim_start1:trim_start1 + num_bins - 1); % Trimmed to match t length

    % Define the second biexponential decay starting at start_time_shift
    f2 = zeros(size(t));
    f2(t >= start_time_shift) = A1 * exp(-(t(t >= start_time_shift) - start_time_shift) / tau1) + ...
                                B1 * exp(-(t(t >= start_time_shift) - start_time_shift) / tau2);

    % Perform convolution for the second decay
    g_full2 = conv(f2, irf, 'full'); % Full convolution for the second decay

    % Trim the second convolution result to align with t
    g2 = g_full2(trim_start1:trim_start1 + num_bins - 1); % Trimmed to match t length

    % Sum the two convolved signals
    convolved_signal = g1 + g2;
    
    % Normalize the combined convolved signal for consistency
    convolved_signal = convolved_signal / max(convolved_signal);

    % Plot the results
    figure;
    plot(t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
    hold on;
    
    % Plot the underlying biexponential components before convolution
    plot(t, f1, 'k:', 'DisplayName', 'Underlying Biexponential 1 (Unconvolved)');
    plot(t, f2, 'r:', 'DisplayName', 'Underlying Biexponential 2 (Unconvolved)');
    
    xlabel('Time (ns)');
    ylabel('Amplitude');
    title('Convolved Biexponential Signal with IRF and Underlying Biexponential Functions');
    legend;
    hold off;
end
