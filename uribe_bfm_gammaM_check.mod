// ============================================================
//  uribe_bfm_gammaM_check.mod
//  ¿Dónde está la frontera de determinación en gamma_M?
//  Calibrado en la moda de E3, variando solo gamma_M.
//  Uso:  dynare uribe_bfm_gammaM_check -DgM=1.05
// ============================================================
@#ifndef gM
  @#define gM = 1.0710
@#endif

@#include "uribe_bfm_est_core.mod"

gamma_F   = 0;
calib_sb  = 1;
sb_target = 2.45*scale;
rho_zm2   = 0.999;
gamma_M   = @{gM};

phi        = 98.0944170;
phi_M      = 2.2491021;
alpha_y    = 0.1906983;
gamma_m    = 0.5999232;
gamma_I    = 0.2550410;
delta      = 0.2169597;
rho_xi     = 0.9238090;
rho_theta  = 0.8795399;
rho_z      = 0.8788246;
rho_g      = 0.2096751;
rho_zm     = 0.3019206;
rho_zetaF  = 0.8967520;
rho_zetaM  = 0.9867245;
phi_F      = 0.4508807;

steady;
check;
