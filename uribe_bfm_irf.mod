// ============================================================
//  uribe_bfm_irf.mod  —  Parte 2: IRFs ante shocks fiscales
//  Calibración: moda de Uribe-B (uribe_B_mode_mode.mat, mode_compute=5)
//  + parámetros fiscales de la consigna.
//
//  Uso desde MATLAB:
//    dynare uribe_bfm_irf -DphiF=0       (caso phi_F = 0)
//    dynare uribe_bfm_irf -DphiF=0.8     (caso phi_F = 0.8)
//    dynare uribe_bfm_irf -DphiF=0 -DphiM2=1   (robustez phi_M = 2)
// ============================================================

@#ifndef phiF
  @#define phiF = 0
@#endif
@#ifndef phiM2
  @#define phiM2 = 0
@#endif

@#include "uribe_bfm_core.mod"

// ---- Moda de Uribe-B ----
phi       = 99.2565513;
alpha_pi  = 2.2681393;
alpha_y   = 0.1912414;
gamma_m   = 0.6119893;
gamma_I   = 0.2200993;
delta     = 0.2031833;
rho_xi    = 0.9217712;
rho_theta = 0.8796668;
rho_z     = 0.8788902;
rho_g     = 0.1832156;
rho_zm    = 0.2893660;

// ---- Bloque fiscal (consigna) ----
gamma_M   = 20;
gamma_F   = 0;
phi_F     = @{phiF};
@#if phiM2 == 1
phi_M     = 2;          // robustez: BFM, slide 14
@#else
phi_M     = alpha_pi;   // caso base: Uribe-B
@#endif
rho_zetaM = 0.5;
rho_zetaF = 0.5;

shocks;
var e_xi;     stderr 2.5974977;
var e_theta;  stderr 0.0190569;
var e_z;      stderr 0.0107801;
var e_g;      stderr 0.7736894;
var e_zm;     stderr 0.1097280;
var e_zetaM;  stderr 1;
var e_zetaF;  stderr 1;
end;

steady;
check;

stoch_simul(order=1, irf=21, nograph, irf_plot_threshold=0,
            irf_shocks=(e_zetaM, e_zetaF))
    yhat y pi i r sb tau piF sbF tauF dy_obs;
