function [matlabbatch] = one_group_t_test_job_custom(inputs, output, cuestionario, nombre_cuestionario)
%Agregar path con el archivo de datos psicologicos adecuado
csv_filename= "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/psicologicos.csv";
[data] = readtable(csv_filename);
[data] = data(data.descartar == 0, :);

output_dir = {char(output)};

scans_column = {};

for index=1:length(inputs)
    input = inputs{index}

    pattern = strcat(input, "/", "*_con_*.nii");
    inputs_files = dir(pattern);

    for jindex=1:length(inputs_files)
        filename = inputs_files(jindex).name;
        scans_column{end+1} = char(strcat(fullfile(input, filename), ",1"));    
    end
end

scans = scans_column';

codigos_scans = scans;
disp(codigos_scans);
string_codigos_scans={};
disp(string_codigos_scans)
for i = 1:length(codigos_scans(:,1))
    path = codigos_scans{i,1};
    [~,filename] = fileparts(path);
    codigo = lower(filename(1:end-9));
    string_codigos_scans{end+1} = codigo;
%%string_codigos_scans{end+1}=lower(codigos_scans{i,1}(140:end-15)); %140:end-15 define el nobre del sujeto recortando el path
end

puntajes = cuestionario(ismember(data.codigo,string_codigos_scans'));

scans = scans(~isnan(puntajes));
puntajes = puntajes(~isnan(puntajes));

matlabbatch{1}.spm.stats.factorial_design.dir = output_dir;

%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = [puntajes];
%%
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = nombre_cuestionario{:};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'up';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'dow';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
