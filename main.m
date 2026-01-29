coordenadas_mm = [[-13;15;50]]; %coordinada que me interese sacar los betas
    %[[-8;54;14]] [16;18;64] [6;30;18]];
    %[-6;22;34] [-26;48;22] [4;30;20]];
%data = get_subjects();
all_intensities = [];
flag=true;

start_index = 1;
end_index = 154;

% Create a cell array to store the strings
contrasts = cell(1, end_index);

% Loop to generate the strings and store them in the cell array
for i = start_index:end_index
    % Use sprintf to create the strings with leading zeros
    contrasts{i} = sprintf('con_%04d', i);
    display(i);
end

for coords_mm = coordenadas_mm
    coords_mm = coords_mm';

        figures_dest = "/media/sebastian/Expansion/maestria_task/FMRI/First_level_trial";

        intensities = mean_intensities(contrasts, coords_mm);

        intensities.codigo=cellstr(intensities.codigo);
        
        if flag == true
            all_intensities = intensities;
            flag=false;
            continue
        end
        
        all_intensities=outerjoin(all_intensities,intensities(:, [1 3]),'Keys','codigo','MergeKeys',true);

end
path = '/media/sebastian/Expansion/maestria_task/proyecto_final_MAESTRIA_R/input';
nombreArchivo = 'analysis_table_-13_15_50.csv'; %cambiar la tabla dependiendo de la coord
% Crea el path completo
pathCompleto = fullfile(path, nombreArchivo);
writetable(all_intensities, pathCompleto);
