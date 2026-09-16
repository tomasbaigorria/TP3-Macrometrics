================================================================
TP3 MACROECONOMETRÍA — PUNTO 1 (Replicación y estimación Uribe)
UdeSA 2026 — García-Cicco / Nuñez
================================================================

QUÉ HAY ACÁ
-----------
Código de Dynare y MATLAB para el punto 1: replicación del modelo
NK de Uribe (2022, AEJ:Macro, sección IV) y estimación bayesiana
de las versiones Uribe-A y Uribe-B.

Estado: punto 1 completo. Faltan los puntos 2, 3 y 4.


REQUISITOS
----------
- MATLAB (no Octave: el MH de 1M draws es inviable ahí)
- Dynare 7.0, con addpath a la carpeta /matlab de la instalación
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


ORDEN DE EJECUCIÓN
------------------

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

* uribe_core.mod contiene el modelo; los demás .mod lo incluyen
  con @#include. Un cambio en el core afecta a todos.

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
  impacto (documentada en el informe, no resuelta).

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
  Los datos NO distinguen entre meta con raíz unitaria y meta
  casi-unitaria (rho=0.999).

- IRFs A vs B: coinciden a partir del trimestre 4, pero difieren
  en el impacto (tasa real: -0.04 en A vs -0.24 en B). La causa
  es el término (1-alpha_pi)*zm2 en la regla de Taylor
  estacionarizada, no la persistencia.


ARCHIVOS QUE NO CONVIENE SUBIR AL REPOSITORIO
---------------------------------------------
Las carpetas de output de Dynare (uribe_A_mh/metropolis/ en
particular) pesan cientos de MB. Sí conviene conservar los
archivos *_mode.mat: son chicos y evitan tener que reestimar.


PENDIENTE
---------
- Punto 2: bloque fiscal a la BFM (1.5 pts)
- Punto 3: estimación Uribe-BFM (2.5 pts)
- Punto 4: versión no estacionaria (1 pt)
- Redacción: máximo 25 páginas + resumen ejecutivo
