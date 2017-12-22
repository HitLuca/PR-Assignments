clear;

A = [1, 1, 0; 0, 1, 1; 0, 0, 0];
R = [0, 0, 0; 0, 0, 0; 0, 0, 1];

mu_state = [0; 0; 0];
sigma_state = zeros(3, 3);

for i=1:5
    [new_mu, new_sigma] = predict_belief(A, R, mu_state, sigma_state);
    mu_state = new_mu;
    sigma_state = new_sigma;
    plot_gaussian_ellipsoid(mu_state(1:2), sigma_state(1:2, 1:2));
    plot(mu_state(1), mu_state(2), '.-','MarkerSize', 10);
end

function [mu_new, sigma_new] = predict_belief(A, R, mu, sigma)
    mu_new = A * mu;
    sigma_new = A * sigma * A' + R; 
end