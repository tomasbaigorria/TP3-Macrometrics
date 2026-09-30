% ============================================================
%  tabla_consolidada.m
%  Descomposicion de varianza del CAMBIO EN LA INFLACION en las
%  siete parametrizaciones del trabajo, para la comparacion que
%  pide la consigna entre el punto 3, el punto 1 y el paper.
%
%  Punto 1:  Uribe-A (moda mc=5 y media posterior MH), Uribe-B
%  Punto 3:  E1, E2, E3 (moda) y E3 (media posterior MH)
%
%  Requiere irfs_A.mat, resultados_B.mat, res_e{1,2,3}.mat y
%  res_e3_mean.mat
% ============================================================

% --- punto 1 ---
A = load('irfs_A.mat');       % vd_mc5, vd_mh : [8 x 7], exo del uribe_core
B = load('resultados_B.mat'); % vd_B
% uribe_core: e_xi e_theta e_z e_g e_zm e_zm2 e_gm ; fila 2 = dpi_obs
iA = struct('xi',1,'theta',2,'z',3,'g',4,'zm',5,'zm2',6,'gm',7);

% --- punto 3 ---
vlist = {'dy_obs','dpi_obs','di_obs','r_obs','y','pi','i','r', ...
         'yhat','tau','sb','def_obs'};
r3 = find(strcmp(vlist,'dpi_obs'));
E = cell(4,1);
E{1} = load('res_e1.mat'); E{2} = load('res_e2.mat');
E{3} = load('res_e3.mat'); E{4} = load('res_e3_mean.mat');
ex3  = E{1}.M_.exo_names;
i3   = @(n) find(strcmp(ex3,n));

% --- armar la matriz: filas = shock, columnas = parametrizacion ---
col = {'Uribe-A md','Uribe-A mean','Uribe-B md','E1','E2','E3 md','E3 mean'};
fila = {'xi (preferencias)','theta','z','g (crecimiento)', ...
        'z^m (monet. transit.)','g^m (meta permanente)', ...
        'z^m2 (meta transit.)','zetaF (fiscal NO fin.)','zetaM (fiscal fin.)'};
M = nan(9,7);

P1 = {A.vd_mc5, A.vd_mh, B.vd_B};
for c = 1:3
    v = P1{c}(2,:);
    M(1,c)=v(iA.xi); M(2,c)=v(iA.theta); M(3,c)=v(iA.z); M(4,c)=v(iA.g);
    M(5,c)=v(iA.zm); M(6,c)=v(iA.gm);    M(7,c)=v(iA.zm2);
end
for k = 1:4
    c = 3+k;  v = E{k}.oo_.variance_decomposition(r3,:);
    M(1,c)=v(i3('e_xi')); M(2,c)=v(i3('e_theta')); M(3,c)=v(i3('e_z'));
    M(4,c)=v(i3('e_g'));  M(5,c)=v(i3('e_zm'));    M(7,c)=v(i3('e_zm2'));
    M(8,c)=v(i3('e_zetaF')); M(9,c)=v(i3('e_zetaM'));
end

fprintf('\n=== Descomposicion de varianza del cambio en la inflacion (%%) ===\n\n');
fprintf('%-24s', 'shock'); fprintf('%13s', col{:}); fprintf('\n');
fprintf('%s\n', repmat('-', 1, 24+13*7));
for f = 1:9
    fprintf('%-24s', fila{f});
    for c = 1:7
        if isnan(M(f,c)), fprintf('%13s','---'); else, fprintf('%13.2f', M(f,c)); end
    end
    fprintf('\n');
end

% --- la fila que resume: quien ocupa el lugar de la tendencia ---
tend = nan(1,7);
for c = 1:7
    cand = M([6 7 8], c);          % g^m, z^m2, zetaF
    tend(c) = max(cand(~isnan(cand)));
end
fprintf('%s\n', repmat('-', 1, 24+13*7));
fprintf('%-24s', 'SHOCK DE TENDENCIA');
fprintf('%13.2f', tend); fprintf('\n');

% --- salida para el informe ---
% Se emite el TABULAR COMPLETO, no solo el cuerpo: LaTeX deja
% tokens despues de \input{} que rompen el \noalign de \bottomrule
% si el \input queda adentro de un tabular. Asi el \input anda en
% cualquier lado. Barras duplicadas en el FORMATO de fprintf.
filaTex = {'$\xi$ preferencias','$\theta$','$z$','$g$ crecimiento', ...
           '$z^m$ monetario transitorio','$g^m$ meta permanente', ...
           '$z^{m2}$ meta transitoria','$\zeta^F$ fiscal no financiado', ...
           '$\zeta^M$ fiscal financiado'};
colTex  = {'Uribe-A md','Uribe-A mean','Uribe-B md','E1','E2', ...
           'E3 md','E3 mean'};
fid = fopen('tabla_consolidada.tex','w');
fprintf(fid, '\\begin{tabular}{@{}lrrrrrrr@{}}\n\\toprule\n');
fprintf(fid, 'Shock');
fprintf(fid, ' & %s', colTex{:});
fprintf(fid, ' \\\\\n\\midrule\n');
for f = 1:9
    fprintf(fid, '%s', filaTex{f});
    for c = 1:7
        if isnan(M(f,c)), fprintf(fid,' & ---');
        else,             fprintf(fid,' & %.2f', M(f,c)); end
    end
    fprintf(fid, ' \\\\\n');
end
fprintf(fid, '\\midrule\n\\textbf{Shock de tendencia}');
fprintf(fid, ' & \\textbf{%.2f}', tend);
fprintf(fid, ' \\\\\n\\bottomrule\n\\end{tabular}\n');
fclose(fid);
fprintf('\nGuardado tabla_consolidada.tex\n');
fprintf(['\nLa ultima fila toma, en cada columna, el shock que cumple el\n' ...
         'papel de tendencia inflacionaria: g^m en Uribe-A, z^m2 en\n' ...
         'Uribe-B y E3, zetaF en E1 y E2 (donde no hay shock a la meta).\n\n']);
