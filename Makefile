# Constants
DIR := $(abspath .)

DEPS := fort

MY_ERB ?= erb
ERB := ${MY_ERB}
ERB_FLAGS := -T '-' -P

# MY_FORTRAN_DEBUG ?= $(MY_IFORT_DEBUG)
MY_RUBY ?= ruby
RUBY := ${MY_RUBY}

MY_FC ?= gfortran
FC := $(MY_FC)
MY_FFLAG_COMMON ?= -ffree-line-length-none -fmax-identifier-length=63 -pipe -Wall
MY_FFLAG_DEBUG ?= -fbounds-check -O0 -fbacktrace -ggdb -pg -DDEBUG
FFLAGS := $(MY_FFLAG_COMMON) $(MY_FFLAG_DEBUG)

MY_CPP ?= cpp
CPP := $(MY_CPP)
CPP_FLAGS := -P -C
ifeq ($(FC),ifort)
   CPP_FLAGS += -D __INTEL_COMPILER
endif

FILES := $(shell git ls-files)
F90_NAMES := $(patsubst %.f90,%,$(filter %.f90,$(FILES)))
F90_NAMES += $(patsubst %.f90.erb,%,$(filter %.f90.erb,$(FILES)))
LIB_NAMES := $(filter %_lib,$(F90_NAMES))
TEST_NAMES := $(filter %_test,$(F90_NAMES))
ERRORTEST_TEMPLATE_NAMES := $(filter %_errortest,$(F90_NAMES))
ERRORTEST_STEMS := $(patsubst %_errortest,%,$(ERRORTEST_TEMPLATE_NAMES))
ERRORTEST_IMPL_NAMES := $(foreach name,$(ERRORTEST_TEMPLATE_NAMES),$(filter $(name)/%,$(F90_NAMES)))
ERRORTEST_NAMES := $(addsuffix _errortest,$(subst _errortest/,_,$(ERRORTEST_IMPL_NAMES)))
EXE_NAMES := $(filter-out $(LIB_NAMES) $(TEST_NAMES) $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES),$(F90_NAMES))


# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber


# Functions

o_mod = $(1:%=%.o) $(addsuffix .mod,$(filter %_lib,$(1)))


# Commands
.PRECIOUS: $(LIB_F90_ERB_SRCS:%.erb=%) $(TEST_F90_ERB_SRCS:%.erb=%)


.PHONY: all src test preprocess deps
all: preprocess src $(EXE_NAMES:%=bin/%.exe)
src: preprocess $(patsubst %,src/%.f90,$(filter-out $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES),$(F90_NAMES))) $(patsubst %,src/%.f90,$(ERRORTEST_NAMES))
test: preprocess $(TEST_NAMES:%=test/%.exe.tested) $(ERRORTEST_NAMES:%=test/%.exe.tested)
preprocess: deps
deps: $(DEPS:%=dep/%.updated)


# Tasks
## Executables
bin/sac_to_json.exe: $(call o_mod,character_lib sac_lib sac_to_json)
bin/text_dump_array.exe: $(call o_mod,constant_lib character_lib config_lib io_lib text_dump_array)
bin/get_wgs84_from_ecef.exe: $(call o_mod,character_lib constant_lib geodetic_lib get_wgs84_from_ecef)
bin/get_ecef_from_wgs84.exe: $(call o_mod,character_lib constant_lib geodetic_lib get_ecef_from_wgs84)


## Tests
test/array_lib_test.exe: $(call o_mod,comparable_lib array_lib array_lib_test)
test/comparable_lib_test.exe: $(call o_mod,constant_lib comparable_lib comparable_lib_test)
test/character_lib_test.exe: $(call o_mod,character_lib character_lib_test)
test/constant_lib_test.exe: $(call o_mod,comparable_lib constant_lib constant_lib_test)
test/sort_lib_test.exe: $(call o_mod,constant_lib stack_lib comparable_lib random_lib sort_lib sort_lib_test)
test/list_lib_test.exe: $(call o_mod,comparable_lib list_lib list_lib_test)
test/stack_lib_test.exe: $(call o_mod,stack_lib stack_lib_test)
test/queue_lib_test.exe: $(call o_mod,queue_lib queue_lib_test)
test/io_lib_test.exe: $(call o_mod,config_lib constant_lib character_lib comparable_lib io_lib io_lib_test)
test/config_lib_test.exe: $(call o_mod,config_lib config_lib_test)
test/binary_tree_map_lib_test.exe: $(call o_mod,binary_tree_map_lib binary_tree_map_lib_test)
test/sac_lib_test.exe: $(call o_mod,character_lib sac_lib sac_lib_test)
test/path_lib_test.exe: $(call o_mod,path_lib path_lib_test)
test/geodetic_lib_test.exe: $(call o_mod,constant_lib comparable_lib geodetic_lib geodetic_lib_test)
test/math_lib_test.exe: $(call o_mod,comparable_lib math_lib math_lib_test)
test/dual_lib_test.exe: $(call o_mod,comparable_lib dual_lib dual_lib_test)
test/optimize_lib_test.exe: $(call o_mod,comparable_lib constant_lib array_lib optimize_lib optimize_lib_test)

test/io_lib_illegal_form_argument_errortest.exe: $(call o_mod,config_lib character_lib io_lib io_lib_illegal_form_argument_errortest)
test/binary_tree_map_lib_add_too_long_key_errortest.exe: $(call o_mod,binary_tree_map_lib binary_tree_map_lib_add_too_long_key_errortest)
test/sac_lib_get_iftype_for_undefined_value_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_get_iftype_for_undefined_value_errortest)
test/sac_lib_get_imagsrc_for_undefined_value_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_get_imagsrc_for_undefined_value_errortest)
test/sac_lib_set_iftype_with_invalid_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_iftype_with_invalid_argument_errortest)
test/sac_lib_set_kevnm_with_too_long_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_kevnm_with_too_long_argument_errortest)
test/sac_lib_set_kstnm_with_too_long_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_kstnm_with_too_long_argument_errortest)


# Rules
define ERRORTEST_F90_TEMPLATE =
src/$(1)_$(2)_errortest.f90: $(1)_errortest.f90 $(1)_errortest/$(2).f90
	mkdir -p $$(@D)
	{
	   cat $$^
	   echo '   stop'
	   echo 'end program main'
	} | $(CPP) $(CPP_FLAGS) -D __FILE__='"$$@"' -o $$@
endef
$(foreach stem,$(ERRORTEST_STEMS),$(foreach branch,$(patsubst $(stem)_%_errortest,%,$(filter $(stem)_%,$(ERRORTEST_NAMES))),$(eval $(call ERRORTEST_F90_TEMPLATE,$(stem),$(branch)))))

test/%_errortest.exe.tested: test/%_errortest.exe
	cd $(@D)
	! ./$(<F)
	touch $(@F)
test/%_test.exe.tested: test/%_test.exe
	cd $(@D)
	./$(<F)
	touch $(@F)
test/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$^)


bin/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$^)


%_lib.mod %_lib.o: src/%_lib.f90
	$(FC) $(FFLAGS) -c -o $*_lib.o $<
	touch $*_lib.mod
%.o: src/%.f90
	$(FC) $(FFLAGS) -c -o $*.o $<


src/%.f90: %.f90 fortran_lib.h
	mkdir -p $(@D)
	$(CPP) $(CPP_FLAGS) $< $@
%.f90: %.f90.erb fortran_lib.h
	$(ERB) $(ERB_FLAGS) $< >| $@


define DEPS_RULE_TEMPLATE =
dep/$(1)/%: | dep/$(1).updated ;
endef
$(foreach f,$(DEPS),$(eval $(call DEPS_RULE_TEMPLATE,$(f))))

dep/%.updated: config/dep/%.ref dep/%.synced
	cd $(@D)/$*
	git fetch origin
	git merge "$$(cat ../../$<)"
	cd -
	if [[ -r dep/$*/Makefile ]]; then
	   $(MAKE) -C dep/$*
	fi
	touch $@

dep/%.synced: config/dep/%.uri | dep/%
	cd $(@D)/$*
	git remote rm origin
	git remote add origin "$$(cat ../../$<)"
	cd -
	touch $@

$(DEPS:%=dep/%): dep/%:
	git init $@
	cd $@
	git remote add origin "$$(cat ../../config/dep/$*.uri)"
