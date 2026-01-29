function [matlabbatch, design_dir] = second_level_parametric_2_job(contrast, label1, label2);

% contrast={'con_0013'};
% label1={'interaccion_up'};
% label2={'interaccion_dw'};

design_dir = {char(fullfile("//media/usuario/Expansion/maestria_task/FMRI/Second_level_parametric_4/outputs", contrast))};
inputs_dir = "/media/usuario/Expansion/maestria_task/FMRI/Second_level_parametric_4/participantes";

folders = dir(inputs_dir);

dirs_w_files = {};

%Exclude "'" and ".."
folders_filtered = folders(~startsWith({folders.name}, '.'));
targets = string({folders_filtered.name});

paths = fullfile(inputs_dir, targets, "niftii", strcat(contrast, ".nii,1"));
dirs = fullfile(inputs_dir, targets, "niftii", strcat(contrast, ".nii"));

for i = dirs
    dirs_w_files{end+1} = dir(i)';
end

dirs_w_files_indexes = find(~cellfun(@isempty,dirs_w_files));

scans = cellstr(paths(dirs_w_files_indexes))';

matlabbatch{1}.spm.stats.factorial_design.dir = design_dir;
matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = label1{:};
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = label2{:};
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = -1;
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
