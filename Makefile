# Constants
MY_ERB ?= erb
ERB := ${MY_ERB}
ERB_FLAGS := -T '-' -P

MY_GFORTRAN_DEBUG ?= gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG
MY_IFORT_DEBUG ?= ifort -fpp -warn -assume realloc_lhs -no-ftz -check -trace -O0 -p -g -DDEBUG
MY_FORTRAN_DEBUG ?= $(MY_GFORTRAN_DEBUG)
# MY_FORTRAN_DEBUG ?= $(MY_IFORT_DEBUG)
MY_RUBY ?= ruby

FC := ${MY_FORTRAN_DEBUG}
RUBY := ${MY_RUBY}

# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber

# Functions

o_mod = $(1:%=%.o) $(patsubst %,%.mod,$(filter %_lib,$(1)))

# Commands
.PHONY: all test erb

EXECS := bin/get_wgs84_from_ecef.exe bin/get_ecef_from_wgs84.exe bin/text_dump_array.exe bin/sac_to_json.exe

LIB_F90_SRCS := $(shell git ls-files *_lib.F90)
LIB_F90_ERB_SRCS := $(shell git ls-files *_lib.F90.erb)
LIBS := $(LIB_F90_SRCS:%.F90=%.o) $(LIB_F90_ERB_SRCS:%.F90.erb=%.o)
all: erb $(EXECS)
erb: $(LIB_F90_ERB_SRCS:%.erb=%)

TEST_F90_SRCS := $(shell git ls-files *_test.F90)
TEST_F90_ERB_SRCS := $(shell git ls-files *_test.F90.erb)
TESTS := $(TEST_F90_SRCS:%.F90=%.exe) $(TEST_F90_ERB_SRCS:%.F90.erb=%.exe)
TEST_RUN_COMMANDS := $(TESTS:%.exe=%.tested)

ERRORTEST_RB_SRCS := $(shell git ls-files *_errortest.rb)
ERRORTESTS := $(ERRORTEST_RB_SRCS:%.rb=%.make)

.PRECIOUS: $(LIB_F90_ERB_SRCS:%.erb=%) $(TEST_F90_ERB_SRCS:%.erb=%)

test: $(TESTS) $(ERRORTESTS) $(LIBS)

# Tasks
# Executables
bin/sac_to_json.exe: $(call o_mod,character_lib sac_lib sac_to_json)
bin/text_dump_array.exe: $(call o_mod,constant_lib character_lib config_lib io_lib text_dump_array)
bin/get_wgs84_from_ecef.exe: $(call o_mod,character_lib constant_lib geodetic_lib get_wgs84_from_ecef)
bin/get_ecef_from_wgs84.exe: $(call o_mod,character_lib constant_lib geodetic_lib get_ecef_from_wgs84)
bin/%.exe: | bin
	$(FC) -o $@ $(filter-out %.mod,$^)
bin:
	mkdir -p $@
# Tests
array_lib_test.exe: $(call o_mod,comparable_lib array_lib array_lib_test)
comparable_lib_test.exe: $(call o_mod,constant_lib comparable_lib comparable_lib_test)
character_lib_test.exe: $(call o_mod,character_lib character_lib_test)
constant_lib_test.exe: $(call o_mod,comparable_lib constant_lib constant_lib_test)
sort_lib_test.exe: $(call o_mod,constant_lib stack_lib comparable_lib random_lib sort_lib sort_lib_test)
list_lib_test.exe: $(call o_mod,comparable_lib list_lib list_lib_test)
stack_lib_test.exe: $(call o_mod,stack_lib stack_lib_test)
queue_lib_test.exe: $(call o_mod,queue_lib queue_lib_test)
io_lib_test.exe: $(call o_mod,config_lib constant_lib character_lib comparable_lib io_lib io_lib_test)
config_lib_test.exe: $(call o_mod,config_lib config_lib_test)
binary_tree_map_lib_test.exe: $(call o_mod,binary_tree_map_lib binary_tree_map_lib_test)
sac_lib_test.exe: $(call o_mod,character_lib sac_lib sac_lib_test)
path_lib_test.exe: $(call o_mod,path_lib path_lib_test)
geodetic_lib_test.exe: $(call o_mod,constant_lib comparable_lib geodetic_lib geodetic_lib_test)
math_lib_test.exe: $(call o_mod,comparable_lib math_lib math_lib_test)
dual_lib_test.exe: $(call o_mod,comparable_lib dual_lib dual_lib_test)
optimize_lib_test.exe: $(call o_mod,comparable_lib constant_lib array_lib optimize_lib optimize_lib_test)
%_test.exe:
	$(FC) -o $@ $(filter-out %.mod,$^)
	./$@
io_lib_errortest.make: errortest_generate.rb io_lib_errortest.rb $(call o_mod,config_lib constant_lib character_lib comparable_lib io_lib io_lib_test)
binary_tree_map_lib_errortest.make: errortest_generate.rb binary_tree_map_lib_errortest.rb $(call o_mod,binary_tree_map_lib binary_tree_map_lib_test)
sac_lib_errortest.make: errortest_generate.rb sac_lib_errortest.rb $(call o_mod,character_lib sac_lib sac_lib_test)
%_errortest.make:
	${RUBY} $< $*_errortest.rb

# Rules
%.F90: %.F90.erb
	$(ERB) $(ERB_FLAGS) $< >| $@
%_lib.mod %_lib.o: %_lib.F90 fortran_lib.h
	$(FC) -c -o $(@:%.mod=%.o) $<
	touch ${@:%.o=%.mod}
%.o: %.F90 fortran_lib.h
	$(FC) -c -o $(@:%.mod=%.o) $<
	touch ${@:%.o=%.mod}
%.tested: %.exe
	./$<
