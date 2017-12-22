clear;

A = [1, 1, 0; 0, 1, 1; 0, 0, 0];
R = [0, 0, 0; 0, 0, 0; 0, 0, 1];
C = [1, 0, 0];
Q = 10;

mu_state = [0; 0; 0];
sigma_state = zeros(3, 3);
z = 5;

for i=1:5
    [new_mu, new_sigma] = predict_belief(A, R, mu_state, sigma_state);
    mu_state = new_mu;
    sigma_state = new_sigma;
    plot_gaussian_ellipsoid(mu_state(1:2), sigma_state(1:2, 1:2));
    plot(mu_state(1), mu_state(2), '.-','MarkerSize', 10);
    xlim([-4 6])
    ylim([-2 3])
end

[new_mu, new_sigma] = update_belief(mu_state, sigma_state, Q, C, 5);
mu_state = new_mu;
sigma_state = new_sigma;

% plot(mu_state(1), mu_state(2), '.-','MarkerSize', 10);
plot_gaussian_ellipsoid(mu_state(1:2), sigma_state(1:2, 1:2));
xlim([-4 6])
ylim([-2 3])
pbaspect([2, 1, 1])

function [mu_new, sigma_new] = predict_belief(A, R, mu, sigma)
    mu_new = A * mu;
    sigma_new = A * sigma * A' + R; 
end

function [mu_new, sigma_new] = update_belief(mu_predicted, sigma_predicted, Q, C, z)
    K = sigma_predicted * C' / (C * sigma_predicted * C' + Q);
    mu_new = mu_predicted + K * (z - C * mu_predicted);
    sigma_new = (eye(size(K * C)) - K * C) * sigma_predicted;
end