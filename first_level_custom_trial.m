addpath('/home/sebastian/maestria_task/MATLAB/spm12') %path al spm12
baseinput = '/media/sebastian/Expansion/maestria_task/FMRI/Prepro'; %Donde toma las imagenes del prepro
baseoutput = '/media/sebastian/Expansion/maestria_task/FMRI/First_level_trial'; %salida del analisis first level
basecomportamental = '/media/sebastian/Expansion/maestria_task/rawdata'; %toma los logfiles
participants_file =  '/media/sebastian/Expansion/maestria_task/FMRI/participants.csv'; %indica que participantes correr
participants = readtable(participants_file);

spm('defaults', 'FMRI');

total_number_sessions = 4;
codigos = participants.first_level_folder; %toma el nombre de la carpera que contiene los datos del sujeto
trigger_id = participants.trigger_id; %tomo el nombre de los triggers
rows = height(participants);

for index=1:rows
    participant = participants(index,:);
    if participant.first_level_trial_enable==1
        continue
    end
    
    name = string(participant.first_level_folder);
    trigger_id = string(participant.trigger_id);
    
    
    inputs_dir  = char(strcat(baseinput, '/', name, '/', "niftii"));
    outputs  = char(strcat(baseoutput, '/', name));
    

% Formar el patrón de búsqueda
%patron_busqueda = char(strcat([basecomportamental trigger_id]));
patron_sujeto = strcat(lower(name),'*.csv');
dir_sujeto = dir(fullfile(basecomportamental, patron_sujeto));
logfile_path = fullfile(dir_sujeto.folder,dir_sujeto.name);
% Obtener la lista de archivos que cumplen con el patrón
%comportamentales = char(strcat(patron_busqueda));



 %tomo los archivos logfile, uso trigger_id para que se llamen igual que el archivo logfile
    
    if ~exist(inputs_dir, 'dir')
        %disp("folder not found");
        continue
    end
    
    if exist(outputs, 'dir')
      rmdir(outputs,'s');
    end
    mkdir(outputs);
    
    disp(participant.first_level_folder); %me imprime que participante tomo para el analisis

    [matlabbatch]=first_level_job_custom_trial(inputs_dir, outputs, logfile_path, total_number_sessions, trigger_id);
     spm_jobman('serial', matlabbatch);
end

