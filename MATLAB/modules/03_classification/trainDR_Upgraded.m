% 1. Load Sorted Dataset
dataDir = 'APTOS_Data';
imds = imageDatastore(dataDir, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% 80% Training, 20% Validation Split
[imdsTrain, imdsVal] = splitEachLabel(imds, 0.8, 'randomized');

% 2. Calculate Class Weights (Fixes Class Imbalance)
tbl = countEachLabel(imdsTrain);
totalImages = sum(tbl.Count);
classWeights = totalImages ./ (height(tbl) * tbl.Count);
classWeights = classWeights'; % Convert to row vector

% 3. Set Up Data Augmentation (Prevents Overfitting)
augmenter = imageDataAugmenter( ...
    'RandRotation', [-30 30], ...
    'RandXReflection', true, ...
    'RandYReflection', true, ...
    'RandScale', [0.85 1.15]);

% Apply augmentation and resize to 224x224
augimdsTrain = augmentedImageDatastore([224 224], imdsTrain, ...
    'DataAugmentation', augmenter, ...
    'ColorPreprocessing', 'gray2rgb');

augimdsVal = augmentedImageDatastore([224 224], imdsVal, ...
    'ColorPreprocessing', 'gray2rgb');

% 4. Load & Modify Pretrained ResNet-18
net = resnet18;
lgraph = layerGraph(net);

numClasses = numel(categories(imdsTrain.Labels));

% Replace Fully Connected Layer
newFCLayer = fullyConnectedLayer(numClasses, 'Name', 'new_fc', ...
    'WeightLearnRateFactor', 10, 'BiasLearnRateFactor', 10);
lgraph = replaceLayer(lgraph, 'fc1000', newFCLayer);

% Replace Classification Layer with Weighted Loss
newClassLayer = classificationLayer('Name', 'new_classoutput', ...
    'Classes', categories(imdsTrain.Labels), ...
    'ClassWeights', classWeights);
lgraph = replaceLayer(lgraph, 'ClassificationLayer_predictions', newClassLayer);

% 5. Optimized Training Settings
options = trainingOptions('adam', ... % ADAM optimizer converges faster
    'MiniBatchSize', 16, ...          % Smaller batch size improves generalization on small datasets
    'MaxEpochs', 12, ...               % 12 epochs provides a solid balance of accuracy vs compute time
    'InitialLearnRate', 3e-4, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropPeriod', 4, ...
    'LearnRateDropFactor', 0.2, ...
    'ValidationData', augimdsVal, ...
    'ValidationFrequency', 15, ...
    'Plots', 'training-progress', ...
    'Verbose', false);

% 6. Train Network & Save
disp('Training optimized model with Class Weighting & Augmentation...');
trainedNet = trainNetwork(augimdsTrain, lgraph, options);

save('DR_TrainedModel.mat', 'trainedNet');
disp('Optimized Model Saved Successfully as DR_TrainedModel.mat!');