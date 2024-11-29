About:
This is the release for the implementation of the RISC_V project out of order version without ROB

Steps to run in modelsim:
1.Open modelsim
2.Select /modelsim/vsim.wlf file through open file option
3.Execute "do run.do" cmd in transcript window, this will compile all sv modules and run the simulation for the sort algorithm as default
4.If more of the available tests want to be run they can be selected manually with the TEST_NAME valueplusargs when simulating
    Example: vsim -gui work.risc_v_sp_tb +TEST_NAME=TEST_1 (there are 1..11 tests to try on)
    the asm codes for each of the tests can be found inside the asm folder