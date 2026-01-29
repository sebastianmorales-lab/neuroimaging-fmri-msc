function [] = analysis_contraste_region(center, contrasts, participants_directory, xlabels, title)

figure

contrast_means = [];
contrast_stds = [];

for i = 1:numel(contrasts)
    contrast = contrasts{i};
    [contrast_mean,contrast_std] = compute_mean_intensity(center, contrast, participants_directory);
    contrast_means = [contrast_means contrast_mean];
    contrast_stds = [contrast_stds contrast_std];
end
disp(contrast_means);
x = 1:length(contrast_means);
err_high = contrast_stds;

%si acepto barras de error negativas
err_low = -contrast_stds;

%si quiero que la barra de error hacia abajo no sea negativa
%err_low = -min(contrast_stds, contrast_means);

barras = bar(x,contrast_means);

hold on

er = errorbar(x,contrast_means,err_low,err_high);    
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 

set(gca, 'XTickLabel', xlabels);

legend(title)
drawnow