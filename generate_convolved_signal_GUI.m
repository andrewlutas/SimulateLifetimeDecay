function generate_convolved_signal_GUI
    % GUI to generate and plot a convolved biexponential signal with IRF,
    % and provide options for first moment, monoexponential, or biexponential fitting.

    % Create the figure
    hFig = figure('Name', 'Generate Convolved Signal', 'NumberTitle', 'off', 'Position', [100, 100, 800, 500]);

    % Create UI controls for input parameters
    uicontrol('Style', 'text', 'Position', [20, 440, 100, 20], 'String', 'Amplitude A1:');
    hA1 = uicontrol('Style', 'edit', 'Position', [120, 440, 100, 20], 'String', '0.7');

    uicontrol('Style', 'text', 'Position', [20, 410, 100, 20], 'String', 'Amplitude B1:');
    hB1 = uicontrol('Style', 'edit', 'Position', [120, 410, 100, 20], 'String', '0.3');

    uicontrol('Style', 'text', 'Position', [20, 380, 100, 20], 'String', 'Tau 1 (ns):');
    hTau1 = uicontrol('Style', 'edit', 'Position', [120, 380, 100, 20], 'String', '1');

    uicontrol('Style', 'text', 'Position', [20, 350, 100, 20], 'String', 'Tau 2 (ns):');
    hTau2 = uicontrol('Style', 'edit', 'Position', [120, 350, 100, 20], 'String', '3');

    uicontrol('Style', 'text', 'Position', [20, 320, 100, 20], 'String', 'IRF Sigma:');
    hSigma = uicontrol('Style', 'edit', 'Position', [120, 320, 100, 20], 'String', '0.1');

    uicontrol('Style', 'text', 'Position', [20, 290, 100, 20], 'String', 'Num Bins:');
    hNumBins = uicontrol('Style', 'edit', 'Position', [120, 290, 100, 20], 'String', '1024');

    uicontrol('Style', 'text', 'Position', [20, 260, 100, 20], 'String', 'Time Range:');
    hTimeRange = uicontrol('Style', 'edit', 'Position', [120, 260, 100, 20], 'String', '[-4, 25]');

    uicontrol('Style', 'text', 'Position', [20, 230, 100, 20], 'String', 'Start Shift (ns):');
    hStartShift = uicontrol('Style', 'edit', 'Position', [120, 230, 100, 20], 'String', '12.5');

    % Dropdown menu to select the type of analysis
    uicontrol('Style', 'text', 'Position', [20, 200, 100, 20], 'String', 'Fit Type:');
    hFitType = uicontrol('Style', 'popupmenu', 'Position', [120, 200, 100, 20], ...
                         'String', {'First Moment', 'Monoexponential', 'Biexponential'});

    % Additional inputs for fitting parameters
    uicontrol('Style', 'text', 'Position', [20, 170, 100, 20], 'String', 'A Fit (Monoexp):');
    hAfit = uicontrol('Style', 'edit', 'Position', [120, 170, 100, 20], 'String', '', 'TooltipString', 'Optional fixed amplitude for monoexponential fit');

    uicontrol('Style', 'text', 'Position', [20, 140, 100, 20], 'String', 'Tau 1 Fixed (Biexp):');
    hTau1Fixed = uicontrol('Style', 'edit', 'Position', [120, 140, 100, 20], 'String', '', 'TooltipString', 'Optional fixed tau1 for biexponential fit');

    uicontrol('Style', 'text', 'Position', [20, 110, 100, 20], 'String', 'Tau 2 Fixed (Biexp):');
    hTau2Fixed = uicontrol('Style', 'edit', 'Position', [120, 110, 100, 20], 'String', '', 'TooltipString', 'Optional fixed tau2 for biexponential fit');

    % Button to generate and plot the signal
    uicontrol('Style', 'pushbutton', 'Position', [250, 70, 150, 40], 'String', 'Generate and Analyze', 'Callback', @generateAndAnalyze);

    % Axes for plotting
    hAxes = axes('Parent', hFig, 'Position', [0.4, 0.2, 0.55, 0.7]);

    % Callback function for the "Generate and Analyze" button
    function generateAndAnalyze(~, ~)
        % Get user inputs
        A1 = str2double(get(hA1, 'String'));
        B1 = str2double(get(hB1, 'String'));
        tau1 = str2double(get(hTau1, 'String'));
        tau2 = str2double(get(hTau2, 'String'));
        sigma = str2double(get(hSigma, 'String'));
        num_bins = str2double(get(hNumBins, 'String'));
        time_range = str2num(get(hTimeRange, 'String')); %#ok<ST2NM>
        start_time_shift = str2double(get(hStartShift, 'String'));
        fit_type = get(hFitType, 'Value');

        % Optional parameters
        A_fixed = str2double(get(hAfit, 'String'));
        tau1_fixed = str2double(get(hTau1Fixed, 'String'));
        tau2_fixed = str2double(get(hTau2Fixed, 'String'));

        % Generate the time vector and convolved signal
        [t, convolved_signal] = generate_convolved_signal(A1, B1, tau1, tau2, sigma, num_bins, time_range, start_time_shift);

        % Plot the generated signal
        cla(hAxes);
        plot(hAxes, t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
        hold(hAxes, 'on');
        xlabel(hAxes, 'Time (ns)');
        ylabel(hAxes, 'Amplitude');
        title(hAxes, 'Generated Signal and Fitting Analysis');
        
        % Perform the selected analysis
        start_time = start_time_shift;
        t_fit = t(t >= start_time); % Time vector starting from the fit start time
        
        switch fit_type
            case 1 % First Moment
                M = calculate_first_moment(t, convolved_signal, start_time);
                legend(hAxes, 'Convolved Signal');
                fprintf('First Moment (Average Time) of Decay Signal from %.2f ns: %.4f ns\n', start_time, M);
                text(0.6, 0.8, sprintf('First Moment: %.4f ns', M), 'Units', 'normalized', 'Parent', hAxes);

            case 2 % Monoexponential Fit
                if isnan(A_fixed)
                    [A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time);
                else
                    [A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time, A_fixed);
                end
                monoexp_fit = A_fit * exp(-(t_fit - start_time) / tau_fit); % Monoexponential fit curve
                plot(hAxes, t_fit, monoexp_fit, 'r--', 'DisplayName', 'Monoexponential Fit');
                legend(hAxes, 'Convolved Signal', 'Monoexponential Fit');
                fprintf('Monoexponential Fit Parameters:\nA = %.4f\nTau = %.4f ns\n', A_fit, tau_fit);

            case 3 % Biexponential Fit
                if isnan(tau1_fixed), tau1_fixed = []; end
                if isnan(tau2_fixed), tau2_fixed = []; end
                [A_fit, B_fit, tau1_fit, tau2_fit] = fit_biexponential(t, convolved_signal, start_time, tau1_fixed, tau2_fixed);
                biexp_fit = A_fit * exp(-(t_fit - start_time) / tau1_fit) + B_fit * exp(-(t_fit - start_time) / tau2_fit); % Biexponential fit curve
                plot(hAxes, t_fit, biexp_fit, 'g--', 'DisplayName', 'Biexponential Fit');
                legend(hAxes, 'Convolved Signal', 'Biexponential Fit');
                fprintf('Biexponential Fit Parameters:\nA = %.4f\nB = %.4f\nTau1 = %.4f ns\nTau2 = %.4f ns\n', A_fit, B_fit, tau1_fit, tau2_fit);
        end
        hold(hAxes, 'off');
    end
end

% Ensure `generate_convolved_signal`, `calculate_first_moment`, `fit_monoexponential`, and `fit_biexponential`
% functions are accessible in the same file or as separate function files in the MATLAB path.
