% ========================================================
%  tabla_modas_parte3.m
%  Tabla de moda y desvio estandar de las tres estimaciones
%  del punto 3, alineada por nombre de parametro (E1 tiene
%  menos parametros que E2 y E3).
%
%  Agrega el diagnostico de identificacion: el rango de la
%  log-VEROSIMILITUD sobre el intervalo que explora mode_check.
%  Cerca de cero = los datos no dicen nada sobre ese parametro
%  y la posterior es la prior.
%
%  Imprime la tabla y escribe tabla_modas_parte3.tex para
%  incluir en el informe con \input{}.
% ========================================================

E = cell(3,1);
for N = 1:3
    S  = load(sprintf('uribe_bfm_e%d_mode/Output/uribe_bfm_e%d_mode_mode.mat',N,N));
    C  = load(sprintf('uribe_bfm_e%d_mode/graphs/uribe_bfm_e%d_mode_check_plot_data.mat',N,N));
    sd = sqrt(diag(inv(S.hh)));
    curv = nan(numel(S.xparam1),1);
    for k = 1:numel(S.parameter_names)
        nm = S.parameter_names{k};
        % mode_check usa otra convencion de nombres para los stderr:
        %   "stderr e_xi"   -> SE_e_xi
        %   "stderr dy_obs" -> SE_EOBS_dy_obs
        if startsWith(nm,"stderr ")
            base = strtrim(extractAfter(nm,"stderr "));
            if startsWith(base,"e_"), nm = "SE_" + base;
            else,                     nm = "SE_EOBS_" + base; end
            nm = char(nm);
        end
        if isfield(C.mcheck.cross, nm)
            X = C.mcheck.cross.(nm);
            curv(k) = max(X(:,3)) - min(X(:,3));   % col 3 = log-verosimilitud
        end
    end
    E{N} = struct('nom',{S.parameter_names(:)},'mo',S.xparam1(:),'sd',sd,'cu',curv);
end

% union de nombres, en el orden de E3 (el mas completo)
nombres = E{3}.nom;

fprintf('\n%-20s %19s %19s %19s %9s\n', '', 'E1', 'E2', 'E3', 'curv.L');
fprintf('%-20s %19s %19s %19s %9s\n', 'parametro', 'moda (desvio)', ...
        'moda (desvio)', 'moda (desvio)', 'en E3');
fprintf('%s\n', repmat('-', 1, 92));

% Tabular COMPLETO: \input{} adentro de un tabular rompe el
% \noalign de \bottomrule.
fid = fopen('tabla_modas_parte3.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lrrrrrr@{}}\n\\toprule\n');
fprintf(fid, [' & \\multicolumn{2}{c}{E1} & \\multicolumn{2}{c}{E2}' ...
              ' & \\multicolumn{2}{c}{E3} \\\\\n']);
fprintf(fid, '\\cmidrule(lr){2-3}\\cmidrule(lr){4-5}\\cmidrule(lr){6-7}\n');
fprintf(fid, ['Par\\''ametro & Moda & Desv\\''io & Moda & Desv\\''io' ...
              ' & Moda & Desv\\''io \\\\\n\\midrule\n']);
for j = 1:numel(nombres)
    nm = nombres{j};
    fprintf('%-20s', nm);
    % OJO: en el FORMATO de fprintf hay que duplicar la barra, porque
    % MATLAB interpreta \f como formfeed. En los ARGUMENTOS no, que
    % no pasan por el procesador de escapes (de ahi el '\_' suelto).
    fprintf(fid, '\\file{%s}', strrep(nm,'_','\_'));
    for N = 1:3
        k = find(strcmp(E{N}.nom, nm));
        if isempty(k)
            fprintf(' %19s', '---');
            fprintf(fid, ' & --- & ---');
        else
            fprintf(' %10.4f (%.4f)', E{N}.mo(k), E{N}.sd(k));
            fprintf(fid, ' & %.4f & %.4f', E{N}.mo(k), E{N}.sd(k));
        end
    end
    k3 = find(strcmp(E{3}.nom, nm));
    fprintf(' %9.4f\n', E{3}.cu(k3));
    fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\bottomrule\n\\end{tabular}\n');
fclose(fid);

fprintf('\nGuardado tabla_modas_parte3.tex\n');

% --- los mal identificados de cada estimacion ---
fprintf('\n=== Parametros con desvio posterior >= desvio de su prior ===\n');
fprintf('(la posterior es tan ancha como la prior: los datos no informan)\n\n');
for N = 1:3
    fprintf('E%d: ', N);
    hay = false;
    for k = 1:numel(E{N}.nom)
        if E{N}.cu(k) < 0.15
            fprintf('%s ', E{N}.nom{k});
            hay = true;
        end
    end
    if ~hay, fprintf('(ninguno bajo el umbral)'); end
    fprintf('\n');
end
