function [A_fit, B_fit, tau1_fit, tau2_fit] = fit_biexponential(t, convolved_signal, start_time, tau1_fixed, tau2_fixed)
    % fit_biexponential: Fits a biexponential model to a convolved signal
    % starting from a specified time, with options to fix tau1 and tau2.
    %
    % Inputs:
    % - t: Time vector for the full signal
    % - convolved_signal: Convolved biexponential signal to be fitted
    % - start_time: Time (ns) to start fitting (e.g., to fit only the second decay)
    % - tau1_fixed (optional): Fixed value for tau1 (leave empty to fit tau1)
    % - tau2_fixed (optional): Fixed value for tau2 (leave empty to fit tau2)
    %
    % Outputs:
    % - A_fit: Fitted amplitude for the first exponential component
    % - B_fit: Fitted amplitude for the second exponential component
    % - tau1_fit: Fitted or fixed decay constant for the first exponential component
    % - tau2_fit: Fitted or fixed decay constant for the second exponential component
    
    % Ensure start_time is within the time range
    if start_time < min(t) || start_time > max(t)
        error('start_time must be within the range of the time vector t.');
    end
    
    % Trim the signal and time vector to start from the specified start_time
    start_index = find(t >= start_time, 1);
    t_trimmed = t(start_index:end) - start_time; % Shift time so it starts from zero
    signal_trimmed = convolved_signal(start_index:end); % Trimmed signal starting from specified time

    % Determine initial guesses for fitting
    A_initial = .7; % Initial guess for amplitude A
    B_initial =.3;     % Initial guess for amplitude B
    tau1_initial = 1;                % Initial guess for tau1 if not fixed
    tau2_initial = 3;                % Initial guess for tau2 if not fixed

    % Set up fitting parameters based on whether tau1 and tau2 are fixed
    if isempty(tau1_fixed) && isempty(tau2_fixed)
        % Fit A, B, tau1, and tau2
        initial_guess = [A_initial, B_initial, tau1_initial, tau2_initial];
        model_fun = @(params, t) params(1) * exp(-t / params(3)) + params(2) * exp(-t / params(4));
        options = optimset('Display', 'off');
        [params_fit, ~] = lsqcurvefit(model_fun, initial_guess, t_trimmed, signal_trimmed, [], [], options);
        A_fit = params_fit(1);
        B_fit = params_fit(2);
        tau1_fit = params_fit(3);
        tau2_fit = params_fit(4);
        
    elseif isempty(tau1_fixed)
        % Fit A, B, and tau1, with tau2 fixed
        initial_guess = [A_initial, B_initial, tau1_initial];
        model_fun = @(params, t) params(1) * exp(-t / params(3)) + params(2) * exp(-t / tau2_fixed);
        options = optimset('Display', 'off');
        [params_fit, ~] = lsqcurvefit(model_fun, initial_guess, t_trimmed, signal_trimmed, [], [], options);
        A_fit = params_fit(1);
        B_fit = params_fit(2);
        tau1_fit = params_fit(3);
        tau2_fit = tau2_fixed; % Use fixed value for tau2
        
    elseif isempty(tau2_fixed)
        % Fit A, B, and tau2, with tau1 fixed
        initial_guess = [A_initial, B_initial, tau2_initial];
        model_fun = @(params, t) params(1) * exp(-t / tau1_fixed) + params(2) * exp(-t / params(3));
        options = optimset('Display', 'off');
        [params_fit, ~] = lsqcurvefit(model_fun, initial_guess, t_trimmed, signal_trimmed, [], [], options);
        A_fit = params_fit(1);
        B_fit = params_fit(2);
        tau1_fit = tau1_fixed; % Use fixed value for tau1
        tau2_fit = params_fit(3);
        
    else
        % Fit only A and B, with both tau1 and tau2 fixed
        initial_guess = [A_initial, B_initial];
        model_fun = @(params, t) params(1) * exp(-t / tau1_fixed) + params(2) * exp(-t / tau2_fixed);
        options = optimset('Display', 'off');
        [params_fit, ~] = lsqcurvefit(model_fun, initial_guess, t_trimmed, signal_trimmed, [], [], options);
        A_fit = params_fit(1);
        B_fit = params_fit(2);
        tau1_fit = tau1_fixed; % Use fixed value for tau1
        tau2_fit = tau2_fixed; % Use fixed value for tau2
    end

    % Calculate fitted signal for plotting
    fitted_signal = model_fun(params_fit, t_trimmed);
    
    % Calculate residuals
    residuals = signal_trimmed - fitted_signal;
    
    % Plot the fit over the convolved signal
    figure;
    
    % Panel 1: Convolved signal and biexponential fit
    subplot(2, 1, 1);
    plot(t_trimmed + start_time, signal_trimmed, 'b-', 'DisplayName', 'Convolved Signal');
    hold on;
    plot(t_trimmed + start_time, fitted_signal, 'r--', 'DisplayName', 'Biexponential Fit');
    xlabel('Time (ns)');
    ylabel('Amplitude');
    legend;
    title('Biexponential Fit of Convolved Signal');
    hold off;
    
    % Panel 2: Residuals
    subplot(2, 1, 2);
    plot(t_trimmed + start_time, residuals, 'k-', 'DisplayName', 'Residuals');
    xlabel('Time (ns)');
    ylabel('Residual');
    title('Residuals of Biexponential Fit');
    legend;
    
    % Display fitted parameters
    fprintf('Fitted Biexponential Parameters:\n');
    fprintf('A = %.4f\n', A_fit);
    fprintf('B = %.4f\n', B_fit);
    fprintf('Tau1 = %.4f ns\n', tau1_fit);
    fprintf('Tau2 = %.4f ns\n', tau2_fit);
end
