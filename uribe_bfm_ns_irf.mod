// ============================================================
//  uribe_bfm_ns_irf.mod  —  PUNTO 4
//  Uribe-BFM con inflación fiscal (casi) no estacionaria.
//
//  IDEA. En BFM (ec. 13 del paper) el bloque monetario de la
//  economía sombra es  E_t pi^F_{t+1} = phi_F * pi^F_t.
//  O sea: la PERSISTENCIA de la inflación fiscal está gobernada
//  por phi_F, el parámetro con el que el banco central acomoda la
//  inflación de origen fiscal. BFM restringen phi_F <= 1.
//
//  En el límite phi_F = 1 la inflación fiscal es un martingala:
//  E_t pi^F_{t+1} = pi^F_t. Un shock zeta^F desplaza pi^F de forma
//  PERMANENTE, igual que X^m en Uribe. Es decir, la modificación
//  que vuelve no estacionaria a pi^F no requiere agregar ninguna
//  tendencia exógena: es el caso de borde del propio espacio de
//  parámetros de BFM (acomodación total).
//
//  IMPLEMENTACIÓN. Se calibra phi_F = 0.999 en vez de 1, por la
//  misma razón por la que Uribe-B usa rho_zm2 = 0.999: el modelo
//  sigue siendo formalmente estacionario, Blanchard-Kahn se
//  verifica y no hace falta una representación estacionaria
//  alternativa. Los dos shocks quedan simétricos: zm2 con
//  rho = 0.999 (tendencia monetaria) y zetaF con phi_F = 0.999
//  (tendencia fiscal).
//
//  Parámetros: moda de la Estimación 3 (punto 3).
//
//  Uso:  dynare uribe_bfm_ns_irf
//        dynare uribe_bfm_ns_irf -DphiF=0.4508807   (caso estimado)
// ============================================================

@#include "uribe_bfm_est_core.mod"

@#ifndef phiF
@#define phiF = 0.999
@#endif

// ---- Calibración fiscal ----
gamma_F   = 0;
calib_sb  = 1;
sb_target = 2.45*scale;

// Las dos tendencias, simétricas
rho_zm2   = 0.999;      // tendencia monetaria a la Uribe
phi_F     = @{phiF};    // tendencia fiscal: acomodación (casi) total

// ---- Moda de la Estimación 3 ----
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

stoch_simul(order=1, irf=61, nograph, irf_plot_threshold=0,
            conditional_variance_decomposition=[1 4 20 60],
            irf_shocks=(e_zm2, e_zetaF))
    dpi_obs di_obs dy_obs pi piF i r y yhat tau sb sbF;