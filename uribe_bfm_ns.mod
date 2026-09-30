// ============================================================
//  uribe_bfm_ns.mod  —  Punto 4: IRFs comparadas
//  Shock monetario no estacionario (e_gm) vs fiscal (e_gpiF)
//  Parámetros: moda de la Estimación 3
// ============================================================

@#include "uribe_bfm_ns_core.mod"

gamma_F   = 0;
calib_sb  = 1;
sb_target = 2.45*scale;

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
phi_F = 0.999;
gamma_M    = 1.0709746;

shocks;
var e_xi    = 2.6059986^2;
var e_theta = 0.0188239^2;
var e_z     = 0.0106765^2;
var e_g     = 0.7517411^2;
var e_zm    = 0.1207503^2;
var e_zm2   = 0.1474294^2;
var e_zetaF = 1.8915389^2;
var e_zetaM = 15.0508679^2;
var e_gm    = 0.1158^2;    // media posterior del MH de Uribe-A
var e_gpiF  = 0.1158^2;    // simétrica a gm
end;

steady;
check;

stoch_simul(order=1, irf=41, nograph, irf_plot_threshold=0,
            irf_shocks=(e_gm, e_gpiF))
    dpi_obs di_obs dy_obs pi piF i r y yhat tau sb sbF dpiF_obs diF_obs;