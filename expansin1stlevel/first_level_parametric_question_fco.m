%Analisis first level parametrizado por categoria del rival y pago con separación por decisión Competitive versus Individual (incluye la pregunta)
%addpath('/home/sebastian/maestria_task/MATLAB/spm12')
%spm fmri
currentFolder=pwd;
%participants_file = 'D:\Expansion\maestria_task\FMRI\participants.csv' %en windows

participants_file = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/participants.csv';
participants = readtable(participants_file);
rows = height(participants);
fail=[];nonfail=[];
%load([currentFolder '/failedSubjectsByDecision.mat']); %<-------Esta línea puede ser
%descomentada una vez se haya corrido completo el First level por primera
%vez
for index=1:rows
    participant = participants(index,:);
    if participant.first_level_parametric_question_enable==1
       
        continue
    end
    
        if index==fail
               continue
        end   %<-------Esta sección puede ser
    %descomentada una vez se haya corrido completo el First level por primera
    %vez
    
     [matlabbatch] = first_level_parametric_question_job_fco(participant.first_level_folder, participant.trigger_id);
    
    try
       
        spm_jobman('serial', matlabbatch);
        nonfail=[nonfail index];
    catch
        fail=[fail index];
        cd(currentFolder)
    end
end
cd(currentFolder)
failedSubs=cell2mat(participants.trigger_id(fail));
nonfailedSubs=cell2mat(participants.trigger_id(nonfail));
save('failedSubjectsByDecision.mat','fail','failedSubs','nonfail','nonfailedSubs');
