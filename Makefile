# Constants
DEPS := fort

MY_ERB ?= erb
ERB := ${MY_ERB}
ERB_FLAGS :=

MY_RUBY ?= ruby
RUBY := ${MY_RUBY}

MY_FC ?= gfortran
FC := $(MY_FC)
ifeq ($(FC),ifort)
   FFLAG_COMMON := -warn -assume realloc_lhs -no-ftz -no-wrap-margin
   FFLAG_DEBUG := -check nouninit -trace -O0 -p -g -DDEBUG -debug all
   FFLAG_OPTIMIZE := -openmp -ip -ipo -parallel -O3 -xHost
   LAPACK := -mkl
else
   FFLAG_COMMON := -ffree-line-length-none -fmax-identifier-length=63 -pipe -Wall
   FFLAG_DEBUG := -fcheck=all -O0 -fbacktrace -ffpe-trap=invalid,zero,overflow -ggdb -pg --coverage -DDEBUG
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

export MY_SHA256SUM ?= sha256sum
SHA256SUM := $(MY_SHA256SUM)

export MY_SED ?= sed

export MY_PYTHON ?= python3
PYTHON := $(MY_PYTHON)


all_files := $(shell git ls-files)
files := $(all_files)


parse_stem = $(subst @, ,$(subst ~,=,$(1)))
get = $(wordlist 2,2,$(subst =, ,$(filter $(1)=%,$(call parse_stem,$(2)))))


define names_template =
$(call get,name,$(1))_files := $$(filter $(call get,file_pattern,$(1)),$$(files))
$(call get,name,$(1))_names := $$($(call get,name,$(1))_files:$(call get,name_pattern,$(1))=%)
files := $$(filter-out $$($(call get,name,$(1))_files),$$(files))
endef
$(foreach params,name~param@file_pattern~%.f90.params@name_pattern~%.f90.params \
                 name~template@file_pattern~%_template.f90.erb@name_pattern~%.f90.erb \
                 name~test_erb@file_pattern~%_test.f90.erb@name_pattern~%.f90.erb \
                 name~test_f90@file_pattern~%_test.f90@name_pattern~%.f90 \
                 name~errortest_erb@file_pattern~%_errortest.f90.erb@name_pattern~%.f90.erb \
                 name~errortest_f90@file_pattern~%_errortest.f90@name_pattern~%.f90 \
                 name~lib_erb@file_pattern~%_lib.f90.erb@name_pattern~%.f90.erb \
                 name~lib_f90@file_pattern~%_lib.f90@name_pattern~%.f90 \
                 name~exe_erb@file_pattern~%.f90.erb@name_pattern~%.f90.erb \
                 name~exe_f90@file_pattern~%.f90@name_pattern~%.f90 \
   ,$(eval $(call names_template,$(params))))


lib_names := $(lib_erb_names) $(lib_f90_names) $(param_names)
exe_names := $(exe_erb_names) $(exe_f90_names)
test_names := $(test_erb_names) $(test_f90_names) $(errortest_erb_names) $(errortest_f90_names)
names := $(lib_names) $(exe_names) $(test_names)


# Configurations
.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDARY:
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

.PHONY: all-$(1) src-$(1) exe-$(1) check-$(1) clean-$(1)

all: all-$(1)
all-$(1): src-$(1) exe-$(1)
src-$(1): deps $(names:%=$(1)/src/%.f90)
exe-$(1): deps $(exe_names:%=$(1)/bin/%.exe)


check: check-$(1)
check-$(1): \
   deps \
   $$(addprefix $(1)/, \
      $(test_names:%=test/%.exe.tested))


clean: clean-$(1)
clean-$(1):
	rm -f $(1)/*.o
	rm -f $(1)/*.mod


# Tasks
-include $$(names:%=$(1)/src/%.f90.make)

## Executables
$(1)/bin/sac_to_json.exe: $$(call o_mod_$(1),character_lib sac_lib sac_to_json)
$(1)/bin/text_dump_array.exe: $$(call o_mod_$(1),character_lib io_lib text_dump_array)
$(1)/bin/get_wgs84_from_ecef.exe: $$(call o_mod_$(1),character_lib constant_lib geodetic_lib get_wgs84_from_ecef)
$(1)/bin/get_ecef_from_wgs84.exe: $$(call o_mod_$(1),character_lib constant_lib geodetic_lib get_ecef_from_wgs84)
$(1)/bin/etas_solve.exe: $$(call o_mod_$(1),comparable_lib constant_lib array_lib optimize_lib ad_lib math_lib geometry_lib etas_lib etas_solve)
$(1)/bin/etas_intensity.exe: $$(call o_mod_$(1),comparable_lib ad_lib math_lib geometry_lib etas_lib etas_intensity)
$(1)/bin/etas_log_likelihood.exe: $$(call o_mod_$(1),comparable_lib ad_lib math_lib geometry_lib etas_lib etas_log_likelihood)

## Tests
$(1)/test/array_lib_test.exe: $$(call o_mod_$(1),comparable_lib array_lib array_lib_test)
$(1)/test/comparable_lib_test.exe: $$(call o_mod_$(1),constant_lib comparable_lib comparable_lib_test)
$(1)/test/character_lib_test.exe: $$(call o_mod_$(1),character_lib character_lib_test)
$(1)/test/constant_lib_test.exe: $$(call o_mod_$(1),comparable_lib constant_lib constant_lib_test)
$(1)/test/sort_lib_test.exe: $$(call o_mod_$(1),constant_lib stack_lib array_lib comparable_lib random_lib sort_lib sort_lib_test)
$(1)/test/list_lib_test.exe: $$(call o_mod_$(1),comparable_lib list_lib list_lib_test)
$(1)/test/stack_lib_test.exe: $$(call o_mod_$(1),stack_lib stack_lib_test)
$(1)/test/queue_lib_test.exe: $$(call o_mod_$(1),queue_lib queue_lib_test)
$(1)/test/io_lib_test.exe: $$(call o_mod_$(1),character_lib comparable_lib io_lib io_lib_test)
$(1)/test/config_lib_test.exe: $$(call o_mod_$(1),config_lib config_lib_test)
$(1)/test/config_lib_test.exe.tested: $(1)/test/config_lib_test.exe.in
$(1)/test/sac_lib_test.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_test)
$(1)/test/path_lib_test.exe: $$(call o_mod_$(1),path_lib path_lib_test)
$(1)/test/geodetic_lib_test.exe: $$(call o_mod_$(1),constant_lib comparable_lib geodetic_lib geodetic_lib_test)
$(1)/test/math_lib_test.exe: $$(call o_mod_$(1),comparable_lib math_lib math_lib_test)
$(1)/test/dual_lib_test.exe: $$(call o_mod_$(1),comparable_lib dual_lib dual_lib_test)
$(1)/test/optimize_lib_test.exe: $$(call o_mod_$(1),comparable_lib constant_lib array_lib math_lib ad_lib optimize_lib optimize_lib_test)
$(1)/test/etas_lib_test.exe.tested: $(1)/test/etas_inputs_111.in $(1)/test/etas_inputs_211.in $(1)/test/etas_inputs_311.in
$(1)/test/etas_lib_test.exe: $$(call o_mod_$(1),comparable_lib ad_lib math_lib geometry_lib etas_lib etas_lib_test)
$(1)/test/ad_lib_test.exe: $$(call o_mod_$(1),constant_lib comparable_lib ad_lib ad_lib_test)
$(1)/test/geometry_lib_test.exe: $$(call o_mod_$(1),comparable_lib math_lib geometry_lib geometry_lib_test)
$(1)/test/quadrature_lib_test.exe: $$(call o_mod_$(1),comparable_lib ad_lib quadrature_lib quadrature_lib_test)
$(1)/test/quadpack_lib_test.exe: $$(call o_mod_$(1),comparable_lib ad_lib quadpack_lib quadpack_lib_test)
$(1)/test/i_r_dict_lib_test.exe: $$(call o_mod_$(1),comparable_lib i_r_pair_lib i_r_dict_lib i_r_dict_lib_test)


$(1)/test/io_lib_errortest.exe: $$(call o_mod_$(1),character_lib io_lib io_lib_errortest)
$(1)/test/sac_lib_errortest.exe: $$(call o_mod_$(1),character_lib sac_lib sac_lib_errortest)

# Rules
$(1)/src/%.f90.make: script/make_include_make.sh $(1)/src/%.f90.sha256 script/fort_deps.sh
	$$< $(1)/src/$$*.f90 $(1) >| $$@


$(1)/test/%_errortest.exe.tested: script/run_errortest.sh $(1)/test/%_errortest.exe
	cd $$(@D)
	$$(addprefix $$(CURDIR)/,$$^)
	touch $$(CURDIR)/$$@


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
endef
$(foreach b,debug release,$(eval $(call MAIN_TEMPLATE,$(b))))


i_r_pair_lib.f90: pair_template.f90.erb
i_r_dict_lib.f90: rbtree_template.f90.erb
stack_lib.f90: stack_template.f90.erb


bin/%.py.tested: bin/%.py
	$(MY_PYTHON) $< --test
	touch $@


%.f90: script/expand_template.sh %.f90.params
	mkdir -p $(@D)
	ERB="$(ERB)" ERB_FLAGS="$(ERB_FLAGS)" $^ $* >| $@


%.f90.params: %.f90.params.rb dep/fort.updated
	mkdir -p $(@D)
	export RUBYLIB=$(CURDIR)/dep/fort/lib:"$${RUBYLIB:-}"
	$(RUBY) $< >| $@


%.f90: %.f90.erb dep/fort.updated
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
