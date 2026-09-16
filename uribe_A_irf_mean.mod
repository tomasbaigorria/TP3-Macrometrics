@#include "uribe_core.mod"

// ---- Media posterior (MH, 1.000.000 draws) ----
phi       = 103.8626;
alpha_pi  = 2.2878;
alpha_y   = 0.2006;
gamma_m   = 0.5977;
gamma_I   = 0.2850;
delta     = 0.2154;
rho_xi    = 0.9227;
rho_theta = 0.7211;
rho_z     = 0.7200;
rho_g     = 0.2107;
rho_zm    = 0.3593;
rho_gm    = 0.2200;
rho_zm2   = 0;

shocks;
var e_xi    = 2.6829^2;
var e_theta = 0.1310^2;
var e_z     = 0.0985^2;
var e_g     = 0.7481^2;
var e_zm    = 0.1127^2;
var e_gm    = 0.1185^2;
var e_zm2   = 0;
end;

stoch_simul(order=1, irf=21, nograph, conditional_variance_decomposition=[1 4 8 20])
    dy_obs dpi_obs di_obs r_obs y pi i r;