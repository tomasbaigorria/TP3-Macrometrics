================================================================
TP3 MACROECONOMETRÍA — PUNTOS 1, 2 Y 3
UdeSA 2026 — García-Cicco / Nuñez
================================================================

QUÉ HAY ACÁ
-----------
Código de Dynare y MATLAB para:
  - Punto 1: replicación del modelo NK de Uribe (2022, AEJ:Macro,
    sección IV) y estimación bayesiana de Uribe-A y Uribe-B.
  - Punto 2: modelo Uribe-BFM (Uribe-B + bloque fiscal de Bianchi,
    Faccini & Melosi, 2023, QJE) calibrado, con IRFs.
  - Punto 3: las tres estimaciones del modelo Uribe-BFM, más el
    bonus de Metropolis-Hastings.

Estado: puntos 1, 2 y 3 completos. Falta el punto 4.

El error de la regla de Taylor que este README marcaba como
pendiente YA ESTÁ CORREGIDO (ver "ERROR DE LA REGLA DE TAYLOR").


REQUISITOS
----------
- MATLAB (no Octave: el MH de 1M draws es inviable ahí)
- Dynare 7.x, con addpath a la carpeta /matlab de la instalación
  (punto 1 corrido con 7.0; punto 2 con 7.2 en MATLAB Online, que
  se instala desde la pestaña "MATLAB Online" de dynare.org/download)
- Replication package de Uribe (openICPSR doi 10.3886/E126661V1),
  necesario solo para regenerar los datos


ANTES DE CORRER NADA: RUTAS A AJUSTAR
-------------------------------------
Hay una ruta hardcodeada al replication package en:
  - armar_datos.m
  - smoothed_inflation.m
  - smoothed_tres.m
  - smoothed_AB.m

Cambiar la variable dir_datos por la ruta local de la carpeta
"empirical_model" del replication package (la que contiene
read_data.m, gdplev.xlsx, LNU.xlsx, fedfunds.xlsx).

Si ya existe datos_uribe.mat, no hace falta tocar nada de esto.


================================================================
ERROR DE LA REGLA DE TAYLOR (YA CORREGIDO)
================================================================

La regla de Taylor de uribe_core.mod tenía el término
    (1-alpha_pi)*zm2/scale
copiado de la versión estacionaria del Online Appendix de Uribe
(p. 11). Ese coeficiente es un error de tipeo del apéndice: si se
estacionariza la regla original (ecuación 17, p. 9), el coeficiente
correcto es
    (1-(1-gamma_I)*alpha_pi)*zm2/scale

Prueba: con la moda de Uribe-B, una suba de 1 pp en la meta
(z^m2, rho = 0.999) lleva la inflación de largo plazo a
    - regla vieja:     1.52 pp   (sin sentido económico)
    - regla corregida: 1.01 pp   (la inflación converge a la meta)

CORREGIDO en el commit 856ee6a, que además volvió a correr
uribe_B_mode, uribe_B_smoother, uribe_B_irf y la réplica calibrada.
No hay que rehacer nada de eso. La estimación de Uribe-A no estaba
afectada (z^m2 apagado), así que el MH no se repitió.

Consecuencia sobre los resultados: la densidad marginal de Uribe-B
pasó de -331.98 a -331.24, o sea que con la regla corregida
Uribe-B le GANA a Uribe-A (-331.78). Antes perdía.

Validación independiente: al derivar el mismo término para la regla
de BFM en el punto 3 (ver uribe_bfm_est_core.mod) sale exactamente
la misma estructura, con phi_M en el lugar de alpha_pi.

LO QUE QUEDÓ SIN ACTUALIZAR: el commit no tocó uribe_bfm_irf.mod,
que tiene la moda de Uribe-B escrita a mano. Esos valores son los
de ANTES de la corrección. Las diferencias no son triviales
(gamma_I 0.2387 vs 0.2201, delta 0.2083 vs 0.2032, rho_g 0.1938 vs
0.1832), así que las IRFs del punto 2 están calculadas con la
calibración vieja. Ver PENDIENTE.


ORDEN DE EJECUCIÓN — PUNTO 1
----------------------------

0) DATOS (solo si hay que regenerarlos)
   >> armar_datos
   Genera datos_uribe.mat con los tres observables demeaneados:
   dy_obs, r_obs, di_obs. Muestra 1955Q1-2018Q2, T=254.

1) MODELO CALIBRADO (Figuras 11 y 12 del paper)
   >> dynare uribereescaled
   >> figura11
   Parámetros: Tabla 4 (calibrados) + Tabla 5 (posterior mean).
   Produce figura11_replicacion.png

2) URIBE-A, MODA (mode_compute = 5)
   >> dynare uribe_mode_A
   >> dpi_mc5 = oo_.SmoothedVariables.dpi_obs;   % (ver paso 5)
   Genera los gráficos de mode_check y la tabla moda/desvíos.

3) URIBE-A, METROPOLIS-HASTINGS
   >> dynare uribe_A_mh
   ATENCIÓN: tarda ~1h25m. mode_compute=6 + 1.000.000 draws,
   mh_nblocks=1, mh_drop=0.5. Acceptance ratio obtenido: 27.99%.
   NO volver a correr con mh_replic>0 si no se quiere regenerar
   la cadena: borra los draws existentes.

4) URIBE-B (mode_compute = 5)
   >> dynare uribe_B_mode
   rho_gm = sigma_gm = 0 ; rho_zm2 = 0.999 calibrado.

5) SMOOTHERS (inflación suavizada)
   >> dynare uribe_A_smoother    ; dpi_mc5 = oo_.SmoothedVariables.dpi_obs;
   >> dynare uribe_A_smoother6   ; dpi_mc6 = oo_.SmoothedVariables.dpi_obs;
   >> dynare uribe_A_mh          ; dpi_mh  = oo_.SmoothedVariables.dpi_obs;
   >> dynare uribe_B_smoother    ; dpi_B   = oo_.SmoothedVariables.dpi_obs;
   >> save('suavizados.mat','dpi_mc5','dpi_mc6','dpi_mh','dpi_B');
   >> smoothed_tres     % A: tres parametrizaciones
   >> smoothed_AB       % A vs B

   IMPORTANTE: guardar cada vector INMEDIATAMENTE después de cada
   corrida. oo_ se sobreescribe en la siguiente.

   Para el smoother de la media posterior, uribe_A_mh.mod debe
   tener el bloque estimation con:
     mh_replic=0, mh_nblocks=1, mh_drop=0.5, load_mh_file,
     smoother, sub_draws=1000
   (sub_draws evita pasar el filtro por los 500.000 draws)

6) IRFs Y DESCOMPOSICIÓN DE VARIANZA
   >> dynare uribe_A_irf        ; irf_mc5=oo_.irfs; vd_mc5=oo_.variance_decomposition;
      (cambiar mode_file a uribe_A_mh/Output/uribe_A_mh_mode)
   >> dynare uribe_A_irf        ; irf_mc6=oo_.irfs; vd_mc6=oo_.variance_decomposition;
   >> dynare uribe_A_irf_mean   ; irf_mh=oo_.irfs;  vd_mh=oo_.variance_decomposition;
   >> dynare uribe_B_irf        ; irf_B=oo_.irfs;   vd_B=oo_.variance_decomposition;
   >> save('irfs_A.mat','irf_mc5','vd_mc5','irf_mc6','vd_mc6','irf_mh','vd_mh');
   >> irfs_tres    % IRFs A, tres parametrizaciones
   >> irfs_AB      % IRFs A vs B
   >> tablas_1     % descomposiciones de varianza


DECISIONES DE MODELADO (leer antes de tocar el .mod)
----------------------------------------------------

* uribe_core.mod contiene el modelo; los demás .mod del punto 1 lo
  incluyen con @#include. Un cambio en el core afecta a todos.
  El punto 2 usa su propio core (uribe_bfm_core.mod).

* ESCALA. El parámetro "scale" (=100) pasa todas las variables de
  shock y las tasas a puntos porcentuales. Con scale=1 el modelo
  vuelve a tanto por uno y debe reproducir EXACTAMENTE el mismo
  estado estacionario y los mismos momentos: es el test de que el
  reescalado está bien.
  Todas las variables de shock (xi, theta, z, g, zm, zm2, gm) entran
  divididas por scale. Sus sigma van multiplicados por scale.

* OBSERVABLES. Definidos en el .mod en puntos porcentuales
  TRIMESTRALES (no anualizados). Los datos en datos_uribe.mat
  también. read_data.m devuelve pai y ff ANUALIZADOS: en
  armar_datos.m se dividen por 4.
  dpi_obs se construye pero NO se usa para estimar (y no va
  demeaneado), como pide el enunciado.

* CALIBRACIÓN NO OBVIA:
  - thetabar = 0.4055*scale  (Tabla 4; theta NO tiene media cero)
  - pibar = 0.0081*scale     (media muestral de la inflación
                              trimestral, calculada de los datos)
  - gmbar = 0                (la meta no tiene drift en promedio)
  - A se computa como residuo de la Taylor en el steady_state_model,
    no se calibra. No está reportado en el paper.

* ESTADO ESTACIONARIO. Forma cerrada, va en steady_state_model.
    mc = 1/mu
    h  = mc*alpha / ( exp(thetabar/scale) *
         ( chi*(1-delta*exp(-gbar/scale)) + mc*alpha ) )
  Valores: y=0.4863, h=0.3825, mc=0.8333, pi=0.81, i=1.8296

* PRIORS. Las Gamma de la Tabla 5 se reemplazaron por normales
  truncadas en cero (lo pide el enunciado). Los sigma van x100,
  los R_ii x100^2.
  Los R_ii de la Tabla 5 son VARIANZAS pero Dynare declara
  measurement errors como stderr. Se usó media = sqrt(R_ii*1e4)
  y desvío escalado proporcionalmente. Es una aproximación
  (E[sqrt(X)] != sqrt(E[X])) y está documentada en el informe.

* MAPEO DE MEASUREMENT ERRORS: R_11->dy_obs, R_22->r_obs,
  R_33->di_obs, siguiendo el orden del vector o_t del Appendix
  (p.3). Verificar si se cambia el orden de varobs.


RESULTADOS PRINCIPALES OBTENIDOS
--------------------------------
- Replicación calibrada: producto ante shock permanente hace pico
  en 0.25 vs 0.26 de Uribe (Figura 11). Coinciden 5 de 6 paneles;
  discrepancia en la respuesta de la tasa nominal ante z^m2 en el
  impacto (documentada en el informe; probable causa: ver
  ERROR DE LA REGLA DE TAYLOR).

- Uribe-A: sigma_gm sube de 0.085 (paper) a 0.125 al apagar z^m2.
  El shock permanente absorbe el rol del transitorio, como
  anticipa el pie de página 4 del enunciado.

- Descomposición de varianza de dpi_obs: e_gm explica 50.8%
  (modas) / 48.5% (media posterior). Uribe reporta ~45%.

- Las dos modas (mc=5 y mc=6) coinciden a 3-4 decimales.
  La media posterior difiere en los parámetros mal identificados
  (phi, gamma_I, rho_zm) y siempre se corre hacia la prior.

- Cuatro parámetros NO identificados: rho_theta, rho_z, rho_gm,
  rho_zm (desvío posterior ~= desvío de la prior). También
  sigma_theta y sigma_z quedan pegados a cero.

- Hessiano mal condicionado en las dos versiones (autovalor mínimo
  ~1e-10). Se refleja en las superficies planas de mode_check.

- Densidades marginales (Laplace), con la regla ya corregida:
  A = -331.78 ; B = -331.24. B le gana a A por 0.54 puntos log.
  Los datos NO distinguen entre meta con raíz unitaria y meta
  casi-unitaria (rho=0.999).

- IRFs A vs B: coinciden a partir del trimestre 4, pero difieren
  en el impacto (tasa real: -0.04 en A vs -0.24 en B). La causa
  es el término de z^m2 en la regla de Taylor estacionarizada, no
  la persistencia. [Medido con la regla vieja: conviene rehacer
  el número con la corregida.]


================================================================
PUNTO 2 — MODELO URIBE-BFM
================================================================

ARCHIVOS
--------
  uribe_bfm_core.mod  Modelo: Uribe-B + bloque fiscal + economía
                      sombra. NO se corre directo. Copia nueva:
                      uribe_core.mod no se toca.
  uribe_bfm_irf.mod   Calibración (moda de Uribe-B + consigna) e IRFs.
  parte2_irfs.m       Corre todo, chequea zetaM y grafica.

Necesita en la misma carpeta: uribe_core.mod, uribe_B_irf.mod,
datos_uribe.mat y uribe_B_mode/Output/uribe_B_mode_mode.mat
(solo para la comparación con Uribe-B).

ORDEN DE EJECUCIÓN
------------------
  >> parte2_irfs

Corre internamente:
  dynare uribe_bfm_irf -DphiF=0            (caso base)
  dynare uribe_bfm_irf -DphiF=0.8
  dynare uribe_bfm_irf -DphiF=0 -DphiM2=1  (robustez phi_M = 2)
  dynare uribe_B_irf                       (z^m2 para comparar)
Guarda irfs_parte2.mat y tres figuras:
  fig_parte2_zetaF.png        zetaF con phi_F = 0 y 0.8
  fig_parte2_zetaM.png        zetaM (chequeo: sin efectos reales)
  fig_parte2_comparacion.png  zetaF vs z^m2 de Uribe-B

EL MODELO (cambios respecto de Uribe-B)
---------------------------------------
Se eliminan g^m y z^m2. Se agregan:

1) Restricción del gobierno, en % del PBI:
     sb = sb(-1)*(1+i(-1)) / ((1+pi)*exp(g)*y/y(-1)) - tau
   Derivación: se parte de Q_t B_t + P_t T_t = B_{t-1} (BFM,
   slide 5), se divide por P_t Y_t, se reescribe el lado derecho
   con la deuda del período anterior y se agrega el crecimiento del
   producto (en BFM el producto es constante). En Uribe-B no hace
   falta corregir inflación ni tasa (meta permanente apagada). Es
   la versión no lineal de la ecuación linealizada de BFM (slide 15).

2) Regla fiscal (BFM, slide 9):
     tau/tau_ss = (sb(-1)/sbF(-1))^gamma_M * (sbF(-1)/sb_ss)^gamma_F
                  * exp(zetaM + zetaF)
   gamma_F = 0 por definición de deuda no financiada.
   gamma_M = 20 > 1 hace estable la deuda financiada.

3) Regla de Taylor con meta fiscal: la de Uribe-B, reemplazando la
   inflación por el término de BFM (slide 10):
     ((1+pi)/(1+piF))^phi_M * ((1+piF)/(1+pibar))^phi_F
   Se mantienen suavizamiento, respuesta al producto y shock zm, de
   modo que con piF en su SS la regla coincide con Uribe-B.
   alpha_pi ya no aparece en ninguna ecuación: su rol lo cumple
   phi_M (por eso el preprocesador avisa "alpha_pi not used").

4) Economía sombra (variables con sufijo F): copia completa del
   equilibrio (con precios rígidos la inflación fiscal depende del
   bloque real). Solo actúa zetaF; el resto de los shocks queda en
   su SS (g = gbar). tauF = tau_ss*exp(zetaF) (gamma_F = 0).
   Taylor sombra: 1+iF = (1+i_ss)*((1+piF)/(1+pibar))^phi_F, solo
   responde a piF (BFM, slide 15).
   Variables compartidas con la economía real: zetaF, piF, sbF
   (nota 7 de la consigna).

CALIBRACIÓN
-----------
  - Parámetros no fiscales: moda de Uribe-B (valores escritos a
    mano en uribe_bfm_irf.mod, tomados de uribe_B_mode_mode.mat).
    HAY QUE ACTUALIZARLOS cuando se corrija el error de Taylor.
  - gamma_M = 20, gamma_F = 0, rho_zetaM = rho_zetaF = 0.5,
    desvíos = 1 (consigna).
  - phi_F = 0 y 0.8 (consigna), por flag -DphiF.
  - phi_M = alpha_pi (caso base). Robustez: phi_M = 2 (BFM, slide 14;
    Online Appendix de BFM, Tabla B.1 — VERIFICADO, ver abajo).
  - Deuda de SS: sb = 2.45 (PBI trimestral, 61% del PBI anual; BFM
    slide 14 — VERIFICADO). El superávit sale de
        tau = sb*[(1+i)/((1+pi)*exp(g)) - 1]  ->  tau = 1.458%
    Con calib_sb = 0 se fija tau (tau_target) y sb sale solo.
    Requiere tau > 0 porque r > g.
  - A = (1+i)/y^alpha_y (piF = pi en SS).
  - La economía sombra es idéntica a la real en SS.

  TABLA B.1 DE BFM, VERIFICADA (filmina 14 de la cursada, que la
  transcribe completa):
      beta = 0.99, alpha = 0.33, N = 0.4, sb = 2.45, tau = 0.02,
      phi_M = 2, phi_F = 0, gamma_M = 1.5, gamma_F = 0, rho = 0.5
  Dos cosas que salen de ahí:
    * sb = 2.45 y phi_M = 2 quedan confirmados.
    * BFM calibran gamma_M = 1.5, NO 20. La consigna manda 20, pero
      conviene mencionar la diferencia en el informe. El punto 3
      estima gamma_M ~ 1.07, mucho más cerca de BFM que de 20.
    * El tau = 0.02 valida la estrategia de estado estacionario:
      2.45*(1/0.99 - 1) = 0.0247, que es la cuenta tau = sb*(RG-1).

CONVENCIONES DE LOS GRÁFICOS
----------------------------
  - Los shocks fiscales mueven el superávit; se grafican con signo
    negativo (= más transferencias), como en BFM.
  - Figuras 1 y 2: por cada 1 pp del PBI trimestral de
    transferencias (se divide por la caída de tau en el impacto).
    Con desvío 1, el shock mueve tau solo 0.015 pp del PBI.
  - Figura 3: cada shock normalizado para que el pico de la
    inflación valga 1 (comparación cualitativa). NO está en la
    misma escala que los gráficos del punto 1.
  - Producto: variable yhat (% de desvío del SS). En la Figura 3,
    el y de Uribe-B se convierte con 100/0.475215.
  - Valores < 1e-10 se redondean a cero al graficar (error de
    redondeo). El chequeo en pantalla muestra los valores crudos.

RESULTADOS (con la moda actual de Uribe-B)
------------------------------------------
  - Modelo determinado en los tres casos (condición de rango OK).
  - zetaM: respuestas de pi, i, y del orden de 1e-14 (cero).
    Solo mueve tau y sb (equivalencia ricardiana).
  - zetaF, phi_F = 0, por 1 pp del PBI (impacto): pi +0.14,
    i +0.01, r -0.14, yhat +0.36%, sb cae. Huella de BFM.
  - zetaF, phi_F = 0.8: inflación mayor y más persistente (pico
    0.30 en t=3), la tasa nominal acompaña, r cae menos.
  - Robustez phi_M = 2: resultados casi idénticos (casi toda la
    inflación del shock es fiscal).
  - Comparación con z^m2: mismos signos en pi, r, y. Difieren en
    persistencia (0.999 vs 0.5, por calibración) y en la tasa
    nominal (Uribe: sube con la meta; BFM con phi_F = 0: no sube).
    El caso más parecido es phi_F = 0.8.
  - La descomposición de varianza que imprime Dynare (zetaF ~0%)
    NO es un resultado: depende del desvío calibrado. Se responde
    en el punto 3.

ADVERTENCIAS PARA EL PUNTO 3 (ya atendidas)
-------------------------------------------
  - Para estimar, usar phi_M (no alpha_pi) en estimated_params.
    HECHO: phi_M hereda la prior de alpha_pi, normal(1.5, 0.25)
    truncada en cero.
  - El nivel de tau reescala el desvío de los shocks fiscales.
    CONFIRMADO y con consecuencia: sigma_zetaM sale 15, a 14
    desvíos de prior de su media. No es conflicto económico sino
    desajuste de unidades (ver EL PROBLEMA DE ESCALA abajo).
    El promedio del déficit resultó POSITIVO como superávit
    (0.116% del PBI), así que la regla multiplicativa queda bien
    definida y no hizo falta reescribirla en niveles.
  - La tercera estimación necesita la regla de Taylor corregida.
    HECHO, y la derivación validó la corrección del punto 1.


================================================================
PUNTO 3 — ESTIMACIÓN DEL MODELO URIBE-BFM
================================================================

ARCHIVOS
--------
  uribe_bfm_est_core.mod   Núcleo de estimación. Copia de
                           uribe_bfm_core.mod (que NO se toca) más
                           def_obs y zm2. NO se corre directo.
  uribe_bfm_e1_mode.mod    E1: observables de Uribe, solo zetaF
  uribe_bfm_e2_mode.mod    E2: + déficit, + zetaM
  uribe_bfm_e3_mode.mod    E3: + z^m2 a la Uribe-B
  uribe_bfm_e2b_mode.mod   Variante de E2 sin cota en el error de
                           medición (chequeo, no es un resultado)
  uribe_bfm_e3_mh.mod      Bonus: Metropolis-Hastings de E3
  uribe_bfm_e{1,2,3}_irf.mod    Cargan la moda con mode_file;
                           IRFs, descomposición y smoother
  uribe_bfm_e3_irf_mean.mod     Lo mismo en la media posterior
  uribe_bfm_gammaM_check.mod    Barrido de la frontera de
                           determinación en gamma_M

  armar_datos_fiscal.m     Construye el observable fiscal
  deficit_primario.csv     Déficit primario federal / PBI, de FRED
  inflacion_observada.csv  Inflación del deflactor y fed funds
  mostrar_moda.m           Lee cualquier *_mode.mat de Dynare
  mode_check_parte3.m      Rehace los gráficos de mode_check
  tablas_parte3.m          Descomposiciones de varianza
  tabla_modas_parte3.m     Moda y desvío, 27 params x 3
  tabla_prior_post.m       Prior vs posterior (necesita el MH)
  tabla_consolidada.m      Las 7 parametrizaciones del trabajo
  irfs_parte3.m            -> irfs_parte3.png
  smoothed_parte3.m        -> inflacion_suavizada_parte3.png
  shocks_parte3.m          -> shocks_parte3.png


ORDEN DE EJECUCIÓN
------------------
  >> armar_datos_fiscal                     (genera datos_uribe_bfm.mat)
  >> dynare uribe_bfm_e1_mode               (~40 s)
  >> dynare uribe_bfm_e2_mode               (~57 s)
  >> dynare uribe_bfm_e3_mode               (~67 s)
  >> dynare uribe_bfm_e3_mh                 (~92 min, el bonus)

  Para cada N en {1,2,3}:
  >> dynare uribe_bfm_e<N>_irf noclearall
  >> save('res_e<N>.mat','oo_','M_')
  >> dynare uribe_bfm_e3_irf_mean noclearall
  >> save('res_e3_mean.mat','oo_','M_')

  >> tablas_parte3 ; tabla_consolidada ; irfs_parte3
  >> smoothed_parte3 ; shocks_parte3
  >> for k=1:3, mode_check_parte3(k); end
  >> tabla_modas_parte3 ; tabla_prior_post

  Todo menos el MH tarda unos cinco minutos en total.


EL OBSERVABLE FISCAL
--------------------
BFM NO usan el déficit primario: sus tres series fiscales son el
crecimiento de las transferencias, el del consumo+inversión pública
y la deuda/PBI (Sección IV.A del paper). Y su muestra arranca en
1960Q1, contra 1955Q1 la de Uribe. Así que hubo que construirla.

Cinco series de FRED, todas trimestrales, Billions of Dollars,
Seasonally Adjusted Annual Rate:
    FGRECPT           Federal Government Current Receipts
    FGEXPND           Federal Government: Current Expenditures
    A091RC1Q027SBEA   Interest payments
    B094RC1Q027SBEA   Interest receipts (solo desde 1960Q1)
    GDP               Gross Domestic Product

    def/PBI = 100*[ (FGEXPND - FGRECPT) - (A091 - B094) ] / GDP

Cuatro decisiones, todas documentadas en la cabecera del script:
  - NO se divide por 4. Un cociente SAAR/SAAR da el mismo número
    que trimestral/trimestral. Es distinto de pai y ff en
    armar_datos.m, que son TASAS y sí se dividen.
  - Intereses NETOS, no solo pagos. FGRECPT incluye income receipts
    on assets; si no se resta B094, el balance "primario" sigue
    teniendo un flujo de intereses del lado de los ingresos.
    B094 arranca en 1960Q1: antes se toma cero, lo que mete un
    quiebre de definición de ~0.25 pp del PBI en 1960Q1.
  - Base de gastos corrientes, no net lending/borrowing. La medida
    NIPA directa (AD02RC1Q027SBEA) arranca en 1959Q3 y no cubre la
    muestra. Sirve de validación: correlacionan 0.98 en el tramo
    que se solapa.
  - Signo positivo = déficit, porque tau es el SUPERÁVIT:
        def_obs = -( tau - STEADY_STATE(tau) )

Resultado: T = 254 (calza exacto con la muestra del punto 1),
media -0.1164% del PBI, desvío 2.1736, varianza 4.7247,
autocorrelación de orden 1 = 0.9553.

La inflación observada (inflacion_observada.csv) se reconstruyó de
FRED con el deflactor GDP/GDPC1, porque el replication package de
Uribe no está en esta máquina. Validada contra el r_obs guardado:
correlación 0.9988, RMSE 0.031 pp. La diferencia es vintage de
datos del BEA y solo desplaza el nivel por una constante.


DECISIONES DE MODELADO
----------------------
* z^m2 EN LA REGLA DE BFM. Es la única derivación del punto.
  Definiendo todo relativo al shock de meta (i_hat = i - z^m2,
  pi_hat = pi - z^m2) y sustituyendo en la regla con suavizamiento,
  el coeficiente que sale es
        [1 - (1-gamma_I)*phi_M] * z^m2_t  -  gamma_I * z^m2_{t-1}
  Misma estructura que el coeficiente corregido de uribe_core.mod,
  con phi_M en el lugar de alpha_pi. La meta pasa a ser pi^F + z^m2.

* PRIORS. gamma_M va con desvío sqrt(5) = 2.2361: la consigna dice
  "media 5 y VARIANZA 5" pero Dynare declara desvíos. Idem
  sigma_zetaF, donde varianza 1 y desvío 1 coinciden.

* EN E1 SE APAGA zetaM con "var e_zetaM = 0", el mismo recurso con
  el que el punto 1 apagó e_gm. Es lo que pide la nota 9: sin datos
  fiscales sus parámetros no están identificados.

* ERROR DE MEDICIÓN DEL DÉFICIT. La consigna pide una prior que
  indique que "a lo mucho" explique 10% de la varianza. Con
  varianza 4.7247 eso da sqrt(0.10*4.7247) = 0.6874 en desvío.
  Se tomó como COTA SUPERIOR con la prior centrada en la mitad:
      stderr def_obs, , 0, 0.6874 , normal_pdf, 0.3437, 0.1718;
  La cota nunca se activa (la moda queda en 0.6211), así que no
  afecta el resultado; lo que mueve el número es dónde se centra
  la prior. Chequeado con uribe_bfm_e2b_mode.mod: sacando la cota
  y centrando en 0.6874 la moda se va a 0.7015, o sea 10.42% de la
  varianza. La verosimilitud quiere pasarse del 10%.
  CUIDADO: si se centra la prior EN la cota y además se acota ahí,
  la moda se clava en el tope y el desvío no se puede computar.

* EL PROBLEMA DE ESCALA DE zeta. La regla fiscal es proporcional,
  tau = tau_ss*(...)^gamma_M * exp((zetaM+zetaF)/100), así que zeta
  es el desvío PORCENTUAL de tau, no pp del PBI. Con tau_ss = 1.458,
  un zeta de 15 son 15% de 1.458 = 0.22 pp del PBI, que es
  razonable. La prior N(1,1) de la consigna solo tendría sentido
  con la regla en niveles. Se mantuvieron las priors de la consigna
  y se reporta sigma_zetaM = 15 explicando la normalización.


RESULTADOS
----------
- gamma_M SOLO SE IDENTIFICA CON EL DÉFICIT. En E1 la moda es
  5.0000 y el desvío 2.2361: exactamente la media y el desvío de
  la prior. El mode_check lo confirma de la manera más limpia
  posible: la curvatura de la log-VEROSIMILITUD en esa dirección
  es 0.0000. Con el observable fiscal pasa a 1.07 con desvío 0.10.

- LA FRONTERA DE DETERMINACIÓN ESTÁ EN gamma_M = 1 exacto
  (uribe_bfm_gammaM_check.mod: con 0.99 hay 8 autovalores
  explosivos contra 7 variables forward-looking; desde 1.00 la
  condición de rango se verifica). La moda de 1.071 está 0.71
  desvíos por encima, o sea interior pero cerca. El MH lo confirma:
  el HPD de gamma_M es [1.0020, 1.4505], con el límite inferior
  clavado en la frontera. La posterior es asimétrica y la
  aproximación de Laplace no la captura.

- EL BLOQUE REAL NO SE MUEVE. E3 reproduce la moda de Uribe-B casi
  exactamente (rho_xi 0.9238 vs 0.9230; gamma_m 0.5999 vs 0.6011;
  rho_theta y rho_z idénticos a 4 decimales). El bloque fiscal se
  lleva el déficit y no toca nada más.

- DENSIDADES MARGINALES. E1 = -334.53 (3 observables, NO comparable
  con las otras dos). E2 = -841.43 y E3 = -837.15, las dos con 4
  observables: E3 gana por 4.29 puntos log. Los datos quieren el
  bloque fiscal Y el shock exógeno a la meta.

- DESCOMPOSICIÓN DE VARIANZA DEL CAMBIO EN LA INFLACIÓN. El
  resultado central del punto, en tabla_consolidada.m:

    shock de tendencia    Uribe-A md   50.78
                          Uribe-A mean 48.52
                          Uribe-B md   55.37
                          E1           48.84   (lo ocupa zetaF)
                          E2           47.40   (lo ocupa zetaF)
                          E3 md        50.72   (lo ocupa z^m2)
                          E3 mean      48.19   (lo ocupa z^m2)

  Hay un lugar de ~50% para la tendencia inflacionaria y lo ocupa
  el shock que esté disponible. En E3, donde los dos compiten,
  z^m2 se queda con 50.72% y zetaF cae a 3.30% (0.36% con la media
  posterior). Uribe reporta ~45% en el paper.

- zetaM ES RICARDIANO, verificado con el shock estimado y no
  calibrado: explica 88% del déficit y 0.00% de la inflación, el
  producto y la tasa, en las cuatro parametrizaciones.

- EL MH (1.000.000 de draws, aceptación 35.05%, 92 minutos)
  refuerza la conclusión: el HPD de sigma_zetaF es [0.0031, 2.9772],
  o sea que NO se puede descartar que el shock fiscal no financiado
  sea cero. El de sigma_zm2 es [0.1055, 0.1894], angosto y lejos
  de cero.

- PARÁMETROS NO IDENTIFICADOS. rho_theta y rho_z en las tres (ya
  pasaba en el punto 1). En E3 se suma phi_F: su desvío posterior
  (0.5709) es mayor que el de su prior (0.25), y el mode_check
  muestra que el máximo de la verosimilitud cae en el borde
  izquierdo del intervalo explorado. Los datos quieren phi_F -> 0
  una vez que z^m2 se lleva la inflación persistente.

- LA RESPUESTA A LA PREGUNTA DEL TP. Los shocks que identifica
  Uribe no son de origen fiscal, pero son casi indistinguibles de
  un shock fiscal si uno mira solamente sus tres observables.
  Hacen falta las dos cosas juntas, el dato del déficit Y la
  competencia directa entre los dos shocks, para separarlos.


ARCHIVOS QUE NO CONVIENE SUBIR AL REPOSITORIO
---------------------------------------------
Las carpetas de output de Dynare (uribe_A_mh/metropolis/ y
uribe_bfm_e3_mh/metropolis/, 76 MB) pesan cientos de MB. Sí
conviene conservar los *_mode.mat: son chicos y evitan reestimar.

Las carpetas con prefijo "+" (+uribe_bfm_e3_mode, etc.) son
PACKAGES de MATLAB que genera Dynare: el .mod traducido a código
.m. Son regenerables y están en el .gitignore por la regla "+*/".

TRAMPA DEL .gitignore: la regla
    */Output/
    !*/Output/*_mode.mat
NO funciona. Cuando un DIRECTORIO está ignorado git ni siquiera
entra a mirar adentro, así que nunca llega a evaluar la excepción.
Los *_mode.mat nuevos hay que agregarlos a mano:

    git add -f uribe_bfm_e1_mode/Output/uribe_bfm_e1_mode_mode.mat
    git add -f uribe_bfm_e2_mode/Output/uribe_bfm_e2_mode_mode.mat
    git add -f uribe_bfm_e3_mode/Output/uribe_bfm_e3_mode_mode.mat
    git add -f uribe_bfm_e3_mh/Output/uribe_bfm_e3_mh_mode.mat

Es de una sola vez: una vez trackeado, el .gitignore deja de
aplicarle al archivo.


PENDIENTE
---------
- Punto 2: actualizar la moda de Uribe-B en uribe_bfm_irf.mod, que
  quedó con los valores de antes de la corrección de Taylor, y
  volver a correr parte2_irfs. Mejor todavía: pasarlo a mode_file
  como ya hace uribe_B_irf.mod, para que no vuelva a desfasarse.
  La moda corregida, lista para pegar (sale de mostrar_moda.m
  sobre uribe_B_mode/Output/uribe_B_mode_mode.mat):
      phi = 98.6550379 ; alpha_pi = 2.2726831
      alpha_y = 0.1897106 ; gamma_m = 0.6011330
      gamma_I = 0.2387028 ; delta = 0.2082673
      rho_xi = 0.9230017 ; rho_theta = 0.8797447
      rho_z = 0.8789118 ; rho_g = 0.1937693 ; rho_zm = 0.3045166
      stderr e_xi = 2.6113892 ; e_theta = 0.0189685
      e_z = 0.0106926 ; e_g = 0.7697094 ; e_zm = 0.1159301
      e_zm2 = 0.1509805

- Punto 3: rehacer las IRFs A vs B con la regla corregida (el
  número de la tasa real en el impacto está medido con la vieja).

- Punto 3, opcional: la regla fiscal en NIVELES como robustez, que
  es lo que haría que la prior N(1,1) de sigma_zeta tenga sentido
  (ver EL PROBLEMA DE ESCALA).

- Punto 3, opcional: el MH de E2, para comparar densidades
  marginales E2 vs E3 con el mismo método. Hoy la comparación es
  Laplace contra Laplace, que sirve, pero con el hessiano mal
  condicionado conviene confirmarla. Son otras ~2 horas.

- Punto 4: versión no estacionaria (1 pt). SIN EMPEZAR.

- Redacción: máximo 25 páginas + resumen ejecutivo
