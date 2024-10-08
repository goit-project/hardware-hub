import glob
#import os
#import goit.dependencies

# aggregate libraries
#dir_path = os.path.dirname(os.path.realpath(__file__))
libs = glob.glob('libs/*')
#libs = glob.glob(dir_path + '/libs/*')

# Aggregate library hierarchy
modules = {
  #"local" : ["/home/rihards/projects/codebase/goit_hardware_hub/libs/goit_common/"]
  #"local" : ["libs/goit_common"]
  #"local" : libs
  "local" : [lib for lib in libs]
  #"local" : goit.dependencies.get_library_paths()
}
