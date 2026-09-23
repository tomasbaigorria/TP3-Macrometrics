// ============================================================
//  uribe_bfm_est_core.mod  —  núcleo para las ESTIMACIONES del Punto 3
//  Copia de uribe_bfm_core.mod (Parte 2), que NO se toca, más:
//    (a) def_obs: deficit primario / PBI, observable de E2 y E3
//    (b) zm2: shock a la meta de Uribe, para E3 (apagado en E1 y E2)
//  Base: uribe_core.mod en su versión Uribe-B (sin meta: gm = zm2 = 0)
//  Agrega el bloque fiscal de Bianchi, Faccini & Melosi (2023):
//    (i)   restricción del gobierno y regla fiscal con zetaM, zetaF
//    (ii)  regla de Taylor con meta de inflación fiscal piF
//    (iii) economía sombra (variables con sufijo F)
//  Variables de shock, tasas, deuda y superávit en PUNTOS PORCENTUALES
//  NO correr directo: se incluye desde otros .mod
//
//  phi_M: fuerza con que la tasa combate la inflación NO fiscal.
//  Caso base: phi_M = alpha_pi (se fija en el archivo que incluye este).
//  Robustez:  phi_M = 2 (BFM, slide 14).
//  alpha_pi ya no aparece en ninguna ecuación: su rol lo cumple phi_M.
// ============================================================

var
    // ---- economía real (igual a Uribe-B) ----
    y h lambda pi i w mc pitilde r
    dy_obs dpi_obs di_obs r_obs def_obs
    yhat          // producto en % de desvío respecto del SS
    xi theta z g zm zm2
    // ---- bloque fiscal real ----
    sb tau
    // ---- shocks fiscales ----
    zetaM zetaF
    // ---- economía sombra ----
    yF hF lambdaF piF iF wF mcF pitildeF rF sbF tauF;

varexo e_xi e_theta e_z e_g e_zm e_zm2 e_zetaM e_zetaF;

parameters beta delta sigma chi alpha eta phi gamma_m mu scale
           A alpha_pi alpha_y gamma_I gbar thetabar pibar r_ss i_ss
           rho_xi rho_theta rho_z rho_g rho_zm rho_zm2
           // fiscales
           gamma_M gamma_F phi_F phi_M rho_zetaM rho_zetaF
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
rho_zm2   = 0;        // E1 y E2: apagado. E3: 0.999 (como Uribe-B)

// ---------------- Bloque fiscal (consigna, Parte 2) ----------------
gamma_M   = 20;
gamma_F   = 0;
phi_F     = 0;
phi_M     = alpha_pi; // caso base (robustez: 2, BFM slide 14)
rho_zetaM = 0.5;
rho_zetaF = 0.5;

// Estado estacionario fiscal:
//   calib_sb = 1 -> se fija la deuda (sb_target) y el superávit sale solo
//   calib_sb = 0 -> se fija el superávit (tau_target) y la deuda sale sola
calib_sb   = 1;
sb_target  = 2.45*scale;   // BFM, slide 14: deuda / PBI trimestral
tau_target = 1;            // superávit en % del PBI trimestral (si calib_sb = 0)

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

// --- 3. Euler (sin gm: Uribe-B) ---
lambda = beta * (1+i/scale) * lambda(+1) / (1+pi(+1)/scale)
         * exp( -sigma*g(+1)/scale );

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

// --- 8. Regla de Taylor con meta fiscal (BFM, slide 10) ---
//     combate la inflación no fiscal (pi respecto de piF)
//     y responde a la fiscal con phi_F
1+i/scale = ( A * ( (1+pi/scale)/(1+piF/scale) )^phi_M
                * ( (1+piF/scale)/(1+pibar/scale) )^phi_F
                * y^alpha_y )^(1-gamma_I)
            * (1+i(-1)/scale)^gamma_I
            * exp( zm/scale + (1-(1-gamma_I)*phi_M)*zm2/scale
                   - gamma_I*zm2(-1)/scale );

// --- 9. Inflación de referencia (indexación, sin gm) ---
1+pitilde/scale = (1+pitilde(-1)/scale)^gamma_m
                  * (1+pi/scale)^(1-gamma_m);

// --- 10. Restricción del gobierno (en % del PBI) ---
sb = sb(-1) * (1+i(-1)/scale)
     / ( (1+pi/scale) * exp(g/scale) * y/y(-1) ) - tau;

// --- 11. Regla fiscal (BFM, slide 9) ---
tau = tau_ss * ( sb(-1)/sbF(-1) )^gamma_M
             * ( sbF(-1)/sb_ss )^gamma_F
             * exp( (zetaM + zetaF)/scale );

// ---------------- Observables (igual que Uribe-B) ----------------
dy_obs  = scale*( log(y) - log(y(-1)) ) + g - gbar;
dpi_obs = pi - pi(-1);
di_obs  = i - i(-1);
r_obs   = ( i - pi ) - r_ss;
yhat    = scale*log( y/STEADY_STATE(y) );

// Deficit primario / PBI, media cero. tau es el SUPERAVIT, de ahi el signo.
def_obs = -( tau - STEADY_STATE(tau) );

// ---------------- Procesos exógenos ----------------
xi    = rho_xi*xi(-1) + e_xi;
theta = (1-rho_theta)*thetabar + rho_theta*theta(-1) + e_theta;
z     = rho_z*z(-1) + e_z;
g     = (1-rho_g)*gbar + rho_g*g(-1) + e_g;
zm    = rho_zm*zm(-1) + e_zm;
zm2   = rho_zm2*zm2(-1) + e_zm2;
zetaM = rho_zetaM*zetaM(-1) + e_zetaM;
zetaF = rho_zetaF*zetaF(-1) + e_zetaF;

// ============================================================
//  ECONOMÍA SOMBRA (solo actúa zetaF; resto de shocks en su SS)
// ============================================================

// --- S1. CPO consumo ---
( yF - delta*yF(-1)/exp(gbar/scale) )^(-sigma)
        * ( 1 - exp(thetabar/scale)*hF )^(chi*(1-sigma)) = lambdaF;

// --- S2. Oferta de trabajo ---
chi * exp(thetabar/scale) * ( yF - delta*yF(-1)/exp(gbar/scale) )
    / ( 1 - exp(thetabar/scale)*hF ) = wF;

// --- S3. Euler ---
lambdaF = beta * (1+iF/scale) * lambdaF(+1) / (1+piF(+1)/scale)
          * exp( -sigma*gbar/scale );

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

// --- S8. Regla de Taylor de la sombra (BFM, slide 15: solo piF) ---
1+iF/scale = (1+i_ss/scale) * ( (1+piF/scale)/(1+pibar/scale) )^phi_F;

// --- S9. Indexación ---
1+pitildeF/scale = (1+pitildeF(-1)/scale)^gamma_m
                   * (1+piF/scale)^(1-gamma_m);

// --- S10. Restricción del gobierno sombra ---
sbF = sbF(-1) * (1+iF(-1)/scale)
      / ( (1+piF/scale) * exp(gbar/scale) * yF/yF(-1) ) - tauF;

// --- S11. Regla fiscal sombra (gamma_F = 0: no responde a la deuda) ---
tauF = tau_ss * exp( zetaF/scale );

end;

steady_state_model;

// ---- economía real (idéntica a Uribe-B) ----
xi = 0; z = 0; zm = 0; zm2 = 0; zetaM = 0; zetaF = 0;
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

// Taylor en SS: pi = piF = pibar -> A = (1+i)/y^alpha_y
A = (1+i/scale) / ( y^alpha_y );

// ---- bloque fiscal ----
// factor (tasa real - crecimiento): sb = sb*RG - tau  ->  tau = sb*(RG-1)
RG     = (1+i/scale) / ( (1+pi/scale)*exp(gbar/scale) );
tau_ss = calib_sb*sb_target*(RG-1) + (1-calib_sb)*tau_target;
sb_ss  = tau_ss/(RG-1);
tau = tau_ss;
sb  = sb_ss;

// ---- economía sombra = economía real ----
yF = y; hF = h; lambdaF = lambda; wF = w; mcF = mc;
piF = pibar; pitildeF = pibar; iF = i; rF = r;
sbF = sb_ss; tauF = tau_ss;

dy_obs = 0; dpi_obs = 0; di_obs = 0; r_obs = 0; yhat = 0;
def_obs = 0;

end;
