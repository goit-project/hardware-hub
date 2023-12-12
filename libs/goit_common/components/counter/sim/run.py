#!/usr/bin/python3
from vunit import VUnit

# create VUnit project from command line arguments
prj = VUnit.from_argv()

# add OSVVM library, verification components
prj.add_osvvm()
prj.add_verification_components()

# add design libraries
prj.add_library("goit_common")
prj.add_library("test")

# add design files
prj.library("goit_common").add_source_file("../src/counter.vhd")

# add testbench files
prj.library("test").add_source_file("../tb/tb.vhd")

# run VUnit simulation
prj.main()
