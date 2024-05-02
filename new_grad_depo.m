clear, clc, close all

% Grid and Movement Setup
nx = 1000; ny = 1000;
grid_size = [ny, nx]; % Size of the grid
grid = zeros(grid_size); % 0 for empty, 1 for gas A, 2 for gas B, 3 for solid A, 4 for solid B

% Probabilities used as equivelent to Sticking coeff and Partial Pressure
partial_pressure_A = 0.2;
sticking_A = 1; sticking_B = 400/1000;

influx = partial_pressure_A * sticking_A / ((1-partial_pressure_A) * sticking_B...
    + partial_pressure_A * sticking_A); % determines how much more A than B

% Simulation Setup Values
n_steps = ny; % Number of simulation steps

% Visualization setup
figure;

% Define the colormap
cmap = [1 1 1; 1 0 0; 0 0 1]; % Colors: white for empty, red for Gas A, blue for Gas B
colormap(cmap);

% Create the image object with initial grid data
h = imagesc(grid);
clim([0 2]); % Set color axis scaling to include all your data values (0 to 2)

% Add a colorbar and specify the ticks and labels
colorbar('Ticks', [0.33, 1, 1.67], ...  % Position the ticks centered for each value
         'TickLabels', {'Empty', 'Gas A', 'Gas B'});

% Set the title
title('Simulation of Gas to Solid Transition');

% adds either gas a or gas b
for step = 1:n_steps
    new_layer = ones(1,nx) + double(rand(1,nx)>influx);

    if mod(step, 1) == 0 || step == 2
        % Display the grid
        set(h, 'CData', grid);
        title(sprintf('Step %d', step));
        drawnow;
    end

    for j = 1:ny
        for i = nx:-1:1
            if grid(i,j) == 0
                if new_layer(j) == 2
                    if rand() < sticking_B, grid(i,j) = 2; end
                else
                    grid(i,j) = 1;
                end
                break
            end
        end

    end
end

% Calculate distribution of solid A and solid B in the entire system
solid_A_count = nnz(grid(:) == 1);
solid_B_count = nnz(grid(:) == 2);
fprintf('Distribution of Solid A in the entire system: %d\n', solid_A_count);
fprintf('Distribution of Solid B in the entire system: %d\n', solid_B_count);
fprintf('Ratio of A/B is: %.2d\n', solid_A_count/solid_B_count);



