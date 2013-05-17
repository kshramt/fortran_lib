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
lib_comparable_test.exe: lib_constant.o lib_comparable.o lib_comparable_test.o
	$(FORTRAN) -o $@ $^
	./$@
lib_character_test.exe: lib_character.o lib_character_test.o
	$(FORTRAN) -o $@ $^
	./$@
lib_constant_test.exe: lib_comparable.o lib_constant.o lib_constant_test.o
	$(FORTRAN) -o $@ $^
	./$@
lib_sort_test.exe: lib_constant.o stack_lib.o lib_comparable.o lib_sort.o lib_sort_test.o
	$(FORTRAN) -o $@ $^
	./$@
lib_list_test.exe: lib_comparable.o lib_list.o lib_list_test.o
	$(FORTRAN) -o $@ $^
	./$@
stack_lib_test.exe: stack_lib.o stack_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
queue_lib_test.exe: queue_lib.o queue_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
lib_io_test.exe: lib_constant.o lib_character.o lib_comparable.o lib_io.o lib_io_test.o
	$(FORTRAN) -o $@ $^
	./$@
binary_tree_map_lib_test.exe: binary_tree_map_lib.o binary_tree_map_lib_test.o
	$(FORTRAN) -o $@ $^
	./$@
sac_lib_test.exe: sac_lib.o sac_lib_test.o
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
