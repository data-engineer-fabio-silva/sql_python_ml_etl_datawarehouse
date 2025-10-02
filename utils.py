import os

def create_path(*paths):
   
    return os.path.join(*paths)

def new_list_files(source_file_path, file_prefix):

    try:
        # list comprehesion
        files = [
                os.path.join(source_file_path, f)
                for f in os.listdir(source_file_path)
                if os.path.isfile(os.path.join(source_file_path, f)) and f.startswith(file_prefix)
            ]
        return files
    except Exception as e:
        print(f"Error listing files in {source_file_path}: {e}")
        return []