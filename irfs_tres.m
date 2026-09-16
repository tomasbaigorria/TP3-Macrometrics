% ============================================================
%  IRFs a los dos shocks monetarios — tres parametrizaciones
%  Uribe-A: producto, inflación, tasa nominal, tasa real
% ============================================================

load('irfs_A.mat');

H  = length(irf_mc5.dpi_obs_e_gm);
hh = 0:H-1;

shocks  = {'e_gm', 'e_zm'};
titulos = {'Shock permanente a la meta (X_t^m)', ...
           'Shock transitorio a la tasa (z_t^m)'};

irfs  = {irf_mc5, irf_mc6, irf_mh};
estilos = {'b-', 'r--', 'k:'};
anchos  = [1.8, 1.5, 1.7];
etiq    = {'Moda (mc=5)','Moda (mc=6)','Media posterior'};

figure('Position',[60 60 1000 720],'Color','w');

for s = 1:2
    sh = shocks{s};
    for p = 1:3
        I = irfs{p};
        % niveles acumulados
        Y  = cumsum(I.(['dy_obs_'  sh])(1:H));
        PI = cumsum(I.(['dpi_obs_' sh])(1:H));
        II = cumsum(I.(['di_obs_'  sh])(1:H));
        R  = I.(['r_obs_' sh])(1:H);

        datos = {Y, PI, II, R};
        for v = 1:4
            subplot(4,2,(v-1)*2+s);
            plot(hh, datos{v}, estilos{p}, 'LineWidth', anchos(p)); hold on;
        end
    end

    nombres = {'Producto (%)','Inflación (pp anual)', ...
               'Tasa nominal (pp anual)','Tasa real (pp anual)'};
    for v = 1:4
        subplot(4,2,(v-1)*2+s);
        yline(0,'k:'); grid on; box off; xlim([0 H-1]);
        if v==1
            title(titulos{s},'FontSize',10,'Interpreter','tex');
            if s==1, legend(etiq,'Box','off','Location','best','FontSize',7); end
        end
        if s==1, ylabel(nombres{v},'FontSize',8); end
        if v==4, xlabel('Trimestres'); end
    end
end

saveas(gcf,'irfs_A_tres.png');