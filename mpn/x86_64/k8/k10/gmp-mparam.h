/* Generated by tuneup.c, 2009-04-10, gcc 4.2 */

#define MUL_KARATSUBA_THRESHOLD          26
#define MUL_TOOM3_THRESHOLD              85
#define MUL_TOOM4_THRESHOLD             692
#define MUL_TOOM7_THRESHOLD             692

#define SQR_BASECASE_THRESHOLD            0  /* always (native) */
#define SQR_KARATSUBA_THRESHOLD          36
#define SQR_TOOM3_THRESHOLD             132

#define MULLOW_BASECASE_THRESHOLD         0  /* always */
#define MULLOW_DC_THRESHOLD              35
#define MULLOW_MUL_N_THRESHOLD          454

#define DIV_SB_PREINV_THRESHOLD           0  /* always */
#define DIV_DC_THRESHOLD                 60
#define POWM_THRESHOLD                  134

#define GCD_ACCEL_THRESHOLD              59
#define GCDEXT_THRESHOLD                  0  /* always */
#define JACOBI_BASE_METHOD                1

#define DIVREM_1_NORM_THRESHOLD       MP_SIZE_T_MAX  /* never */
#define DIVREM_1_UNNORM_THRESHOLD     MP_SIZE_T_MAX  /* never */
#define MOD_1_NORM_THRESHOLD              0  /* always */
#define MOD_1_UNNORM_THRESHOLD            0  /* always */
#define USE_PREINV_DIVREM_1               0
#define USE_PREINV_MOD_1                  1
#define DIVREM_2_THRESHOLD                0  /* always */
#define DIVEXACT_1_THRESHOLD              0  /* always */
#define MODEXACT_1_ODD_THRESHOLD          0  /* always (native) */

#define GET_STR_DC_THRESHOLD              6
#define GET_STR_PRECOMPUTE_THRESHOLD      7
#define SET_STR_THRESHOLD              7059

#define MUL_FFT_TABLE  { 720, 1568, 3392, 5888, 15360, 45056, 114688, 327680, 1310720, 5242880, 0 }
#define MUL_FFT_MODF_THRESHOLD          848
#define MUL_FFT_THRESHOLD             14848

#define SQR_FFT_TABLE  { 720, 1568, 2880, 5888, 15360, 45056, 114688, 327680, 1310720, 5242880, 12582912, 0 }
#define SQR_FFT_MODF_THRESHOLD          848
#define SQR_FFT_THRESHOLD              5504

/* Tuneup completed successfully, took 305 seconds */