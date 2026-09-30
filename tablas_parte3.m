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
          'E3: con deficit, con z^{m2}  (moda, mode_compute=5)', ...
          'E3: MEDIA POSTERIOR  (Metropolis-Hastings, 1e6 draws)'};
arch   = {'res_e1.mat','res_e2.mat','res_e3.mat','res_e3_mean.mat'};
vlist  = {'dy_obs','dpi_obs','di_obs','r_obs','y','pi','i','r', ...
          'yhat','tau','sb','def_obs'};

% Salida para el informe, cuerpo de tabular para \input{}.
% Barras duplicadas en el FORMATO porque fprintf procesa escapes.
% Etiquetas aparte: las de pantalla tienen z^{m2} suelto, que en
% LaTeX necesita modo matematico.
etiqTex = {'E1: sin d\''eficit, sin $z^{m2}$', ...
           'E2: con d\''eficit, sin $z^{m2}$', ...
           'E3: con d\''eficit, con $z^{m2}$ (moda)', ...
           'E3: media posterior (Metropolis-Hastings)'};
% Tabular COMPLETO: \input{} adentro de un tabular rompe el
% \noalign de \bottomrule.
fid = fopen('tablas_parte3.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lrrrrrrrrr@{}}\n\\toprule\n');
fprintf(fid, 'Variable');
S0 = load(arch{1});
for k = 1:numel(S0.M_.exo_names)
    fprintf(fid, ' & \\file{%s}', strrep(S0.M_.exo_names{k},'_','\_'));
end
fprintf(fid, ' & Suma \\\\\n\\midrule\n');

for N = 1:numel(arch)
    S  = load(arch{N});
    vd = S.oo_.variance_decomposition;
    ex = S.M_.exo_names;

    fprintf(fid, '\\multicolumn{10}{@{}l}{\\itshape %s}\\\\[2pt]\n', etiqTex{N});
    for v = 1:numel(vars)
        r = find(strcmp(vlist, vars{v}));
        fprintf(fid, '\\file{%s}', strrep(vars{v},'_','\_'));
        fprintf(fid, ' & %.2f', vd(r,:));
        fprintf(fid, ' & %.2f \\\\\n', sum(vd(r,:)));
    end
    if N < numel(arch), fprintf(fid, '\\addlinespace\n'); end

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
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('\nGuardado tablas_parte3.tex\n');
