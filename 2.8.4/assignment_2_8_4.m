clear;
% input data
x_mean = 1000;
x_var = 900;
z_mean = 1100;
z_var = 100;

x_z_mean = z_var / (z_var + x_var)*x_mean + x_var / (z_var + x_var) * z_mean; % 1090
x_z_var = 1 / (1/x_var + 1/z_var); % 90
x = 900:1:1150;

% distributions
px = @(x) 1/sqrt(2*pi*x_var)*exp((-0.5*(x-x_mean).^2)/x_var);
pz_x = @(x) 1/sqrt(2*pi*z_var)*exp((-0.5*(x-z_mean).^2)/z_var);
px_z = @(x) 1/sqrt(2*pi*x_z_var)*exp((-0.5*(x - x_z_mean).^2)/x_z_var);
pz = @(x, z) 1/(sqrt(2*pi*z_var)*sqrt(2 * pi * x_var)) * exp((-0.5*(z - x).^2)/z_var +(-0.5 * (x - x_mean).^2)/x_var);

figure();
ax=axes;
plot(x, px(x), 'LineWidth', 1);
hold on;
plot(x, pz_x(x), 'LineWidth', 1);
plot(x, px_z(x), 'LineWidth', 1.5);
line([z_mean z_mean],get(ax,'YLim'), 'Color', 'Red', 'LineStyle', '--');
legend("p(x)", "p(z|x)", "p(x|z)", 'Location','NorthWest');

