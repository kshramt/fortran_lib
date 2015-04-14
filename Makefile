# Constants
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
CPP_FLAGS := -P -C -nostdinc
ifeq ($(FC),ifort)
   CPP_FLAGS += -D __INTEL_COMPILER
endif

FILES := $(shell git ls-files)
F90_NAMES := $(patsubst %.f90,%,$(filter %.f90,$(FILES)))
F90_NAMES += $(patsubst %.f90.erb,%,$(filter %.f90.erb,$(FILES)))
LIB_NAMES := $(filter %_lib,$(F90_NAMES))
TEMPLATE_NAMES := $(filter %_template,$(F90_NAMES))
TEST_NAMES := $(filter %_test,$(F90_NAMES))
ERRORTEST_TEMPLATE_NAMES := $(filter %_errortest,$(F90_NAMES))
ERRORTEST_STEMS := $(patsubst %_errortest,%,$(ERRORTEST_TEMPLATE_NAMES))
ERRORTEST_IMPL_NAMES := $(foreach name,$(ERRORTEST_TEMPLATE_NAMES),$(filter $(name)/%,$(F90_NAMES)))
ERRORTEST_NAMES := $(addsuffix _errortest,$(subst _errortest/,_,$(ERRORTEST_IMPL_NAMES)))
EXE_NAMES := $(filter-out $(LIB_NAMES) $(TEST_NAMES) $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES) $(TEMPLATE_NAMES),$(F90_NAMES))


# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.ONESHELL:
.PRECIOUS: %.sha256 %.sha256.new
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber


# Functions
sha256 = $(1:%=%.sha256)
unsha256 = $(1:%.sha256=%)
o_mod = $(call sha256,$(1:%=%.o)) $(call sha256,$(addsuffix .mod,$(filter %_lib,$(1))))


# Commands
.PHONY: download-deps arrange-deps all all-impl check check-impl


define INTERFACE_TARGET_TEMPLATE =
$(1):
	$$(MAKE) download-deps
	$$(MAKE) $(1)-impl
endef
$(foreach f,all check,$(eval $(call INTERFACE_TARGET_TEMPLATE,$(f))))


all-impl: arrange-deps $(patsubst %,src/%.f90,$(filter-out $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES) $(TEMPLATE_NAMES),$(F90_NAMES))) $(patsubst %,src/%.f90,$(ERRORTEST_NAMES)) $(EXE_NAMES:%=bin/%.exe)


check-impl: arrange-deps $(TEST_NAMES:%=test/%.exe.tested) $(ERRORTEST_NAMES:%=test/%.exe.tested)


arrange-deps:
download-deps: $(DEPS:%=dep/%.updated)


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
test/sort_lib_test.exe: $(call o_mod,constant_lib stack_lib array_lib comparable_lib random_lib sort_lib sort_lib_test)
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
test/sac_lib_get_iftype_for_undefined_value_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_get_iftype_for_undefined_value_errortest)
test/sac_lib_get_imagsrc_for_undefined_value_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_get_imagsrc_for_undefined_value_errortest)
test/sac_lib_set_iftype_with_invalid_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_iftype_with_invalid_argument_errortest)
test/sac_lib_set_kevnm_with_too_long_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_kevnm_with_too_long_argument_errortest)
test/sac_lib_set_kstnm_with_too_long_argument_errortest.exe: $(call o_mod,character_lib sac_lib sac_lib_set_kstnm_with_too_long_argument_errortest)


# Rules
define ERRORTEST_F90_TEMPLATE =
$(1)_$(2)_errortest.f90: $$(call sha256,$(1)_errortest.f90 $(1)_errortest/$(2).f90)
	mkdir -p $$(@D)
	{
	   cat $$(call unsha256,$$^)
	   echo '   stop'
	   echo 'end program main'
	} >| $$@
endef
$(foreach stem,$(ERRORTEST_STEMS),$(foreach branch,$(patsubst $(stem)_%_errortest,%,$(filter $(stem)_%,$(ERRORTEST_NAMES))),$(eval $(call ERRORTEST_F90_TEMPLATE,$(stem),$(branch)))))

test/%_errortest.exe.tested: test/%_errortest.exe.sha256
	cd $(@D)
	! $(call unsha256,./$(<F)) && touch $(call unsha256,$(@F))
test/%_test.exe.tested: test/%_test.exe.sha256
	cd $(@D)
	$(call unsha256,./$(<F))
	touch $(call unsha256,$(@F))
test/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$(call unsha256,$^))


bin/%.exe:
	mkdir -p $(@D)
	$(FC) $(FFLAGS) -o $@ $(filter-out %.mod,$(call unsha256,$^))


%_lib.mod %_lib.o: src/%_lib.f90.sha256
	$(FC) $(FFLAGS) -c -o $*_lib.o $(call unsha256,$<)
	touch $*_lib.mod
%.o: src/%.f90.sha256
	$(FC) $(FFLAGS) -c -o $*.o $(call unsha256,$<)


src/%.f90: %.f90.sha256 fortran_lib.h.sha256
	mkdir -p $(@D)
	$(CPP) $(CPP_FLAGS) $(call unsha256,$<) $@
%.f90: %.f90.erb.sha256
	export RUBYLIB=dep/fort/lib:$(CURDIR):"$${RUBYLIB}"
	$(ERB) $(ERB_FLAGS) $(call unsha256,$<) >| $@


dep/%.updated: config/dep/%.ref.sha256 dep/%.synced
	cd $(@D)/$*
	git fetch origin
	git checkout "$$(cat ../../$(call unsha256,$<))"
	cd -
	if [[ -r dep/$*/Makefile ]]; then
	   $(MAKE) -C dep/$*
	fi
	touch $@

dep/%.synced: config/dep/%.uri.sha256 | dep/%
	cd $(@D)/$*
	git remote rm origin
	git remote add origin "$$(cat ../../$(call unsha256,$<))"
	cd -
	touch $@

$(DEPS:%=dep/%): dep/%:
	git init $@
	cd $@
	git remote add origin "$$(cat ../../config/dep/$*.uri)"


%.sha256.new: %
	sha256sum $< >| $@


%.sha256: %.sha256.new
	cmp -s $< $@ || cat $< >| $@
