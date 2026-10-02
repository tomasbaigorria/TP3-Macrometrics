% ============================================================
%  Figura 12 — respuesta de la tasa real a los tres shocks
%  Correr DESPUÉS de: dynare uribereescaled
% ============================================================

H  = length(oo_.irfs.r_obs_e_gm);
hh = 0:H-1;

shocks = {'e_gm','e_zm2','e_zm'};
R  = zeros(H,3);
PI = zeros(H,3);
II = zeros(H,3);
for s = 1:3
    sh = shocks{s};
    R(:,s)  = 4*oo_.irfs.(['r_obs_'   sh])(1:H)';
    PI(:,s) = 4*cumsum(oo_.irfs.(['dpi_obs_' sh])(1:H))';
    II(:,s) = 4*cumsum(oo_.irfs.(['di_obs_'  sh])(1:H))';
end

% Misma normalización que la Figura 11
esc = zeros(1,3);
esc(1) = 1/II(end,1);
for s = 2:3
    idx    = strmatch(shocks{s}, M_.exo_names, 'exact');
    esc(s) = 0.25 / sqrt(M_.Sigma_e(idx,idx));
end
R = R.*esc;

figure('Position',[100 100 700 480],'Color','w');
plot(hh, R(:,1), 'b-',  'LineWidth',1.8); hold on;
plot(hh, R(:,2), 'b--', 'LineWidth',1.5);
plot(hh, R(:,3), 'b:',  'LineWidth',1.8);
yline(0,'k:');
legend({'Shock permanente a la meta','Shock transitorio a la meta', ...
        'Shock transitorio a la tasa'}, 'Box','off','Location','best');
ylabel('Desvío del estado estacionario, pp anuales');
xlabel('Trimestres');
grid on; box off; xlim([0 H-1]);
saveas(gcf,'figura12_replicacion.png');

fprintf('\nTasa real en el impacto (t=0):\n');
fprintf('  permanente a la meta : %7.3f\n', R(1,1));
fprintf('  transitorio a la meta: %7.3f\n', R(1,2));
fprintf('  transitorio a la tasa: %7.3f\n', R(1,3));