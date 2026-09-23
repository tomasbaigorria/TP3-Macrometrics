% ========================================================
%  armar_datos_fiscal.m
%  Agrega el cuarto observable del punto 3: el DEFICIT
%  PRIMARIO FEDERAL como % del PBI nominal, desestacionalizado
%  y sin media.
%
%  Lee deficit_primario.csv (ya construido desde FRED, ver
%  cabecera de abajo), lo alinea contra las fechas de
%  datos_uribe.mat y guarda todo en datos_uribe_bfm.mat.
%
%  NO toca datos_uribe.mat: el punto 1 sigue siendo
%  reproducible exactamente igual.
%
%  Uso:  >> armar_datos_fiscal
% ========================================================
%
%  CONSTRUCCION DE LA SERIE (deficit_primario.csv)
%  -----------------------------------------------
%  Fuente: FRED, cuatro series trimestrales, todas en
%  Billions of Dollars, Seasonally Adjusted Annual Rate,
%  disponibles desde 1947Q1:
%
%    FGRECPT           Federal Government Current Receipts
%    FGEXPND           Federal Government: Current Expenditures
%    A091RC1Q027SBEA   Federal government current expenditures:
%                      Interest payments
%    B094RC1Q027SBEA   Federal government current receipts: Income
%                      receipts on assets: Interest receipts
%                      (solo desde 1960Q1; antes se toma 0)
%    GDP               Gross Domestic Product
%
%    deficit primario / PBI  =  100 * [ (FGEXPND - FGRECPT)
%                                        - (A091 - B094) ] / GDP
%
%  Intereses NETOS, no solo pagos: FGRECPT incluye income receipts
%  on assets, de los cuales B094 es el componente de intereses. Si
%  se restan solo los pagos, el balance "primario" sigue teniendo
%  un flujo de intereses del lado de los ingresos. Hay que sacarlos
%  de los dos lados.
%  B094 arranca en 1960Q1; antes se toma 0, lo que introduce un
%  quiebre de definicion de ~0.25 pp del PBI en 1960Q1. Los cobros
%  de intereses federales eran genuinamente chicos en los 50.
%
%  Signo: positivo = deficit. Mapea contra el modelo como
%     def_obs = -( tau - tau_ss )
%  porque tau en uribe_bfm_core.mod es el SUPERAVIT primario
%  en % del PBI (BFM, filmina 6: tau_t = T_t/Y).
%
%  Escala: no se divide por 4. Un cociente SAAR/SAAR da el
%  mismo numero que trimestral/trimestral, a diferencia de
%  pai y ff en armar_datos.m, que son TASAS y si se dividen.
%
%  Base elegida: gastos corrientes (equivale al net federal
%  saving primario). Se descarta la medida NIPA de net
%  lending/borrowing (AD02RC1Q027SBEA) porque arranca en
%  1959Q3 y no cubre el inicio de la muestra de Uribe.
%  En el tramo que se solapa las dos correlacionan 0.98; la
%  diferencia de nivel (0.62 pp, inversion bruta y transfe-
%  rencias de capital) desaparece al demanear.
% ========================================================

clear; clc;

% --- 1. Leer el CSV del deficit ---
if exist('deficit_primario.csv','file') ~= 2
    error('Falta deficit_primario.csv en la carpeta.');
end
D = readtable('deficit_primario.csv');

% --- 2. Leer los observables de Uribe ---
U = load('datos_uribe.mat');   % dy_obs r_obs di_obs fechas

% --- 3. Alinear por fecha ---
% fechas viene de read_data.m en anio decimal (1955.00, 1955.25, ...)
f_u = round(U.fechas(:)*100)/100;
f_d = round(D.t(:)*100)/100;

[tf, loc] = ismember(f_u, f_d);
if ~all(tf)
    error(['No hay deficit para %d de las %d fechas de la muestra ' ...
           '(primera faltante: %.2f).'], sum(~tf), numel(f_u), ...
           f_u(find(~tf,1)));
end
def_raw = D.def_pib(loc);

% --- 4. Demeanear (como los otros tres observables) ---
def_media = mean(def_raw);
def_obs   = def_raw - def_media;

% --- 5. Chequeos ---
fprintf('\n=== Deficit primario federal (%% del PBI nominal) ===\n');
fprintf('Muestra   : %.2f a %.2f   (T = %d)\n', ...
        f_u(1), f_u(end), numel(def_obs));
fprintf('NaNs      : %d\n', sum(isnan(def_obs)));
fprintf('Media original (antes de demeanear): %+.4f %% del PBI\n', def_media);
fprintf('  (signo negativo = SUPERAVIT primario promedio)\n');
fprintf('Desvio    : %.4f    Varianza : %.4f\n', ...
        std(def_obs), var(def_obs));

R = corrcoef(def_obs(1:end-1), def_obs(2:end));
fprintf('Autocorr(1): %.4f\n', R(1,2));

% Lo que hace falta para la prior del measurement error:
% "a lo mucho puede explicar 10%% de la varianza del observable"
sd_me = sqrt(0.10*var(def_obs));
fprintf(['\nPrior del measurement error (10%% de la varianza):\n' ...
         '   stderr def_obs -> media %.4f\n'], sd_me);
fprintf('   linea para el .mod:\n');
fprintf('   stderr def_obs, , 0, ,  normal_pdf,  %.4f,  %.4f;\n', ...
        sd_me, sd_me/2);

% --- 6. Grafico de control ---
figure('Position',[100 100 900 420],'Color','w');
plot(f_u, def_obs, 'LineWidth', 1.1); hold on;
yline(0,'k:'); grid on; box off;
ylabel('def\_obs'); xlabel('Anio');
title('Deficit primario federal, % del PBI nominal (media cero)');

% --- 7. Guardar ---
dy_obs = U.dy_obs;  r_obs = U.r_obs;  di_obs = U.di_obs;
fechas = U.fechas;
save('datos_uribe_bfm.mat', 'dy_obs','r_obs','di_obs','def_obs', ...
     'fechas','def_media');
fprintf('\nGuardado en datos_uribe_bfm.mat (4 observables)\n\n');
