% clear all
% hold off
% close all

participants_directory = '/media/usuario/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/First_level';

title = 'caudado';
xlabels = {'bb','bm'};
center = [-14 8 10];
% Usar etiquetas en lugar de nombres de archivo
contrasts = {'BB','BM' };
results_table = analysis_subject_region(center, contrasts, participants_directory, xlabels, title);

% Guardar la tabla en CSV
output_filename = sprintf('intensities_%s_%d_%d_%d.csv', strrep(title, ' ', '_'), center(1), center(2), center(3));
writetable(results_table, output_filename);

participants_directory = '/media/usuario/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/First_level';

title = 'precuneo';
xlabels = {'bb','bm'};
center = [8 -42 40];
% Usar etiquetas en lugar de nombres de archivo
contrasts = {'BB','BM' };
results_table = analysis_subject_region(center, contrasts, participants_directory, xlabels, title);

% Guardar la tabla en CSV
output_filename = sprintf('intensities_%s_%d_%d_%d.csv', strrep(title, ' ', '_'), center(1), center(2), center(3));
writetable(results_table, output_filename);

participants_directory = '/media/usuario/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/First_level';

title = 'Insula anterior izquierda';
xlabels = {'mb','mm'};
center = [-36 18 4];
% Usar etiquetas en lugar de nombres de archivo
contrasts = {'MB','MM' };
results_table = analysis_subject_region(center, contrasts, participants_directory, xlabels, title);

% Guardar la tabla en CSV
output_filename = sprintf('intensities_%s_%d_%d_%d.csv', strrep(title, ' ', '_'), center(1), center(2), center(3));
writetable(results_table, output_filename);

participants_directory = '/media/usuario/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/First_level';

title = 'Insula anterior derecha';
xlabels = {'mb','mm'};
center = [44 14 -10];
% Usar etiquetas en lugar de nombres de archivo
contrasts = {'MB','MM' };
results_table = analysis_subject_region(center, contrasts, participants_directory, xlabels, title);

% Guardar la tabla en CSV
output_filename = sprintf('intensities_%s_%d_%d_%d.csv', strrep(title, ' ', '_'), center(1), center(2), center(3));
writetable(results_table, output_filename);


%% Calculo betas sin usar find_contrast_by_label.m


% participants_directory = '/media/usuario/Expansion/maestria_task/FMRI/Second_level_parametric_2/participantes';
% 
% title = 'corteza prefrontal medial'
% xlabels = {'rival'};
% center = [-1 43 42];
% contrasts = {'con_0002.nii'};
% analysis_subject_region(center, contrasts, participants_directory, xlabels, title);

% title = 'corteza orbotofrontal lateral derecha'
% xlabels = {'bb' 'bm' 'mb' 'mm'};
% center = [34 50 0];
% contrasts = {'con_0015.nii' 'con_0016.nii' 'con_0017.nii' 'con_0018.nii'};
% analysis_contraste_region(center, contrasts, participants_directory, xlabels, title);



% title = 'caudado??'
% xlabels = {'bb' 'bm' 'mb' 'mm'};
% center = [32 -6 -8];
% contrasts = {'con_0015.nii' 'con_0016.nii' 'con_0017.nii' 'con_0018.nii'};
% analysis_contraste_region(center, contrasts, participants_directory, xlabels, title);
% 
% title = 'putamen'
% xlabels = {'indB' 'indM'};
% center = [38 -6 -8];
% contrasts = {'con_0019.nii' 'con_0020.nii'};
% analysis_contraste_region(center, contrasts, participants_directory, xlabels, title);
