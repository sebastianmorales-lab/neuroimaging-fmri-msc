function [results_table] = analysis_subject_region(center, contrasts, participants_directory, xlabels, title)

figure
hold on

contrast_means = [];
contrast_stds = [];
symbols = {"o" "*"};
all_data = table();  % Tabla acumulativa para todos los contrastes

for i = 1:numel(contrasts)
    contrast = contrasts{i};
    [contrast_mean, contrast_std, table_data] = compute_subject_intensity(center, contrast, participants_directory);
    x = 1:length(contrast_mean);
    errorbar(x, contrast_mean, contrast_std, symbols{i});
    
    % Acumular datos
    all_data = [all_data; table_data];
end

legend(xlabels)
drawnow

% Retornar la tabla completa
results_table = all_data;

% Mostrar la tabla
disp('Tabla de resultados:')
disp(results_table)

% 
% disp(contrast_means);
% x = 1:length(contrast_means);
% err_high = contrast_stds;
% 
% %si acepto barras de error negativas
% err_low = -contrast_stds;
% 
% %si quiero que la barra de error hacia abajo no sea negativa
% %err_low = -min(contrast_stds, contrast_means);
% 
% %barras = bar(x,contrast_means);
% 
% T = table(contrast_means(1:37)', contrast_means(38:74)');
% T.Properties.VariableNames = {'MB','MM'};
% disp('tabla para grafico')
% disp( T);
% 
% scatter_plot = scatter(x,T,'filled');
% 
% %scatter_plot = scatter(x,contrast_means);
% grid 
% 
% 
% % er = errorbar(x,contrast_means,err_low,err_high);    
% % er.Color = [0 0 0];                            
% % er.LineStyle = 'none'; 
% 
% %set(gca, 'XTickLabel', xlabels);
% 
 
