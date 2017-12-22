clear;

initial_pose = [0, 0, 0];
l = 100;
d = 80;
delta_t = 5;
control = [90, -25];
assert(abs(control(2)) <= 80)

variance_alpha = 25;
variance_v = 50;

predict_pose(initial_pose, control, delta_t, l, d);

%% support functions
function [new_pose] = predict_pose(initial_pose, control, delta_t, l, d)
    x_front = initial_pose(1);
    y_front = initial_pose(2);
    theta = initial_pose(3);
    v = control(1);
    alpha = control(2);
    
    rotation_radius = l * cotd(alpha);
    
    x_back = x_front - l * cosd(theta);
    y_back = y_front - l * sind(theta);
    
    x_icr = x_back - rotation_radius * sind(theta);
    y_icr = y_back + rotation_radius * cosd(theta);
    
    distance_travelled = v * delta_t;
    angle_travelled = rad2deg(distance_travelled / abs(rotation_radius));
    
    if alpha < 0
        angle_travelled = -angle_travelled;
    end
    
    beta = rad2deg(atan2(y_back - y_icr, x_back - x_icr));
    angle_travelled_horizontal = beta + angle_travelled;
    
    new_x_back = x_icr + abs(rotation_radius) * cosd(angle_travelled_horizontal);
    new_y_back = y_icr + abs(rotation_radius) * sind(angle_travelled_horizontal);
    
    new_theta = theta + angle_travelled;
    
    new_x_front = new_x_back + l * cosd(new_theta);
    new_y_front = new_y_back + l * sind(new_theta);
    
    new_pose = [new_x_front, new_y_front, new_theta];
    
    plot_pose(initial_pose, l);
    plot_pose(new_pose, l);
    plot_turning_circle([x_icr, y_icr], abs(rotation_radius));
    
    pbaspect([1, 1, 1])
    xlim([-500 500])
    ylim([-500 500])
end

function [] = plot_pose(pose, l)
    x_back = pose(1) - l * cosd(pose(3));
    y_back = pose(2) - l * sind(pose(3));
    
    plot([pose(1), x_back], [pose(2), y_back]);
    hold on;
    scatter([pose(1), x_back], [pose(2), y_back]);
end

function [] = plot_turning_circle(center, radius)
    scatter(center(1), center(2));
    hold on;
    th = 0:pi/50:2*pi;
    xunit = abs(radius) * cos(th) + center(1);
    yunit = abs(radius) * sin(th) + center(2);
    h = plot(xunit, yunit);
end