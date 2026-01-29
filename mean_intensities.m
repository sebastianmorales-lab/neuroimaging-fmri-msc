function[output]=mean_intensities(contrasts,coords_mm)
%contrasts = {'con_0001.nii' 'con_0002.nii'};
%all_coords_mm = {[38 -6 -8]};

r_mm = 5;
max_mm = [r_mm r_mm r_mm];

first_level_dir = "/media/sebastian/Expansion/maestria_task/FMRI/First_level_trial";

folders = dir(fullfile(first_level_dir, "SUJETO*"))';
%folders = {struct('name', 'participante_012') struct('name', 'participante_429')}';

contrast_column = [];
output = table();
for contrast=contrasts
    for folder=folders
        participant = folder.name;
        disp(participant);

        archivo = char(fullfile(first_level_dir, participant, strcat(contrast, ".nii")));

        [pathArchivo,nombreArchivo,extensionArchivo] = fileparts(archivo);
        [M] = spm_get_space(archivo);
        iM=inv(M);
        V = spm_vol(archivo);
        [Y,XYZ] = spm_read_vols(V); 

        coords = iM * [coords_mm 1]';
        coords = coords(1:3)';
        %coords = int16(coords);

        x0 = coords(1);
        y0 = coords(2);
        z0 = coords(3);

        limits = iM * [max_mm 0]';
        max_vox = ceil(abs(limits(1:3)'));
        a = max_vox(1);
        b = max_vox(2);
        c = max_vox(3);

        bubble = {};

        for dx=-a:a
            for dy=-b:b
                for dz=-c:c
                    dist = sqrt((dx/a)^2+(dy/b)^2+(dz/c)^2);
                    if dist<=1
                        x = x0 + dx;
                        y = y0 + dy;
                        z = z0 + dz;
                        bubble{end+1}=[x,y,z];
                    end  
                end
            end
        end

        intensities = [];

        for index=1:length(bubble)
          voxel = bubble{index};
          x = voxel(1);
          y = voxel(2);
          z = voxel(3);
          intensity = Y(x,y,z);
          if isnan(intensity)
            continue
          end
          intensities(end+1) = intensity;
        end

        mean_intensity = mean(intensities);
        output = [output; {string(participant) string(contrast) mean_intensity}];
    end
end

output.Properties.VariableNames = {'codigo' 'contrast' char(strcat('mean_',replace(strjoin(string(coords_mm),'_'),'-','_')))};
