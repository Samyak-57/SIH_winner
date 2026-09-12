%% organize_combined_dataset.m
clear; clc;

% Define Paths
aptosImgDir = fullfile(pwd, 'data', 'raw', 'aptos', 'train_images');
aptosCsv    = fullfile(pwd, 'data', 'raw', 'aptos', 'train.csv');
combinedDir = fullfile(pwd, 'data', 'processed', 'combined_train');
idridDir    = fullfile(pwd, 'data', 'processed', 'idrid_train');

% 1. Create combined severity folders (0 to 4)
for grade = 0:4
    targetFolder = fullfile(combinedDir, num2str(grade));
    if ~exist(targetFolder, 'dir')
        mkdir(targetFolder);
    end
end

% 2. Process and Sort APTOS Data
disp('Parsing APTOS 2019 dataset...');
opts = detectImportOptions(aptosCsv);
opts.VariableNamingRule = 'preserve';
aptosData = readtable(aptosCsv, opts);

countAptos = 0;
for i = 1:height(aptosData)
    % APTOS CSV does not include the .png extension
    imgName = string(aptosData{i, 1}) + ".png"; 
    grade = num2str(aptosData{i, 2});

    srcPath = fullfile(aptosImgDir, char(imgName));
    dstPath = fullfile(combinedDir, grade, char(imgName));

    if exist(srcPath, 'file')
        copyfile(srcPath, dstPath);
        countAptos = countAptos + 1;
    end
end
fprintf('Copied %d APTOS images.\n', countAptos);

% 3. Merge Existing IDRiD Data
disp('Merging IDRiD dataset...');
for grade = 0:4
    srcFolder = fullfile(idridDir, num2str(grade), '*.*');
    dstFolder = fullfile(combinedDir, num2str(grade));

    % Copy all files from the IDRiD grade folder to the Combined grade folder
    copyfile(srcFolder, dstFolder);
end

disp('Datasets successfully merged into data/processed/combined_train/');
