%% Script principal para análisis de segundo nivel

% Directorios
input_dir = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/Second_level_parametric_questionaries/inputs';
output_dir = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/Second_level_parametric_questionaries/outputs';
csv_file = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/psicologicos.scv';

% Lectura de la tabla de cuestionarios
questionnaires = readtable(csv_file);
questionnaire_names = questionnaires.Properties.VariableNames(2:end); % Excluye la primera columna si es identificador

% Obtener lista de carpetas de contrastes
contrast_dirs = dir(fullfile(input_dir, 'con_*'));
contrast_dirs = contrast_dirs([contrast_dirs.isdir]);

% Iterar sobre cada contraste
for c = 1:length(contrast_dirs)
    contrast_name = contrast_dirs(c).name;
    contrast_path = fullfile(input_dir, contrast_name);
    disp(['Procesando contraste: ', contrast_name]);

    % Crear carpeta de salida para el contraste
    contrast_output_dir = fullfile(output_dir, contrast_name);
    if ~exist(contrast_output_dir, 'dir')
        mkdir(contrast_output_dir);
    end

    % Iterar sobre cada cuestionario
    for q = 1:length(questionnaire_names)
        questionnaire_name = questionnaire_names{q};
        questionnaire_output_dir = fullfile(contrast_output_dir, questionnaire_name);

        % Crear subcarpeta para el cuestionario
        if ~exist(questionnaire_output_dir, 'dir')
            mkdir(questionnaire_output_dir);
        end

        % Definir los parámetros de entrada y salida
        images_pattern = fullfile(contrast_path, '*con_*.nii');
        questionnaire_data = questionnaires.(questionnaire_name);

        % Verificar datos antes de llamar al análisis
        disp(['  Cuestionario: ', questionnaire_name]);
        disp(['  Imágenes patrón: ', images_pattern]);
        disp(['  Directorio de salida: ', questionnaire_output_dir]);

        % Llamada al script customizado para el análisis
        try
            one_group_t_test_custom(images_pattern, questionnaire_data, questionnaire_output_dir);
            disp('  Análisis completado para este cuestionario.');
        catch ME
            disp(['  Error en el análisis del cuestionario: ', questionnaire_name]);
            disp(['  Mensaje de error: ', ME.message]);
        end
    end
end

disp('Análisis completado.');
