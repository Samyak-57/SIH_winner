function reportPath = generate_report(patientName, patientID, scanDate, hba1c, rawImgPath, gradCamImgPath, severityText, lesionText, patientEmail)
% If patientEmail is not provided, default to your telemedicine email
if nargin < 9 || isempty(patientEmail)
    patientEmail = 'telemedicine.neuroforge@gmail.com';
end

% Figure create karein (Hidden window for fast background processing)
fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 650], 'Color', 'w');

% 1. Header Title
annotation('textarrow', [0.05 0.05], [0.94 0.94], 'String', 'NEUROFORGE DIAGNOSTICS – Diabetic Retinopathy Screening', ...
    'FontSize', 16, 'FontWeight', 'bold', 'Color', [0.07, 0.24, 0.40], 'HeadStyle', 'none', 'LineStyle', 'none');

% 2. Patient Info Table Bar (Top Section)
infoText = sprintf('  Name: %-18s | Patient ID: %-10s | Date of Scan: %-12s | HbA1c: %s  ', ...
    patientName, patientID, scanDate, hba1c);
annotation('textbox', [0.05, 0.84, 0.90, 0.06], 'String', infoText, ...
    'FontSize', 11, 'FontWeight', 'bold', 'BackgroundColor', [0.92, 0.94, 0.96], ...
    'EdgeColor', [0.75, 0.80, 0.85], 'VerticalAlignment', 'middle');

% 3. Raw Fundus Image Box (Left Side)
ax1 = axes('Position', [0.05, 0.28, 0.42, 0.50]);
if ~isempty(rawImgPath) && exist(rawImgPath, 'file')
    imshow(rawImgPath, 'Parent', ax1);
else
    rectangle('Position', [0 0 1 1], 'FaceColor', [0.95 0.95 0.95]);
end
title(ax1, 'Raw Image', 'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.5, -0.12, 0]);

% 4. AI Grad-CAM Analysis Box (Right Top)
ax2 = axes('Position', [0.53, 0.38, 0.42, 0.40]);
if ~isempty(gradCamImgPath) && exist(gradCamImgPath, 'file')
    imshow(gradCamImgPath, 'Parent', ax2);
else
    rectangle('Position', [0 0 1 1], 'FaceColor', [0.95 0.95 0.95]);
end
title(ax2, 'AI Grad-CAM Analysis', 'FontSize', 12, 'FontWeight', 'bold', 'Units', 'normalized', 'Position', [0.5, -0.15, 0]);

% 5. Severity Level & Lesion Count Box (Right Bottom)
severityBoxText = sprintf('Severity Level: %s\n\nLesion Count / Clinical Details: %s', severityText, lesionText);
annotation('textbox', [0.53, 0.14, 0.42, 0.16], 'String', severityBoxText, ...
    'FontSize', 11, 'FontWeight', 'bold', 'BackgroundColor', [0.88, 0.91, 0.94], ...
    'EdgeColor', [0.75, 0.80, 0.85]);

% 6. Footer Disclaimer
annotation('textbox', [0.05, 0.02, 0.90, 0.05], ...
    'String', 'Confidential Disclaimer: NeuroForge Diagnostics report generated for clinical decision support. Final diagnosis must be confirmed by a certified ophthalmologist.', ...
    'FontSize', 8, 'Color', [0.4 0.4 0.4], 'EdgeColor', 'none');

% High Resolution PNG export
reportPath = 'NeuroForge_Diagnostic_Report.png';
exportgraphics(fig, reportPath, 'Resolution', 300);
close(fig);

% --- 7. AUTOMATED EMAIL SENDING SECTION ---
subject = sprintf('NeuroForge Diagnostic Report - Patient ID: %s', patientID);
bodyText = sprintf('Dear %s,\n\nAttached is your Diabetic Retinopathy screening diagnostic report.\nSeverity Level: %s\n\nRegards,\nNeuroForge Telemedicine Team', patientName, severityText);

% Python script trigger command
cmd = sprintf('python send_mail.py "%s" "%s" "%s" "%s"', patientEmail, subject, bodyText, reportPath);
[status, cmdout] = system(cmd);

if status == 0 && contains(cmdout, 'SUCCESS')
    disp('✅ Report generated and sent via Email successfully!');
else
    disp(['❌ Email sending failed: ', cmdout]);
end

end