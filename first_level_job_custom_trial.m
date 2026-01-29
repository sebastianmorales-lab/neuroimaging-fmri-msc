function [matlabbatch] = first_level_job_custom_trial(inputs_dir, output_dir, logfile_path, total_number_sessions, trigger_id)
%total_number_sessions = 2;
data_format = "%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
images_start = 1;
images_finish = 295;
number_sessions = 4;
number_conditions = 4;
trials_per_block=32;
multis_files = dir(fullfile(inputs_dir, "rp_A_*_fMRI_*txt"))';
triggers_dir = "/media/sebastian/Expansion/maestria_task/triggers";

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



%Not sure why HeaderLines -> 0, but this way data is a table with
%column names read correctly
data = readtable(logfile_path, 'Delimiter', ',', 'HeaderLines', 0,'Format',data_format);
%Remove demo trials
filter = string(data.nro_bloque)=="0";
data(filter,:) = [];
data.nro_bloque = str2double(data.nro_bloque);

%times minus triggers
data.show_game_type = str2double(data.show_game_type);
data.show_outcome = str2double(data.show_outcome);
data.social_time = str2double(data.social_time);
data.rival = str2double(data.rival);
data.pay_competitive = str2double(data.pay_competitive);
data.show_question = str2double(data.show_question);


data.game_type_time = data.show_game_type + data.social_time - triggers;
data.outcome_time = data.show_outcome - triggers;
data.social_time = data.social_time - triggers;
data.show_game_time = data.show_game_type - triggers;
data.show_question = data.show_question - triggers;


%%%%%%%%%%%%%%%% ACA SE CARGAN LOS VOLUMENES %%%%%%%%%%%%%%
volumes = {};

for i=1:total_number_sessions
    volumes_session = {};
    patron_nii = strcat("swA_", string(i),"*.nii");
    pattern = fullfile(inputs_dir,patron_nii);
    files = dir(pattern);
    file_session = files(1);
    filename = file_session.name;
    for j = images_start:images_finish
        volume = strcat(inputs_dir, "/", filename, ",", string(j));
        volume_cell = char(volume);
        volumes_session{end+1} = volume_cell;
    end
    vertical_volumes = volumes_session';
    volumes{end+1} = vertical_volumes;
end

multi_regs = {};

for index_i=1:length(multis_files)
    file_data = multis_files(index_i);
    path = fullfile(file_data.folder, file_data.name);
    
    multi_regs{end+1} = {path};
end

triggers_paths = {};
onsets = {};
conditions_cell = {};
conditions_matrix = zeros(number_sessions, number_conditions);
whole_task = {};

matlabbatch{1}.spm.stats.fmri_spec.dir = {output_dir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2.5;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

for i=1:total_number_sessions
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).scans = volumes{i};
 %filter by block number, to split in sessions
    filter= data.nro_bloque==i;
    session = data(filter,:);   
    session.aparecen_opciones = session.show_game_time;
    session.tiempo_reacc_cat = session.social_time;
    session.aparece_resultado = session.outcome_time;
    session.aparecen_preguntas = session.show_question;
    %rename the outcome columns
    session.resultado_participante = session.outcome_competitive;
    session.resultado_jugador = session.outcome_rival;
    
    whole_task(i)={session};
  %con este loop se arma los regresores por trial  
    for j = 1:length(session.aparecen_opciones)
        onset = session.aparecen_opciones(j);
        duration = session.tiempo_reacc_cat(j);
        nro_condicion = j;
        name = ['decision' num2str(j,'%02d')];

        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).name = name;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).onset = onset;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).duration = duration;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).orth = 1;
    end
    
    
    tiempos_bb = session.aparece_resultado(string(session.resultado_participante)=="1" & string(session.resultado_jugador)=="1" & string(session.game_type)=="competitive");
    tiempos_bm = session.aparece_resultado(string(session.resultado_participante)=="1" & string(session.resultado_jugador)=="0" & string(session.game_type)=="competitive");
    tiempos_mb = session.aparece_resultado(string(session.resultado_participante)=="0" & string(session.resultado_jugador)=="1" & string(session.game_type)=="competitive");
    tiempos_mm = session.aparece_resultado(string(session.resultado_participante)=="0" & string(session.resultado_jugador)=="0" & string(session.game_type)=="competitive");
    

        nro_condicion = nro_condicion+1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).name = 'tiempos_bb';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).onset = tiempos_bb;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).duration = 3;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).orth = 1;
    
        nro_condicion = nro_condicion+1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).name = 'tiempos_bm';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).onset = tiempos_bm;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).duration = 3;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).orth = 1;
    
        nro_condicion = nro_condicion+1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).name = 'tiempos_mb';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).onset = tiempos_mb;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).duration = 3;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).orth = 1;
    
        nro_condicion = nro_condicion+1;
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).name = 'tiempos_mm';
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).onset = tiempos_mm;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).duration = 3;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).tmod = 0;
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).pmod = struct('name', {}, 'param', {}, 'poly', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).cond(nro_condicion).orth = 1;
    
    nro_condiciones{i} = {nro_condicion};
    
  %Sacar los valores 0 de las rondas que se saltearon 
    tiempos_bb_flat         = range(tiempos_bb)~=0;
    tiempos_bm_flat         = range(tiempos_bm)~=0;
    tiempos_mb_flat         = range(tiempos_mb)~=0;
    tiempos_mm_flat         = range(tiempos_mm)~=0;
    
    conditions_cell{i} = {tiempos_bb_flat,tiempos_bm_flat,tiempos_mb_flat,tiempos_mm_flat};
    
    
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi = {''};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).regress = struct('name', {}, 'val', {});
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).multi_reg = multi_regs{i};
    matlabbatch{1}.spm.stats.fmri_spec.sess(i).hpf = 128;
end



for k = 1:number_sessions
    for l = 1:number_conditions
        if conditions_cell{k}{l}~=0 & ~isempty(conditions_cell{k}{l});
            conditions_matrix(k,l)=1;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

contrastes = compute_contrastes_trial(nro_condiciones, whole_task);

nrows_contrastes = size(contrastes,1);

for index=1:nrows_contrastes
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.name = char(strcat('con_', string(index)));
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.weights = contrastes(index,:);
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.sessrep = 'none';
end
matlabbatch{3}.spm.stats.con.delete = 0;
save(fullfile(output_dir, "matlabbatch.mat"), 'matlabbatch');