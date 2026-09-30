// ============================================================
//  uribe_bfm_e3_irf_mean.mod
//  IRFs y descomposicion de varianza de la ESTIMACION 3
//  evaluadas en la MEDIA POSTERIOR del Metropolis-Hastings
//  (1.000.000 de draws, mh_drop = 0.5).
//
//  Mismo patron que uribe_A_irf_mean.mod del punto 1: los
//  valores estan escritos a mano porque stoch_simul necesita
//  parametros fijos. Se generaron desde
//  uribe_bfm_e3_mh/Output/uribe_bfm_e3_mh_results.mat
//  para no transcribirlos.
//
//  Comparar contra uribe_bfm_e3_irf.mod, que es lo mismo pero
//  en la moda de mode_compute = 5.
// ============================================================

@#include "uribe_bfm_est_core.mod"

// ---- calibracion que no se estima ----
gamma_F   = 0;
calib_sb  = 1;
sb_target = 2.45*scale;
rho_zm2   = 0.999;

// ---- media posterior (MH) ----
phi        = 104.9305261;
phi_M      = 2.2827386;
alpha_y    = 0.2013108;
gamma_m    = 0.6101195;
gamma_I    = 0.2508794;
delta      = 0.2132464;
rho_xi     = 0.9198774;
rho_theta  = 0.7259092;
rho_z      = 0.7217311;
rho_g      = 0.2035201;
rho_zm     = 0.3771730;
rho_zetaF  = 0.7240513;
rho_zetaM  = 0.9853691;
phi_F      = 0.4896227;
gamma_M    = 1.2176069;

// ---- desvios: stoch_simul pide VARIANZAS ----
shocks;
var e_xi      = 2.6352771^2;
var e_theta   = 0.1330363^2;
var e_z       = 0.1006430^2;
var e_g       = 0.7286739^2;
var e_zm      = 0.1074136^2;
var e_zm2     = 0.1443471^2;
var e_zetaF   = 1.6584136^2;
var e_zetaM   = 15.3014638^2;
end;

steady;
check;

stoch_simul(order=1, irf=21, nograph, irf_plot_threshold=0,
            conditional_variance_decomposition=[1 4 8 20],
            irf_shocks=(e_zm, e_zm2, e_zetaF, e_zetaM))
    dy_obs dpi_obs di_obs r_obs y pi i r yhat tau sb def_obs;
