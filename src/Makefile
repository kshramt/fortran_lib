# Constants
TMP_DIR := $(shell mktemp --directory --suffix=.fortran_lib)

ERB := ${MY_ERB} -T '-' -P
FORTRAN := ${MY_FORTRAN_DEBUG}
RUBY := ${MY_RUBY}

# Configurations
.SUFFIXES:

# Commands
.PHONY: all check

LIB_F90_SRCS := $(shell git ls-files *_lib.F90)
LIB_F90_ERB_SRCS := $(shell git ls-files *_lib.F90.erb)
LIBS := $(LIB_F90_SRCS:%.F90=%.o) $(LIB_F90_ERB_SRCS:%.F90.erb=%.o)
all: $(LIBS)

TEST_F90_SRCS := $(shell git ls-files *_test.F90)
TEST_F90_ERB_SRCS := $(shell git ls-files *_test.F90.erb)
TESTS := $(TEST_F90_SRCS:%.F90=%.exe) $(TEST_F90_ERB_SRCS:%.F90.erb=%.exe)
TEST_RUN_COMMANDS := $(TESTS:%.exe=%.tested)

ERRORTEST_RB_SRCS := $(shell git ls-files *_errortest.rb)
ERRORTESTS := $(ERRORTEST_RB_SRCS:%.rb=%.make)

.PRECIOUS: $(LIB_F90_ERB_SRCS:%.erb=%) $(TEST_F90_ERB_SRCS:%.erb=%)

check: $(TESTS) $(ERRORTESTS)

# Tasks
comparable_lib_test.exe: constant_lib.o comparable_lib.o comparable_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
character_lib_test.exe: character_lib.o character_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
constant_lib_test.exe: comparable_lib.o constant_lib.o constant_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
sort_lib_test.exe: constant_lib.o stack_lib.o comparable_lib.o sort_lib.o sort_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
list_lib_test.exe: comparable_lib.o list_lib.o list_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
stack_lib_test.exe: stack_lib.o stack_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
queue_lib_test.exe: queue_lib.o queue_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
io_lib_test.exe: constant_lib.o character_lib.o comparable_lib.o io_lib.o io_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
binary_tree_map_lib_test.exe: binary_tree_map_lib.o binary_tree_map_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
sac_lib_test.exe: sac_lib.o sac_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
path_lib_test.exe: path_lib.o path_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@

# Rules
%.F90: %.F90.erb
	$(ERB) $^ > $(TMP_DIR)/$@
	mv -f $(TMP_DIR)/$@ $@
%.mod %.o: %.F90 utils.h
	$(FORTRAN) -c -o $@ $(filter-out %.h,$^)
%.tested: %.exe
	./$<
%_errortest.make: %_errortest.rb
	${RUBY} errortest_generate.rb $<
