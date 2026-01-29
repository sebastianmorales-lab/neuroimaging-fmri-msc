%Agregamos sexo y edad como variables de no interes. 
function [matlabbatch] = one_group_t_test_job_hotfix(inputs, output, cuestionario, nombre_cuestionario)

% Leer datos
 csv_filename = "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/psicologicos.csv";
%csv_filename = "D:\Expansion\maestria_task\FMRI\psicologicos.csv"; en
%windws

data = readtable(csv_filename, 'Delimiter', ',', 'ReadVariableNames',true);
data = data(data.descartar == 0, :);

output_dir = {char(output)};
scans_column = {};

for index = 1:length(inputs)
    input = inputs{index};
     pattern = strcat(input, "/", "*_con_*.nii");
    % pattern = strcat(input, "\", "*_con_*.nii");
    inputs_files = dir(pattern);

    for jindex = 1:length(inputs_files)
        filename = inputs_files(jindex).name;
        scans_column{end+1} = char(strcat(fullfile(input, filename), ",1"));
    end
end

scans = scans_column';
codigos_scans = scans;
string_codigos_scans = {};

for i = 1:length(codigos_scans)
    path = codigos_scans{i};
    [~, filename] = fileparts(path);
    disp("filename");
    disp(filename);
    codigo = lower(filename(1:end-9));
    string_codigos_scans{end+1} = codigo;
end

disp("++++");
disp(data.codigo);
disp(string_codigos_scans');
% Obtener variables
puntajes = cuestionario(ismember(data.codigo, string_codigos_scans'))';
sexo = data.sexo(ismember(data.codigo, string_codigos_scans'))';
edad = data.edad(ismember(data.codigo, string_codigos_scans'))';

% Filtrar valores válidos
scans = scans(~isnan(puntajes));
puntajes = puntajes(~isnan(puntajes));
sexo = sexo(~isnan(puntajes));
edad = edad(~isnan(puntajes));

% Construcción del diseño
matlabbatch{1}.spm.stats.factorial_design.dir = output_dir;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.scans = scans;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.c = [puntajes];
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.cname = nombre_cuestionario{:};
matlabbatch{1}.spm.stats.factorial_design.des.mreg.mcov.iCC = 1;
matlabbatch{1}.spm.stats.factorial_design.des.mreg.incint = 1;

% Covariables de no interés: sexo y edad
matlabbatch{1}.spm.stats.factorial_design.cov(1).c = double(sexo);
matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'sexo';
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;

matlabbatch{1}.spm.stats.factorial_design.cov(2).c = double(edad);
matlabbatch{1}.spm.stats.factorial_design.cov(2).cname = 'edad';
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCFI = 1;
matlabbatch{1}.spm.stats.factorial_design.cov(2).iCC = 1;

% Otros parámetros del diseño
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;

% Estimación
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File',substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

% Contrastes
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'up';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1 0 0]; % [intercepto, cuestionario, sexo, edad]
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'dow';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;
