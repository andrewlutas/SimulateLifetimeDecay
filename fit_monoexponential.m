function [A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time, A_fixed)
    % fit_monoexponential: Fits a monoexponential model to a convolved signal
    % starting from a specified time, with an optional fixed amplitude.
    %
    % Inputs:
    % - t: Time vector for the full signal
    % - convolved_signal: Convolved biexponential signal to be fitted
    % - start_time: Time (ns) to start fitting (e.g., to fit only the second decay)
    % - A_fixed (optional): Fixed amplitude for the monoexponential model
    %
    % Outputs:
    % - A_fit: Fitted or fixed amplitude for the monoexponential model
    % - tau_fit: Fitted decay constant for the monoexponential model
    
    % Ensure start_time is within the time range
    if start_time < min(t) || start_time > max(t)
        error('start_time must be within the range of the time vector t.');
    end
    
    % Trim the signal and time vector to start from the specified start_time
    start_index = find(t >= start_time, 1);
    t_trimmed = t(start_index:end) - start_time; % Shift time so it starts from zero
    signal_trimmed = convolved_signal(start_index:end); % Trimmed signal starting from specified time

    % Define the model function for monoexponential decay
    if nargin < 4
        % If A_fixed is not provided, fit both A and tau
        initial_guess = [max(signal_trimmed), 1]; % Initial guess: [amplitude, tau]
        model_fun = @(params, t) params(1) * exp(-t / params(2));
        options = optimset('Display', 'off');
        [params_fit, ~] = lsqcurvefit(model_fun, initial_guess, t_trimmed, signal_trimmed, [], [], options);
        A_fit = params_fit(1);
        tau_fit = params_fit(2);
    else
        % If A_fixed is provided, fit only tau with fixed amplitude
        A_fit = A_fixed;
        initial_tau_guess = 1;
        model_fun = @(tau, t) A_fit * exp(-t / tau);
        options = optimset('Display', 'off');
        tau_fit = lsqcurvefit(model_fun, initial_tau_guess, t_trimmed, signal_trimmed, [], [], options);
    end

    % Calculate fitted signal for plotting
    fitted_signal = model_fun(tau_fit, t_trimmed);
    
    % Calculate residuals
    residuals = signal_trimmed - fitted_signal;
    
    % Plot the fit over the convolved signal
    figure;
    
    % Panel 1: Convolved signal and monoexponential fit
    subplot(2, 1, 1);
    plot(t_trimmed + start_time, signal_trimmed, 'b-', 'DisplayName', 'Convolved Signal');
    hold on;
    plot(t_trimmed + start_time, fitted_signal, 'r--', 'DisplayName', 'Monoexponential Fit');
    xlabel('Time (ns)');
    ylabel('Amplitude');
    legend;
    title('Monoexponential Fit of Convolved Signal');
    hold off;
    
    % Panel 2: Residuals
    subplot(2, 1, 2);
    plot(t_trimmed + start_time, residuals, 'k-', 'DisplayName', 'Residuals');
    xlabel('Time (ns)');
    ylabel('Residual');
    title('Residuals of Monoexponential Fit');
    legend;
    
    % Display fitted parameters
    fprintf('Fitted Monoexponential Parameters:\n');
    fprintf('A = %.4f\n', A_fit);
    fprintf('Tau = %.4f ns\n', tau_fit);
end
