import re
import os

output_file = 'mesh.txt'
input_file = 'printer_max.cfg'

if __name__ == "__main__":

    # Detect anything with printer*.cfg
    for file in os.listdir('.'):
        # Check if the filename contains printer and cfg
        if "printer" in file and ".cfg" in file:
            input_file = file
            break

    # Open the input file
    with open(input_file, 'r') as f:
        # Read the file
        data = f.read()

        # Extract points values from: [besh_profile_default]
        mesh_raw = re.search(r'\[besh_profile_default\]\nversion : 1\npoints : (.+?)\n', data, re.DOTALL).group(1)

        # Split by comma into a array

        mesh_array = mesh_raw.split(', ')

        # Ask for the grid size
        grid_size = str(input("Enter the grid size. Example: 7x7: "))

        try:
            grid_x = int(grid_size.split('x')[0])
            grid_y = int(grid_size.split('x')[1])
        except:
            print("Invalid grid size")
            exit(1)
        

        # Take all points up to the grid size. 7 values then put them into a new array and repeat until there are no more points
        # mesh = [mesh_array[i:i+grid_size] for i in range(0, len(mesh_array), grid_size)]
        # Use x and y
        mesh = [mesh_array[i:i+grid_x] for i in range(0, len(mesh_array), grid_y)]

        mesh_str = ""
        mesh_str += "\n"
        for i in range(len(mesh)):
            mesh_str += f"{i} {' '.join(map(str, mesh[i]))}\n"

        # Print the result
        print(mesh_str)

        