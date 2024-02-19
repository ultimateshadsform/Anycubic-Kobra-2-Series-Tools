import sys
import re

# grid size
grid_size = 7

input_file = 'printer_max.cfg'
output_file = 'mesh.txt'

# Check if --grid is defined
if '--grid' in sys.argv:
    # If --grid is defined, then set the grid size to specified value
    grid_size = int(sys.argv[sys.argv.index('--grid') + 1])

# Open the input file
with open(input_file, 'r') as f:
    # Read the file
    data = f.read()

    # Extract points values from: [besh_profile_default]
    mesh_raw = re.search(r'\[besh_profile_default\]\nversion : 1\npoints : (.+?)\n', data, re.DOTALL).group(1)

    # Split by comma into a array

    mesh_array = mesh_raw.split(', ')

    # Take all points up to the grid size. 7 values then put them into a new array and repeat until there are no more points
    mesh = [mesh_array[i:i + grid_size] for i in range(0, len(mesh_array), grid_size)]

    for i in range(grid_size):
        print(i, end=' ')
    print()
    for i in range(grid_size):
        # print(f'{i} {mesh[i]}')
        # Unstructure the array 
        print(f'{i} {" ".join(mesh[i])}')

        