%-----------------------------------------------------------
%Second Level con Sexo y Edad como covariables de no interes
%-----------------------------------------------------------
output_base = "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/Second_level_parametric_questionnaries/outputs";
%output_base = "D:\Expansion\maestria_task\FMRI\Second_level_parametric_questionnaries\outputs3";
 input_base  = "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/Second_level_parametric_questionnaries/inputs";
%input_base  = "D:\Expansion\maestria_task\FMRI\Second_level_parametric_questionnaries\inputs";
 csv_filename = "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/psicologicos.csv";
%csv_filename = "D:\Expansion\maestria_task\FMRI\psicologicos.csv";

data = readtable(csv_filename);
[data] = data(data.descartar == 0, :);
% Seleccionar las columnas con los questionarios
desde = find(string(data.Properties.VariableNames) == "PCA");
hasta = find(string(data.Properties.VariableNames) == "PCA");

ANALYSIS_LABEL = 1;
GROUP = 2;


grupos_analisis = {
   {'second_all', {'second_all'}}
};
n_contrastes = 20;

for i = desde:hasta
    
    cuestionario = data{:,i};
    
    nombre_cuestionario = string(data.Properties.VariableNames(i));
    
    for index=1:length(grupos_analisis)
        analisis = grupos_analisis{index};
        label = analisis{ANALYSIS_LABEL};
        grupos = string(analisis{GROUP});

        for kindex=1:n_contrastes   
            contrast = strcat("con_",  num2str(kindex,'%04d'));

            inputs = {};
            for jindex=1:length(grupos)  
                input = fullfile(input_base, grupos(jindex), contrast);
                inputs{end+1} = char(input);
            end    

            output = string(fullfile(output_base, label, contrast, nombre_cuestionario{:}));
             delete(strcat(output, "/", "*"));
            %delete(strcat(output, "\", "*"));

            disp("1*****");
            [matlabbatch] = one_group_t_test_job_hotfix_fco(inputs, kindex, output, cuestionario, nombre_cuestionario);
            spm_jobman('serial', matlabbatch);
            disp('guardando matlabbatch...')
            batch_filename = fullfile(output, 'matlabbatch.mat');
            save(batch_filename, 'matlabbatch');
            disp("2*****");
        end
    end
end
