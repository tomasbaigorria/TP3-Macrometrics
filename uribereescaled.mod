// ============================================================
//  Uribe (2022), "The Neo-Fisher Effect", AEJ:Macro 14(3)
//  Modelo NK de la sección IV — versión reescalada
//  TODAS las variables de shock y tasas en PUNTOS PORCENTUALES
//  Parámetros: Tabla 4 (calibrados) y Tabla 5 (posterior mean)
// ============================================================

var y h lambda pi i w mc pitilde r
    dy_obs dpi_obs di_obs r_obs
    xi theta z g zm zm2 gm;

varexo e_xi e_theta e_z e_g e_zm e_zm2 e_gm;

parameters beta delta sigma chi alpha eta phi gamma_m mu scale
           A alpha_pi alpha_y gamma_I gbar gmbar thetabar pibar r_ss
           rho_xi rho_theta rho_z rho_g rho_zm rho_zm2 rho_gm;

// ---------------- Escala ----------------
scale = 100;          // 100 = puntos porcentuales ; 1 = tanto por uno

// ---------------- Calibración (Tabla 4) ----------------
beta     = 0.9982;
sigma    = 2;
chi      = 0.625;
alpha    = 0.75;
eta      = 6;
thetabar = 0.4055*scale;
gbar     = 0.004131*scale;
gmbar    = 0;
pibar    = 0.0081*scale;        // media muestral, 1954Q4-2018Q2

mu   = eta/(eta-1);
r_ss = scale*(1+pibar/scale)*( exp(sigma*gbar/scale)/beta - 1 );

// ---------------- Posterior mean (Tabla 5) ----------------
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
rho_zm2   = 0.796;
rho_gm    = 0.248;

model;

// --- 1. CPO consumo (utilidad marginal) ---
exp(xi/scale) * ( y - delta*y(-1)/exp(g/scale) )^(-sigma)
        * ( 1 - exp(theta/scale)*h )^(chi*(1-sigma)) = lambda;

// --- 2. Oferta de trabajo ---
chi * exp(theta/scale) * ( y - delta*y(-1)/exp(g/scale) )
    / ( 1 - exp(theta/scale)*h ) = w;

// --- 3. Euler ---
lambda = beta * (1+i/scale) * lambda(+1) / (1+pi(+1)/scale)
         * exp( -gm(+1)/scale - sigma*g(+1)/scale );

// --- 4. Tasa real ex-ante ---
r = scale*( (1+i/scale)/(1+pi(+1)/scale) - 1 );

// --- 5. Producción ---
y = exp(z/scale) * h^alpha;

// --- 6. Costo marginal real ---
mc = w / ( alpha * exp(z/scale) * h^(alpha-1) );

// --- 7. Curva de Phillips (Rotemberg) ---
(1+pi/scale)/(1+pitilde/scale) * ( (1+pi/scale)/(1+pitilde/scale) - 1 )
  = beta * exp((1-sigma)*g(+1)/scale) * lambda(+1)/lambda
    * (1+pi(+1)/scale)/(1+pitilde(+1)/scale)
    * ( (1+pi(+1)/scale)/(1+pitilde(+1)/scale) - 1 )
  + 1/(phi*(mu-1)) * ( mu*mc - 1 ) * y;

// --- 8. Regla de Taylor ---
1+i/scale = ( A * (1+pi/scale)^alpha_pi * y^alpha_y )^(1-gamma_I)
            * (1+i(-1)/scale)^gamma_I
            * exp( zm/scale + (1-alpha_pi)*zm2/scale
                   - gamma_I*zm2(-1)/scale );

// --- 9. Inflación de referencia ---
1+pitilde/scale = exp(-gamma_m*gm/scale)
                  * (1+pitilde(-1)/scale)^gamma_m
                  * (1+pi/scale)^(1-gamma_m);

// ---------------- Observables (puntos porcentuales) ----------------
// dy_obs, r_obs, di_obs : los tres usados en la estimación (media cero)
// dpi_obs : construido pero NO demeaneado (no es observable de estimación)

dy_obs  = scale*( log(y) - log(y(-1)) ) + g - gbar;
dpi_obs = pi - pi(-1) + gm;
di_obs  = i - i(-1) + gm;
r_obs   = ( i - pi ) - r_ss;

// ---------------- Procesos exógenos ----------------
xi    = rho_xi*xi(-1) + e_xi;
theta = (1-rho_theta)*thetabar + rho_theta*theta(-1) + e_theta;
z     = rho_z*z(-1) + e_z;
g     = (1-rho_g)*gbar + rho_g*g(-1) + e_g;
zm    = rho_zm*zm(-1) + e_zm;
zm2   = rho_zm2*zm2(-1) + e_zm2;
gm    = (1-rho_gm)*gmbar + rho_gm*gm(-1) + e_gm;

end;

steady_state_model;

// Shocks en su media
xi = 0; z = 0; zm = 0; zm2 = 0;
theta = thetabar;
g  = gbar;
gm = gmbar;

// Bloque real
mc = 1/mu;
h  = mc*alpha / ( exp(thetabar/scale)
     * ( chi*(1-delta*exp(-gbar/scale)) + mc*alpha ) );
y  = h^alpha;
w  = mc*alpha*h^(alpha-1);
lambda = ( y - delta*y*exp(-gbar/scale) )^(-sigma)
         * ( 1 - exp(thetabar/scale)*h )^(chi*(1-sigma));

// Bloque nominal
pi      = pibar;
pitilde = pibar;
i = scale*( (1+pi/scale)*exp(sigma*gbar/scale)/beta - 1 );
r = scale*( (1+i/scale)/(1+pi/scale) - 1 );

// A como residuo de la regla de Taylor
A = (1+i/scale) / ( (1+pi/scale)^alpha_pi * y^alpha_y );

// Observables
dy_obs = 0; dpi_obs = 0; di_obs = 0; r_obs = 0;

end;

shocks;
var e_xi    = (0.0287*scale)^2;
var e_theta = (0.00164*scale)^2;
var e_z     = (0.00122*scale)^2;
var e_g     = (0.00758*scale)^2;
var e_zm    = (0.000832*scale)^2;
var e_zm2   = (0.00131*scale)^2;
var e_gm    = (0.000848*scale)^2;
end;

steady;
check;

stoch_simul(order=1, irf=21, nograph) dy_obs dpi_obs di_obs r_obs y pi i r;