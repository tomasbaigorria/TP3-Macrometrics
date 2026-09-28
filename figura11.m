% ============================================================
%  Figura 11 — normalización igual a Uribe (ir_chain.m / nk_irfs.m)
%  Correr DESPUÉS de: dynare uribereescaled
% ============================================================

H  = length(oo_.irfs.dpi_obs_e_gm);
hh = 0:H-1;
shocks  = {'e_gm', 'e_zm2', 'e_zm'};
titulos = {'X_t^m', 'z_t^{m2}', 'z_t^m'};

PI = zeros(H,3); II = zeros(H,3); YY = zeros(H,3);
for s = 1:3
    sh = shocks{s};
    PI(:,s) = 4*cumsum(oo_.irfs.(['dpi_obs_' sh])(1:H))';   % pp anuales
    II(:,s) = 4*cumsum(oo_.irfs.(['di_obs_'  sh])(1:H))';   % pp anuales
    YY(:,s) =   cumsum(oo_.irfs.(['dy_obs_'  sh])(1:H))';   % %
end

% Normalización de Uribe
esc = zeros(1,3);
esc(1) = 1/II(end,1);                       % X^m: tasa +1 pp anual en el largo plazo
for s = 2:3                                  % z^m2, z^m: innovación de 1 pp anual
    idx    = strmatch(shocks{s}, M_.exo_names, 'exact');
    esc(s) = 0.25 / sqrt(M_.Sigma_e(idx,idx)); % 0.25 = 1 pp anual en unidades trimestrales
end
PI = PI.*esc;  II = II.*esc;  YY = YY.*esc;

figure('Position',[80 80 1000 560],'Color','w');
for s = 1:3
    subplot(2,3,s);
    plot(hh, II(:,s), 'r--', 'LineWidth', 1.8); hold on;
    plot(hh, PI(:,s), 'b-',  'LineWidth', 1.8); yline(0,'k:');
    title(titulos{s},'FontSize',13,'Interpreter','tex');
    legend({'I_t','\Pi_t'},'Location','best','Box','off','Interpreter','tex');
    grid on; box off; xlim([0 H-1]);
    if s==1, ylabel('pp anuales'); end

    subplot(2,3,3+s);
    plot(hh, YY(:,s), 'b-', 'LineWidth', 1.8); hold on; yline(0,'k:');
    title(titulos{s},'FontSize',13,'Interpreter','tex');
    legend({'Y_t'},'Location','best','Box','off','Interpreter','tex');
    grid on; box off; xlim([0 H-1]); xlabel('Trimestres');
    if s==1, ylabel('% desv. del nivel pre-shock'); end
end
saveas(gcf,'figura11_replicacion.png');