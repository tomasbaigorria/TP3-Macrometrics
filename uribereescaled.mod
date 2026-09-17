// ============================================================
//  uribereescaled.mod
//  Uribe (2022), modelo NK sección IV — versión calibrada
//  Parámetros: Tabla 4 (calibrados) + Tabla 5 (posterior mean)
//  Produce las IRFs para replicar las Figuras 11 y 12
// ============================================================

@#include "uribe_core.mod"

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