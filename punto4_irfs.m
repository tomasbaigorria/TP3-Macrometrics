% ============================================================
%  Punto 4 — shock no estacionario monetario vs fiscal
%  Correr DESPUÉS de: dynare uribe_bfm_ns
% ============================================================

H  = length(oo_.irfs.dpi_obs_e_gm);
hh = 0:H-1;

% Niveles: acumular los cambios observados. Nominales anualizadas.
PI_m = 4*cumsum(oo_.irfs.dpi_obs_e_gm)';      % monetario
II_m = 4*cumsum(oo_.irfs.di_obs_e_gm)';
Y_m  =   cumsum(oo_.irfs.dy_obs_e_gm)';
R_m  = 4*oo_.irfs.r_e_gm';

PI_f = 4*cumsum(oo_.irfs.dpi_obs_e_gpiF)';    % fiscal
II_f = 4*cumsum(oo_.irfs.di_obs_e_gpiF)';
Y_f  =   cumsum(oo_.irfs.dy_obs_e_gpiF)';
R_f  = 4*oo_.irfs.r_e_gpiF';

% Normalizar a 1 pp de inflación observada en el largo plazo
nm = 1/PI_m(end);
nf = 1/PI_f(end);
fprintf('\nEscalas — monetario: %.3f   fiscal: %.3f\n', nm, nf);

datos = { {PI_m*nm, PI_f*nf}, {II_m*nm, II_f*nf}, ...
          {Y_m*nm,  Y_f*nf }, {R_m*nm,  R_f*nf } };
nombres = {'Inflación (pp anual)','Tasa nominal (pp anual)', ...
           'Producto (%)','Tasa real (pp anual)'};

figure('Position',[80 80 900 720],'Color','w');
for v = 1:4
    subplot(4,1,v);
    plot(hh, datos{v}{1}, 'b-',  'LineWidth',1.8); hold on;
    plot(hh, datos{v}{2}, 'r--', 'LineWidth',1.6);
    yline(0,'k:'); grid on; box off; xlim([0 H-1]);
    ylabel(nombres{v},'FontSize',9);
    if v==1
        title('Shocks no estacionarios: monetario (g^m) vs fiscal (g^{\pi F})', ...
              'Interpreter','tex','FontWeight','bold');
        legend({'Monetario (g^m)','Fiscal (g^{\pi F})'}, ...
               'Box','off','Location','best','Interpreter','tex');
    end
    if v==4, xlabel('Trimestres'); end
end
saveas(gcf,'punto4_irfs.png');

fprintf('\nInflación observada a t=40 (normalizada):\n');
fprintf('  monetario: %.3f\n', PI_m(end)*nm);
fprintf('  fiscal   : %.3f\n', PI_f(end)*nf);