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
    };
labels1 = {
   'solo_onset_up'       %  1
   'rival_up'            %  2
   'pago_up'             %  3
   'compJB_grt_compJM'   %  4
   'cojB_grt_cojM'       %  5
   'BB_grt_BM'           %  6
   'BB_grt_MB'           %  7
   'BB_grt_MM'           %  8
   'BM_grt_MB'           %  9
   'BM_grt_MM'           %  10
   'MB_grt_MM'           %  11
   'interaccion_up'      %  12
   };
   
labels2 = {
   'solo_onset_dw'       %  1
   'rival_dw'            %  2
   'pago_dw'             %  3
   'compJM_grt_compJB'   %  4
   'cojM_grt_cojB'       %  5
   'BM_grt_BB'           %  6
   'MB_grt_BB'           %  7
   'MM_grt_BB'           %  8
   'MB_grt_BM'           %  9
   'MM_grt_BM'           %  10
   'MM_grt_MB'           %  11
   'interaccion_dw'      %  12
   };


for i = 1:length(contrastes)
    contrast = contrastes(i);
    label1 = labels1(i);
    label2 = labels2(i);
    disp(contrast)
    [matlabbatch, design_dir] = second_level_parametric_2_job(contrast,label1,label2);
    spm_jobman('serial', matlabbatch);
    save(fullfile(design_dir, "matlabbatch.mat"), 'matlabbatch');
end
