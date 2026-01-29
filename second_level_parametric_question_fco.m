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
    'con_0014'
    'con_0015'
    'con_0016'
    'con_0017'
    'con_0018'
    'con_0019'
    'con_0020'
    };
labels1 = {
   'comp_onset_up'       %  1
   'comp_rival_up'       %  2
   'comp_pago_up'        %  3
   'indv_onset_up'       %  4
   'indv_rival_up'       %  5
   'indv_pago_up'        %  6
   'preguntas_up'        %  7
   'compJB_grt_compJM'   %  8
   'cojB_grt_cojM'       %  9
   'BB_grt_BM'           %  10
   'BB_grt_MB'           %  11
   'BB_grt_MM'           %  12
   'BM_grt_MB'           %  13
   'BM_grt_MM'           %  14
   'MB_grt_MM'           %  15
   'interaccion_up'      %  16
   'BB_up'               %  17
   'BM_up'               %  18
   'MB_up'               %  19
   'MM_up'               %  20
   };
   
labels2 = {
   'comp_onset_dw'       %  1
   'comp_rival_dw'       %  2
   'comp_pago_dw'        %  3
   'indv_onset_dw'       %  4
   'indv_rival_dw'       %  5
   'indv_pago_dw'        %  6
   'preguntas_dw'        %  7
   'compJM_grt_compJB'   %  8
   'cojM_grt_cojB'       %  9
   'BM_grt_BB'           %  10
   'MB_grt_BB'           %  11
   'MM_grt_BB'           %  12
   'MB_grt_BM'           %  13
   'MM_grt_BM'           %  14
   'MM_grt_MB'           %  15
   'interaccion_dw'      %  16
   'BB_dw'               %  17
   'BM_dw'               %  18
   'MB_dw'               %  19
   'MM_dw'               %  20
   };


for i = 1:length(contrastes)
    contrast = contrastes(i);
    label1 = labels1(i);
    label2 = labels2(i);
    disp(contrast)
    [matlabbatch, design_dir] = second_level_parametric_question_job_fco(contrast,i,label1,label2);
    spm_jobman('serial', matlabbatch);
    save(fullfile(design_dir, "matlabbatch.mat"), 'matlabbatch');
end
