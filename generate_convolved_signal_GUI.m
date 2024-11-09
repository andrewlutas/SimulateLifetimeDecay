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

    % Radio button for toggling log scale on the y-axis
    uicontrol('Style', 'text', 'Position', [20, 80, 100, 20], 'String', 'Log Y-Axis:');
    hParams.LogScale = uicontrol('Style', 'radiobutton', 'Position', [120, 80, 20, 20], ...
                                 'TooltipString', 'Toggle logarithmic scaling on the y-axis');

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

        % Check if log scale is selected and add a small offset if true
        if get(hParams.LogScale, 'Value') == 1
            y_offset = 1e-3; % Small positive offset to avoid log(0)
            convolved_signal = convolved_signal + y_offset;
        end

        % Plot the generated signal
        cla(hAxes);
        plot(hAxes, t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
        hold(hAxes, 'on');
        xlabel(hAxes, 'Time (ns)');
        ylabel(hAxes, 'Amplitude');
        title(hAxes, 'Generated Signal and Fitting Analysis');

        % Apply logarithmic y-axis if selected
        if get(hParams.LogScale, 'Value') == 1
            set(hAxes, 'YScale', 'log');
        else
            set(hAxes, 'YScale', 'linear');
        end

        % Perform the selected analysis
        performAnalysis(hAxes, t, convolved_signal, params);
        hold(hAxes, 'off');
    end

end

% --- Helper Function to Create Input Fields with Labels ---
function hParams = createInputFields(hFig)
    % Creates UI controls with labels for input parameters and returns the handles.

    % Define labels and positions
    labels = {'Amplitude A1:', 'Amplitude B1:', 'Tau 1 (ns):', 'Tau 2 (ns):', ...
              'IRF Sigma:', 'Num Bins:', 'Time Range:', 'Start Shift (ns):', ...
              'A Fit (Monoexp):', 'Tau 1 Fixed (Biexp):', 'Tau 2 Fixed (Biexp):'};
    positions = [20, 440; 20, 410; 20, 380; 20, 350; 20, 320; 20, 290; 20, 260; ...
                 20, 230; 20, 170; 20, 140; 20, 110];

    % Create labels and corresponding input fields
    hParams = struct();
    fields = {'A1', 'B1', 'tau1', 'tau2', 'sigma', 'num_bins', 'time_range', ...
              'start_time_shift', 'Afit', 'Tau1Fixed', 'Tau2Fixed'};
    defaultValues = {'0.2', '0.8', '.7', '2.1', '0.1', '1024', '[-4, 25]', '12.5', '', '', ''};
    tooltips = {'Amplitude A1', 'Amplitude B1', 'Decay constant Tau 1', 'Decay constant Tau 2', ...
                'Standard deviation of IRF', 'Number of bins in the time vector', ...
                'Time range as [t_min, t_max]', 'Start time shift for second decay', ...
                'Fixed amplitude for monoexponential fit', ...
                'Fixed tau1 for biexponential fit', 'Fixed tau2 for biexponential fit'};

    for i = 1:length(fields)
        % Create label
        uicontrol(hFig, 'Style', 'text', 'Position', [positions(i, 1), positions(i, 2), 100, 20], ...
                  'String', labels{i}, 'HorizontalAlignment', 'left');

        % Create input field
        hParams.(fields{i}) = uicontrol(hFig, 'Style', 'edit', 'Position', [positions(i, 1) + 100, positions(i, 2), 100, 20], ...
                                        'String', defaultValues{i}, 'TooltipString', tooltips{i});
    end
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
