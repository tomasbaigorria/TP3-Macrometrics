% --- Inflación observada vs suavizada ---

% Serie observada de inflación (% anualizada) desde el replication package
dir_datos = 'G:\Mi unidad\Facultad\UdeSA\Macroeconometría\Uribe_Neo_Fisher\empirical_model';   % ajustá
dir_trab  = pwd;
cd(dir_datos);
[~,~,~,~,pai,~,date] = read_data;
cd(dir_trab);

% Alinear con la muestra de estimación (1955Q1-2018Q2, T=254)
pai_obs = pai(2:end);
fechas  = date(2:end);

% Cambio suavizado (pp trimestrales) -> anualizar
dpi_sm = 4*oo_.SmoothedVariables.dpi_obs(:);

% Reconstruir el nivel desde el primer valor observado
pi_sm = pai_obs(1) + cumsum(dpi_sm);

% Chequeo de longitudes
fprintf('obs: %d   smooth: %d\n', length(pai_obs), length(pi_sm));

figure('Position',[100 100 900 450],'Color','w');
plot(fechas, pai_obs, 'Color',[.6 .6 .6], 'LineWidth',1.1); hold on;
plot(fechas, pi_sm,  'b-', 'LineWidth',1.8);
legend({'Observada','Suavizada'}, 'Box','off','Location','best');
ylabel('% anual'); xlabel('Año');
title('Inflación: observada vs. suavizada (Uribe-A, moda)');
grid on; box off;
saveas(gcf,'inflacion_suavizada.png');