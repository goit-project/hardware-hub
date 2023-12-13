import goit.dependencies

# Module defines library
library = "goit_common"

# Array with design unit filenames 
files = goit.dependencies.get_component_paths() \
      + goit.dependencies.get_procedure_paths()
