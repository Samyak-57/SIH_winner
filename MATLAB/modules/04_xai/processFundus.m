function [enhancedImg, isGradeable, statusMsg] = processFundus(imagePath)
    % 1. Read Image
    img = imread(imagePath);
    
    % Ensure image is double precision for filtering calculations
    imgDouble = im2double(img);
    
    % 2. Quality Check: Blur Detection via Laplacian Variance
    if size(imgDouble, 3) == 3
        grayImg = rgb2gray(imgDouble);
    else
        grayImg = imgDouble;
    end
    
    lapFilter = [0 1 0; 1 -4 1; 0 1 0];
    lapImg = filter2(lapFilter, grayImg);
    blurScore = var(double(lapImg(:))); % Cast to double prevents type error
    
    % Blur thresholding
    if blurScore < 0.0001
        isGradeable = false;
        statusMsg = 'REJECTED: Image too blurry or low quality.';
        enhancedImg = [];
        return;
    else
        isGradeable = true;
        statusMsg = 'PASSED: Image quality approved for AI evaluation.';
    end
    
    % 3. Contrast Enhancement via CLAHE (Green Channel)
    if size(img, 3) == 3
        gChannel = img(:,:,2); % Extract green channel for microaneurysm contrast
        enhancedG = adapthisteq(gChannel, 'ClipLimit', 0.03, 'Distribution', 'rayleigh');
        enhancedImg = img;
        enhancedImg(:,:,2) = enhancedG;
    else
        enhancedImg = adapthisteq(img);
    end
end