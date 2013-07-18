# Constants
TMP_DIR := $(shell mktemp --directory --suffix=.fortran_lib)

MY_ERB ?= erb -T - -P
MY_GFORTRAN_DEBUG ?= gfortran -ffree-line-length-none -fmax-identifier-length=63 -pipe -cpp -C -Wall -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG
MY_IFORT_DEBUG ?= ifort -fpp -warn -assume realloc_lhs -no-ftz -check -trace -O0 -p -g -DDEBUG
MY_FORTRAN_DEBUG ?= $(MY_GFORTRAN_DEBUG)
# MY_FORTRAN_DEBUG ?= $(MY_IFORT_DEBUG)
MY_RUBY ?= ruby

ERB := ${MY_ERB} -T '-' -P
FORTRAN := ${MY_FORTRAN_DEBUG}
RUBY := ${MY_RUBY}

# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:

# Commands
.PHONY: all test

EXECS := ../bin/get_wgs84_from_ecef.exe ../bin/get_ecef_from_wgs84.exe ../bin/text_dump_array.exe

LIB_F90_SRCS := $(shell git ls-files *_lib.F90)
LIB_F90_ERB_SRCS := $(shell git ls-files *_lib.F90.erb)
LIBS := $(LIB_F90_SRCS:%.F90=%.o) $(LIB_F90_ERB_SRCS:%.F90.erb=%.o)
all: $(LIBS) $(EXECS)

TEST_F90_SRCS := $(shell git ls-files *_test.F90)
TEST_F90_ERB_SRCS := $(shell git ls-files *_test.F90.erb)
TESTS := $(TEST_F90_SRCS:%.F90=%.exe) $(TEST_F90_ERB_SRCS:%.F90.erb=%.exe)
TEST_RUN_COMMANDS := $(TESTS:%.exe=%.tested)

ERRORTEST_RB_SRCS := $(shell git ls-files *_errortest.rb)
ERRORTESTS := $(ERRORTEST_RB_SRCS:%.rb=%.make)

.PRECIOUS: $(LIB_F90_ERB_SRCS:%.erb=%) $(TEST_F90_ERB_SRCS:%.erb=%)

test: $(TESTS) $(ERRORTESTS)

# Tasks
# Executables
../bin/text_dump_array.exe: constant_lib.o constant_lib.mod character_lib.o character_lib.mod config_lib.o config_lib.mod io_lib.o io_lib.mod text_dump_array.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
../bin/get_wgs84_from_ecef.exe: character_lib.o character_lib.mod constant_lib.o constant_lib.mod geodetic_lib.o geodetic_lib.mod get_wgs84_from_ecef.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
../bin/get_ecef_from_wgs84.exe: character_lib.o character_lib.mod constant_lib.o constant_lib.mod geodetic_lib.o geodetic_lib.mod get_ecef_from_wgs84.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
# Tests
comparable_lib_test.exe: constant_lib.o constant_lib.mod comparable_lib.o comparable_lib.mod comparable_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
character_lib_test.exe: character_lib.o character_lib.mod character_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
constant_lib_test.exe: comparable_lib.o comparable_lib.mod constant_lib.o constant_lib.mod constant_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
sort_lib_test.exe: constant_lib.o constant_lib.mod stack_lib.o stack_lib.mod comparable_lib.o comparable_lib.mod sort_lib.o sort_lib.mod sort_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
list_lib_test.exe: comparable_lib.o comparable_lib.mod list_lib.o list_lib.mod list_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
stack_lib_test.exe: stack_lib.o stack_lib.mod stack_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
queue_lib_test.exe: queue_lib.o queue_lib.mod queue_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
io_lib_test.exe: config_lib.o config_lib.mod constant_lib.o constant_lib.mod character_lib.o character_lib.mod comparable_lib.o comparable_lib.mod io_lib.o io_lib.mod io_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
config_lib_test.exe: config_lib.o config_lib.mod config_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
io_lib_errortest.make: io_lib_errortest.rb config_lib.o config_lib.mod constant_lib.o constant_lib.mod character_lib.o character_lib.mod comparable_lib.o comparable_lib.mod io_lib.o io_lib.mod io_lib_test.o
	${RUBY} errortest_generate.rb $<
binary_tree_map_lib_test.exe: binary_tree_map_lib.o binary_tree_map_lib.mod binary_tree_map_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
binary_tree_map_lib_errortest.make: binary_tree_map_lib_errortest.rb binary_tree_map_lib.o binary_tree_map_lib.mod binary_tree_map_lib_test.o
	${RUBY} errortest_generate.rb $<
sac_lib_test.exe: character_lib.o character_lib.mod sac_lib.o sac_lib.mod sac_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
sac_lib_errortest.make: sac_lib_errortest.rb character_lib.o character_lib.mod sac_lib.o sac_lib.mod sac_lib_test.o
	${RUBY} errortest_generate.rb $<
path_lib_test.exe: path_lib.o path_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@
geodetic_lib_test.exe: constant_lib.o constant_lib.mod comparable_lib.o comparable_lib.mod geodetic_lib.o geodetic_lib.mod geodetic_lib_test.o
	$(FORTRAN) -o $@ $(filter-out %.mod, $^)
	./$@

# Rules
%.F90: %.F90.erb
	$(ERB) $(filter-out %.mod, $^) > $(TMP_DIR)/$@
	mv -f $(TMP_DIR)/$@ $@
%.o: %.F90 utils.h
	$(FORTRAN) -c $(filter-out %.h, $^)
%.mod: %.F90 utils.h
	$(FORTRAN) -c $(filter-out %.h, $^)
	touch $@
%.tested: %.exe
	./$<
