// ============================================================
//  uribe_bfm_e2_mode.mod  —  Punto 3, ESTIMACIÓN 2
//
//  Agrega el déficit primario / PBI como cuarto observable.
//  Sigue SIN shock a la meta z^m2, pero ahora zetaM está activo
//  y se estiman rho_zetaM y sigma_zetaM (con datos fiscales sus
//  parámetros SÍ están identificados: es el punto de la nota 9).
//
//  Maximización de la posterior, mode_compute = 5.
//
//  Uso:  >> dynare uribe_bfm_e2_mode
// ============================================================

@#include "uribe_bfm_est_core.mod"

// ------------------------------------------------------------
//  Calibración que NO se estima
// ------------------------------------------------------------
gamma_F   = 0;      // consigna: deuda no financiada
calib_sb  = 1;      // se fija la deuda de SS, tau sale como residuo
sb_target = 2.45*scale;

// z^m2 sigue apagado (rho_zm2 = 0 por defecto en el core)
shocks;
var e_zm2 = 0;
end;

varobs dy_obs r_obs di_obs def_obs;

estimated_params;

// ---- Estructurales (phi_M hereda la prior de alpha_pi) ----
phi,       , 0,    ,  normal_pdf,  50,    20;
phi_M,     , 0,    ,  normal_pdf,  1.5,   0.25;
alpha_y,   , 0,    ,  normal_pdf,  0.125, 0.1;
gamma_m,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
gamma_I,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
delta,     , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;

// ---- Persistencias ----
rho_xi,    , , ,  beta_pdf,  0.7,  0.2;
rho_theta, , , ,  beta_pdf,  0.7,  0.2;
rho_z,     , , ,  beta_pdf,  0.7,  0.2;
rho_g,     , , ,  beta_pdf,  0.3,  0.2;
rho_zm,    , , ,  beta_pdf,  0.3,  0.2;

// ---- Bloque fiscal ----
//  rho_zetaM y sigma_zetaM con priors análogos a los de zetaF,
//  como pide la consigna.
rho_zetaF, , , ,      beta_pdf,    0.7,  0.2;
rho_zetaM, , , ,      beta_pdf,    0.7,  0.2;
phi_F,     , 0,  1 ,  beta_pdf,    0.5,  0.25;
gamma_M,   , 0,    ,  normal_pdf,  5,    2.2360680;

// ---- Desvíos de los shocks ----
stderr e_xi,    , 0, ,  normal_pdf,  1,     1;
stderr e_theta, , 0, ,  normal_pdf,  1,     1;
stderr e_z,     , 0, ,  normal_pdf,  1,     1;
stderr e_g,     , 0, ,  normal_pdf,  1,     1;
stderr e_zm,    , 0, ,  normal_pdf,  0.25,  0.25;
stderr e_zetaF, , 0, ,  normal_pdf,  1,     1;
stderr e_zetaM, , 0, ,  normal_pdf,  1,     1;

// ---- Measurement errors ----
stderr dy_obs,  , 0, ,  normal_pdf,  0.194, 0.112;
stderr r_obs,   , 0, ,  normal_pdf,  0.144, 0.083;
stderr di_obs,  , 0, ,  normal_pdf,  0.049, 0.028;

//  def_obs: "a lo mucho puede explicar 10% de la varianza del
//  observable". var(def_obs) = 4.7247 (armar_datos_fiscal.m), asi
//  que el 10% corresponde a un desvio de sqrt(0.10*4.7247) = 0.6874.
//  Se toma ese valor como COTA SUPERIOR de la prior (lectura literal
//  de "a lo mucho") y se centra la prior en la mitad. Alternativa:
//  centrarla en la cota; cambia una linea.
stderr def_obs, , 0, 0.6874 ,  normal_pdf,  0.3437,  0.1718;

end;

estimation(datafile      = datos_uribe_bfm,
           mode_compute  = 5,
           mode_check,
           mh_replic     = 0,
           plot_priors   = 1,
           graph_format  = eps,
           nograph);
