% ========================================================
%  armar_datos.m
%  Construye los tres observables de Uribe (2022) y los
%  guarda en datos_uribe.mat para la estimación en Dynare.
%
%  Correr desde la carpeta del replication package
%  (donde están read_data.m y los tres .xlsx)
% ========================================================

clear; clc;

% --- 1. Leer las series crudas ---
% Dy  : crecimiento del PIB real per cápita, % trimestral
% pai : inflación del deflactor, % ANUALIZADA
% ff  : tasa de fondos federales, % ANUAL
dir_trabajo = pwd;
dir_datos   = 'G:\Mi unidad\Facultad\UdeSA\Macroeconometría\Uribe_Neo_Fisher\empirical_model';

cd(dir_datos);
[Dy, Dpai, Dff, y, pai, ff, date] = read_data;
cd(dir_trabajo);
% --- 2. Pasar tasas a frecuencia trimestral ---
% Aproximación estándar: dividir por 4.
% (La conversión exacta sería 100*((1+x/100)^(1/4)-1); a estos
%  niveles la diferencia es de segundo orden.)
pai_q = pai/4;
ff_q  = ff/4;

% --- 3. Construir los observables (Appendix, p.3) ---
obs_dy = Dy;                        % 100 x Delta y_t
obs_r  = ff_q - pai_q;              % r_t = i_t - pi_t
obs_di = [NaN; diff(ff_q)];         % Delta i_t

% --- 4. Alinear: diff() pierde la primera observación ---
ini = 2;
obs_dy = obs_dy(ini:end);
obs_r  = obs_r(ini:end);
obs_di = obs_di(ini:end);
fechas = date(ini:end);

% --- 5. Demeanear (los tres, como pide el enunciado) ---
dy_obs = obs_dy - mean(obs_dy);
r_obs  = obs_r  - mean(obs_r);
di_obs = obs_di - mean(obs_di);

% --- 6. Chequeos ---
fprintf('\n=== Chequeos ===\n');
fprintf('Muestra      : %.2f  a  %.2f   (T = %d)\n', ...
         fechas(1), fechas(end), length(fechas));
fprintf('NaNs         : %d\n', sum(isnan([dy_obs r_obs di_obs]),'all'));
fprintf('\n%-10s %10s %10s %10s\n','serie','media','desvío','autocorr(1)');
nombres = {'dy_obs','r_obs','di_obs'};
series  = [dy_obs r_obs di_obs];
for k = 1:3
    R  = corrcoef(series(1:end-1,k), series(2:end,k));
    ac = R(1,2);
    fprintf('%-10s %10.2e %10.4f %10.4f\n', ...
            nombres{k}, mean(series(:,k)), std(series(:,k)), ac);
end

fprintf('\nMedias originales (antes de demeanear):\n');
fprintf('  crecimiento PIB : %6.4f %% trimestral\n', mean(obs_dy));
fprintf('  tasa real       : %6.4f %% trimestral\n', mean(obs_r));
fprintf('  cambio tasa nom.: %6.4f %% trimestral\n', mean(obs_di));

% --- 7. Gráfico de control ---
figure('Position',[100 100 900 600],'Color','w');
for k = 1:3
    subplot(3,1,k);
    plot(fechas, series(:,k), 'LineWidth', 1.1);
    yline(0,'k:'); grid on; box off;
    ylabel(nombres{k}, 'Interpreter','none');
    if k==1, title('Observables (media cero, % trimestral)'); end
    if k==3, xlabel('Año'); end
end

% --- 8. Guardar ---
save('datos_uribe.mat', 'dy_obs', 'r_obs', 'di_obs', 'fechas');
fprintf('\nGuardado en datos_uribe.mat\n\n');