csvData = readtable('train.csv');

if ~exist('APTOS_Data','dir')
    mkdir('APTOS_Data');
end

for k = 0:4
    folder = fullfile('APTOS_Data',num2str(k));
    if ~exist(folder,'dir')
        mkdir(folder);
    end
end

files = dir(fullfile('new1','*.png'));

disp('Sorting remaining images...');
for i = 1:length(files)
    name = erase(files(i).name,'.png');
    row = strcmp(string(csvData.id_code), name);
    
    if any(row)
        label = csvData.diagnosis(find(row,1));
        source = fullfile('new1',files(i).name);
        destination = fullfile('APTOS_Data',num2str(label),files(i).name);
        
        % Using movefile is instant
        movefile(source, destination);
    end
end
disp('ALL IMAGES SORTED SUCCESSFULLY!');