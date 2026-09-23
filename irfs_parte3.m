% ============================================================
%  irfs_parte3.m
%  IRFs de las tres estimaciones del punto 3 a los shocks
%  monetarios (z^m, z^m2) y fiscales (zeta^F, zeta^M).
%  Variables: producto, inflacion, tasa nominal, tasa real.
%
%  Requiere res_e1.mat, res_e2.mat, res_e3.mat.
%  Genera irfs_parte3.png
%
%  Las tasas y la inflacion del modelo estan en pp TRIMESTRALES;
%  se multiplican por 4 para reportarlas anualizadas, como el
%  punto 1. yhat ya es % de desvio del SS.
% ============================================================

E = cell(3,1);
for N = 1:3
    S = load(sprintf('res_e%d.mat', N));
    E{N} = S.oo_.irfs;
end

shocks  = {'e_zm','e_zm2','e_zetaF','e_zetaM'};
titulos = {'Monetario transitorio z^m', 'Meta exogena z^{m2}', ...
           'Fiscal NO financiado \zeta^F', 'Fiscal financiado \zeta^M'};
% en que estimaciones existe cada shock
presente = {[1 2 3], 3, [1 2 3], [2 3]};

vars    = {'yhat','pi','i','r'};
escala  = [1 4 4 4];
nombres = {'Producto (% del SS)','Inflacion (pp anual)', ...
           'Tasa nominal (pp anual)','Tasa real (pp anual)'};

estilos = {'b-','r--','k-.'};
anchos  = [1.8 1.5 1.7];
etiq    = {'E1','E2','E3'};

figure('Position',[40 40 1150 760],'Color','w');

for s = 1:4
    for N = presente{s}
        I = E{N};
        for v = 1:4
            campo = [vars{v} '_' shocks{s}];
            if ~isfield(I, campo), continue; end
            subplot(4,4,(v-1)*4+s);
            x = escala(v)*I.(campo)(:);
            plot(0:numel(x)-1, x, estilos{N}, 'LineWidth', anchos(N));
            hold on;
        end
    end
    for v = 1:4
        subplot(4,4,(v-1)*4+s);
        yline(0,'k:'); grid on; box off;
        if v==1
            title(titulos{s},'FontSize',9,'Interpreter','tex');
        end
        if s==1
            ylabel(nombres{v},'FontSize',8);
            if v==1
                legend(etiq(presente{s}),'Box','off', ...
                       'Location','best','FontSize',7);
            end
        end
        if v==4, xlabel('Trimestres','FontSize',8); end
    end
end

saveas(gcf,'irfs_parte3.png');
fprintf('Guardado irfs_parte3.png\n');
