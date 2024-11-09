function M = calculate_first_moment(t, decay_signal, start_time)
    % calculate_first_moment: Calculates the first moment of a decay signal
    % starting from a specified time.
    %
    % Inputs:
    % - t: Time vector corresponding to the decay signal
    % - decay_signal: Amplitude values of the decay signal
    % - start_time: Time (ns) to start calculating the first moment
    %
    % Output:
    % - M: First moment of the decay signal (average time) starting from start_time
    
    % Ensure the time and decay_signal vectors are the same length
    if length(t) ~= length(decay_signal)
        error('Time vector and decay signal must be the same length.');
    end

    % Find the index corresponding to the start time
    start_index = find(t >= start_time, 1);
    if isempty(start_index)
        error('start_time must be within the range of the time vector t.');
    end

    % Trim the time and decay_signal vectors to start from the specified start_time
    t_trimmed = t(start_index:end) - start_time; % Shift time so it starts from zero
    signal_trimmed = decay_signal(start_index:end); % Trimmed signal starting from specified time

    % Calculate the weighted time (t * signal_trimmed) and total area (sum of signal_trimmed)
    weighted_time = t_trimmed .* signal_trimmed;
    total_area = sum(signal_trimmed); % Integral approximation by summing over all points

    % Calculate the first moment
    M = sum(weighted_time) / total_area;
    
    % Display the result
    fprintf('First Moment (Average Time) of Decay Signal from %.2f ns: %.4f ns\n', start_time, M);
end
