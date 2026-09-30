% ============================================================
%  tablas_cuerpo.m
%  Los tres cuadros CHICOS del cuerpo del informe, que son los
%  que van en las 6 páginas. Los grandes (27 filas) van al anexo
%  y los genera tabla_modas_parte3.m / tabla_prior_post.m.
%
%  Genera, con el tabular COMPLETO para pegar con \input{}:
%    tabla_fiscal.tex        el bloque fiscal en E1/E2/E3
%    tabla_extracto_mh.tex   prior vs posterior, solo los fiscales
%    tabla_densidades.tex    densidades marginales
%
%  OJO con el escapado: en el FORMATO de fprintf hay que duplicar
%  la barra invertida (MATLAB lee \f como formfeed). En los
%  ARGUMENTOS no, que no pasan por el procesador de escapes.
% ============================================================

% --- los parámetros que importan para la discusión ---
par    = {'rho_zetaF','stderr e_zetaF','rho_zetaM','stderr e_zetaM', ...
          'phi_F','gamma_M','stderr e_zm2'};
parTex = {'$\rho_{\zeta^F}$','$\sigma_{\zeta^F}$', ...
          '$\rho_{\zeta^M}$','$\sigma_{\zeta^M}$', ...
          '$\phi_F$','$\gamma^M$','$\sigma_{z^{m2}}$'};
np = numel(par);

% ============================================================
%  1. El bloque fiscal en las tres estimaciones
% ============================================================
E = cell(3,1);
for N = 1:3
    S = load(sprintf('uribe_bfm_e%d_mode/Output/uribe_bfm_e%d_mode_mode.mat',N,N));
    E{N} = struct('nom',{S.parameter_names(:)}, 'mo',S.xparam1(:), ...
                  'sd',sqrt(diag(inv(S.hh))));
end

fid = fopen('tabla_fiscal.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lccc@{}}\n\\toprule\n');
fprintf(fid, ['Par\\''ametro & E1 & E2 & E3 \\\\\n' ...
              ' & \\multicolumn{3}{c}{\\footnotesize moda (desv\\''io)} \\\\\n' ...
              '\\midrule\n']);
for j = 1:np
    fprintf(fid, '%s', parTex{j});
    for N = 1:3
        k = find(strcmp(E{N}.nom, par{j}));
        if isempty(k)
            fprintf(fid, ' & ---');
        else
            fprintf(fid, ' & %.4f\\,(%.4f)', E{N}.mo(k), E{N}.sd(k));
        end
    end
    fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('Guardado tabla_fiscal.tex\n');

% ============================================================
%  2. Prior vs posterior, solo los fiscales (E3 + MH)
% ============================================================
MH   = load('uribe_bfm_e3_mh/Output/uribe_bfm_e3_mh_results.mat');
oo   = MH.oo_;  b = MH.bayestopt_;
MODA = load('uribe_bfm_e3_mode/Output/uribe_bfm_e3_mode_mode.mat');
formas = {'beta','gamma','normal','invg','uniform','invg2'};

% (la función buscar() está al final: MATLAB las exige ahí)

fid = fopen('tabla_extracto_mh.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lllrrc@{}}\n\\toprule\n');
fprintf(fid, [' & \\multicolumn{3}{c}{Prior} & Moda & Posterior (MH) \\\\\n' ...
              '\\cmidrule(lr){2-4}\\cmidrule(lr){5-5}\\cmidrule(lr){6-6}\n' ...
              'Par\\''ametro & Forma & Media & Desv\\''io' ...
              ' & \\texttt{mc=5} & Media\\quad HPD 90\\%% \\\\\n\\midrule\n']);
for j = 1:np
    k = find(strcmp(MODA.parameter_names, par{j}));
    if isempty(k), continue; end
    [mu,lo,hi] = buscar(oo, par{j});
    fprintf(fid, '%s & %s & %.3f & %.3f & %.4f & %.4f\\quad[%.4f,\\,%.4f] \\\\\n', ...
            parTex{j}, formas{b.pshape(k)}, b.p1(k), b.p2(k), ...
            MODA.xparam1(k), mu, lo, hi);
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('Guardado tabla_extracto_mh.tex\n');

% ============================================================
%  3. Densidades marginales
% ============================================================
mods = {'uribe_mode_A','uribe_B_mode','uribe_bfm_e1_mode', ...
        'uribe_bfm_e2_mode','uribe_bfm_e3_mode'};
etiq = {'Uribe-A','Uribe-B','E1','E2','E3'};
nobs = {'3','3','3','4','4'};
md   = nan(1,5);
for k = 1:5
    f = sprintf('%s/Output/%s_results.mat', mods{k}, mods{k});
    if exist(f,'file')==2
        S = load(f);
        if isfield(S.oo_,'MarginalDensity') && ...
           isfield(S.oo_.MarginalDensity,'LaplaceApproximation')
            md(k) = S.oo_.MarginalDensity.LaplaceApproximation;
        end
    end
end
mh_hm = NaN;
if isfield(oo,'MarginalDensity') && isfield(oo.MarginalDensity,'ModifiedHarmonicMean')
    mh_hm = oo.MarginalDensity.ModifiedHarmonicMean;
end

fid = fopen('tabla_densidades.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lrcl@{}}\n\\toprule\n');
fprintf(fid, ['Versi\\''on & Densidad marginal & Observables & M\\''etodo' ...
              ' \\\\\n\\midrule\n']);
for k = 1:5
    fprintf(fid, '%s & %.2f & %s & Laplace \\\\\n', etiq{k}, md(k), nobs{k});
end
if ~isnan(mh_hm)
    fprintf(fid, ['E3 (MH) & %.2f & 4 & Media arm\\''onica mod. ' ...
                  '\\\\\n'], mh_hm);
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('Guardado tabla_densidades.tex\n');

fprintf('\nSolo son comparables entre si las que comparten observables\n');
fprintf('Y metodo: E2 vs E3 por Laplace, con 4 observables.\n');
fprintf('Densidades: '); fprintf('%s=%.2f  ', ...
        etiq{1}, md(1), etiq{2}, md(2), etiq{3}, md(3), ...
        etiq{4}, md(4), etiq{5}, md(5));
fprintf('\n');


% ============================================================
%  Los campos posterior_* de Dynare guardan los nombres SIN el
%  prefijo "stderr", y repartidos en tres structs. Esto los busca
%  en los tres.
% ============================================================
function [mu,lo,hi] = buscar(oo, nombre)
    g = {'shocks_std','measurement_errors_std','parameters'};
    n = nombre;
    if startsWith(n,'stderr '), n = strtrim(extractAfter(n,'stderr ')); end
    mu = NaN; lo = NaN; hi = NaN;
    for q = 1:3
        if isfield(oo.posterior_mean.(g{q}), n)
            mu = oo.posterior_mean.(g{q}).(n);
            lo = oo.posterior_hpdinf.(g{q}).(n);
            hi = oo.posterior_hpdsup.(g{q}).(n);
            return
        end
    end
end
