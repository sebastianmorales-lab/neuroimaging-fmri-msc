function [contrast_filename] = find_contrast_by_label(contrast_label, participant_dir)
% FIND_CONTRAST_BY_LABEL Busca el archivo de contraste por su etiqueta
%   contrast_filename = find_contrast_by_label(contrast_label, participant_dir)
%   
%   Busca en el directorio del participante el archivo SPM.mat, carga los
%   contrastes y encuentra el que tiene la etiqueta especificada.
%   Retorna el nombre del archivo de contraste (ej: 'con_0017.nii')
%
%   Inputs:
%       contrast_label: String con la etiqueta del contraste (ej: 'BB_up')
%       participant_dir: Directorio del participante donde buscar SPM.mat
%
%   Output:
%       contrast_filename: Nombre del archivo de contraste encontrado

    % Buscar el archivo SPM.mat en diferentes ubicaciones posibles
    spm_mat_path = '';
    
    % 1. Buscar en el directorio raíz del participante
    candidate_path = fullfile(participant_dir, 'SPM.mat');
    if exist(candidate_path, 'file')
        spm_mat_path = candidate_path;
    else
        % 2. Buscar en el subdirectorio niftii
        candidate_path = fullfile(participant_dir, 'niftii', 'SPM.mat');
        if exist(candidate_path, 'file')
            spm_mat_path = candidate_path;
        else
            % 3. Buscar recursivamente en todos los subdirectorios
            % Función auxiliar para búsqueda recursiva compatible
            spm_mat_path = find_spm_mat_recursive(participant_dir);
        end
    end
    
    if isempty(spm_mat_path)
        error('No se encontró SPM.mat en %s', participant_dir);
    end
    
    % Cargar la estructura SPM
    try
        load(spm_mat_path, 'SPM');
    catch ME
        error('Error al cargar SPM.mat desde %s: %s', spm_mat_path, ME.message);
    end
    
    % Buscar el contraste por su etiqueta
    contrast_found = false;
    contrast_index = [];
    
    if isfield(SPM, 'xCon') && ~isempty(SPM.xCon)
        for i = 1:length(SPM.xCon)
            if strcmp(SPM.xCon(i).name, contrast_label)
                contrast_index = i;
                contrast_found = true;
                break;
            end
        end
    end
    
    if ~contrast_found
        % Listar los contrastes disponibles para ayudar al usuario
        available_labels = {};
        if isfield(SPM, 'xCon') && ~isempty(SPM.xCon)
            for i = 1:length(SPM.xCon)
                available_labels{end+1} = SPM.xCon(i).name;
            end
        end
        error('No se encontró el contraste con etiqueta "%s" en %s.\nContrastes disponibles: %s', ...
              contrast_label, participant_dir, strjoin(available_labels, ', '));
    end
    
    % Construir el nombre del archivo de contraste
    contrast_filename = sprintf('con_%04d.nii', contrast_index);
    
end

function spm_path = find_spm_mat_recursive(dir_path)
    % Función auxiliar para buscar SPM.mat recursivamente
    % Compatible con versiones antiguas de MATLAB
    
    % Buscar en el directorio actual
    candidate = fullfile(dir_path, 'SPM.mat');
    if exist(candidate, 'file')
        spm_path = candidate;
        return;
    end
    
    % Buscar en subdirectorios
    dirs = dir(dir_path);
    for i = 1:length(dirs)
        if dirs(i).isdir && ~strcmp(dirs(i).name, '.') && ~strcmp(dirs(i).name, '..')
            subdir_path = fullfile(dir_path, dirs(i).name);
            spm_path = find_spm_mat_recursive(subdir_path);
            if ~isempty(spm_path)
                return;
            end
        end
    end
    
    spm_path = '';
end

