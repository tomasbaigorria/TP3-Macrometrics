% ============================================================
%  IRFs al shock a la meta: Uribe-A (e_gm) vs Uribe-B (e_zm2)
%  Requiere: irf_mc5 y irf_B en el workspace
% ============================================================

H  = length(irf_mc5.dpi_obs_e_gm);
hh = 0:H-1;

% A: shock permanente e_gm ; B: shock transitorio persistente e_zm2
YA  = cumsum(irf_mc5.dy_obs_e_gm(1:H));
PIA = cumsum(irf_mc5.dpi_obs_e_gm(1:H));
IA  = cumsum(irf_mc5.di_obs_e_gm(1:H));
RA  = irf_mc5.r_obs_e_gm(1:H);

YB  = cumsum(irf_B.dy_obs_e_zm2(1:H));
PIB = cumsum(irf_B.dpi_obs_e_zm2(1:H));
IB  = cumsum(irf_B.di_obs_e_zm2(1:H));
RB  = irf_B.r_obs_e_zm2(1:H);

% Normalizar a 1 pp de aumento de la inflación en el horizonte final
escA = 1/PIA(end);
escB = 1/PIB(end);
fprintf('\nEscala A: %.3f   Escala B: %.3f\n', escA, escB);

datosA = {YA*escA, PIA*escA, IA*escA, RA*escA};
datosB = {YB*escB, PIB*escB, IB*escB, RB*escB};
nombres = {'Producto (%)','Inflación (pp anual)', ...
           'Tasa nominal (pp anual)','Tasa real (pp anual)'};

figure('Position',[80 80 850 700],'Color','w');
for v = 1:4
    subplot(4,1,v);
    plot(hh, datosA{v}, 'b-',  'LineWidth',1.8); hold on;
    plot(hh, datosB{v}, 'r--', 'LineWidth',1.5);
    yline(0,'k:'); grid on; box off; xlim([0 H-1]);
    ylabel(nombres{v},'FontSize',9);
    if v==1
        title('Shock a la meta de inflación: A (permanente) vs B (\rho=0.999)', ...
              'Interpreter','tex');
        legend({'Uribe-A (X_t^m)','Uribe-B (z_t^{m2})'}, ...
               'Box','off','Location','best','Interpreter','tex');
    end
    if v==4, xlabel('Trimestres'); end
end
saveas(gcf,'irfs_AB.png');