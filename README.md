# fortran_lib

This Fortran library provides basic data structures, algorithms and some handy utilities, which are applicable for almost all of intrinsic types.

## Modules

### `ad_lib`

This module contains types and routines for automatic differentiation up to second-order derivatives with 1, 2 and 5 independent variables.

### `comparable_lib`

This module contains `almost_equal`.

## Command line programs

### `etas_solve.exe`

This program estimates ETAS parameters.

### `sac_to_json.exe`

This program converts binary SAC file to JSON format.

## Compilation

```bash
gmake
gmake check
```

## Dependencies

- GNU Make 3.82 or newer.
- GFortran 4.9 or newer.
- Ruby 1.9 or newer.

## License

GPL Version 3.
