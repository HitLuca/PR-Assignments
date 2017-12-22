clear;
transitions = [
    0.8, 0.2, 0.0;
    0.4, 0.4, 0.2;
    0.2, 0.6, 0.2];

labels = ["sunny", "cloudy", "rainy"];
epsilon = 0.00001;

states_number = size(transitions, 2);

history = [];
stationary_distribution = ones(1, states_number) / states_number;
state = randi([1, states_number]);

loop = true;

while loop
    history = [history, state];
    probabilities = transitions(state, :);
    p = rand;
    result_index = 1;
    tot = probabilities(result_index);
    while tot < p
        result_index = result_index + 1;
        tot = tot + probabilities(result_index);
    end
    state = result_index;
    
    new_distribution = zeros(1, states_number);
    for j=1:states_number
        new_distribution(j) = sum(history == j) / size(history, 2);
    end
    
    stationary_distribution = [stationary_distribution; new_distribution];
    if all(new_distribution - stationary_distribution(end-1, :) < epsilon)
        loop = false;
    end
end

% plot of random weather generation
% figure();
% plot(history);

% plot of probability distribution of weathers over time
figure();
plot(stationary_distribution);
legend(labels);

% stationary distribution
stationary_distribution(end, :)

% entropy of the stationary distribution
entropy = 0;
for i=1:states_number
    for j=1:states_number
        if transitions(i, j) ~= 0
            entropy = entropy - stationary_distribution(end, i) * transitions(i, j) * log(transitions(i, j));
        end
    end
end
entropy