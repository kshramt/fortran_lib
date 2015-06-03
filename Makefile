# Constants
DEPS := fort

MY_ERB ?= erb
ERB := ${MY_ERB}
ERB_FLAGS := -T '-' -P

MY_FC ?= gfortran
FC := $(MY_FC)
ifeq ($(FC),ifort)
   FFLAG_COMMON := -warn -assume realloc_lhs -no-ftz
   FFLAG_DEBUG := -check nouninit -trace -O0 -p -g -DDEBUG -debug all
   FFLAG_OPTIMIZE := -openmp -ip -ipo -parallel -O3 -xHost
   LAPACK := -mkl
else
   FFLAG_COMMON := -ffree-line-length-none -fmax-identifier-length=63 -pipe -Wall
   FFLAG_DEBUG := -fbounds-check -O0 -fbacktrace -ffpe-trap=invalid,zero,overflow -ggdb -pg --coverage -DDEBUG
   FFLAG_OPTIMIZE := -O3 -flto -fwhole-program
   ifneq ($(shell uname -s),Darwin)
      FFLAG_OPTIMIZE += -march=native -fopenmp -ftree-parallelize-loops=$(shell nproc)
   endif
   LAPACK := -llapack -lblas
endif
FFLAGS_release := $(FFLAG_COMMON) $(FFLAG_OPTIMIZE)
FFLAGS_debug := $(FFLAG_COMMON) $(FFLAG_DEBUG)

MY_CPP ?= cpp
CPP := $(MY_CPP)
CPP_FLAG_COMMON := -P -C -nostdinc
ifeq ($(FC),ifort)
   CPP_FLAG_COMMON += -D __INTEL_COMPILER
endif
CPP_FLAGS_release := $(CPP_FLAG_COMMON)
CPP_FLAGS_debug := $(CPP_FLAG_COMMON) -DDEBUG

MY_SHA256SUM ?= sha256sum
SHA256SUM := $(MY_SHA256SUM)

FILES := $(shell git ls-files)
F90_NAMES := $(patsubst %.f90,%,$(filter %.f90,$(FILES)))
ERB_F90_NAMES := $(patsubst %.f90.erb,%,$(filter %.f90.erb,$(FILES)))
F90_NAMES += $(ERB_F90_NAMES)
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
export SHELL := /bin/bash
export SHELLOPTS := pipefail:errexit:nounset:noclobber


# Commands
.PHONY: deps all check clean
all:
deps: $(DEPS:%=dep/%.updated)


# Functions
sha256 = $(1:%=%.sha256)
unsha256 = $(1:%.sha256=%)

define MAIN_TEMPLATE =
# Functions
mod_$(1) = $$(patsubst %,$(1)/%.mod,$$(filter %_lib,$$(1)))
o_mod_$(1) = $$(1:%=$(1)/%.o) $$(call mod_$(1),$$(1))

.PHONY: all-$(1) check-$(1) clean-$(1)

all: all-$(1)
all-$(1): deps $(addprefix $(1)/,$(patsubst %,src/%.f90,$(filter-out $(ERRORTEST_TEMPLATE_NAMES) $(ERRORTEST_IMPL_NAMES) $(TEMPLATE_NAMES),$(F90_NAMES))) $(patsubst %,src/%.f90,$(ERRORTEST_NAMES)) $(EXE_NAMES:%=bin/%.exe))


check: check-$(1)
check-$(1): deps $(addprefix $(1)/,$(TEST_NAMES:%=test/%.exe.tested) $(ERRORTEST_NAMES:%=test/%.exe.tested))


clean: clean-$(1)
clean-$(1):
	rm -f $(1)/*.o
	rm -f $(1)/*.mod


# Tasks
-include $(addprefix $(1)/,$(LIB_NAMES:%=src/%.f90.make) $(EXE_NAMES:%=src/%.f90.make) $(TEST_NAMES:%=src/%.f90.make) $(ERRORTEST_NAMES:%=src/%.f90.make))

## Executables
$(1)/bin/sac_to_json.exe: $$(call o_mod_$(1),character_lib sac_lib sac_to_json)
$(1)/bin/text_dump_array.exe: $$(call o_mod_$(1),constant_lib character_lib config_lib io_lib text_dump_array)
$(1)/bin/get_wgs84_from_ecef.exe: $$(call o_mod_$(1),character_lib constant_lib geodetic_lib get_wgs84_from_ecef)
$(1)/bin/get_ecef_from_wgs84.exe: $$(call o_mod_$(1),character_lib constant_lib geodetic_lib get_ecef_from_wgs84)
$(1)/bin/etas_solve.exe: $$(call o_mod_$(1),comparable_lib constant_lib array_lib optimize_lib ad_lib etas_lib etas_solve)
$(1)/bin/etas_intensity.exe: $$(call o_mod_$(1),ad_lib etas_lib etas_intensity)
$(1)/bin/etas_log_likelihood.exe: $$(call o_mod_$(1),ad_lib etas_lib etas_log_likelihood)

## Tests
$(1)/test/array_lib_test.exe: $$(call o_mod_$(1),comparable_lib array_lib array_lib_test)
$(1)/test/comparable_lib_test.exe: $$(call o_mod_$(1),constant_lib comparable_lib comparable_lib_test)
$(1)/test/character_lib_test.exe: $$(call o_mod_$(1),character_lib character_lib_test)
$(1)/test/constant_lib_test.exe: $$(call o_mod_$(1),comparable_lib constant_lib constant_lib_test)
$(1)/test/sort_lib_test.exe: $$(call o_mod_$(1),constant_lib stack_lib array_lib comparable_lib random_lib sort_lib sort_lib_test)
$(1)/test/list_lib_test.exe: $$(call o_mod_$(1),comparable_lib list_lib list_lib_test)
$(1)/test/stack_lib_test.exe: $$(call o_mod_$(1),stack_lib stack_lib_test)
$(1)/test/queue_lib_test.exe: $$(call o_mod_$(1),queue_lib queue_lib_test)
$(1)/test/io_lib_test.exe: $$(call o_mod_$(1),config_lib constant_lib character_lib comparable_lib io_lib io_lib_test)
$(1)/test/config_lib_test.exe: $$(call o_mod_$(1),config_lib config_lib_test)
$(1)/test/binary_tree_map_lib_test.exe: $$(call o_mod_$(1),binary_tree_map_lib binary_tree_map_lib_test)
$(1)/test/sac_lib_test.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_test)
$(1)/test/path_lib_test.exe: $$(call o_mod_$(1),path_lib path_lib_test)
$(1)/test/geodetic_lib_test.exe: $$(call o_mod_$(1),constant_lib comparable_lib geodetic_lib geodetic_lib_test)
$(1)/test/math_lib_test.exe: $$(call o_mod_$(1),comparable_lib math_lib math_lib_test)
$(1)/test/dual_lib_test.exe: $$(call o_mod_$(1),comparable_lib dual_lib dual_lib_test)
$(1)/test/optimize_lib_test.exe: $$(call o_mod_$(1),comparable_lib constant_lib array_lib math_lib optimize_lib optimize_lib_test)
$(1)/test/etas_lib_test.exe: $$(call o_mod_$(1),comparable_lib ad_lib etas_lib etas_lib_test)
$(1)/test/ad_lib_test.exe: $$(call o_mod_$(1),comparable_lib ad_lib ad_lib_test)
$(1)/test/config_lib_test.exe.tested: $(1)/test/config_lib_test.exe.in


$(1)/test/io_lib_illegal_form_argument_errortest.exe: $$(call o_mod_$(1),config_lib character_lib io_lib io_lib_illegal_form_argument_errortest)
$(1)/test/sac_lib_get_iftype_for_undefined_value_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_get_iftype_for_undefined_value_errortest)
$(1)/test/sac_lib_get_imagsrc_for_undefined_value_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_get_imagsrc_for_undefined_value_errortest)
$(1)/test/sac_lib_set_iftype_with_invalid_argument_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_set_iftype_with_invalid_argument_errortest)
$(1)/test/sac_lib_set_kevnm_with_too_long_argument_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_set_kevnm_with_too_long_argument_errortest)
$(1)/test/sac_lib_set_kstnm_with_too_long_argument_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_set_kstnm_with_too_long_argument_errortest)


# Rules
$(1)/src/%.f90.make: script/make_include_make.sh $(1)/src/%.f90.sha256 script/fort_deps.sh
	$$< $(1)/src/$$*.f90 $(1) >| $$@


$(1)/test/%_errortest.exe.tested: $(1)/test/%_errortest.exe
	cd $$(@D)
	! ./$$(<F) && touch $$(@F)
$(1)/test/%_test.exe.tested: $(1)/test/%_test.exe
	cd $$(@D)
	./$$(<F)
	touch $$(@F)
$(1)/test/%.exe:
	mkdir -p $$(@D)
	cd $(1)
	$(FC) $$(FFLAGS_$(1)) -o test/$$*.exe $$(patsubst $(1)/%,%,$$(filter-out %.mod,$$^)) $(LAPACK)
$(1)/test/%.in: data/test/%.in
	mkdir -p $$(@D)
	cp -f $$< $$@


$(1)/bin/%.exe:
	mkdir -p $$(@D)
	cd $(1)
	$(FC) $$(FFLAGS_$(1)) -o bin/$$*.exe $$(patsubst $(1)/%,%,$$(filter-out %.mod,$$^)) $(LAPACK)


$(1)/%_lib.o $(1)/%_lib.mod: $(1)/src/%_lib.f90.sha256
	cd $(1)
	$(FC) $$(FFLAGS_$(1)) -c -o $$*_lib.o src/$$*_lib.f90 $(LAPACK)
	touch $$*_lib.mod

$(1)/%.o: $(1)/src/%.f90.sha256
	cd $(1)
	$(FC) $$(FFLAGS_$(1)) -c -o $$*.o src/$$*.f90 $(LAPACK)

$(1)/src/%.f90.sha256: $(1)/src/%.f90.sha256.new
	@cmp -s $$< $$@ || cp -f $$< $$@

$(1)/src/%.f90.sha256.new: $(1)/src/%.f90
	$(SHA256SUM) $$< >| $$@

$(1)/src/%.f90: %.f90 fortran_lib.h
	mkdir -p $$(@D)
	$(CPP) $$(CPP_FLAGS_$(1)) $$< $$@

.PRECIOUS: $(1)/src/%.f90.sha256.new $(1)/src/%.f90.sha256
endef
$(foreach b,debug release,$(eval $(call MAIN_TEMPLATE,$(b))))


define ERRORTEST_F90_TEMPLATE =
$(1)_$(2)_errortest.f90: $(1)_errortest.f90 $(1)_errortest/$(2).f90
	{
	   cat $$^
	   echo '   stop'
	   echo 'end program main'
	} >| $$@
endef
$(foreach stem,$(ERRORTEST_STEMS),$(foreach branch,$(patsubst $(stem)_%_errortest,%,$(filter $(stem)_%,$(ERRORTEST_NAMES))),$(eval $(call ERRORTEST_F90_TEMPLATE,$(stem),$(branch)))))


%.f90: %.f90.erb dep/fort/lib/fort.rb
	export RUBYLIB=$(CURDIR)/dep/fort/lib:"$${RUBYLIB:-}"
	$(ERB) $(ERB_FLAGS) $< >| $@


define DEPS_RULE_TEMPLATE =
dep/$(1)/%: | dep/$(1).updated ;
endef
$(foreach f,$(DEPS),$(eval $(call DEPS_RULE_TEMPLATE,$(f))))


$(DEPS:%=dep/%.updated): dep/%.updated: config/dep/%.ref dep/%.synced
	cd $(@D)/$*
	git fetch origin
	git checkout "$$(cat ../../$<)"
	cd -
	if [[ -r dep/$*/Makefile ]]; then
	   $(MAKE) -C dep/$*
	fi
	touch $@

$(DEPS:%=dep/%.synced): dep/%.synced: config/dep/%.uri | dep/%
	cd $(@D)/$*
	git remote rm origin
	git remote add origin "$$(cat ../../$<)"
	cd -
	touch $@

$(DEPS:%=dep/%): dep/%:
	git init $@
	cd $@
	git remote add origin "$$(cat ../../config/dep/$*.uri)"
