function [Cmm, Cvox, C0] = spm_getcluster(X,Y,Z,xSPM)
% Extracts a list of voxels (in mm and in voxel space) of the cluster centered in XYZ for a given contrast
% Use [Cmm,Cvox] = spm_getcluster(X,Y,Z,SPM,xSDM);

% Find it in SPM.XYZmm
index = find(xSPM.XYZmm(1,:)==X & xSPM.XYZmm(2,:)==Y & xSPM.XYZmm(3,:)==Z);
C0 = [X;Y;Z];
if isempty(index)
disp('Voxel not found!, moving to closest voxel');
[xyz,d] = spm_XYZreg('RoundCoords',[X,Y,Z],xSPM.M,xSPM.DIM)
C0 = xyz;
index = find(xSPM.XYZmm(1,:)==xyz(1) & xSPM.XYZmm(2,:)==xyz(2) & xSPM.XYZmm(3,:)==xyz(3));
end

clustid = spm_clusters(xSPM.XYZ);

i = clustid(index);
clustXYZ = find(clustid==i);

Cmm = xSPM.XYZmm(:,clustXYZ);
Cvox = xSPM.XYZ(:,clustXYZ);

