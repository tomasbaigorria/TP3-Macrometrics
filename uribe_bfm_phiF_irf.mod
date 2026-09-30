// ============================================================
//  uribe_bfm_phiF_irf.mod  —  Punto 4, etapa 1 (verificación)
//  Modelo Uribe-BFM en la moda de E3, variando phi_F.
//  BFM ec. (13): E_t pi^F_{t+1} = phi_F * pi^F_t
//  -> phi_F gobierna la persistencia de la inflación fiscal.
//     Con phi_F -> 1, pi^F tiende a un martingala (raíz unitaria).
//
//  Uso:  dynare uribe_bfm_phiF_irf -DphiF=0.999
//        dynare uribe_bfm_phiF_irf -DphiF=0.4508807   (moda E3)
// ============================================================

@#include "uribe_bfm_est_core.mod"

@#ifndef phiF
@#define phiF = 0.999
@#endif

// ---- Calibración fiscal ----
gamma_F   = 0;
calib_sb  = 1;
sb_target = 2.45*scale;
rho_zm2   = 0.999;
phi_F     = @{phiF};

// ---- Moda de E3 ----
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
end;

steady;
check;

stoch_simul(order=1, irf=41, nograph, irf_plot_threshold=0,
            irf_shocks=(e_zetaF, e_zm2))
    dpi_obs di_obs dy_obs pi i r y yhat piF sb sbF tau;