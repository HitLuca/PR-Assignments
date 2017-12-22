clear;

% initial data
initial_pose = [0, 0, 0];
l = 100;
d = 80;
delta_t = 1;

% variances
variance_alpha = 25;
variance_v = 50;

% samples
samples = 200;

% controls
controls = [20, 25; 20 -25; 90, 25; 10, 80; 90, 85];

% draw samples for each control
for c=1:size(controls, 1)
    figure();
    control = controls(c, :);
    plot_pose(initial_pose, l);
    
    % sample poses
    sampled_poses = sample_poses(initial_pose, control, delta_t, l, variance_alpha, variance_v, samples);
    
    % plot poses
    for i=1:samples
        plot_pose(sampled_poses(:, i), l);
    end
    pbaspect([1, 1, 1])
end


%% support functions
% generate an output pose given starting pose and control
function [new_pose] = predict_pose(initial_pose, control, delta_t, l)
    x_front = initial_pose(1);
    y_front = initial_pose(2);
    theta = initial_pose(3);
    v = control(1);
    alpha = control(2);
    
    % icr radius
    rotation_radius = l * cotd(alpha);
    
    % back wheel position
    x_back = x_front - l * cosd(theta);
    y_back = y_front - l * sind(theta);
    
    % icr position
    x_icr = x_back - rotation_radius * sind(theta);
    y_icr = y_back + rotation_radius * cosd(theta);
    
    % arc length
    distance_travelled = v * delta_t;
    
    % angle length
    angle_travelled = rad2deg(distance_travelled / abs(rotation_radius));
    
    if alpha < 0
        angle_travelled = -angle_travelled;
    end
    
    % angle from the horizontal
    beta = atan2d(y_back - y_icr, x_back - x_icr);
    angle_travelled_horizontal = beta + angle_travelled;
    
    % new back wheel position
    new_x_back = x_icr + abs(rotation_radius) * cosd(angle_travelled_horizontal);
    new_y_back = y_icr + abs(rotation_radius) * sind(angle_travelled_horizontal);
    
    % new orientation
    new_theta = theta + angle_travelled;
    
    % new front wheel position
    new_x_front = new_x_back + l * cosd(new_theta);
    new_y_front = new_y_back + l * sind(new_theta);
    
    % new final pose
    new_pose = [new_x_front, new_y_front, new_theta];
end

% draw samples given input data
function [sampled_poses] = sample_poses(initial_pose, control, delta_t, l, variance_alpha, variance_v, samples)    
    sampled_poses = zeros(3, samples);
    
    for i=1:samples
        % generate a noisy control state
        noisy_control(1) = normrnd(control(1), sqrt(variance_v * abs(control(1))));
        noisy_control(2) = normrnd(control(2), sqrt(variance_alpha));
        
        % clip the generated control
        noisy_control = check_limits(noisy_control);
        
        % predict output pose
        sampled_poses(:, i) = predict_pose(initial_pose, noisy_control, delta_t, l);
    end
end

% plot bike
function [] = plot_pose(pose, l)
    x_back = pose(1) - l * cosd(pose(3));
    y_back = pose(2) - l * sind(pose(3));
    
    plot([pose(1), x_back], [pose(2), y_back], 'blue');
    hold on;
    scatter([pose(1), x_back], [pose(2), y_back], 'black');
end

% clip a control if over thresholds
function [result] = check_limits(noisy_control)
    result = noisy_control;
    
    % angle
    if noisy_control(2) > 80
        result(2) = 80;
    elseif noisy_control(2) < -80
        result(2) = -80;
    end

    % velocity
    if noisy_control(1) < 0
        result(1) = 0;
    elseif noisy_control(1) > 100
        result(1) = 100;
    end
end