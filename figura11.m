% ========================================================
%  Figura 11 — IRFs a los tres shocks monetarios
%  Layout comparable a Uribe (2022), Figura 11
%  Correr DESPUÉS de: dynare uribereescaled
% ========================================================

H  = length(oo_.irfs.dpi_obs_e_gm);
hh = 0:H-1;

shocks  = {'e_gm', 'e_zm2', 'e_zm'};
titulos = {'X_t^m', 'z_t^{m2}', 'z_t^m'};

% --- Series en niveles acumulados ---
PI = zeros(H,3); II = zeros(H,3); YY = zeros(H,3);

for s = 1:3
    sh = shocks{s};
    PI(:,s) = cumsum(oo_.irfs.(['dpi_obs_' sh])(1:H))';
    II(:,s) = cumsum(oo_.irfs.(['di_obs_'  sh])(1:H))';
    YY(:,s) = cumsum(oo_.irfs.(['dy_obs_'  sh])(1:H))';
end

% --- Normalización ---
% gm  : a 1 pp de aumento de largo plazo de la inflación
% zm2 : a 1 pp de aumento máximo de la inflación
% zm  : a 0.75 pp de salto inicial de la tasa nominal
esc = [ 1/PI(end,1) , 1/max(PI(:,2)) , 0.75/II(1,3) ];

fprintf('\nFactores de normalización:\n');
fprintf('  %-6s : %.3f\n',   'gm',  esc(1));
fprintf('  %-6s : %.3f\n',   'zm2', esc(2));
fprintf('  %-6s : %.3f\n\n', 'zm',  esc(3));

for s = 1:3
    PI(:,s) = PI(:,s)*esc(s);
    II(:,s) = II(:,s)*esc(s);
    YY(:,s) = YY(:,s)*esc(s);
end

% --- Gráfico ---
figure('Position',[80 80 1000 560],'Color','w');

for s = 1:3
    % Fila 1: inflación y tasa nominal
    subplot(2,3,s);
    plot(hh, II(:,s), 'r--', 'LineWidth', 1.8); hold on;
    plot(hh, PI(:,s), 'b-',  'LineWidth', 1.8);
    yline(0,'k:');
    title(titulos{s}, 'FontSize', 13, 'Interpreter','tex');
    legend({'I_t','\Pi_t'}, 'Location','best', 'Box','off', 'Interpreter','tex');
    grid on; box off; xlim([0 H-1]);
    if s==1, ylabel('pp anuales'); end

    % Fila 2: producto
    subplot(2,3,3+s);
    plot(hh, YY(:,s), 'b-', 'LineWidth', 1.8); hold on;
    yline(0,'k:');
    title(titulos{s}, 'FontSize', 13, 'Interpreter','tex');
    legend({'Y_t'}, 'Location','best', 'Box','off', 'Interpreter','tex');
    grid on; box off; xlim([0 H-1]);
    xlabel('Trimestres');
    if s==1, ylabel('% desv. del nivel pre-shock'); end
end

saveas(gcf, 'figura11_replicacion.png');