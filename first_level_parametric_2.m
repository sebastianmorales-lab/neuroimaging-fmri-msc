%Analisis first level parametrizado por categoria del rival y pago
addpath('/home/usuario/Documents/MATLAB/spm12')
participants_file = "/media/usuario/Expansion/maestria_task/FMRI/participants.csv";
participants = readtable(participants_file);

rows = height(participants);
for index=1:rows
    participant = participants(index,:);
    if participant.first_level_parametric_2_enable==1
       
        continue
    end
    [matlabbatch] = first_level_parametric_2_job(participant.first_level_folder, participant.trigger_id);
    spm_jobman('serial', matlabbatch);
end
