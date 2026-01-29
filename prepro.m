   % List of open inputs
   addpath('/media/sebastian/Seagate Portable Drive/Expansion/spm12 (seba)/')
nrun = 1; % enter the number of runs here
jobfile = {'/media/sebastian/Seagate Portable Drive/Expansion/MATLAB/analisis_Maestria/prepro_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
pilotos_directory = '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/Prepro/'; %paths folder
pilotos = dir(fullfile(pilotos_directory, '+SUJETO_*')); %subjects directory cambiar por SUJETO
for i = 1:numel(pilotos)
    sesions = dir(fullfile(pilotos_directory, pilotos(i).name,'/niftii' ,'A_*_fMRI_*.nii'));
    piloto = pilotos(i);
    [matlabbatch] = prepro_job(sesions,piloto);
    spm_jobman('serial', matlabbatch);
end
%spm_jobman('run', jobs, inputs{:})
