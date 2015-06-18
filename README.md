# fortran_lib

This Fortran library provides basic data structures, algorithms and some handy utilities, which are applicable for almost all of intrinsic types.

## Modules

### `release/src/ad_lib.f90`

This module contains types and routines for automatic differentiation up to second-order derivatives with 1, 2 and 5 independent variables.

### `release/src/comparable_lib.f90`

This module contains `almost_equal`.

## Command line programs

### `release/bin/etas_solve.exe`

This program estimates the ETAS parameters.
Please run

```bash
bin/etas_solve.sh --help
```

for the details.

### `release/bin/etas_intensity.exe`

This program calculates the intensity function given data and the parameters estimated by `etas_solve`.
Please run

```bash
bin/etas_intensity.sh --help
```

for the details.

### `release/bin/etas_log_likelihood.exe`

This program returns log-likelihood, Jacobian and Hessian for given data and successive parameter sets.
Please run

```bash
bin/etas_log_likelihood.sh --help
```

for the details.

### `release/bin/sac_to_json.exe`

This program converts binary SAC file to JSON format.

## Compilation

```bash
gmake
gmake check
```

## Dependencies

- Git
- GNU Make 3.82 or newer.
- GFortran 4.9 or newer.
- Ruby 1.9 or newer.

### Notes for Mac users

GNU version of basic commands (`sed`, `awk`, `getopt` and so on) are assumed to be installed.
For example, `script/make_include_make.sh` does not work with BSD-sed.
Please install GNU Coreutils and GNU version of other necessary commands.

## License

GPL Version 3.
