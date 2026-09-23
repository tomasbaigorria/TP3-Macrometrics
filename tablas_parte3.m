% ============================================================
%  tablas_parte3.m
%  Descomposición de varianza incondicional de las tres
%  estimaciones del punto 3 (E1, E2, E3), en la moda.
%
%  Requiere res_e1.mat, res_e2.mat, res_e3.mat, generados por
%  uribe_bfm_e{1,2,3}_irf.mod.
%
%  El orden de las filas es el var_list del stoch_simul:
%    dy_obs dpi_obs di_obs r_obs y pi i r yhat tau sb def_obs
%  Se buscan por nombre igual, para no depender de eso.
% ============================================================

vars   = {'dy_obs','dpi_obs','di_obs','def_obs'};
etiq   = {'E1: sin deficit, sin z^{m2}', ...
          'E2: con deficit, sin z^{m2}', ...
          'E3: con deficit, con z^{m2}'};
vlist  = {'dy_obs','dpi_obs','di_obs','r_obs','y','pi','i','r', ...
          'yhat','tau','sb','def_obs'};

for N = 1:3
    S  = load(sprintf('res_e%d.mat', N));
    vd = S.oo_.variance_decomposition;
    ex = S.M_.exo_names;

    fprintf('\n=== %s ===\n', etiq{N});
    fprintf('%-10s', 'variable');
    fprintf('%9s', ex{:});
    fprintf('%9s\n', 'suma');

    for v = 1:numel(vars)
        r = find(strcmp(vlist, vars{v}));
        fprintf('%-10s', vars{v});
        fprintf('%9.2f', vd(r,:));
        fprintf('%9.2f\n', sum(vd(r,:)));
    end

    % Cuánto de la inflación es fiscal no financiada vs meta exógena
    r  = find(strcmp(vlist,'dpi_obs'));
    iF = find(strcmp(ex,'e_zetaF'));
    iM = find(strcmp(ex,'e_zetaM'));
    i2 = find(strcmp(ex,'e_zm2'));
    fprintf(['  -> del cambio en la inflacion: zetaF %.2f%% | ' ...
             'zetaM %.2f%% | z^m2 %.2f%%\n'], ...
             vd(r,iF), vd(r,iM), vd(r,i2));
end
fprintf('\n');
