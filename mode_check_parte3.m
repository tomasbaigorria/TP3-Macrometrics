function mode_check_parte3(N)
% ========================================================
%  mode_check_parte3(N)
%  Rehace los graficos de mode_check de la estimacion N
%  (1, 2 o 3) del punto 3, a partir de los datos que Dynare
%  guardo en uribe_bfm_eN_mode/graphs/*_check_plot_data.mat.
%
%  Hace falta porque las estimaciones se corrieron con la
%  opcion nograph, que calcula el mode_check pero no dibuja.
%  Los datos estan, asi que no hay que re-estimar.
%
%  Cada panel muestra, alrededor de la moda:
%    linea azul  = log-posterior
%    linea gris  = log-verosimilitud
%    linea roja  = la moda
%  Una superficie plana alrededor de la moda = el parametro no
%  esta identificado por los datos.
%
%  Uso:  >> mode_check_parte3(3)
%        >> for k=1:3, mode_check_parte3(k); end
% ========================================================

arch = sprintf('uribe_bfm_e%d_mode/graphs/uribe_bfm_e%d_mode_check_plot_data.mat', N, N);
if exist(arch,'file') ~= 2
    error('No existe %s. Hay que correr dynare uribe_bfm_e%d_mode primero.', arch, N);
end
S = load(arch);
cross = S.mcheck.cross;
emode = S.mcheck.emode;
par   = fieldnames(cross);
np    = numel(par);

% 9 paneles por figura
porfig = 9;
nfig   = ceil(np/porfig);

for f = 1:nfig
    figure('Position',[40 40 1100 780],'Color','w');
    idx = (f-1)*porfig + (1:porfig);
    idx = idx(idx <= np);
    for j = 1:numel(idx)
        k = idx(j);
        X = cross.(par{k});          % [valor, log-posterior, log-verosimilitud]
        subplot(3,3,j);
        plot(X(:,1), X(:,2), 'b-', 'LineWidth',1.5); hold on;
        plot(X(:,1), X(:,3), 'Color',[.6 .6 .6], 'LineWidth',1.1);
        xline(emode.(par{k}), 'r-', 'LineWidth',1.2);
        grid on; box off;
        title(strrep(par{k},'_','\_'), 'FontSize',9);
        if j==1
            legend({'log-posterior','log-verosimilitud','moda'}, ...
                   'Box','off','Location','best','FontSize',6);
        end
    end
    sgtitle(sprintf('mode\_check — Estimacion %d (%d de %d)', N, f, nfig), ...
            'FontSize',11);
    nombre = sprintf('mode_check_e%d_%d.png', N, f);
    saveas(gcf, nombre);
    fprintf('Guardado %s\n', nombre);
end

% --- resumen: que tan plana es la posterior en cada direccion ---
fprintf('\n=== E%d: curvatura de la posterior alrededor de la moda ===\n', N);
fprintf('(rango de la log-posterior sobre el intervalo explorado;\n');
fprintf(' valores chicos = direccion plana = mal identificado)\n\n');
rango = zeros(np,1);
for k = 1:np
    X = cross.(par{k});
    rango(k) = max(X(:,2)) - min(X(:,2));
end
[~, ord] = sort(rango);
fprintf('%-20s %12s\n','parametro','rango logpost');
for j = 1:min(8,np)
    k = ord(j);
    fprintf('%-20s %12.4f\n', par{k}, rango(k));
end
end
