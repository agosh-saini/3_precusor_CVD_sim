import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
from matplotlib.patches import Patch, FancyBboxPatch
from matplotlib.colors import LinearSegmentedColormap

# Grid and Movement Setup
nx, ny = 50, 50
grid_size = (nx, ny)
grid = np.zeros(grid_size, dtype=int)  # 0: empty, 1: gas A, 2: gas B, 3: solid A, 4: solid B
moved = np.zeros(grid_size, dtype=bool)

# Probabilities (sticking coefficients and partial pressures)
probA = 0.05
probB = 0.05
probAB = 0.05
probBA = 0.05
probAA = 0.05
probBB = 0.05

# Simulation Setup
n_steps = 750
max_idle_steps = 25
influx_rate = 1
A_ratio = 0.5
B_ratio = 1 - A_ratio

# Visualization setup
cmap = mcolors.ListedColormap([
    [1, 1, 1],     # Empty
    [1, 0, 0],     # Gas A
    [0, 0, 1],     # Gas B
    [0.5, 0, 0],   # Solid A
    [0, 0, 0.5]    # Solid B
])
fig, ax = plt.subplots()
img = ax.imshow(grid, cmap=cmap, vmin=0, vmax=4)
cbar = fig.colorbar(img, ticks=[0.1, 0.9, 1.9, 2.9, 3.9])
cbar.ax.set_yticklabels(['Empty', 'Gas A', 'Gas B', 'Solid A', 'Solid B'])

# Main simulation loop
for step in range(1, n_steps + 1):
    if step % 500 == 0:
        img.set_data(grid)
        ax.set_title(f'Step {step}')
        plt.draw()
        plt.pause(0.01)

    new_grid = grid.copy()

    # Add gas influx
    for j in range(ny):
        if np.random.rand() < influx_rate:
            new_grid[0, j] = 2 if np.random.rand() < B_ratio else 1

    # Move gases downward
    for i in range(nx - 2, -1, -1):
        for j in range(ny):
            move = np.random.choice([-1, 0, 1])
            target_j = j + move
            if 0 <= target_j < ny and 0 < grid[i, j] < 3:
                if new_grid[i + 1, target_j] == 0:
                    new_grid[i + 1, target_j] = grid[i, j]
                    new_grid[i, j] = 0
                    moved[i + 1, target_j] = True

    # Apply solidification rules
    for i in range(nx):
        for j in range(ny):
            local = new_grid[max(i - 1, 0):min(i + 2, nx), max(j - 1, 0):min(j + 2, ny)]
            if new_grid[i, j] == 1:
                if i == nx - 1:
                    if np.random.rand() < probA:
                        new_grid[i, j] = 3
                elif 4 in local:
                    if np.random.rand() < probAB:
                        new_grid[i, j] = 3
                elif 3 in local:
                    if np.random.rand() < probAA:
                        new_grid[i, j] = 3
            elif new_grid[i, j] == 2:
                if i == nx - 1:
                    if np.random.rand() < probB:
                        new_grid[i, j] = 4
                elif 3 in local:
                    if np.random.rand() < probBA:
                        new_grid[i, j] = 4
                elif 4 in local:
                    if np.random.rand() < probBB:
                        new_grid[i, j] = 4

    # Remove stagnant gas
    if step > max_idle_steps:
        for i in range(nx):
            for j in range(ny):
                if 0 < grid[i, j] < 3 and not moved[i, j]:
                    new_grid[i, j] = 0

    grid = new_grid
    moved[:] = False

# Final solid distribution
solid_A_count = np.sum(grid == 3)
solid_B_count = np.sum(grid == 4)
print(f'Distribution of Solid A in the entire system: {solid_A_count}')
print(f'Distribution of Solid B in the entire system: {solid_B_count}')
print(f'Expecteed Ratio: {A_ratio/B_ratio}, Actual Ratio: {solid_A_count/solid_B_count}')


# Create a colormap for visualization
colors = ['white', 'lightblue', 'lightgreen', 'blue', 'green']
cmap = LinearSegmentedColormap.from_list('custom_cmap', colors)


for i in range(nx):
    for j in range(ny):
        if grid[i, j] == 1:
            grid[i, j] = 0
        elif grid[i, j] == 2:
            grid[i, j] = 0
        else:
            grid[i, j] = grid[i, j]
            

# Add legend
legend_elements = [
    Patch(facecolor='white', edgecolor='black', label='Empty'),
    Patch(facecolor='blue', edgecolor='black', label='Solid A'),
    Patch(facecolor='green', edgecolor='black', label='Solid B')
]

# Create a figure with more space on the right for the legend and textbox
plt.figure(figsize=(12, 8))

# Plot the main grid
plt.imshow(grid, cmap=cmap, interpolation='nearest')

# Add labels and title
title_main = 'Film Distribution of Two Gas CVD Deposition'
title_sticking = f"Sticking Coefficients: A-A: {probAA:.2f}, A-B: {probAB:.2f}, B-A: {probBA:.2f}, B-B: {probBB:.2f}"
title_ratio = f"A/B Fraction: {solid_A_count/solid_B_count:.2f}"

plt.suptitle(f"{title_main}", fontsize=14, fontname='Arial', fontweight='bold', y=0.95)
plt.title(f"{title_sticking}\n"
             f"{title_ratio}",
             fontsize=10, fontname='Arial', pad=5)

plt.xlabel('Width (Particles)', fontsize=12, fontname='Arial')
plt.ylabel('Height (Particles)', fontsize=12, fontname='Arial')

# Add textbox with sticking coefficients
textstr = '\n'.join((
    'Sticking Coefficients:',
    f'A-A: {probAA:.2f}',
    f'A-B: {probAB:.2f}', 
    f'B-A: {probBA:.2f}',
    f'B-B: {probBB:.2f}'))

# Shared box style and dimensions
box_style = dict(boxstyle='round,pad=0.5', facecolor='white', edgecolor='black', alpha=0.8)

# Add legend
legend = plt.legend(handles=legend_elements, loc='center left',
                    bbox_to_anchor=(1.15, 0.5),
                    bbox_transform=plt.gca().transAxes,
                    prop={'family': 'Arial', 'size': 10},
                    framealpha=0.8, edgecolor='black')

# Set same box style for legend
legend.get_frame().set_boxstyle('round,pad=0.5')
legend.get_frame().set_facecolor('white')
legend.get_frame().set_alpha(0.8)
legend.get_frame().set_edgecolor('black')

# Adjust layout to prevent label cutoff
plt.subplots_adjust(right=0.85)  # Make room for the legend and textbox

plt.show()  # Keep the final frame displayed



