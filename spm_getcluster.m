function [Cmm, Cvox, C0] = spm_getcluster(X,Y,Z,SPM,xSDM)
% Extracts a list of voxels (in mm and in voxel space) of the cluster centered in XYZ for a given contrast
% Use [Cmm,Cvox] = spm_getcluster(X,Y,Z,SPM,xSDM);

% Find it in SPM.XYZmm
index = find(SPM.XYZmm(1,:)==X & SPM.XYZmm(2,:)==Y & SPM.XYZmm(3,:)==Z);
C0 = [X;Y;Z];
if isempty(index)
disp('Voxel not found!, moving to closest voxel');
[xyz,d] = spm_XYZreg('RoundCoords',[X,Y,Z],xSDM.M,xSDM.DIM)
C0 = xyz;
index = find(SPM.XYZmm(1,:)==xyz(1) & SPM.XYZmm(2,:)==xyz(2) & SPM.XYZmm(3,:)==xyz(3));
end

clustid = spm_clusters(SPM.XYZ);

i = clustid(index);
clustXYZ = find(clustid==i);

Cmm = SPM.XYZmm(:,clustXYZ);
Cvox = SPM.XYZ(:,clustXYZ);

