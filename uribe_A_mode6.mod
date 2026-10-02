// ============================================================
//  uribe_A_mode6.mod
//  Uribe-A: moda de la posterior con mode_compute = 6
//  (rutina Monte Carlo, sin derivadas). Sin Metropolis-Hastings.
//  Genera uribe_A_mode6/Output/uribe_A_mode6_mode.mat
// ============================================================

@#include "uribe_core.mod"

// ---- Uribe-A: apagar el shock transitorio a la meta ----
rho_zm2 = 0;

shocks;
var e_zm2 = 0;
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

// ---- Persistencias ----
rho_xi,    , , ,  beta_pdf,  0.7,  0.2;
rho_theta, , , ,  beta_pdf,  0.7,  0.2;
rho_z,     , , ,  beta_pdf,  0.7,  0.2;
rho_g,     , , ,  beta_pdf,  0.3,  0.2;
rho_zm,    , , ,  beta_pdf,  0.3,  0.2;
rho_gm,    , , ,  beta_pdf,  0.3,  0.2;

// ---- Desvíos de los shocks ----
stderr e_xi,    , 0, ,  normal_pdf,  1,     1;
stderr e_theta, , 0, ,  normal_pdf,  1,     1;
stderr e_z,     , 0, ,  normal_pdf,  1,     1;
stderr e_g,     , 0, ,  normal_pdf,  1,     1;
stderr e_zm,    , 0, ,  normal_pdf,  0.25,  0.25;
stderr e_gm,    , 0, ,  normal_pdf,  0.25,  0.25;

// ---- Measurement errors ----
stderr dy_obs,  , 0, ,  normal_pdf,  0.194, 0.112;
stderr r_obs,   , 0, ,  normal_pdf,  0.144, 0.083;
stderr di_obs,  , 0, ,  normal_pdf,  0.049, 0.028;

end;

estimation(datafile      = datos_uribe,
           mode_compute  = 6,
           mh_replic     = 0,
           plot_priors   = 0,
           nograph);