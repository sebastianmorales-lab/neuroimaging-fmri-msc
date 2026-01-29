%addpath('/home/usuario/Documents/MATLAB/spm12') %agraga la carpeta de spm a Matlab

function [matlabbatch] = first_level_parametric_custom_job(participant_folder, trigger_id)

CONTRASTE_LABEL = 1;
CONTRASTE_VALUES = 2;
repMB = 4;
repIndB = 4;
repIndM = 4;
posicionMB = zeros(1,4)
posicionIndB = zeros(1,4)
posicionIndM = zeros(1,4)

disp(trigger_id);

logfiles = "/media/usuario/Expansion/maestria_task/rawdata";
triggers_dir = "/media/usuario/Expansion/maestria_task/triggers";

data_format = "%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q";

n_blocks = 4;
trials_per_block = 32;

base_dir = '/media/usuario/Expansion/maestria_task/FMRI/First_level_parametric';
disp(char(participant_folder))
output      = fullfile(base_dir,'participantes', char(participant_folder), 'niftii');
inputs_base = fullfile(base_dir,'participantes', char(participant_folder), 'niftii');
session_files = dir(fullfile(inputs_base, "swA_*_fMRI_*nii"))';
multis_files = dir(fullfile(inputs_base, "rp_A_*_fMRI_*txt"))';

multi_regs = {};

scans = {};

scans_session = {};

for index_i=1:length(session_files)
    file_data = session_files(index_i);
    path = fullfile(file_data.folder, file_data.name);
    
    scans_session = {};
    for index_j=1:295 %especificar el numero de imagenes
        scans_session{end+1} = char(strcat(path, ",", string(index_j)));
    end
    scans{end+1} = scans_session';
end

for index_i=1:length(multis_files)
    file_data = multis_files(index_i);
    path = fullfile(file_data.folder, file_data.name);
    
    multi_regs{end+1} = {path};
end

files = dir(fullfile(triggers_dir, strcat(trigger_id,"*csv")));
triggers = [];

n_triggers_files = length(files);

%skip first trigger file, because it's for trainning
for index=1:n_triggers_files
    file = files(index);
    trigger_path = fullfile(triggers_dir, file.name);
    triggers_block = readtable(trigger_path, 'Delimiter', ',', 'HeaderLines', 0,'ReadVariableNames', false);
    triggers_block.Properties.VariableNames = {'value'};
    trigger = triggers_block.value(end);
    trigger_chunk = repmat(trigger,trials_per_block,1);
    triggers  = cat(1, triggers, trigger_chunk);
end

files = dir(fullfile(logfiles, strcat(trigger_id,"*csv")));
file = files(1);
disp(file)
logfile_path = fullfile(logfiles, file.name);

%Not sure why HeaderLines -> 0, but this way data is a table with
%column names read correctly
data = readtable(logfile_path, 'Delimiter', ',', 'HeaderLines', 0,'Format',data_format);

%Remove demo trials
filter = string(data.nro_bloque)=="0";
data(filter,:) = [];
data.nro_bloque = str2double(data.nro_bloque);

data.show_game_type = str2double(data.show_game_type);
data.show_outcome = str2double(data.show_outcome);
data.social_time = str2double(data.social_time);
data.rival = str2double(data.rival);
data.pay_competitive = str2double(data.pay_competitive);

%data.game_type_time = data.show_game_type + data.social_time - triggers;
data.outcome_time = data.show_outcome - triggers;
data.show_game_time = data.show_game_type - triggers;

choice_competitive_blocks = {};
choice_individual_blocks = {};

for i_block=1:n_blocks
    %filter by block number, to split in sessions
    filter = data.nro_bloque==i_block;
    data_block = data(filter,:);
   
    %slice data by game type (competitive)
    filter = string(data_block.game_type)=="competitive";
    choice_competitive_blocks{i_block} = data_block(filter,:);
    
    %slice data by game type (individual)
    filter = string(data_block.game_type)=="individual";
    choice_individual_blocks{i_block} = data_block(filter,:);
end

disp(choice_competitive_blocks);
disp(choice_individual_blocks);

outcomes_competitive_bb = {};
outcomes_competitive_bm = {};
outcomes_competitive_mb = {};
outcomes_competitive_mm = {};

outcomes_individual_b = {};
outcomes_individual_m = {};

bloques = {};

for i_block=1:n_blocks
    %filter by block number, to split in sessions
    filter = data.nro_bloque==i_block;
    data_block = data(filter,:);
    
    bloques{i_block} = data_block;
            
    %slice data by game type and outcome
    filter = string(data_block.game_type)=="competitive" & string(data_block.outcome_competitive)=="1" & string(data_block.outcome_rival)=="1";
    outcomes_competitive_bb{i_block} = data_block(filter,:);
    
    filter = string(data_block.game_type)=="competitive" & string(data_block.outcome_competitive)=="1" & string(data_block.outcome_rival)=="0";
    outcomes_competitive_bm{i_block} = data_block(filter,:);
    
    filter = string(data_block.game_type)=="competitive" & string(data_block.outcome_competitive)=="0" & string(data_block.outcome_rival)=="1";
    outcomes_competitive_mb{i_block} = data_block(filter,:);
    
    filter = string(data_block.game_type)=="competitive" & string(data_block.outcome_competitive)=="0" & string(data_block.outcome_rival)=="0";
    outcomes_competitive_mm{i_block} = data_block(filter,:);
    
    %slice data by game type and outcome
    filter = string(data_block.game_type)=="individual" & string(data_block.outcome_individual)=="1";
    outcomes_individual_b{i_block} = data_block(filter,:);
    
    filter = string(data_block.game_type)=="individual" & string(data_block.outcome_individual)=="0";
    outcomes_individual_m{i_block} = data_block(filter,:);
end


disp(outcomes_competitive_bb);
disp(outcomes_competitive_bm);
disp(outcomes_competitive_mb);
disp(outcomes_competitive_mm);

disp(outcomes_individual_b);
disp(outcomes_individual_m);
[contrastes, all_contrastes] = deal(compute_contrastes_parametric_maestria(choice_individual_blocks,outcomes_individual_b, outcomes_individual_m, repMB, repIndB, repIndM,posicionMB, posicionIndB, posicionIndM));

%[contrastes, all_contrastes] = deal(compute_contrastes_parametric_maestria(choice_individual_blocks,outcomes_individual_b, outcomes_individual_m, repMB, repIndB, repIndM,posicionMB, posicionIndB, posicionIndM));
% read contrast in computer_contrastes_parametric.m

matlabbatch{1}.spm.stats.fmri_spec.dir = {output};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.5;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;



for i_block=1:n_blocks
    
    numero_condicion = 0;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).scans = scans{i_block};
    numero_condicion = numero_condicion +1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'tiempos_decision';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = bloques{i_block}.show_game_time;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
    
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(1).name = 'rival';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(1).param = bloques{i_block}.rival;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(1).poly = 1;
    
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(2).name = 'pay_competitive';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(2).param = bloques{i_block}.pay_competitive;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod(2).poly = 1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
    
    numero_condicion = numero_condicion +1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'BB';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_competitive_bb{i_block}.outcome_time;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
    
    numero_condicion = numero_condicion +1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'BM';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_competitive_bm{i_block}.outcome_time;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
    
   if length(outcomes_competitive_mb{i_block}.outcome_time)~= 0
                
        numero_condicion = numero_condicion +1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'MB';
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_competitive_mb{i_block}.outcome_time;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
        
    else
        posicionMB(i_block) = numero_condicion+3;
            repMB = repMB -1;
    end
        
    numero_condicion = numero_condicion +1;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'MM';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_competitive_mm{i_block}.outcome_time;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
    
    
        if length(outcomes_individual_b{i_block}.outcome_time) ~= 0
            
            numero_condicion = numero_condicion +1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'ind_B';
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_individual_b{i_block}.outcome_time;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
            
        else
            posicionIndB(i_block) = numero_condicion+3;
            repIndB = repIndB -1;
            
        end
    
        if length(outcomes_individual_m{i_block}.outcome_time) ~= 0
                        
            numero_condicion = numero_condicion +1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).name = 'indM';
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).onset = outcomes_individual_m{i_block}.outcome_time;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).duration = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).tmod = 0;
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
            matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).cond(numero_condicion).orth = 1;
            
            
        else
             posicionIndM(i_block) = numero_condicion+3; 
            repIndM = repIndM -1;
        end
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).multi_reg = multi_regs{i_block};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i_block).hpf = 128;
    
end
   
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

disp(repIndB)
disp(repIndM)
%contrastes_computed = compute_contrastes_parametric_maestria(choice_individual_blocks,outcomes_individual_b, outcomes_individual_m,repMB, repIndB,repIndM,posicionMB, posicionIndB,posicionIndM);
contrastes_computed = compute_contrastes_parametric_maestria(choice_individual_blocks,outcomes_individual_b, outcomes_individual_m,repMB, repIndB,repIndM,posicionMB, posicionIndB,posicionIndM);

contrastes = contrastes_computed{1};

for index=1:length(contrastes)
    matlabbatch{3}.spm.stats.con.consess{index}.tcon.name = contrastes{index}{CONTRASTE_LABEL};
    matlabbatch{3}.spm.stats.con.consess{index}.tcon.weights = contrastes{index}{CONTRASTE_VALUES};
    matlabbatch{3}.spm.stats.con.consess{index}.tcon.sessrep = 'none';
end
  
matlabbatch{3}.spm.stats.con.delete = 0;
save(fullfile(output, "matlabbatch.mat"), 'matlabbatch');
