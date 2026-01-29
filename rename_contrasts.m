%function [] = rename_contrasts(participant_folder, trigger_id)

data_format = "%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q%q";

logfiles = "/media/usuario/Expansion/maestria_task/tmp/rawdata";
second_level = "/media/usuario/Expansion/maestria_task/tmp/FMRI/Second_level_parametric";
triggers_dir = "/media/usuario/Expansion/maestria_task/tmp/trigger";
base_dir = '/media/usuario/Expansion/maestria_task/tmp/FMRI/First_level_parametric';

participants_list = '/media/usuario/Expansion/maestria_task/tmp/FMRI/participants.csv';
data_participants = readtable(participants_list);
    
trigger_ids = data_participants.trigger_id;
for i = 1:length(trigger_ids)
    trigger_id = trigger_ids{i};
    disp(['participant id: ' trigger_id]);

    participant_folder = ['' trigger_id];

    CONTRASTE_LABEL = 1;
    CONTRASTE_VALUES = 2;
    repMB = 4;
    repIndB = 4;
    repIndM = 4;
    posicionMB = zeros(1,4);
    posicionIndB = zeros(1,4);
    posicionIndM = zeros(1,4);

    n_blocks = 4;
    trials_per_block = 32;

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
        for index_j=5:252
            scans_session{end+1} = char(strcat(path, ",", string(index_j)));
        end
        scans{end+1} = scans_session';
    end

    for index_i=1:length(multis_files)
        file_data = multis_files(index_i);
        path = fullfile(file_data.folder, file_data.name);

        multi_regs{end+1} = {path};
    end

    files = dir(fullfile(logfiles, strcat(trigger_id,"*csv")));
    if length(files)<=0
        continue
    end
    file = files(1);
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

    for i_block=1:n_blocks
        if length(outcomes_competitive_mb{i_block}.outcome_time)==0
            posicionMB(i_block) = 1;
            repMB = repMB -1;
        end

        if length(outcomes_individual_b{i_block}.outcome_time)==0
            posicionIndB(i_block) = 1;
            repIndB = repIndB -1;
        end

        if length(outcomes_individual_m{i_block}.outcome_time)==0
            posicionIndM(i_block) = 1; 
            repIndM = repIndM -1;
        end
    end

    contrastes_computed = compute_contrastes_parametric_maestria(choice_individual_blocks,outcomes_individual_b, outcomes_individual_m, repMB, repIndB, repIndM,posicionMB, posicionIndB, posicionIndM);
    contrastes_filtered = contrastes_computed{1};
    all_contrastes = contrastes_computed{2};

    labels = {};
    for i = 1:length(contrastes_filtered)
        labels{end+1} = contrastes_filtered{i}{1};
    end

    folder = dir(fullfile(second_level,'participantes', participant_folder, 'niftii'))';

    contrast_count = length(contrastes_filtered);
    if contrast_count==20
        continue
    end
    for i = length(all_contrastes):-1:1
        label = all_contrastes{i}{1};

        if find(strcmp(labels,label))
            old_filename = sprintf('con_%0.4d.nii', contrast_count);
            new_filename = sprintf('con_%0.4d.nii', i);            
            old_path = fullfile(second_level, 'participantes',participant_folder, 'niftii', old_filename);
            new_path = fullfile(second_level, 'participantes',participant_folder, 'niftii', new_filename);            

            disp("--------------");
            disp(label);
%            disp(old_path);
%            disp(new_path);
            
            if old_path == new_path
                contrast_count = contrast_count - 1;
                continue
            end
            
%            disp(sprintf("%s <..> %s", old_filename, new_filename));
            
            if exist(old_path) == 0
%                disp("++++");
                contrast_count = contrast_count - 1;
                continue
            end
            
            movefile(old_path, new_path);

            
            contrast_count = contrast_count - 1;
        else
 %         disp("**** not found ***");
 %:n
 :q
 disp(label);          
        end

    end
end
