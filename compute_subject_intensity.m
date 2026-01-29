function [mean_intensity, std_intensity, table_data] = compute_subject_intensity(center, contrast, participants_directory);

participants = dir(fullfile(participants_directory, 'SUJETO_*'));
intensities = [];
intensities_std = [];
table_data = table();  % Crear tabla vacía

% Determinar si 'contrast' es una etiqueta o un nombre de archivo
% Si termina en .nii, es un nombre de archivo; si no, es una etiqueta
is_label = isempty(regexp(contrast, '\.nii$', 'once'));

% Debug: mostrar qué se está buscando
if is_label
    fprintf('Buscando contraste por ETIQUETA: "%s"\n', contrast);
else
    fprintf('Buscando contraste por NOMBRE DE ARCHIVO: "%s"\n', contrast);
end

for i = 1:numel(participants)
    participant_dir = fullfile(participants_directory, participants(i).name);
    
    % Si es una etiqueta, buscar el archivo por etiqueta
    if is_label
        try
            contrast_filename = find_contrast_by_label(contrast, participant_dir);
            contrast_to_use = contrast_filename;
            contrast_display = contrast; % Guardar la etiqueta para mostrar
            fprintf('  %s: Etiqueta "%s" -> Archivo "%s"\n', participants(i).name, contrast, contrast_filename);
        catch ME
            fprintf('  %s: ERROR - %s\n', participants(i).name, ME.message);
            continue
        end
    else
        contrast_to_use = contrast;
        contrast_display = contrast;
    end
    
    path = fullfile(participant_dir, 'niftii', contrast_to_use);
    if ~ exist(path, 'file')
        fprintf('  %s: Archivo no encontrado en %s\n', participants(i).name, path);
        continue
    end
    
    participant_intensities = compute_intensities(center, path);
    mean_val = mean(participant_intensities);
    std_val = std(participant_intensities);
    
    intensities = [intensities mean_val];
    intensities_std = [intensities_std std_val];
    
    % Agregar fila a la tabla (usar la etiqueta o nombre original para mostrar)
    new_row = table({participants(i).name}, {contrast_display}, center(1), center(2), center(3), mean_val, std_val, ...
                    'VariableNames', {'participant', 'contrast', 'center_x', 'center_y', 'center_z', 'mean_intensity', 'std_intensity'});
    table_data = [table_data; new_row];
    
    disp(participants(i).name)
    disp(intensities)
end

mean_intensity = intensities;
std_intensity = intensities_std;
