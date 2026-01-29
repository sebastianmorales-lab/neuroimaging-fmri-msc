function [matlabbatch] = first_level_job_custom(inputs_dir, output_dir, comportamental_dir, total_number_sessions)
%total_number_sessions = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DATA MASSAGE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
images_start = 5; %primer imagen del first level
images_finish = 258; % ultima imagen del first
number_sessions = 4;
number_conditions = 4; % numero de regresores, sin contar los de movimiento, ni los  que voy a sacar trial a trial

% files = dir(pattern);
% file_session = files(1);
% filename = file_session.name;

volumes = {};

for i=1:total_number_sessions
    volumes_session = {};
    pattern = strcat(inputs_dir, "/", "swA_", string(i),"_","*.nii");
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

for i=1:total_number_sessions
    pattern = strcat(inputs_dir, "/", "rp_A_", string(i),"_","*.txt");
    files = dir(pattern);
    file_session = files(1);
    filename = file_session.name;
    multi_regs{end+1} = {char(strcat(inputs_dir, "/", filename))};
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
    
    session = dir(fullfile(comportamental_dir, ['*' num2str(i) '_team2trivia' '*']));
    session = readtable(fullfile(comportamental_dir,session.name));
    
    session.tiempo_reacc_cat=str2double(string(session.tiempo_reacc_cat));
    session = session(~isnan(session.tiempo_reacc_cat),:);
    session.aparece_resultado=str2double(string(session.aparece_resultado));
    
    trigger = dir(fullfile(comportamental_dir, ['*' num2str(i) '_trigger' '*']));
    trigger = readtable(fullfile(comportamental_dir,trigger.name));
    trigger = table2array(trigger(4,1));
    
    session.aparecen_opciones = session.aparecen_opciones - trigger;
    session.aparece_resultado = session.aparece_resultado - trigger;
    
    whole_task(i)={session};
    
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
    
    tiempos_bb = session.aparece_resultado((string(session.resultado_participante)=="1") & string(session.resultado_jugador)=="1");
    tiempos_bm = session.aparece_resultado((string(session.resultado_participante)=="1") & string(session.resultado_jugador)=="0");
    tiempos_mb = session.aparece_resultado((string(session.resultado_participante)=="0") & string(session.resultado_jugador)=="1");
    tiempos_mm = session.aparece_resultado((string(session.resultado_participante)=="0") & string(session.resultado_jugador)=="0");
    
    
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

contrastes = compute_contrastes(nro_condiciones, whole_task);

nrows_contrastes = size(contrastes,1);

for index=1:nrows_contrastes
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.name = char(strcat('con_', string(index)));
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.weights = contrastes(index,:);
  matlabbatch{3}.spm.stats.con.consess{index}.tcon.sessrep = 'none';
end
matlabbatch{3}.spm.stats.con.delete = 0;
save(fullfile(output_dir, "matlabbatch.mat"), 'matlabbatch');