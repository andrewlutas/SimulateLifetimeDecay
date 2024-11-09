function generate_convolved_signal_GUI
    % Main GUI to generate and analyze a convolved biexponential signal with IRF.

    % Create the figure
    hFig = figure('Name', 'Generate Convolved Signal', 'NumberTitle', 'off', 'Position', [100, 100, 800, 500]);

    % Create UI controls for input parameters using a helper function
    hParams = createInputFields(hFig);

    % Dropdown menu to select the type of analysis
    uicontrol('Style', 'text', 'Position', [20, 200, 100, 20], 'String', 'Fit Type:');
    hParams.FitType = uicontrol('Style', 'popupmenu', 'Position', [120, 200, 100, 20], ...
                         'String', {'First Moment', 'Monoexponential', 'Biexponential'});

    % Button to generate and plot the signal
    uicontrol('Style', 'pushbutton', 'Position', [250, 70, 150, 40], 'String', 'Generate and Analyze', 'Callback', @generateAndAnalyze);

    % Axes for plotting
    hAxes = axes('Parent', hFig, 'Position', [0.4, 0.2, 0.55, 0.7]);

    % Callback function for the "Generate and Analyze" button
    function generateAndAnalyze(~, ~)
        % Get user inputs
        params = getUserInputs(hParams);
        
        % Generate the time vector and convolved signal
        [t, convolved_signal] = generate_convolved_signal(params.A1, params.B1, params.tau1, params.tau2, ...
                                                          params.sigma, params.num_bins, params.time_range, params.start_time_shift);

        % Plot the generated signal
        cla(hAxes);
        plot(hAxes, t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
        hold(hAxes, 'on');
        xlabel(hAxes, 'Time (ns)');
        ylabel(hAxes, 'Amplitude');
        title(hAxes, 'Generated Signal and Fitting Analysis');
        
        % Perform the selected analysis
        performAnalysis(hAxes, t, convolved_signal, params); 
        hold(hAxes, 'off');
    end
end

% --- Helper Function to Create Input Fields ---
function hParams = createInputFields(hFig)
    % Creates and returns UI controls for input parameters.
    hParams.A1 = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 440, 100, 20], 'String', '0.7', 'TooltipString', 'Amplitude A1');
    hParams.B1 = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 410, 100, 20], 'String', '0.3', 'TooltipString', 'Amplitude B1');
    hParams.tau1 = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 380, 100, 20], 'String', '1', 'TooltipString', 'Tau 1 (ns)');
    hParams.tau2 = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 350, 100, 20], 'String', '3', 'TooltipString', 'Tau 2 (ns)');
    hParams.sigma = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 320, 100, 20], 'String', '0.1', 'TooltipString', 'IRF Sigma');
    hParams.num_bins = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 290, 100, 20], 'String', '1024', 'TooltipString', 'Num Bins');
    hParams.time_range = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 260, 100, 20], 'String', '[-4, 25]', 'TooltipString', 'Time Range');
    hParams.start_time_shift = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 230, 100, 20], 'String', '12.5', 'TooltipString', 'Start Shift (ns)');
    
    % Additional inputs for fitting parameters
    hParams.Afit = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 170, 100, 20], 'String', '', 'TooltipString', 'Optional fixed amplitude for monoexponential fit');
    hParams.Tau1Fixed = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 140, 100, 20], 'String', '', 'TooltipString', 'Optional fixed tau1 for biexponential fit');
    hParams.Tau2Fixed = uicontrol(hFig, 'Style', 'edit', 'Position', [120, 110, 100, 20], 'String', '', 'TooltipString', 'Optional fixed tau2 for biexponential fit');
end

% --- Helper Function to Retrieve Input Values from Fields ---
function params = getUserInputs(hParams)
    % Retrieves values from input fields and returns them as a structure.
    params.A1 = str2double(get(hParams.A1, 'String'));
    params.B1 = str2double(get(hParams.B1, 'String'));
    params.tau1 = str2double(get(hParams.tau1, 'String'));
    params.tau2 = str2double(get(hParams.tau2, 'String'));
    params.sigma = str2double(get(hParams.sigma, 'String'));
    params.num_bins = str2double(get(hParams.num_bins, 'String'));
    params.time_range = str2num(get(hParams.time_range, 'String')); %#ok<ST2NM>
    params.start_time_shift = str2double(get(hParams.start_time_shift, 'String'));
    params.FitType = get(hParams.FitType, 'Value');
    params.A_fixed = str2double(get(hParams.Afit, 'String'));
    params.tau1_fixed = str2double(get(hParams.Tau1Fixed, 'String'));
    params.tau2_fixed = str2double(get(hParams.Tau2Fixed, 'String'));
end

% --- Helper Function to Perform Analysis and Plot Results ---
function performAnalysis(hAxes, t, convolved_signal, params)
    % Performs the selected analysis type and plots the results.

    start_time = params.start_time_shift;
    t_fit = t(t >= start_time);

    switch params.FitType
        case 1 % First Moment
            M = calculate_first_moment(t, convolved_signal, start_time);
            legend(hAxes, 'Convolved Signal');
            fprintf('First Moment (Average Time) of Decay Signal from %.2f ns: %.4f ns\n', start_time, M);
            text(0.6, 0.8, sprintf('First Moment: %.4f ns', M), 'Units', 'normalized', 'Parent', hAxes);

        case 2 % Monoexponential Fit
            if isnan(params.A_fixed)
                [A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time);
            else
                [A_fit, tau_fit] = fit_monoexponential(t, convolved_signal, start_time, params.A_fixed);
            end
            monoexp_fit = A_fit * exp(-(t_fit - start_time) / tau_fit);
            plot(hAxes, t_fit, monoexp_fit, 'r--', 'DisplayName', 'Monoexponential Fit');
            legend(hAxes, 'Convolved Signal', 'Monoexponential Fit');
            fprintf('Monoexponential Fit Parameters:\nA = %.4f\nTau = %.4f ns\n', A_fit, tau_fit);

        case 3 % Biexponential Fit
            if isnan(params.tau1_fixed), tau1_fixed = []; else, tau1_fixed = params.tau1_fixed; end
            if isnan(params.tau2_fixed), tau2_fixed = []; else, tau2_fixed = params.tau2_fixed; end
            [A_fit, B_fit, tau1_fit, tau2_fit] = fit_biexponential(t, convolved_signal, start_time, tau1_fixed, tau2_fixed);
            biexp_fit = A_fit * exp(-(t_fit - start_time) / tau1_fit) + B_fit * exp(-(t_fit - start_time) / tau2_fit);
            plot(hAxes, t_fit, biexp_fit, 'g--', 'DisplayName', 'Biexponential Fit');
            legend(hAxes, 'Convolved Signal', 'Biexponential Fit');
            fprintf('Biexponential Fit Parameters:\nA = %.4f\nB = %.4f\nTau1 = %.4f ns\nTau2 = %.4f ns\n', A_fit, B_fit, tau1_fit, tau2_fit);
    end
end
