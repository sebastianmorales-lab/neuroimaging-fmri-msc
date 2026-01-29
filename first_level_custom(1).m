baseinput = '/media/cibpsi/TOSHIBA EXT/team_task/prepro';
baseoutput = '/media/cibpsi/Portable Drive/datos_tesis_maestria/fmri_team_task_analysis/first_level_up_down_x_trial_outcomes_normalTimeModeled_question_noInterest';
basecomportamental = '/media/cibpsi/Portable Drive/datos_tesis_maestria/fmri_team_task_data/comportamental/team2Colapsado_modelo_con_stimulus_duration_y_question_no_interest/';

csv_filename = "/media/cibpsi/Portable Drive/datos_tesis_maestria/fmri_team_task_data/subject_key_data.csv";
[data] = readtable(csv_filename);

spm('defaults', 'FMRI');

total_number_sessions = 4;
codigos = data.codigo;

for i=93:numel(codigos)
    if data.descartar{i}== '1' || data.prepro{i}=='0'
        continue
    end
    name = string(codigos(i));
    
    inputs  = char(strcat(baseinput, '/', name));
    outputs  = char(strcat(baseoutput, '/', name));
    comportamentales  = char(strcat(basecomportamental, '/', name,'/'));
    
    if ~exist(inputs, 'dir')
        %disp("folder not found");
        continue
    end
    
    if exist(outputs, 'dir')
      rmdir(outputs,'s');
    end
    mkdir(outputs);
    
    disp(codigos(i));

    [matlabbatch]=first_level_job_custom(inputs, outputs, comportamentales, total_number_sessions);
     spm_jobman('serial', matlabbatch);
end

