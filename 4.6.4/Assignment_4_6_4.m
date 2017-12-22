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
axis = -4:0.5:4;
dimension = size(axis, 2);
M = 10000; % number of particles
steps = 5;

% particles initialization
X_hat = zeros(3, M, steps);
X = zeros(2, M);
plot_particles(X_hat(1:2, :, 1));

for t=2:steps
    for i=1:M
        % sample a particle and add it
        sampled_state = mvnrnd(A * X_hat(1:2, i, t-1),R)';
        X_hat(1:2, i, t) = sampled_state;
    end
    plot_particles(X_hat(:, :, t));
end

% weight each particle at t=5
for i=1:M
    X_hat(3, i, steps) = measurement_probability(C, Q, X_hat(1:2, i, steps), measurement);
end
    
% sampling of the new particles
total_weights = sum(X_hat(3, :, steps));
for m=1:M
    random_weight = rand * total_weights;
    index = 1;
    while random_weight > 0
        random_weight = random_weight - X_hat(3, index, steps);
        index = index + 1;
    end
    index = index - 1;
    X = [X, X_hat(1:2, index, steps)];
end

plot_particles(X(:, :));


%% support functions
function [] = plot_particles(particles)
    figure();
    plot(particles(1, :), particles(2, :), '.','MarkerSize', 1);
    xlim([-10 10])
    ylim([-10 10])
    pbaspect([1, 1, 1])
    drawnow;
end