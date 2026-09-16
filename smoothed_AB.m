% ============================================================
%  Inflación suavizada: Uribe-A vs Uribe-B
%  Requiere: dpi_mc5 (A, moda) y dpi_B (B, moda) en el workspace
% ============================================================

dir_datos = 'G:\Mi unidad\Facultad\UdeSA\Macroeconometría\Uribe_Neo_Fisher\empirical_model';
dir_trab  = pwd;
cd(dir_datos);
[~,~,~,~,pai,~,date] = read_data;
cd(dir_trab);

pai_obs = pai(2:end);
fechas  = date(2:end);
pi0     = pai_obs(1);

pi_A = pi0 + cumsum(4*dpi_mc5(:));
pi_B = pi0 + cumsum(4*dpi_B(:));

figure('Position',[100 100 950 480],'Color','w');
plot(fechas, pai_obs, 'Color',[.75 .75 .75], 'LineWidth',1.0); hold on;
plot(fechas, pi_A, 'b-',  'LineWidth',1.7);
plot(fechas, pi_B, 'r--', 'LineWidth',1.5);
legend({'Observada','Uribe-A','Uribe-B'}, 'Box','off','Location','best');
ylabel('% anual'); xlabel('Año');
title('Inflación observada y suavizada — Uribe-A vs Uribe-B');
grid on; box off;
saveas(gcf,'inflacion_suavizada_AB.png');

% Diferencia máxima entre las dos
fprintf('\nDiferencia máxima A-B: %.4f pp\n', max(abs(pi_A - pi_B)));
fprintf('Diferencia media  A-B: %.4f pp\n', mean(abs(pi_A - pi_B)));