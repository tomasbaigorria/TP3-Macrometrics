% ============================================================
%  Descomposición de varianza — tres parametrizaciones
% ============================================================

load('irfs_A.mat');

vars   = {'dy_obs','dpi_obs','di_obs'};
shocks = {'e_xi','e_theta','e_z','e_g','e_zm','e_zm2','e_gm'};
vds    = {vd_mc5, vd_mc6, vd_mh};
etiq   = {'Moda (mc=5)','Moda (mc=6)','Media posterior'};

for p = 1:3
    fprintf('\n=== %s ===\n', etiq{p});
    fprintf('%-10s', 'variable');
    fprintf('%9s', shocks{:}); fprintf('\n');
    for v = 1:3
        fprintf('%-10s', vars{v});
        fprintf('%9.2f', vds{p}(v,:));
        fprintf('\n');
    end
end