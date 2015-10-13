# fortran_lib

This Fortran library provides basic data structures, algorithms and some handy utilities, which are applicable for almost all of intrinsic types.

[![Build Status](https://travis-ci.org/kshramt/fortran_lib.svg?branch=master)](https://travis-ci.org/kshramt/fortran_lib)

## Compilation

```bash
make
```

You may get `internal compiler error: Killed (program f951)` if your computer does not have enoguh memory (about 3 GB for GCC).

## Useful Codes

### `bin/etas_solve.sh` and `release/bin/etas_solve.exe`

These programs estimate the ETAS parameters.
Please run

```bash
bin/etas_solve.sh --help
```

for the details.

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

### `release/src/ad_lib.f90`

This module contains types and routines for automatic differentiation up to second-order derivatives with 1, 2 and 5 independent variables.

### `release/src/comparable_lib.f90`

This module contains `almost_equal`.

## Dependencies

- Git
- GNU Make 3.82 or newer
- GFortran 4.9 or newer
- Ruby 1.9 or newer
- BLAS and Lapack

### Notes for Mac users

GNU version of basic commands (`sed`, `awk`, `getopt` and so on) are assumed to be installed.
For example, `script/make_include_make.sh` does not work with BSD-sed.
Please install GNU Coreutils and GNU version of other necessary commands.

## License

GPL Version 3.
