function [vector_intensity] = compute_intensities(center, contrast);

%definir parametros
r=5;                      % radio de la esfera
% coord_set={[38 -6 -8]};   %coord. center of the sphere
% region='putamen';

%levantar los contrastes de la carpeta Fist_level
%contraste = fullfile('/media/usuario/seagate/competition_task/FMRI/First_level_parametric', participant, '/niftii', contrast);

%Generar la esfera
[M] = spm_get_space(contrast);      % matrix to transform from mm to voxels
iM = inv(M);

x0=center(1);
y0=center(2);
z0=center(3);

matriz_coord_mm = [];

x_run=[x0-r:1:x0+r];
y_run=[y0-r:1:y0+r];
z_run=[z0-r:1:z0+r];

%Ver que no este tomando puntos fuera de la esfera

s=1;
for k=1:length(z_run) %construye esfera con coordenadas
    
    for j=1:length(y_run)
        
        for i=1:length(x_run)
            x=x_run(i);
            y=y_run(j);
            z=z_run(k);
            dist=sqrt((x-x0)^2+(y-y0)^2+(z-z0)^2);
            
            if dist<=r
                
                matriz_coord_mm(s,:)=[x,y,z]; %matriz donde cada fila es un punto en mm adentro de la esfera
                s=s+1;
                
            end
        end
    end
end

%Convertir de mm a voxels
matriz_coord_vox = [];
for i=1:length(matriz_coord_mm(:,1))   
    coord_mm = [matriz_coord_mm(i,1) matriz_coord_mm(i,2) matriz_coord_mm(i,3)];          % x,y,z co-ordinates
    coord_vox = iM * [coord_mm 1]';
    coord_vox = coord_vox(1:3)';    % coordinates in voxel space
    coord_vox = int16(coord_vox);
    matriz_coord_vox(i,:)=coord_vox;
end

%Ver que no tome puntos repetidos
s=1;

for i=1:length(matriz_coord_vox(:,1))                   %check that there are not repeted voxels
    
    u=0;
    j=0;
    
    while u==0
        
        j=j+1;
        
        if j==i;
            
            matriz_coord_vox_corr(s,:)=matriz_coord_vox(i,:);
            s=s+1;
            u=1;
            
        else
            
            if matriz_coord_vox(i,1)==matriz_coord_vox(j,1) && matriz_coord_vox(i,2)==matriz_coord_vox(j,2) && matriz_coord_vox(i,3)==matriz_coord_vox(j,3)
                u=1;
            end
        end
    end
end

%Verificar que no hayan coordenadas repetidas en voxels
matriz_coord_vox_corr = [];

s=1;

for i=1:length(matriz_coord_vox(:,1))                   
    
    u=0;
    j=0;
    
    while u==0
        
        j=j+1;
        
        if j==i;
            
            matriz_coord_vox_corr(s,:)=matriz_coord_vox(i,:);
            s=s+1;
            u=1;
            
        else
            
            if matriz_coord_vox(i,1)==matriz_coord_vox(j,1) && matriz_coord_vox(i,2)==matriz_coord_vox(j,2) && matriz_coord_vox(i,3)==matriz_coord_vox(j,3)
                u=1;
            end
        end
    end
end

vector_intensity=[];
s=1;
%levantar las intensidades de los voxels
V = spm_vol(contrast);                     %reads the volume
[I,XYZ] = spm_read_vols(V);     %from the volume gets a matriz (I) where every component is the intensity of a voxel

for i=1:length(matriz_coord_vox_corr(:,1))
    
    x_vox=matriz_coord_vox_corr(i,1);
    y_vox=matriz_coord_vox_corr(i,2);
    z_vox=matriz_coord_vox_corr(i,3);
    
    if I(x_vox,y_vox,z_vox)==0 || I(x_vox,y_vox,z_vox)> 0 || I(x_vox,y_vox,z_vox)< 0
        vector_intensity(s)= I(x_vox,y_vox,z_vox);             %get the intensity for the voxel
        s=s+1;
    end
    
end
