# CVD Film Growth Simulation

A Python simulation of Chemical Vapor Deposition (CVD) film growth using two precursor gases with different sticking coefficients.

## Features
- Simulates gas particle movement and interactions in a 2D grid
- Models different sticking probabilities between gas-surface and gas-gas interactions
- Visualizes the growth process using matplotlib
- Configurable parameters
  - Sticking coefficients
  - Partial pressures
  - Influx rates
  - Grid dimensions

## Initalization

Ensure you have the following prerequisites installed:
- Python 3.10 or higher
- pip (Python package installer)
- git

Clone the respository

```bash
git clone https://github.com/agosh-saini/3_precusor_CVD_sim
cd repository
```

Create a virtual Enviroment 

For Mac and Linux
```bash
python -m venv venv
source venv/bin/activate  
```

For Windows
```bash
    python -m venv venv
    venv\Scripts\activate
```

Install all the dependencies 
```bash
pip install -r requirements.txt
```

## Usage
Run `sticking_coeff.py` to start the simulation. The visualization will show:
- Empty cells (white)
- Gas A particles (red)
- Gas B particles (blue) 
- Solid A deposits (dark red)
- Solid B deposits (dark blue)

## Parameters
Key simulation parameters can be adjusted in `sticking_coeff.py`:
- Grid size
- Number of simulation steps
- Sticking coefficients (probA, probB, probAB, etc.)
- Gas influx rates and ratios

## Folder Strucutre

```bash
3_precusor_CVD_sim/
│   ├── .gitignore
│   ├── LICENSE.md # MIT license
│   ├── README.md # this file
│   ├── requirements.txt # dependencies
│   ├── sticking_coeff.py # Main file to run
│   ├── Archive/
│   │   ├── ... # v0 Matlab Files
│   ├── figures/
│   │   ├── ... # Saved figures
```

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contributions
This project was created by Agosh Saini. Tools such as Cursor were used during this project. 

## Reference
[1]: "Sticking coefficient." Wikipedia, The Free Encyclopedia, https://en.wikipedia.org/wiki/Sticking_coefficient \
[2]: "Sticking Probability." Wikipedia, The Free Encyclopedia, https://en.wikipedia.org/wiki/Sticking_probability
