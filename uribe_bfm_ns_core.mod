// ============================================================
//  uribe_bfm_ns_core.mod  —  núcleo del PUNTO 4
//  Copia de uribe_bfm_est_core.mod con inflación fiscal NO ESTACIONARIA.
//
//  Dos tendencias nominales, simétricas:
//    X^m_t  : meta monetaria (Uribe). Crecimiento gm, AR(1) estacionario.
//    X^F_t  : meta de inflación fiscal (nueva). Crecimiento gpiF, id.
//  Las nominales del bloque real se deflactan por X^m; las del bloque
//  sombra por X^F. Ambas tendencias son I(1) en niveles, así que pi^F
//  es no estacionaria y el modelo queda directamente comparable con
//  el de Uribe.
//
//  Los factores nuevos salen del desfasaje temporal del deflactor:
//    Euler:    X_t/X_{t+1}         -> exp(-g_{t+1})
//    pitilde:  (X_{t-1}/X_t)^gamma_m -> exp(-gamma_m*g_t)
//    deuda:    X_{t-1}/X_t         -> exp(-g_t) en el denominador
//  Las reglas de Taylor NO cambian: ya están normalizadas por la meta.
//
//  Estado estacionario: sin cambios. gm y gpiF tienen media cero, así
//  que los tres factores valen 1 en SS.
//
//  NO correr directo: se incluye desde otros .mod
// ============================================================

var
    // ---- economía real ----
    y h lambda pi i w mc pitilde r
    dy_obs dpi_obs di_obs r_obs def_obs
    yhat
    xi theta z g zm zm2 gm
    // ---- bloque fiscal real ----
    sb tau
    // ---- shocks fiscales ----
    zetaM zetaF
    // ---- economía sombra ----
    yF hF lambdaF piF iF wF mcF pitildeF rF sbF tauF gpiF dpiF_obs diF_obs;

varexo e_xi e_theta e_z e_g e_zm e_zm2 e_gm e_zetaM e_zetaF e_gpiF;

parameters beta delta sigma chi alpha eta phi gamma_m mu scale
           A alpha_pi alpha_y gamma_I gbar thetabar pibar r_ss i_ss
           rho_xi rho_theta rho_z rho_g rho_zm rho_zm2 rho_gm
           // fiscales
           gamma_M gamma_F phi_F phi_M rho_zetaM rho_zetaF rho_gpiF
           tau_ss sb_ss sb_target tau_target calib_sb;

// ---------------- Escala ----------------
scale = 100;

// ---------------- Calibración (Tabla 4 de Uribe) ----------------
beta     = 0.9982;
sigma    = 2;
chi      = 0.625;
alpha    = 0.75;
eta      = 6;
thetabar = 0.4055*scale;
gbar     = 0.004131*scale;
pibar    = 0.0081*scale;

mu   = eta/(eta-1);
r_ss = scale*(1+pibar/scale)*( exp(sigma*gbar/scale)/beta - 1 );

// ---------------- Valores por defecto (se pisan en cada archivo) ----
phi      = 146;
delta    = 0.258;
gamma_m  = 0.606;
alpha_pi = 2.32;
alpha_y  = 0.188;
gamma_I  = 0.242;
rho_xi    = 0.915;
rho_theta = 0.708;
rho_z     = 0.7;
rho_g     = 0.221;
rho_zm    = 0.306;
rho_zm2   = 0.999;
rho_gm    = 0.2019;    // media posterior del MH de Uribe-A
rho_gpiF  = 0.2019;    // simétrica a gm: decisión de diseño, sin anclaje propio

// ---------------- Bloque fiscal ----------------
gamma_M   = 20;
gamma_F   = 0;
phi_F     = 0;
phi_M     = alpha_pi;
rho_zetaM = 0.5;
rho_zetaF = 0.5;

calib_sb   = 1;
sb_target  = 2.45*scale;
tau_target = 1;

model;

// ============================================================
//  ECONOMÍA REAL
// ============================================================

// --- 1. CPO consumo ---
exp(xi/scale) * ( y - delta*y(-1)/exp(g/scale) )^(-sigma)
        * ( 1 - exp(theta/scale)*h )^(chi*(1-sigma)) = lambda;

// --- 2. Oferta de trabajo ---
chi * exp(theta/scale) * ( y - delta*y(-1)/exp(g/scale) )
    / ( 1 - exp(theta/scale)*h ) = w;

// --- 3. Euler. CON gm: X^m_t/X^m_{t+1} = exp(-gm(+1)) ---
lambda = beta * (1+i/scale) * lambda(+1) / (1+pi(+1)/scale)
         * exp( -gm(+1)/scale - sigma*g(+1)/scale );

// --- 4. Tasa real ex-ante ---
r = scale*( (1+i/scale)/(1+pi(+1)/scale) - 1 );

// --- 5. Producción ---
y = exp(z/scale) * h^alpha;

// --- 6. Costo marginal real ---
mc = w / ( alpha * exp(z/scale) * h^(alpha-1) );

// --- 7. Phillips (Rotemberg) ---
(1+pi/scale)/(1+pitilde/scale) * ( (1+pi/scale)/(1+pitilde/scale) - 1 )
  = beta * exp((1-sigma)*g(+1)/scale) * lambda(+1)/lambda
    * (1+pi(+1)/scale)/(1+pitilde(+1)/scale)
    * ( (1+pi(+1)/scale)/(1+pitilde(+1)/scale) - 1 )
  + 1/(phi*(mu-1)) * ( mu*mc - 1 ) * y;

// --- 8. Regla de Taylor con meta fiscal. SIN CAMBIOS:
//     ya está normalizada por la meta, así que gm no aparece.
1+i/scale = ( A * ( (1+pi/scale)/(1+piF/scale) )^phi_M
                * ( (1+piF/scale)/(1+pibar/scale) )^phi_F
                * y^alpha_y )^(1-gamma_I)
            * (1+i(-1)/scale)^gamma_I
            * exp( zm/scale + (1-(1-gamma_I)*phi_M)*zm2/scale
                   - gamma_I*zm2(-1)/scale );

// --- 9. Inflación de referencia. CON gm: (X^m_{t-1}/X^m_t)^gamma_m ---
1+pitilde/scale = exp(-gamma_m*gm/scale)
                  * (1+pitilde(-1)/scale)^gamma_m
                  * (1+pi/scale)^(1-gamma_m);

// --- 10. Restricción del gobierno. CON gm en el denominador:
//     el retorno real es (1+i(-1))/((1+pi)*exp(gm)) ---
sb = sb(-1) * (1+i(-1)/scale)
     / ( (1+pi/scale) * exp(gm/scale) * exp(g/scale) * y/y(-1) ) - tau;

// --- 11. Regla fiscal ---
tau = tau_ss * ( sb(-1)/sbF(-1) )^gamma_M
             * ( sbF(-1)/sb_ss )^gamma_F
             * exp( (zetaM + zetaF)/scale );

// Inflación y tasa fiscales OBSERVADAS: incluyen la tendencia X^F
dpiF_obs = piF - piF(-1) + gpiF;
diF_obs  = iF - iF(-1) + gpiF;

// ---------------- Observables ----------------
//  dpi_obs y di_obs llevan +gm, como en Uribe-A: la inflación y la
//  tasa OBSERVADAS incluyen el crecimiento de la meta.
dy_obs  = scale*( log(y) - log(y(-1)) ) + g - gbar;
dpi_obs = pi - pi(-1) + gm;
di_obs  = i - i(-1) + gm;
r_obs   = ( i - pi ) - r_ss;
yhat    = scale*log( y/STEADY_STATE(y) );
def_obs = -( tau - STEADY_STATE(tau) );

// ---------------- Procesos exógenos ----------------
xi    = rho_xi*xi(-1) + e_xi;
theta = (1-rho_theta)*thetabar + rho_theta*theta(-1) + e_theta;
z     = rho_z*z(-1) + e_z;
g     = (1-rho_g)*gbar + rho_g*g(-1) + e_g;
zm    = rho_zm*zm(-1) + e_zm;
zm2   = rho_zm2*zm2(-1) + e_zm2;
gm    = rho_gm*gm(-1) + e_gm;
zetaM = rho_zetaM*zetaM(-1) + e_zetaM;
zetaF = rho_zetaF*zetaF(-1) + e_zetaF;

// ============================================================
//  ECONOMÍA SOMBRA
// ============================================================

// --- S1. CPO consumo ---
( yF - delta*yF(-1)/exp(gbar/scale) )^(-sigma)
        * ( 1 - exp(thetabar/scale)*hF )^(chi*(1-sigma)) = lambdaF;

// --- S2. Oferta de trabajo ---
chi * exp(thetabar/scale) * ( yF - delta*yF(-1)/exp(gbar/scale) )
    / ( 1 - exp(thetabar/scale)*hF ) = wF;

// --- S3. Euler. CON gpiF: X^F_t/X^F_{t+1} = exp(-gpiF(+1)) ---
lambdaF = beta * (1+iF/scale) * lambdaF(+1) / (1+piF(+1)/scale)
          * exp( -gpiF(+1)/scale - sigma*gbar/scale );

// --- S4. Tasa real ex-ante ---
rF = scale*( (1+iF/scale)/(1+piF(+1)/scale) - 1 );

// --- S5. Producción ---
yF = hF^alpha;

// --- S6. Costo marginal real ---
mcF = wF / ( alpha * hF^(alpha-1) );

// --- S7. Phillips ---
(1+piF/scale)/(1+pitildeF/scale) * ( (1+piF/scale)/(1+pitildeF/scale) - 1 )
  = beta * exp((1-sigma)*gbar/scale) * lambdaF(+1)/lambdaF
    * (1+piF(+1)/scale)/(1+pitildeF(+1)/scale)
    * ( (1+piF(+1)/scale)/(1+pitildeF(+1)/scale) - 1 )
  + 1/(phi*(mu-1)) * ( mu*mcF - 1 ) * yF;

// --- S8. Regla de Taylor de la sombra. SIN CAMBIOS ---
1+iF/scale = (1+i_ss/scale) * ( (1+piF/scale)/(1+pibar/scale) )^phi_F;

// --- S9. Indexación. CON gpiF ---
1+pitildeF/scale = exp(-gamma_m*gpiF/scale)
                   * (1+pitildeF(-1)/scale)^gamma_m
                   * (1+piF/scale)^(1-gamma_m);

// --- S10. Restricción del gobierno sombra. CON gpiF ---
sbF = sbF(-1) * (1+iF(-1)/scale)
      / ( (1+piF/scale) * exp(gpiF/scale) * exp(gbar/scale) * yF/yF(-1) ) - tauF;

// --- S11. Regla fiscal sombra ---
tauF = tau_ss * exp( zetaF/scale );

// --- S12. Tendencia de la meta fiscal ---
gpiF = rho_gpiF*gpiF(-1) + e_gpiF;

end;

steady_state_model;

// ---- shocks en su media. gm y gpiF tienen media cero: los factores
//      exp(-gm), exp(-gamma_m*gm), exp(-gpiF) valen 1 en SS, así que
//      el estado estacionario es el mismo que sin las tendencias. ----
xi = 0; z = 0; zm = 0; zm2 = 0; zetaM = 0; zetaF = 0;
gm = 0; gpiF = 0;
theta = thetabar;
g  = gbar;

mc = 1/mu;
h  = mc*alpha / ( exp(thetabar/scale)
     * ( chi*(1-delta*exp(-gbar/scale)) + mc*alpha ) );
y  = h^alpha;
w  = mc*alpha*h^(alpha-1);
lambda = ( y - delta*y*exp(-gbar/scale) )^(-sigma)
         * ( 1 - exp(thetabar/scale)*h )^(chi*(1-sigma));

pi      = pibar;
pitilde = pibar;
i = scale*( (1+pi/scale)*exp(sigma*gbar/scale)/beta - 1 );
r = scale*( (1+i/scale)/(1+pi/scale) - 1 );
i_ss = i;

A = (1+i/scale) / ( y^alpha_y );

RG     = (1+i/scale) / ( (1+pi/scale)*exp(gbar/scale) );
tau_ss = calib_sb*sb_target*(RG-1) + (1-calib_sb)*tau_target;
sb_ss  = tau_ss/(RG-1);
tau = tau_ss;
sb  = sb_ss;

yF = y; hF = h; lambdaF = lambda; wF = w; mcF = mc;
piF = pibar; pitildeF = pibar; iF = i; rF = r;
sbF = sb_ss; tauF = tau_ss;

dy_obs = 0; dpi_obs = 0; di_obs = 0; r_obs = 0; yhat = 0;
def_obs = 0; dpiF_obs = 0; diF_obs = 0;

end;