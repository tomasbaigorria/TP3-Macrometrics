// ============================================================
//  uribe_B_mode.mod
//  Uribe-B: SIN shock permanente a la meta (rho_gm = sigma_gm = 0)
//           Shock transitorio muy persistente (rho_zm2 = 0.999)
//  Estimación por maximización de la posterior, mode_compute = 5
// ============================================================

@#include "uribe_core.mod"

// ---- Uribe-B: apagar gm, activar zm2 muy persistente ----
rho_gm  = 0;
rho_zm2 = 0.999;

shocks;
var e_gm = 0;
end;

varobs dy_obs r_obs di_obs;

estimated_params;

// ---- Estructurales ----
phi,       , 0,    ,  normal_pdf,  50,    20;
alpha_pi,  , 0,    ,  normal_pdf,  1.5,   0.25;
alpha_y,   , 0,    ,  normal_pdf,  0.125, 0.1;
gamma_m,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
gamma_I,   , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;
delta,     , 0,  1 ,  uniform_pdf,  ,  ,  0, 1;

// ---- Persistencias (sin rho_gm, sin rho_zm2) ----
rho_xi,    , , ,  beta_pdf,  0.7,  0.2;
rho_theta, , , ,  beta_pdf,  0.7,  0.2;
rho_z,     , , ,  beta_pdf,  0.7,  0.2;
rho_g,     , , ,  beta_pdf,  0.3,  0.2;
rho_zm,    , , ,  beta_pdf,  0.3,  0.2;

// ---- Desvíos (sin e_gm, con e_zm2) ----
stderr e_xi,    , 0, ,  normal_pdf,  1,     1;
stderr e_theta, , 0, ,  normal_pdf,  1,     1;
stderr e_z,     , 0, ,  normal_pdf,  1,     1;
stderr e_g,     , 0, ,  normal_pdf,  1,     1;
stderr e_zm,    , 0, ,  normal_pdf,  0.25,  0.25;
stderr e_zm2,   , 0, ,  normal_pdf,  0.25,  0.25;

// ---- Measurement errors ----
stderr dy_obs,  , 0, ,  normal_pdf,  0.194, 0.112;
stderr r_obs,   , 0, ,  normal_pdf,  0.144, 0.083;
stderr di_obs,  , 0, ,  normal_pdf,  0.049, 0.028;

end;

estimation(datafile      = datos_uribe,
           mode_compute  = 5,
           mode_check,
           mh_replic     = 0,
           plot_priors   = 1,
           graph_format  = eps,
           nograph);