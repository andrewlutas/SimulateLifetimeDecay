function generate_convolved_signal_GUI
    % GUI to generate and plot a convolved biexponential signal with IRF.

    % Create the figure
    hFig = figure('Name', 'Generate Convolved Signal', 'NumberTitle', 'off', 'Position', [100, 100, 600, 400]);

    % Create UI controls for input parameters
    uicontrol('Style', 'text', 'Position', [20, 350, 100, 20], 'String', 'Amplitude A1:');
    hA1 = uicontrol('Style', 'edit', 'Position', [120, 350, 100, 20], 'String', '0.7');

    uicontrol('Style', 'text', 'Position', [20, 320, 100, 20], 'String', 'Amplitude B1:');
    hB1 = uicontrol('Style', 'edit', 'Position', [120, 320, 100, 20], 'String', '0.3');

    uicontrol('Style', 'text', 'Position', [20, 290, 100, 20], 'String', 'Tau 1 (ns):');
    hTau1 = uicontrol('Style', 'edit', 'Position', [120, 290, 100, 20], 'String', '1');

    uicontrol('Style', 'text', 'Position', [20, 260, 100, 20], 'String', 'Tau 2 (ns):');
    hTau2 = uicontrol('Style', 'edit', 'Position', [120, 260, 100, 20], 'String', '3');

    uicontrol('Style', 'text', 'Position', [20, 230, 100, 20], 'String', 'IRF Sigma:');
    hSigma = uicontrol('Style', 'edit', 'Position', [120, 230, 100, 20], 'String', '0.1');

    uicontrol('Style', 'text', 'Position', [20, 200, 100, 20], 'String', 'Num Bins:');
    hNumBins = uicontrol('Style', 'edit', 'Position', [120, 200, 100, 20], 'String', '1024');

    uicontrol('Style', 'text', 'Position', [20, 170, 100, 20], 'String', 'Time Range:');
    hTimeRange = uicontrol('Style', 'edit', 'Position', [120, 170, 100, 20], 'String', '[-4, 25]');

    uicontrol('Style', 'text', 'Position', [20, 140, 100, 20], 'String', 'Start Shift (ns):');
    hStartShift = uicontrol('Style', 'edit', 'Position', [120, 140, 100, 20], 'String', '12.5');

    % Button to generate and plot the signal
    uicontrol('Style', 'pushbutton', 'Position', [250, 90, 120, 40], 'String', 'Generate Signal', 'Callback', @generateSignal);

    % Axes for plotting
    hAxes = axes('Parent', hFig, 'Position', [0.4, 0.2, 0.55, 0.7]);

    % Callback function for the "Generate Signal" button
    function generateSignal(~, ~)
        % Get user inputs
        A1 = str2double(get(hA1, 'String'));
        B1 = str2double(get(hB1, 'String'));
        tau1 = str2double(get(hTau1, 'String'));
        tau2 = str2double(get(hTau2, 'String'));
        sigma = str2double(get(hSigma, 'String'));
        num_bins = str2double(get(hNumBins, 'String'));
        time_range = str2num(get(hTimeRange, 'String')); %#ok<ST2NM>
        start_time_shift = str2double(get(hStartShift, 'String'));

        % Generate the time vector
        t = linspace(time_range(1), time_range(2), num_bins);
        dt = t(2) - t(1);

        % Define the first biexponential decay function
        f1 = A1 * exp(-t / tau1) + B1 * exp(-t / tau2);
        f1(t < 0) = 0;

        % Define the IRF centered at zero
        irf = exp(-t.^2 / (2 * sigma^2)) / (sigma * sqrt(2 * pi));

        % Perform convolution for the first decay
        g_full1 = conv(f1, irf, 'full');

        % Trim the convolution result to match the length of t
        t_conv = (0:length(g_full1) - 1) * dt + t(1);
        trim_start1 = find(t_conv >= 0, 1);
        g1 = g_full1(trim_start1:trim_start1 + num_bins - 1);

        % Define the second biexponential decay starting at start_time_shift
        f2 = zeros(size(t));
        f2(t >= start_time_shift) = A1 * exp(-(t(t >= start_time_shift) - start_time_shift) / tau1) + ...
                                    B1 * exp(-(t(t >= start_time_shift) - start_time_shift) / tau2);

        % Perform convolution for the second decay
        g_full2 = conv(f2, irf, 'full');
        g2 = g_full2(trim_start1:trim_start1 + num_bins - 1);

        % Sum the two convolved signals
        convolved_signal = g1 + g2;
        convolved_signal = convolved_signal / max(convolved_signal);

        % Plot the results
        cla(hAxes);
        plot(hAxes, t, convolved_signal, 'b-', 'DisplayName', 'Convolved Signal');
        hold(hAxes, 'on');
        plot(hAxes, t, f1, 'k:', 'DisplayName', 'Underlying Biexponential 1 (Unconvolved)');
        plot(hAxes, t, f2, 'r:', 'DisplayName', 'Underlying Biexponential 2 (Unconvolved)');
        xlabel(hAxes, 'Time (ns)');
        ylabel(hAxes, 'Amplitude');
        title(hAxes, 'Convolved Biexponential Signal with IRF and Underlying Biexponential Functions');
        legend(hAxes);
        hold(hAxes, 'off');
    end
end
