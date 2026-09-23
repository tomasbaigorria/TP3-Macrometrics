% ============================================================
%  smoothed_parte3.m
%  Inflacion suavizada de las tres estimaciones del punto 3.
%
%  Como pide la consigna: se toma el CAMBIO suavizado en la
%  inflacion (dpi_obs) y se acumula desde el primer valor
%  OBSERVADO de la inflacion.
%
%  La serie observada sale de inflacion_observada.csv, que se
%  reconstruye de FRED (deflactor del PBI = GDP/GDPC1) porque el
%  replication package de Uribe no esta en esta maquina. Validada
%  contra el r_obs guardado en datos_uribe.mat: correlacion
%  0.9988, RMSE 0.031 pp. La diferencia es vintage de datos (BEA
%  revisa), y solo desplaza el NIVEL de las series reconstruidas
%  por una constante.
%
%  Requiere res_e1.mat, res_e2.mat, res_e3.mat.
%  Genera inflacion_suavizada_parte3.png
% ============================================================

P      = readtable('inflacion_observada.csv');
fechas = P.t;
obs    = P.pai;          % % anual
pi0    = obs(1);

estilos = {'b-','r--','k-.'};
anchos  = [1.8 1.5 1.7];
etiq    = {'E1: sin deficit, sin z^{m2}', ...
           'E2: con deficit, sin z^{m2}', ...
           'E3: con deficit, con z^{m2}'};

figure('Position',[60 60 1000 500],'Color','w');
plot(fechas, obs, 'Color',[.7 .7 .7], 'LineWidth',1.0); hold on;

fprintf('\n%-6s %10s %10s %10s\n','', 'corr(obs)','RMSE','media');
for N = 1:3
    S   = load(sprintf('res_e%d.mat', N));
    dsm = S.oo_.SmoothedVariables.dpi_obs(:);   % pp trimestrales
    lvl = pi0 + cumsum(4*dsm);                  % a % anual
    plot(fechas, lvl, estilos{N}, 'LineWidth', anchos(N));
    R = corrcoef(lvl, obs);
    fprintf('E%-5d %10.4f %10.4f %10.4f\n', ...
            N, R(1,2), sqrt(mean((lvl-obs).^2)), mean(lvl));
end
fprintf('%-6s %10s %10.4f %10.4f\n','obs','--',0,mean(obs));

legend([{'Observada'} etiq], 'Box','off','Location','best','FontSize',8);
ylabel('% anual'); xlabel('Anio');
title('Inflacion observada y suavizada — estimaciones del punto 3');
grid on; box off;
saveas(gcf,'inflacion_suavizada_parte3.png');
fprintf('\nGuardado inflacion_suavizada_parte3.png\n');
