%Agregamos sexo y edad como variables de no interes.
function [matlabbatch] = one_group_t_test_job_hotfix_fco(inputs, contrastNr, output, cuestionario, nombre_cuestionario)

contrastGuide=[1:20 ; 1:3 NaN NaN NaN 4:17; NaN NaN NaN 1:17]';

for istudy=1:size(contrastGuide,2)
    for icon=1:size(contrastGuide,1)
        if contrastGuide(icon,istudy)<10
            celda_contrastes{istudy,icon}=['con_000' num2str(contrastGuide(icon,istudy)) '.nii,1'];
        else
            celda_contrastes{istudy,icon}=['con_00' num2str(contrastGuide(icon,istudy)) '.nii,1'];
        end
        
        if isnan(contrastGuide(icon,istudy))
            celda_contrastes{istudy,icon}=[];
        end
    end
end;


inputs_dir ={'/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/Second_level_parametric_question_timesByDecision/participantes2';
    '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/Second_level_parametric_question_timesByDecisionNoIndv/participantes';
    '/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/news/Second_level_parametric_question_timesByDecisionNoComp/participantes'};

idx=1;
for istudy=1:size(celda_contrastes,1)
    first_level= dir(fullfile(inputs_dir{istudy}, 'SUJETO_*'));%directorio especifico de cada participante
    
    for i= 1:numel(first_level)
        if not(isempty(celda_contrastes{istudy,contrastNr}))
            contraste(idx) = fullfile(inputs_dir{istudy}, first_level(i).name, 'niftii',celda_contrastes(istudy,contrastNr));
            idx=idx+1;
        end
        
    end
end
contraste_str=char(contraste);
csv_filename = "/media/sebastian/Seagate Portable Drive/Expansion/maestria_task/FMRI/utils/psicologicos.csv";

data = readtable(csv_filename, 'Delimiter', ',', 'ReadVariableNames',true);
data = data(data.descartar == 0, :);

for isub=1:size(contraste_str,1)
    pat = strfind(contraste_str(isub,:), "SUJETO_");
    subs=contraste_str(isub,pat+7:pat+7+7);
    temp=subs;%(isub,:);
    temp(regexp(temp,'/'))=[];
    for ijk=1:height(data)
        temp2=data.codigo{ijk};
        temp2=temp2(8:end);
        if temp2(end)==' '
            temp2(end)=[];
        end
        try
            counter(ijk)=sum(temp2==[lower(temp)]);
        catch
             counter(ijk)=0;%disp(length(temp2));
        end
    end
    [aa idx]=max(counter);disp(length(idx))
    sexlist(isub)=data.sexo(idx);
    agelist(isub)=data.edad(idx);
    zpsicolist(isub)=data.PCA(idx);
    %         %emoSlope(isub)=data.judgeEmotion_slope(data.codigo==temp);
    %         %emoInt(isub)=data.judgeEmotion_intercept(data.codigo==temp);
    %         %behSlope(isub)=data.behModel_slope(data.codigo==temp);
    %         %behInt(isub)=data.behModel_intercept(data.codigo==temp);
    clear temp;
end
% Leer datos
%csv_filename = "D:\Expansion\maestria_task\FMRI\psicologicos.csv"; en
%windws


% 
 output_dir = {char(output)};
 scans=contraste';
 puntajes=zpsicolist';
 sexo=sexlist';
 edad=agelist';
% scans_column = {};
% 
% for index = 1:length(inputs)
%     input = inputs{index};
%     pattern = strcat(input, "/", "*_con_*.nii");
%     % pattern = strcat(input, "\", "*_con_*.nii");
%     inputs_files = dir(pattern);
%     
%     for jindex = 1:length(inputs_files)
%         filename = inputs_files(jindex).name;
%         scans_column{end+1} = char(strcat(fullfile(input, filename), ",1"));
%     end
% end
% 
% scans = scans_column';
% codigos_scans = scans;
% string_codigos_scans = {};
% 
% for i = 1:length(codigos_scans)
%     path = codigos_scans{i};
%     [~, filename] = fileparts(path);
%     disp("filename");
%     disp(filename);
%     codigo = lower(filename(1:end-9));
%     string_codigos_scans{end+1} = codigo;
% end
% 
% disp("++++");
% disp(data.codigo);
% disp(string_codigos_scans');
% % Obtener variables
% puntajes = cuestionario(ismember(data.codigo, string_codigos_scans'))';
% sexo = data.sexo(ismember(data.codigo, string_codigos_scans'))';
% edad = data.edad(ismember(data.codigo, string_codigos_scans'))';
% 
% % Filtrar valores válidos
% scans = scans(~isnan(puntajes));
% puntajes = puntajes(~isnan(puntajes));
% sexo = sexo(~isnan(puntajes));
% edad = edad(~isnan(puntajes));



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
