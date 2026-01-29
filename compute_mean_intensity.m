function [mean_intensity,std_intensity] = compute_mean_intensity(center, contrast, participants_directory);

participants = dir(fullfile(participants_directory, 'SUJETO_*'));
intensities = [];
for i = 1:numel(participants)
    path = fullfile(participants_directory, participants(i).name,'niftii' ,contrast);
    if ~ exist(path, 'file')
        continue
    end
    participant_intensities = compute_intensities(center, path);
    intensities = [intensities participant_intensities];
end

mean_intensity = mean(intensities);
std_intensity = std(intensities);
