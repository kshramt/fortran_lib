# fortran_lib

This Fortran library provides basic data structures, algorithms and some handy utilities, which are applicable for almost all of intrinsic types.

[![Build Status](https://travis-ci.org/kshramt/fortran_lib.svg?branch=master)](https://travis-ci.org/kshramt/fortran_lib)

## Compilation

```bash
# fortran_lib should be cloned rather than downloaded as a tar file
# because `git ls-files` is used in the build process
git clone https://github.com/kshramt/fortran_lib
cd fortran_lib
make
```

Compilation may fail with `internal compiler error: Killed (program f951)` if your computer does not have enoguh memory (about 3 GB for GFortran).

`*.f90.erb` files are preprocessed by eRuby and `cpp` during the compilation.
Preprocessed pure Fortran code is also available at <https://github.com/kshramt/fortran_lib_expanded> and <https://bitbucket.org/kshramt/fortran_lib_expanded>.
<!-- ```bash -->
<!-- gfortran -o etas_solve.exe etas_solve.f90 [<dependency>...] -lblas -llapack -->
<!-- ``` -->

### Dependencies

- Git
- GNU Make 3.82 or newer
- GFortran 4.9 or newer
- Ruby 1.9 or newer
- BLAS and Lapack

#### Notes for Mac users

GNU version of basic commands (`sed`, `awk`, `getopt` and so on) are assumed to be installed.
For example, `script/make_include_make.sh` does not work with BSD-sed.
Please install GNU Coreutils and GNU version of other necessary commands.

## Useful Codes

### `bin/etas_solve.sh` and `release/bin/etas_solve.exe`

These programs estimate the ETAS parameters.
Please run

```bash
bin/etas_solve.sh --help
```

for the details.
[example/etas_solve/README.md](http://kshramt.github.io/fortran_lib/example/etas_solve/README.html) describes output format of `etas_solve.exe`.

#### Example

```bash
bin/etas_solve.sh \
   --t_normalize_len=1 \
   --m_for_K=6 \
   --t_pre=0 \
   --t_begin=0 \
   --t_end=1000 \
   --data_file=example/etas_solve/catalog.tsv |
   release/bin/etas_solve.exe
```

### `bin/etas_intensity.sh` and `release/bin/etas_intensity.exe`

These programs calculate the intensity function given data and parameters.
Please run

```bash
bin/etas_intensity.sh --help
```

for the details.

### `bin/etas_log_likelihood.sh` and `release/bin/etas_log_likelihood.exe`

These programs calculate log likelihood, gradient and Hessian for given data and successive parameter sets.
Please run

```bash
bin/etas_log_likelihood.sh --help
```

for the details.

### `example/etas_solve/make_catalog.py`

This script generates a synthetic catalog for the temporal ETAS model.

### `release/src/ad_lib.f90`

This module contains types and routines for automatic differentiation up to second-order derivatives with 1, 2 and 5 independent variables.

### `release/src/comparable_lib.f90`

This module contains `almost_equal`.

## License

This program is distributed under the terms of [the GNU General Public License version 3](http://www.gnu.org/licenses/).
