%% 1. Define Paths based on your folder structure
baseIdrid = fullfile(pwd, 'data', 'raw', 'idrid', 'B. Disease Grading');

% Find images folder and groundtruth CSV automatically
trainImgDir = fullfile(baseIdrid, '1. Original Images', 'a. Training Set');
if ~exist(trainImgDir, 'dir')
    % Check alternative folder naming if slightly different
    trainImgDir = fullfile(baseIdrid, 'Original Images', 'Training Set');
end

csvDir = fullfile(baseIdrid, '2. Groundtruths');
if ~exist(csvDir, 'dir')
    csvDir = fullfile(baseIdrid, 'Groundtruths');
end

csvFiles = dir(fullfile(csvDir, '*Training*.csv'));
if isempty(csvFiles)
    csvFiles = dir(fullfile(csvDir, '*.csv'));
end
csvPath = fullfile(csvFiles(1).folder, csvFiles(1).name);

outputDir = fullfile(pwd, 'data', 'processed', 'idrid_train');

% 2. Create destination folders: 0, 1, 2, 3, 4
for grade = 0:4
    targetSub = fullfile(outputDir, num2str(grade));
    if ~exist(targetSub, 'dir')
        mkdir(targetSub);
    end
end

% 3. Read Labels and Sort Images
opts = detectImportOptions(csvPath);
opts.VariableNamingRule = 'preserve';
labelsTable = readtable(csvPath, opts);

disp('Sorting images into class folders (0 to 4)...');
count = 0;
for i = 1:height(labelsTable)
    imgName = string(labelsTable{i, 1});
    if ~endsWith(imgName, '.jpg', 'IgnoreCase', true)
        imgName = imgName + ".jpg";
    end

    grade = num2str(labelsTable{i, 2}); % Column 2 is the DR Retinopathy Grade

    src = fullfile(trainImgDir, char(imgName));
    dst = fullfile(outputDir, grade, char(imgName));

    if exist(src, 'file')
        copyfile(src, dst);
        count = count + 1;
    end
end

fprintf('Successfully organized %d images into %s\n', count, outputDir);