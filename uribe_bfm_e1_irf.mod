// ============================================================
//  uribe_bfm_e1_irf.mod  —  Punto 3: IRFs, descomposición de varianza
//  y smoother de la ESTIMACIÓN 1. Carga la moda, no la re-estima.
//
//  Modelo Uribe-BFM estimado con los MISMOS observables que
//  Uribe (dy_obs, r_obs, di_obs), sin shock a la meta z^m2 y
//  con shocks fiscales SOLO del tipo zetaF.
//
//  Maximización de la posterior, mode_compute = 5.
//
//  Uso:  >> dynare uribe_bfm_e1_mode
// ============================================================

@#include "uribe_bfm_est_core.mod"

// ------------------------------------------------------------
//  Calibración que NO se estima
// ------------------------------------------------------------
gamma_F   = 0;      // consigna: deuda no financiada
rho_zetaM = 0.5;    // irrelevante: e_zetaM apagado
calib_sb  = 1;      // se fija la deuda de SS, tau sale como residuo
sb_target = 2.45*scale;

// zetaM apagado: sin datos fiscales sus parámetros no están
// identificados (nota 9 de la consigna). Mismo recurso que se usó
// para apagar e_gm en Uribe-B.
shocks;
var e_zetaM = 0;
var e_zm2   = 0;   // E1 no tiene shock a la meta
end;

varobs dy_obs r_obs di_obs;

estimated_params;

// ---- Estructurales (idénticos a Uribe-B, con phi_M en lugar de
//      alpha_pi: alpha_pi ya no aparece en ninguna ecuación y su
//      rol en la regla de Taylor lo cumple phi_M, así que hereda
//      su prior) ----
phi,       , 0,    ,  normal_pdf,  50,    20;
phi_M,     , 0,    ,  normal_pdf,  1.5,   0.25;
alpha_y,   , 0,    ,  normal_pdf,  0.125, 0.1;
gamma_m,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
gamma_I,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
delta,     , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;

// ---- Persistencias (sin rho_gm ni rho_zm2) ----
rho_xi,    , , ,  beta_pdf,  0.7,  0.2;
rho_theta, , , ,  beta_pdf,  0.7,  0.2;
rho_z,     , , ,  beta_pdf,  0.7,  0.2;
rho_g,     , , ,  beta_pdf,  0.3,  0.2;
rho_zm,    , , ,  beta_pdf,  0.3,  0.2;

// ---- Bloque fiscal (priors adicionales de la consigna) ----
//      gamma_M: "media 5 y varianza 5" -> Dynare pide DESVÍO,
//      por eso sqrt(5) = 2.2360680.
rho_zetaF, , , ,      beta_pdf,    0.7,  0.2;
phi_F,     , 0,  1 ,  beta_pdf,    0.5,  0.25;
gamma_M,   , 0,    ,  normal_pdf,  5,    2.2360680;

// ---- Desvíos de los shocks ----
stderr e_xi,    , 0, ,  normal_pdf,  1,     1;
stderr e_theta, , 0, ,  normal_pdf,  1,     1;
stderr e_z,     , 0, ,  normal_pdf,  1,     1;
stderr e_g,     , 0, ,  normal_pdf,  1,     1;
stderr e_zm,    , 0, ,  normal_pdf,  0.25,  0.25;
stderr e_zetaF, , 0, ,  normal_pdf,  1,     1;

// ---- Measurement errors (idénticos a Uribe-A / Uribe-B) ----
stderr dy_obs,  , 0, ,  normal_pdf,  0.194, 0.112;
stderr r_obs,   , 0, ,  normal_pdf,  0.144, 0.083;
stderr di_obs,  , 0, ,  normal_pdf,  0.049, 0.028;

end;

// Datafile: datos_uribe.mat, el mismo del punto 1. Las estimaciones 2 y 3
// usan datos_uribe_bfm.mat, que agrega def_obs; dy_obs, r_obs y di_obs son
// idénticos por construcción (armar_datos_fiscal.m los copia de acá).
estimation(datafile      = datos_uribe,
           mode_compute  = 0,
           mode_file     = 'uribe_bfm_e1_mode/Output/uribe_bfm_e1_mode_mode',
           smoother,
           mh_replic     = 0,
           nograph)
    dpi_obs dy_obs di_obs r_obs def_obs pi i r y yhat tau sb
    zetaF zetaM zm2;

// ---- IRFs y descomposición de varianza en la moda ----
stoch_simul(order=1, irf=21, nograph, irf_plot_threshold=0,
            conditional_variance_decomposition=[1 4 8 20],
            irf_shocks=(e_zm, e_zetaF))
    dy_obs dpi_obs di_obs r_obs y pi i r yhat tau sb def_obs;
