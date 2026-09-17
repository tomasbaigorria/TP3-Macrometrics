% ============================================================
%  parte2_irfs.m  —  Parte 2 del TP3 (modelo Uribe-BFM)
%
%  1) Corre uribe_bfm_irf con phi_F = 0, phi_F = 0.8 y la robustez phi_M = 2
%  2) Corre uribe_B_irf (archivo del punto 1) para comparar con z^m2
%  3) Chequea que zetaM no mueva inflación, producto ni tasa
%  4) Grafica
%
%  Requisitos: en la misma carpeta, uribe_bfm_core.mod, uribe_bfm_irf.mod,
%  uribe_core.mod, uribe_B_irf.mod, datos_uribe.mat y la carpeta
%  uribe_B_mode/ (con el archivo de moda de Uribe-B).
%
%  CONVENCIONES DE LOS GRÁFICOS
%  - Los shocks fiscales mueven el SUPERÁVIT. Se grafica el shock con signo
%    negativo (menos superávit = más transferencias), como en BFM.
%  - Figura 1 y 2: respuestas por cada 1 punto del PBI trimestral de
%    transferencias (se divide por la caída del superávit en el impacto).
%  - Figura 3 (comparación con Uribe-B): cada shock se normaliza para que
%    el pico de la respuesta de la inflación valga 1. La comparación es
%    cualitativa (forma de las respuestas), como pide la consigna.
% ============================================================

clear; close all;
% addpath('C:/dynare/7.0/matlab');   % <- ajustar si hace falta

H = 21;                 % horizonte (igual que uribe_B_irf)
t = 0:H-1;
res = struct();

% ---------- 1) Modelo Uribe-BFM ----------
casos = {'phiF0',   '-DphiF=0';
         'phiF08',  '-DphiF=0.8';
         'phiM2',   '-DphiF=0 -DphiM2=1'};

% (Dynare corre sus scripts en este mismo workspace: se guarda y recarga
%  todo en cada vuelta para que no se pise ninguna variable.)
save('parte2_tmp.mat','res','casos','H','t');
for kk = 1:3
    save('parte2_kk.mat','kk');
    load('parte2_tmp.mat');
    eval(['dynare uribe_bfm_irf ' casos{kk,2} ' noclearall nolog']);
    tmp = oo_.irfs;
    load('parte2_tmp.mat'); load('parte2_kk.mat');
    res.(casos{kk,1}) = tmp;
    save('parte2_tmp.mat','res','casos','H','t');
end

% ---------- 2) Uribe-B (shock transitorio a la meta) ----------
dynare uribe_B_irf noclearall nolog
tmp = oo_.irfs;
load('parte2_tmp.mat');
res.uribeB = tmp;
save('irfs_parte2.mat','res');

% Funciones auxiliares: devuelven la IRF o ceros si Dynare no la guardó.
%  getirf_raw: valores tal cual (para el chequeo numérico)
%  getirf:     valores menores a 1e-10 se redondean a 0 (para graficar).
%              Son errores de redondeo de la computadora, no efectos del modelo.
tol = 1e-10;
getirf_raw = @(S,v,e) local_get(S, v, e, H, 0);
getirf     = @(S,v,e) local_get(S, v, e, H, tol);

% ---------- 3) Chequeo: zetaM no tiene efectos ----------
fprintf('\n===== CHEQUEO: respuesta máxima (en valor absoluto) a e_zetaM =====\n');
for k = 1:size(casos,1)
    S = res.(casos{k,1});
    fprintf('%-7s  y: %.1e   pi: %.1e   i: %.1e   r: %.1e   | sb: %.1e  tau: %.1e\n', ...
        casos{k,1}, ...
        max(abs(getirf_raw(S,'yhat','e_zetaM'))),  max(abs(getirf_raw(S,'pi','e_zetaM'))), ...
        max(abs(getirf_raw(S,'i','e_zetaM'))),  max(abs(getirf_raw(S,'r','e_zetaM'))), ...
        max(abs(getirf_raw(S,'sb','e_zetaM'))), max(abs(getirf_raw(S,'tau','e_zetaM'))));
end
fprintf('(Valores del orden de 1e-14 o menores son cero numérico.)\n\n');

% ---------- Figura 1: zetaF, phi_F = 0 vs 0.8 (por 1 pp del PBI) ----------
vars   = {'pi','piF','i','r','yhat','tau','sb','sbF'};
titles = {'Inflación \pi','Inflación fiscal \pi^F','Tasa nominal i', ...
          'Tasa real r','Producto (% desvío)', ...
          'Superávit \tau (% PBI)','Deuda s_b (% PBI)','Deuda no financiada s_b^F (% PBI)'};

fig1 = figure('Name','zetaF: phi_F = 0 vs 0.8','Position',[100 100 1100 600]);
for j = 1:numel(vars)
    subplot(2,4,j); hold on;
    for k = 1:2
        S = res.(casos{k,1});
        norm = -getirf(S,'tau','e_zetaF'); norm = norm(1);   % caída del superávit
        x = getirf(S,vars{j},'e_zetaF') / norm;              % signo ya invertido
        if k==1, plot(t,x,'b-','LineWidth',2); else, plot(t,x,'r--','LineWidth',2); end
    end
    plot(t,0*t,'k:'); title(titles{j}); xlim([0 H-1]); grid on;
    if j==1, legend('\phi^F = 0','\phi^F = 0.8','Location','best'); end
end
annotation('textbox',[0 0.95 1 0.05],'String', ...
  'Shock no financiado \zeta^F: +1 pp del PBI trimestral de transferencias (puntos porcentuales trimestrales)', ...
  'EdgeColor','none','HorizontalAlignment','center');
print(fig1,'fig_parte2_zetaF.png','-dpng','-r150');

% ---------- Figura 2: zetaM (debe ser cero salvo fiscales) ----------
fig2 = figure('Name','zetaM','Position',[100 100 1100 300]);
vM = {'pi','i','yhat','tau','sb'};
tM = {'Inflación \pi','Tasa nominal i','Producto y','Superávit \tau','Deuda s_b'};
S = res.phiF0;
norm = -getirf(S,'tau','e_zetaM'); norm = norm(1);
for j = 1:numel(vM)
    subplot(1,5,j);
    x = getirf(S,vM{j},'e_zetaM')/norm;
    plot(t, x,'k-','LineWidth',2); hold on;
    plot(t,0*t,'k:'); title(tM{j}); xlim([0 H-1]); grid on;
    if all(x == 0), ylim([-1 1]); end   % respuesta nula: escala comparable
end
annotation('textbox',[0 0.92 1 0.08],'String', ...
  'Shock financiado \zeta^M: +1 pp del PBI trimestral de transferencias (\phi^F = 0)', ...
  'EdgeColor','none','HorizontalAlignment','center');
print(fig2,'fig_parte2_zetaM.png','-dpng','-r150');

% ---------- Figura 3: zetaF vs z^m2 de Uribe-B (normalizadas) ----------
vC = {'pi','i','r','y'};
tC = {'Inflación','Tasa nominal','Tasa real','Producto (% desvío)'};
fig3 = figure('Name','zetaF vs zm2','Position',[100 100 1100 320]);
for j = 1:numel(vC)
    subplot(1,4,j); hold on;
    % Uribe-B: z^m2 positivo (sube la meta)
    pB = getirf(res.uribeB,'pi','e_zm2');  [~,m] = max(abs(pB)); nB = pB(m);
    % el archivo de Uribe-B no tiene yhat: se pasa el nivel de y a % de desvío
    % (0.475215 = producto de estado estacionario, igual en ambos modelos)
    esc = 1; if strcmp(vC{j},'y'), esc = 100/0.475215; end
    plot(t, esc*getirf(res.uribeB,vC{j},'e_zm2')/nB, 'k-','LineWidth',2);
    % Uribe-BFM: zetaF negativo (más transferencias)
    sty = {'b--','r-.'};
    for k = 1:2
        S = res.(casos{k,1});
        p = -getirf(S,'pi','e_zetaF'); [~,m] = max(abs(p)); nF = p(m);
        plot(t, -esc*getirf(S,vC{j},'e_zetaF')/nF, sty{k},'LineWidth',2);
    end
    plot(t,0*t,'k:'); title(tC{j}); xlim([0 H-1]); grid on;
    if j==1, legend('Uribe-B: z^{m2}','BFM: \zeta^F, \phi^F=0','BFM: \zeta^F, \phi^F=0.8','Location','best'); end
end
annotation('textbox',[0 0.92 1 0.08],'String', ...
  'Comparación cualitativa: cada shock normalizado para que el pico de la inflación sea 1', ...
  'EdgeColor','none','HorizontalAlignment','center');
print(fig3,'fig_parte2_comparacion.png','-dpng','-r150');

% ---------- Robustez phi_M = 2 (tabla) ----------
fprintf('===== ROBUSTEZ: zetaF (por 1 pp del PBI), impacto y trimestre 4 =====\n');
for c = {'phiF0','phiM2'}
    S = res.(c{1});
    norm = -getirf(S,'tau','e_zetaF'); norm = norm(1);
    fprintf('%-6s', c{1});
    for v = {'pi','i','r','yhat'}
        x = getirf(S,v{1},'e_zetaF')/norm;   % norm ya invierte el signo
        fprintf('  %s: %7.4f / %7.4f', v{1}, x(1), x(5));
    end
    fprintf('\n');
end

% ============================================================
function x = local_get(S, v, e, H, tol)
    f = [v '_' e];
    if isfield(S, f)
        x = S.(f)(:)'; x = x(1:min(end,H));
    else
        x = zeros(1,H);   % Dynare no guarda respuestas nulas
    end
    x(abs(x) < tol) = 0;  % cero numérico
end
