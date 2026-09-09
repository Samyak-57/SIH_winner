% =========================================================================
% SCRIPT 3: Explainability Hub & Automated Clinical Report (generateReport.m)
% =========================================================================

% 1. Load Trained Model
if exist('DR_TrainedModel.mat', 'file')
    load('DR_TrainedModel.mat', 'trainedNet');
else
    error('DR_TrainedModel.mat not found. Run Script 2 first!');
end

% 2. Specify Test Image File Name
% Make sure this image is uploaded to your left-hand Files panel

% WITH THIS FILE PICKER:
% 2. Dynamic File Selection
[fileName, filePath] = uigetfile({'*.png;*.jpg;*.jpeg', 'Image Files'}, 'Select Patient Fundus Scan');
if isequal(fileName, 0)
    disp('No image selected. Evaluation cancelled.');
    return;
end
testImageFile = fullfile(filePath, fileName);

if ~exist(testImageFile, 'file')
    error('Test image %s not found in workspace Files panel!', testImageFile);
end

% 3. Run Quality Gatekeeper (Script 1: processFundus)
[enhancedImg, isGradeable, statusMsg] = processFundus(testImageFile);
disp(statusMsg);

if isGradeable
    % Resize image to match ResNet-18 input specs (224x224x3)
    resizedImg = imresize(enhancedImg, [224 224]);
    if isa(resizedImg, 'double') || isa(resizedImg, 'single')
        resizedImg = im2uint8(resizedImg);
    end

    % 4. Classify Severity
    [predClass, scores] = classify(trainedNet, resizedImg);
    confidence = max(scores) * 100;
    gradeNumeric = str2double(char(predClass));

    % Check Referral Triage (Level 2+ is Referable)
    if gradeNumeric >= 2
        triageStatus = 'REFERABLE DR (Urgent Referral Required)';
        statusColor = [0.8 0 0]; % Red text
    else
        triageStatus = 'NON-REFERABLE (Routine Annual Check)';
        statusColor = [0 0.5 0]; % Green text
    end

    % 5. Generate Grad-CAM Heatmap
    layerName = 'res5b_relu'; 
    try
        scoreMap = gradCAM(trainedNet, resizedImg, predClass, 'FeatureLayer', layerName);
    catch
        % Fallback auto-detection if layer graph differs
        scoreMap = gradCAM(trainedNet, resizedImg, predClass);
    end

    % 6. Render 30-Second Doctor Verification Report
    figure('Name', 'Automated DR Clinical Report', 'Position', [100 100 900 450]);

    % Subplot 1: Enhanced Fundus Photo
    subplot(1,2,1);
    imshow(resizedImg);
    title('Enhanced Patient Fundus Image', 'FontSize', 11, 'FontWeight', 'bold');

    % Subplot 2: Grad-CAM Overlay
    subplot(1,2,2);
    imshow(resizedImg);
    hold on;
    h = imagesc(scoreMap);
    set(h, 'AlphaData', 0.45); % Translucent heatmap overlay
    colormap jet;
    colorbar;
    title(sprintf('Grad-CAM Heatmap\nPredicted Level: %d | Grade: %s', gradeNumeric, char(predClass)), ...
        'FontSize', 11, 'FontWeight', 'bold');
    hold off;

    % Clinical Summary Label
    annotation('textbox', [0.15 0.02 0.7 0.08], 'String', ...
        sprintf('Triage Result: %s | AI Confidence: %.1f%%', triageStatus, confidence), ...
        'FontSize', 12, 'FontWeight', 'bold', 'LineStyle', 'none', ...
        'HorizontalAlignment', 'center', 'TextColor', statusColor);

    disp('Clinical Report Generated Successfully!');
end