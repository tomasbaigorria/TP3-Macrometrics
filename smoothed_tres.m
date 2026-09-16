% ============================================================
%  Inflación suavizada bajo las tres parametrizaciones
% ============================================================

% --- Correr los tres y guardar ---
% (ejecutar estas líneas de a una en la consola)
%
%   dynare uribe_A_smoother
%   dpi_mc5 = oo_.SmoothedVariables.dpi_obs;
%
%   dynare uribe_A_smoother6
%   dpi_mc6 = oo_.SmoothedVariables.dpi_obs;
%
%   dynare uribe_A_mh
%   dpi_mh  = oo_.SmoothedVariables.dpi_obs;
%
% Después correr este script.

% --- Serie observada ---
dir_datos = 'G:\Mi unidad\Facultad\UdeSA\Macroeconometría\Uribe_Neo_Fisher\empirical_model';
dir_trab  = pwd;
cd(dir_datos);
[~,~,~,~,pai,~,date] = read_data;
cd(dir_trab);

pai_obs = pai(2:end);
fechas  = date(2:end);

% --- Reconstruir niveles ---
pi0 = pai_obs(1);
pi_mc5 = pi0 + cumsum(4*dpi_mc5(:));
pi_mc6 = pi0 + cumsum(4*dpi_mc6(:));
pi_mh  = pi0 + cumsum(4*dpi_mh(:));

% --- Gráfico ---
figure('Position',[100 100 950 480],'Color','w');
plot(fechas, pai_obs, 'Color',[.7 .7 .7], 'LineWidth',1.0); hold on;
plot(fechas, pi_mc5, 'b-',  'LineWidth',1.7);
plot(fechas, pi_mc6, 'r--', 'LineWidth',1.4);
plot(fechas, pi_mh,  'k:',  'LineWidth',1.6);
legend({'Observada','Moda (mc=5)','Moda (mc=6)','Media posterior'}, ...
       'Box','off','Location','best');
ylabel('% anual'); xlabel('Año');
title('Inflación observada y suavizada — Uribe-A, tres parametrizaciones');
grid on; box off;
saveas(gcf,'inflacion_suavizada_tres.png');