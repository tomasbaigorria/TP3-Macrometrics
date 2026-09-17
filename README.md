================================================================
TP3 MACROECONOMETRÍA — PUNTOS 1 Y 2
UdeSA 2026 — García-Cicco / Nuñez
================================================================

QUÉ HAY ACÁ
-----------
Código de Dynare y MATLAB para:
  - Punto 1: replicación del modelo NK de Uribe (2022, AEJ:Macro,
    sección IV) y estimación bayesiana de Uribe-A y Uribe-B.
  - Punto 2: modelo Uribe-BFM (Uribe-B + bloque fiscal de Bianchi,
    Faccini & Melosi, 2023, QJE) calibrado, con IRFs.

Estado: punto 2 completo. Punto 1 completo, PERO con un error
detectado en la regla de Taylor que afecta a z^m2 (ver sección
"ERROR DETECTADO"). Faltan los puntos 3 y 4.


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
ERROR DETECTADO EN EL PUNTO 1 (PENDIENTE DE CORREGIR)
================================================================

La regla de Taylor de uribe_core.mod tiene el término
    (1-alpha_pi)*zm2/scale
copiado de la versión estacionaria del Online Appendix de Uribe
(p. 11). Ese coeficiente es un error de tipeo del apéndice: si se
estacionariza la regla original (ecuación 17, p. 9), el coeficiente
correcto es
    (1-(1-gamma_I)*alpha_pi)*zm2/scale

Prueba: con la moda de Uribe-B, una suba de 1 pp en la meta
(z^m2, rho = 0.999) lleva la inflación de largo plazo a
    - regla actual:    1.52 pp   (sin sentido económico)
    - regla corregida: 1.01 pp   (la inflación converge a la meta)

Afecta: todo lo que usa z^m2 (réplica calibrada Fig. 11-12,
Uribe-B completo, comparación A vs B). Probablemente es la causa
de la discrepancia en la respuesta de la tasa ante z^m2 que figura
en RESULTADOS. NO afecta la estimación de Uribe-A (z^m2 apagado),
así que el MH no hace falta repetirlo.

Para corregir: cambiar esa línea en uribe_core.mod y volver a
correr uribe_B_mode, uribe_B_smoother, uribe_B_irf
y la réplica calibrada. Después actualizar la moda de Uribe-B en
uribe_bfm_irf.mod (punto 2) y volver a correr parte2_irfs.

El modelo Uribe-BFM del punto 2 NO tiene este error (esa parte de
la regla se reemplaza), pero su calibración y la curva de z^m2 en
la Figura 3 dependen de Uribe-B.


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
  ERROR DETECTADO).

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

- Densidades marginales (Laplace): A = -331.78 ; B = -331.98.
  [B hay que recalcularla con la regla corregida.]
  Los datos NO distinguen entre meta con raíz unitaria y meta
  casi-unitaria (rho=0.999).

- IRFs A vs B: coinciden a partir del trimestre 4, pero difieren
  en el impacto (tasa real: -0.04 en A vs -0.24 en B). La causa
  es el término (1-alpha_pi)*zm2 en la regla de Taylor
  estacionarizada, no la persistencia. [Ese término es el error
  detectado: ver arriba. Este resultado hay que rehacerlo.]


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
    Online Appendix de BFM, Tabla B.1 — VERIFICAR antes de citar).
  - Deuda de SS: sb = 2.45 (PBI trimestral, 61% del PBI anual; BFM
    slide 14, verificar). El superávit sale de
        tau = sb*[(1+i)/((1+pi)*exp(g)) - 1]  ->  tau = 1.458%
    Con calib_sb = 0 se fija tau (tau_target) y sb sale solo.
    Requiere tau > 0 porque r > g.
  - A = (1+i)/y^alpha_y (piF = pi en SS).
  - La economía sombra es idéntica a la real en SS.

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

ADVERTENCIAS PARA EL PUNTO 3
----------------------------
  - Para estimar, usar phi_M (no alpha_pi) en estimated_params.
  - Como el déficit entra sin media, el nivel de tau solo reescala
    el desvío estimado de los shocks fiscales. Si se quisiera
    calibrar tau con el promedio de los datos y fuera negativo, hay
    que reescribir la regla fiscal en niveles.
  - La tercera estimación (con z^m2) necesita la regla de Taylor
    corregida.


ARCHIVOS QUE NO CONVIENE SUBIR AL REPOSITORIO
---------------------------------------------
Las carpetas de output de Dynare (uribe_A_mh/metropolis/ en
particular) pesan cientos de MB. Sí conviene conservar los
archivos *_mode.mat: son chicos y evitan tener que reestimar.


PENDIENTE
---------
- Punto 1: corregir la regla de Taylor (ver ERROR DETECTADO) y
  volver a correr lo que usa z^m2
- Punto 2: actualizar la moda de Uribe-B en uribe_bfm_irf.mod y
  volver a correr parte2_irfs (después de lo anterior)
- Punto 2: verificar en el Online Appendix de BFM (Tabla B.1) los
  valores sb = 2.45 y phi_M = 2 antes de citarlos
- Punto 3: estimación Uribe-BFM (2.5 pts)
- Punto 4: versión no estacionaria (1 pt)
- Redacción: máximo 25 páginas + resumen ejecutivo
