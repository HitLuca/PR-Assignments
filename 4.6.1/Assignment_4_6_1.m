clear;

% probabilities
transition_probability = @(A, R, past_state, state) (det(2*pi*R)^-0.5) * exp(-0.5 * (state - A * past_state)' / R * (state - A * past_state));
measurement_probability = @(C, Q, state, measurement) (det(2*pi*Q)^-0.5) * exp(-0.5 * (measurement - C * state)' / Q * (measurement - C * state));

% matrices
A = [1, 1; 0, 1];
R = [1e-6, 0; 0, 1];
C = [1, 0];
Q = 10;

% parameters
measurement = 5;
steps = 5;
axis = -4:0.5:4;
dimension = size(axis, 2);
assert(mod(dimension, 2) ~= 0);

% first histogram
histogram = zeros(dimension, dimension);
histogram((dimension-1)/2 + 1, (dimension-1)/2 + 1) = 1.0;

% history
frames = zeros(dimension, dimension, steps + 1);
frames(:, :, 1) = histogram;

plot_histogram(frames(:, :, 1), axis);

% prediction steps
for t=2:steps
    for i=1:dimension
        for j=1:dimension
            state_k = [axis(i); axis(j)];
            frames(i, j, t) = predict_belief_histogram(A, R, frames(:, :, t-1), axis, state_k, transition_probability);
        end
    end
    
    % normalization of the histogram
    frames(:, :, t) = frames(:, :, t) / sum(sum(frames(:, :, t)));
    
    plot_histogram(frames(:, :, t)', axis);
end

t = steps+1;

% update step
for i=1:dimension
    for j=1:dimension
        state_k = [axis(i); axis(j)];
        frames(i, j, t) = update_belief_histogram(C, Q, state_k, measurement, frames(i, j, t-1), measurement_probability);
    end
end

% normalization of the histogram
frames(:, :, t) = frames(:, :, t) / sum(sum(frames(:, :, t)));

plot_histogram(frames(:, :, t)', axis);


%% support functions
function [] = plot_histogram(histogram, axis)
    figure()
    imagesc(axis, axis, histogram); 
    set(gca,'YDir','normal')
    colormap jet;
    pbaspect([1, 1, 1])
    drawnow;
end

function [result] = predict_belief_histogram(A, R, histogram, axis, state_k, transition_probability)
    dimension = size(axis, 2);

    total = 0;
    
    % for each past histogram cell
    for i=1:dimension
        for j=1:dimension
            past_state = [axis(i); axis(j)];
            % add the weighted transition probability
            total = total + transition_probability(A, R, past_state, state_k) * histogram(i, j);
        end
    end
    result = total;
end

function [result] = update_belief_histogram(C, Q, state, measurement, state_probability, measurement_probability)
    result = measurement_probability(C, Q, state, measurement) * state_probability;
end