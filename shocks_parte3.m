% ============================================================
%  shocks_parte3.m
%  Series historicas suavizadas de los tres shocks que compiten
%  por explicar la inflacion persistente: zeta^F (fiscal no
%  financiado), zeta^M (fiscal financiado) y z^{m2} (meta exogena).
%
%  Requiere res_e2.mat, res_e3.mat e inflacion_observada.csv.
%  Genera shocks_parte3.png
%
%  UNIDADES. zeta entra en la regla fiscal como tau_ss*exp(zeta/100),
%  o sea que zeta es el desvio PORCENTUAL de tau. Para leerlo en pp
%  del PBI se multiplica por tau_ss/100. Signo invertido (como en
%  BFM y como el punto 2): positivo = MAS transferencias.
%  z^{m2} esta en pp trimestrales de inflacion -> x4 para anualizar.
% ============================================================

P      = readtable('inflacion_observada.csv');
fechas = P.t;

S2 = load('res_e2.mat');
S3 = load('res_e3.mat');

% tau_ss de los parametros del modelo
k      = strcmp(S3.M_.param_names,'tau_ss');
tau_ss = S3.M_.params(k);
fprintf('tau_ss = %.4f pp del PBI\n', tau_ss);
conv = tau_ss/100;    % de "% de tau" a "pp del PBI"

zF3 = -conv*S3.oo_.SmoothedVariables.zetaF(:);
zM3 = -conv*S3.oo_.SmoothedVariables.zetaM(:);
zF2 = -conv*S2.oo_.SmoothedVariables.zetaF(:);
m2  =  4*S3.oo_.SmoothedVariables.zm2(:);

figure('Position',[40 40 1000 780],'Color','w');

% --- A: los dos shocks fiscales en E3 ---
subplot(3,1,1);
plot(fechas, zM3, 'Color',[.85 .33 .10], 'LineWidth',1.5); hold on;
plot(fechas, zF3, 'b-', 'LineWidth',1.7);
yline(0,'k:'); grid on; box off;
legend({'\zeta^M financiado','\zeta^F no financiado'}, ...
       'Box','off','Location','best','FontSize',8);
ylabel('pp del PBI'); title('E3: shocks fiscales suavizados (+ = mas transferencias)');

% --- B: la meta exogena contra la inflacion observada ---
subplot(3,1,2);
plot(fechas, P.pai, 'Color',[.7 .7 .7], 'LineWidth',1.0); hold on;
plot(fechas, m2, 'k-', 'LineWidth',1.7);
yline(0,'k:'); grid on; box off;
legend({'Inflacion observada','z^{m2} suavizado'}, ...
       'Box','off','Location','best','FontSize',8);
ylabel('% anual'); title('E3: meta exogena suavizada vs. inflacion observada');

% --- C: que le pasa a zeta^F cuando aparece z^{m2} ---
subplot(3,1,3);
plot(fechas, zF2, 'r--', 'LineWidth',1.5); hold on;
plot(fechas, zF3, 'b-',  'LineWidth',1.7);
yline(0,'k:'); grid on; box off;
legend({'\zeta^F en E2 (sin z^{m2})','\zeta^F en E3 (con z^{m2})'}, ...
       'Box','off','Location','best','FontSize',8);
ylabel('pp del PBI'); xlabel('Anio');
title('El shock no financiado se achica cuando compite con la meta exogena');

saveas(gcf,'shocks_parte3.png');

% --- resumen numerico ---
fprintf('\n%-28s %9s %9s %9s\n','serie','desvio','min','max');
nm = {'zeta^F (E2)','zeta^F (E3)','zeta^M (E3)','z^{m2} (E3)'};
dd = {zF2, zF3, zM3, m2};
for j = 1:4
    fprintf('%-28s %9.4f %9.4f %9.4f\n', nm{j}, std(dd{j}), ...
            min(dd{j}), max(dd{j}));
end
R = corrcoef(m2, P.pai);
fprintf('\ncorr(z^{m2} suavizado, inflacion observada) = %.4f\n', R(1,2));
fprintf('Guardado shocks_parte3.png\n');
