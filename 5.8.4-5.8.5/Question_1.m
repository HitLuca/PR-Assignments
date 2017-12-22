clear;
% question a)

% initial pose
initial_pose = [0; 0; 0];

% measurements
measurement1 = [10; 3; 10];
measurement2 = [-20; 10; -10];

pose_1 = calculate_true_position(initial_pose, measurement1)
pose_2 = calculate_true_position(pose_1, measurement2)

% question b)
% movement errors
errors = [5; 0.5; 10];

% calculate all possible errors combinations
combined_errors = calculate_errors_combinations(errors);
combinations_number = size(combined_errors, 2);

new_poses1 = zeros(3, combinations_number);
% try every combination
for i=1:combinations_number
    new_poses1(:, i) = calculate_true_position(initial_pose, measurement1 + combined_errors(:, i));
end

% plot all the calculated poses
figure();
plot_pose(initial_pose);

for i=1:size(new_poses1, 2)
    plot_pose(new_poses1(:, i));
end

xlim([-1, 5])
ylim([-1, 2])

% question c)
new_poses2 = zeros(3, combinations_number * combinations_number);
for p=1:combinations_number
    for i=1:combinations_number
        new_poses2(:, (p-1)*combinations_number + i) = calculate_true_position(new_poses1(:, p), measurement2 + combined_errors(:, i));
    end
end

% plot the old poses
figure();
plot_pose(initial_pose);
for i=1:size(new_poses1, 2)
    plot_pose(new_poses1(:, i));
end

% plot the new poses
for i=1:size(new_poses2, 2)
    plot_pose(new_poses2(:, i));
end

xlim([-2, 20])
ylim([-5, 5])


%% support functions
% calculate the true robot's position given a pose and a measurement (5.40)
function [new_pose] = calculate_true_position(initial_pose, measurement)
    x = initial_pose(1) + measurement(2) * cosd(initial_pose(3) + measurement(1));
    y = initial_pose(2) + measurement(2) * sind(initial_pose(3) + measurement(1));
    theta = initial_pose(3) + measurement(1) + measurement(3);
    new_pose = [x; y; theta];
end

% generate all possible combinations of errors
function [combined_errors] = calculate_errors_combinations(errors)
    combinations = dec2bin(0:2^3-1);
    
    combined_errors = repmat(errors, 1, size(combinations, 1));
    for i=1:size(combinations, 1)
        for j=1:3
            if combinations(i, j) == '0'
                combined_errors(j, i) = -combined_errors(j, i);
            end
        end
    end
end

% plot a robot pose
function [] = plot_pose(pose)
    plot(pose(1), pose(2), '.', 'MarkerSize', 10);
    line([pose(1), pose(1) + cosd(pose(3))], [pose(2), pose(2) + sind(pose(3))]);
    hold on;
end