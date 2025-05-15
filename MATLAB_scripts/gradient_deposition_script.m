clear, clc, close all

% Grid and Movement Setup
nx = 100; ny = 100;
grid_size = [nx, ny]; % Size of the grid
grid = zeros(grid_size); % 0 for empty, 1 for gas A, 2 for gas B, 3 for solid A, 4 for solid B
%grid(end, :) = 4*ones(1,ny); % uncomment for solid B substrate
moved = zeros(grid_size); % 0 means not moved, 1 means moved

% Probabilities used as equivelent to Sticking coeff and Partial Pressure
probA = 0.1; % Probability of gas A turning into solid A at the bottom
probB = 0.05; % Probability of gas B turning into solid B at the bottom
probAB = 0.05; % Probability of A turning solid when adjacent to solid B
probBA = 0.025; % Probability of B turning solid when adjacent to solid A
probAA = 0.1; % Probability of A turning solid when adjacent to solid A
probBB = 0.05; % Probability of B turning solid when adjacent to solid B

% Simulation Setup Values
n_steps = 1000; % Number of simulation steps
max_idle_steps = 50; % Maximum number of steps a gas can stay idle
influx_rate = 1; % Rate of gas influx from the top (adjust as needed)
A_ratio = 0.4; % controls 1-X probability of gas A
B_ratio = 0.2;




% Visualization setup
figure;
cmap = [1 1 1; 1 0 0; 0 0 1; 0.5 0 0; 0 0 0.5]; % colors: empty, gas A, gas B, solid A, solid B
colormap(cmap);
h = imagesc(grid);
colorbar('Ticks', [0.1, 0.9, 1.9, 2.9, 3.9], ...
         'TickLabels', {'Empty', 'Gas A', 'Gas B', 'Solid A', 'Solid B'});
title('Simulation of Gas to Solid Transition');

% Main simulation loop
for step = 1:n_steps
    if mod(step, 1) == 0 || step == 2
        % Display the grid
        set(h, 'CData', grid);
        title(sprintf('Step %d', step));
        drawnow;
    end
    % Copy grid to update states
    new_grid = grid;
    
    % Add gas influx from the top
    for j = 1:grid_size(2)
        if rand() < influx_rate
            %if rand() > 1-A_ratio, new_grid(1, j) = 1; end 
            if rand() > 1-B_ratio, new_grid(1, j) = 2; else new_grid(1,j) = 1;
            end 
        end
    end
    
    % Move gases downward
    for i = grid_size(1)-1:-1:1
        for j = 1:grid_size(2)
            move = randsample([-1, 0, 1],1); % Randomly choose left (-1), stay (0), or right (1)

            if move + j < 1 || move + j > ny
                new_grid(i,j) = 0;
                new_grid(i+1,j) = grid(i,j);
            elseif grid(i, j) > 0 && grid(i, j) < 3 % If the cell contains gas
                if new_grid(i+1, j+move) == 0 % Check if the cell below is empty
                    new_grid(i+1, j+move) = grid(i, j); % Move gas down
                    new_grid(i, j) = 0; % Clear current cell
                    moved(i+1, j+move) = 1; % Mark as moved
                end
            end
        end
    end
  

    
    % Apply solidification rules for all gases
    for i = 1:grid_size(1)
        for j = 1:grid_size(2)
            % Extract the local neighborhood
            local = new_grid(max(i-1,1):min(i+1,grid_size(1)), max(j-1,1):min(j+1,grid_size(2)));

            if new_grid(i, j) == 1
                % Gas A checks for solid B in the neighborhood
                if i == grid_size(1)
                    if rand() < probA
                        new_grid(i, j) = 3;
                    end  
                elseif any(local(:) == 4)
                    if rand() < probAB
                        new_grid(i, j) = 3; % Turn to solid A
                    end
                elseif any(local(:) == 3)
                    if rand() < probAA
                        new_grid(i, j) = 3; % Turn to solid A
                    end
                end
            elseif new_grid(i, j) == 2
                % Gas B checks for solid A in the neighborhood
                if i == grid_size(1) 
                    if rand() < probB
                        new_grid(i, j) = 4;
                    end 
                elseif any(local(:) == 3)
                    if rand() < probBA
                        new_grid(i, j) = 4; % Turn to solid B
                    end
                elseif any(local(:) == 4)
                    if rand() < probBB
                        new_grid(i, j) = 4; % Turn to solid B
                    end
                end
            end
        end
    end
    
    % Check for gases that haven't moved in max_idle_steps steps and remove them
    if step > max_idle_steps
        for i = 1:grid_size(1)
            for j = 1:grid_size(2)
                if grid(i, j) > 0 && grid(i, j) < 3 && ~moved(i, j)
                    new_grid(i, j) = 0; % Remove stagnant gas
                end
            end
        end
    end
    
    % Update the grid state
    grid = new_grid;
    
    % Reset the moved matrix for the next step
    moved = zeros(grid_size);
end

% Calculate distribution of solid A and solid B in the entire system
solid_A_count = sum(grid(:) == 3);
solid_B_count = sum(grid(:) == 4);
fprintf('Distribution of Solid A in the entire system: %d\n', solid_A_count);
fprintf('Distribution of Solid B in the entire system: %d\n', solid_B_count);

% Print row-by-row distribution for rows with solids
fprintf('Row-by-row distribution:\n');
for i = 1:grid_size(1)
    if any(grid(i, :) == 3) || any(grid(i, :) == 4)
        solid_A_row_count = sum(grid(i, :) == 3);
        solid_B_row_count = sum(grid(i, :) == 4);
        fprintf('Row %d: Solid A - %d, Solid B - %d\n', i, solid_A_row_count, solid_B_row_count);
    end
end

