%Analisis first level parametrizado por categoria del rival y pago (incluye la pregunta)
%addpath('/home/sebastian/maestria_task/MATLAB/spm12')
%spm fmri

%participants_file = 'D:\Expansion\maestria_task\FMRI\participants.csv' %en windows
participants_file = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/participants.csv';
participants = readtable(participants_file);

rows = height(participants);
for index=1:rows
    participant = participants(index,:);
    if participant.first_level_parametric_question_enable==1
       
        continue
    end
    

    [matlabbatch] = first_level_parametric_question_job(participant.first_level_folder, participant.trigger_id);
    spm_jobman('serial', matlabbatch);
end
