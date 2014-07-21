#if (defined(__GFORTRAN__) && (__GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 7))) || (defined(__INTEL_COMPILER) && __INTEL_COMPILER >= 1200)
#define NEWUNIT_AVAILABLE 1
#endif
