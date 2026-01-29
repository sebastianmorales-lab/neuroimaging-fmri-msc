contrastes = {
    'con_0001'
    'con_0002'
    'con_0003'
    'con_0004'
    'con_0005'
    'con_0006'
    'con_0007'
    'con_0008'
    'con_0009'
    'con_0010'
    'con_0011'
    'con_0012'
    'con_0013'
    };
labels1 = {
   'solo_onset_up'       %  1
   'rival_up'            %  2
   'pago_up'             %  3
   'preguntas_up'        %  4
   'compJB_grt_compJM'   %  5
   'cojB_grt_cojM'       %  6
   'BB_grt_BM'           %  7
   'BB_grt_MB'           %  8
   'BB_grt_MM'           %  9
   'BM_grt_MB'           %  10
   'BM_grt_MM'           %  11
   'MB_grt_MM'           %  12
   'interaccion_up'      %  13
   };
   
labels2 = {
   'solo_onset_dw'       %  1
   'rival_dw'            %  2
   'pago_dw'             %  3
   'preguntas_dw'        %  4
   'compJM_grt_compJB'   %  5
   'cojM_grt_cojB'       %  6
   'BM_grt_BB'           %  7
   'MB_grt_BB'           %  8
   'MM_grt_BB'           %  9
   'MB_grt_BM'           %  10
   'MM_grt_BM'           %  11
   'MM_grt_MB'           %  12
   'interaccion_dw'      %  13
   };


for i = 1:length(contrastes)
    contrast = contrastes(i);
    label1 = labels1(i);
    label2 = labels2(i);
    disp(contrast)
    [matlabbatch, design_dir] = second_level_parametric_question_job(contrast,label1,label2);
    spm_jobman('serial', matlabbatch);
    save(fullfile(design_dir, "matlabbatch.mat"), 'matlabbatch');
end
