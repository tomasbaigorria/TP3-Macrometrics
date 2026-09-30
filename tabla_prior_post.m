% ========================================================
%  tabla_prior_post.m
%  Tabla prior vs posterior de la estimacion E3 del punto 3.
%
%  Junta, para cada parametro:
%    - la prior: forma, media y desvio
%    - la moda de mode_compute = 5 y su desvio (hessiano)
%    - la media posterior y el HPD al 90% del Metropolis-Hastings
%
%  Imprime la tabla y escribe tabla_prior_post.tex para
%  incluir en el informe con \input{}.
% ========================================================

MH   = load('uribe_bfm_e3_mh/Output/uribe_bfm_e3_mh_results.mat');
MODA = load('uribe_bfm_e3_mode/Output/uribe_bfm_e3_mode_mode.mat');

oo = MH.oo_;  b = MH.bayestopt_;
sd_moda = sqrt(diag(inv(MODA.hh)));

formas = {'beta','gamma','normal','invg','uniform','invg2'};

% bayestopt_.name trae los nombres en el orden interno de Dynare;
% posterior_* los guarda en tres structs separados. Se arma el
% indice recorriendo los tres en el orden en que Dynare los ordena:
% primero shocks_std, despues measurement_errors_std, despues parameters.
grupos = {'shocks_std','measurement_errors_std','parameters'};
etiq   = {'Desvios de shocks','Errores de medicion','Estructurales'};

% Tabular COMPLETO: \input{} adentro de un tabular rompe el
% \noalign de \bottomrule.
fid = fopen('tabla_prior_post.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lllrrrc@{}}\n\\toprule\n');
fprintf(fid, [' & \\multicolumn{3}{c}{Prior} & \\multicolumn{1}{c}{Moda}' ...
              ' & \\multicolumn{2}{c}{Posterior (MH)} \\\\\n']);
fprintf(fid, '\\cmidrule(lr){2-4}\\cmidrule(lr){5-5}\\cmidrule(lr){6-7}\n');
fprintf(fid, ['Par\\''ametro & Forma & Media & Desv\\''io & \\texttt{mc=5}' ...
              ' & Media & HPD 90\\%% \\\\\n\\midrule\n']);
fprintf('\n%-18s %9s %8s %8s %12s %10s %18s\n', ...
        'parametro','prior','media','desvio','moda (mc5)','media MH','HPD 90%');
fprintf('%s\n', repmat('-',1,92));

k = 0;
for g = 1:3
    nm = fieldnames(oo.posterior_mean.(grupos{g}));
    fprintf('\n-- %s --\n', etiq{g});
    % Barras duplicadas: el formato de fprintf procesa escapes.
    fprintf(fid, '\\multicolumn{7}{@{}l}{\\itshape %s}\\\\[2pt]\n', etiq{g});
    for j = 1:numel(nm)
        k = k + 1;
        p   = nm{j};
        mu  = oo.posterior_mean.(grupos{g}).(p);
        lo  = oo.posterior_hpdinf.(grupos{g}).(p);
        hi  = oo.posterior_hpdsup.(grupos{g}).(p);
        % la prior y la moda, buscando por posicion en bayestopt_
        forma = formas{b.pshape(k)};
        pm    = b.p1(k);   ps = b.p2(k);
        mo    = MODA.xparam1(k);  sm = sd_moda(k);

        fprintf('%-18s %9s %8.3f %8.3f %8.4f(%.3f) %10.4f  [%7.4f,%8.4f]\n', ...
                p, forma, pm, ps, mo, sm, mu, lo, hi);
        fprintf(fid, '\\file{%s} & %s & %.3f & %.3f & %.4f & %.4f & [%.4f, %.4f]\\\\\n', ...
                strrep(p,'_','\_'), forma, pm, ps, mo, mu, lo, hi);
    end
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('\nGuardado tabla_prior_post.tex\n');

% --- chequeo de que el indice de bayestopt_ calzo bien ---
fprintf('\nChequeo: la moda de mode_compute=5 debe coincidir con la del .mat\n');
fprintf('  n parametros en bayestopt_ = %d ; en xparam1 = %d\n', ...
        numel(b.pshape), numel(MODA.xparam1));
