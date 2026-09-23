function T = mostrar_moda(archivo)
% ========================================================
%  mostrar_moda(archivo)
%  Imprime la moda y el desvío estándar respecto a ella que
%  Dynare guarda en un archivo *_mode.mat, y devuelve una
%  tabla con ambos.
%
%  Ejemplos:
%    mostrar_moda('uribe_B_mode/Output/uribe_B_mode_mode')
%    mostrar_moda('uribe_bfm_e1_mode/Output/uribe_bfm_e1_mode_mode')
%
%  Los desvíos salen de la raíz de la diagonal de la inversa
%  del hessiano numérico (hh). Si el hessiano está mal
%  condicionado los desvíos no son confiables: se avisa.
% ========================================================

S = load(archivo);

theta = S.xparam1(:);

% El nombre del campo con los nombres cambia entre versiones
if isfield(S,'parameter_names')
    nombres = S.parameter_names(:);
else
    nombres = arrayfun(@(k) sprintf('param_%d',k), ...
                       (1:numel(theta))', 'UniformOutput', false);
    warning('El .mat no trae los nombres: se numeran los parámetros.');
end

% Desvíos a partir del hessiano
if isfield(S,'hh')
    V = inv(S.hh);
    sd = sqrt(diag(V));
    c  = rcond(S.hh);
    if c < 1e-12
        fprintf(['\nAVISO: hessiano mal condicionado (rcond = %.2e). ' ...
                 'Los desvíos de abajo no son confiables.\n'], c);
    end
else
    sd = nan(size(theta));
end

T = table(nombres, theta, sd, ...
          'VariableNames', {'parametro','moda','desvio'});

fprintf('\n=== %s ===\n', archivo);
fprintf('%-18s %12s %12s\n', 'parámetro', 'moda', 'desvío');
fprintf('%s\n', repmat('-', 1, 44));
for k = 1:numel(theta)
    fprintf('%-18s %12.7f %12.7f\n', nombres{k}, theta(k), sd(k));
end

% Líneas listas para pegar en un .mod
fprintf('\n--- para pegar en un .mod ---\n');
for k = 1:numel(theta)
    n = nombres{k};
    if startsWith(n, 'SE_')          % desvío de un shock
        fprintf('var %-10s stderr %.7f;\n', n(4:end), theta(k));
    else
        fprintf('%-10s = %.7f;\n', n, theta(k));
    end
end
fprintf('\n');
end
