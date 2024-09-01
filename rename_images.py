import os
import shutil

# Specify the directory containing the subfolders
source_directory = "assets/images/"
# Specify the directory where you want to move the renamed files
destination_directory = "assets/exercise_images/"

# Create the destination directory if it doesn't exist
if not os.path.exists(destination_directory):
    os.makedirs(destination_directory)

# Iterate over all subfolders in the source directory
for folder_name in os.listdir(source_directory):
    folder_path = os.path.join(source_directory, folder_name)

    if os.path.isdir(folder_path):
        # Iterate over all files in the subfolder
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)

            # Create a new filename by appending the folder name to the file name
            new_filename = f"{folder_name}_{filename}"
            new_file_path = os.path.join(destination_directory, new_filename)

            # Move and rename the file
            shutil.move(file_path, new_file_path)

print("Files have been renamed and moved successfully.")
