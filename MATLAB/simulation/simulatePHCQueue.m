% =========================================================================
% SIMULATION: Rural PHC Workflow (Traditional vs AI Triage)
% =========================================================================
clear; clc; close all;

% System Parameters (in minutes)
numPatients = 50;
seed = 42; rng(seed);

% Patient Inter-arrival times (Exponential distribution, mean = 10 mins)
interArrivalTimes = exprnd(10, [numPatients, 1]);
arrivalTimes = cumsum(interArrivalTimes);

% Process 1: Fundus Image Capture (Mean = 3 mins, Normal distribution)
captureTime = normrnd(3, 0.5, [numPatients, 1]);
captureTime = max(0.5, captureTime); % Floor to min 30 sec

% Process 2A: Manual Doctor Diagnostic Latency (Mean = 150 mins)
manualDiagnosisLatency = exprnd(150, [numPatients, 1]);

% Process 2B: AI Edge Diagnostic Latency (Mean = 0.05 mins / 3 seconds)
aiDiagnosisLatency = normrnd(0.05, 0.01, [numPatients, 1]);
aiDiagnosisLatency = max(0.01, aiDiagnosisLatency);

% -------------------------------------------------------------------------
% 1. Simulate Traditional Manual Workflow Queue
% -------------------------------------------------------------------------
manualWaitTimes = zeros(numPatients, 1);
manualTotalTimes = zeros(numPatients, 1);
doctorFreeTime = 0;

for i = 1:numPatients
    captureEnd = arrivalTimes(i) + captureTime(i);
    serviceStart = max(captureEnd, doctorFreeTime);
    manualWaitTimes(i) = serviceStart - arrivalTimes(i);
    doctorFreeTime = serviceStart + manualDiagnosisLatency(i);
    manualTotalTimes(i) = doctorFreeTime - arrivalTimes(i);
end

% -------------------------------------------------------------------------
% 2. Simulate AI Triage Workflow Queue
% -------------------------------------------------------------------------
aiWaitTimes = zeros(numPatients, 1);
aiTotalTimes = zeros(numPatients, 1);
aiSystemFreeTime = 0;

for i = 1:numPatients
    captureEnd = arrivalTimes(i) + captureTime(i);
    serviceStart = max(captureEnd, aiSystemFreeTime);
    aiWaitTimes(i) = serviceStart - arrivalTimes(i);
    aiSystemFreeTime = serviceStart + aiDiagnosisLatency(i);
    aiTotalTimes(i) = aiSystemFreeTime - arrivalTimes(i);
end

% -------------------------------------------------------------------------
% 3. Calculate Key Impact Metrics
% -------------------------------------------------------------------------
avgManualWait = mean(manualTotalTimes);
avgAIWait = mean(aiTotalTimes);
reductionPercent = ((avgManualWait - avgAIWait) / avgManualWait) * 100;

fprintf('====================================================\n');
fprintf('  RURAL PHC PATIENT WAIT-TIME SIMULATION RESULTS    \n');
fprintf('====================================================\n');
fprintf('Traditional System Avg Turnaround: %.1f minutes\n', avgManualWait);
fprintf('AI-Powered System Avg Turnaround : %.1f minutes\n', avgAIWait);
fprintf('Total Patient Wait Time Saved    : %.1f%%\n', reductionPercent);
fprintf('====================================================\n');

% -------------------------------------------------------------------------
% 4. Generate Visual Proof Graphs for Hackathon Submission
% -------------------------------------------------------------------------
figure('Name', 'PHC Queue System Performance', 'Position', [100 100 1000 450]);

% Plot 1: Individual Patient Turnaround Time Comparison
subplot(1,2,1);
plot(1:numPatients, manualTotalTimes, '-o', 'Color', [0.8 0.2 0.2], 'LineWidth', 1.5, 'DisplayName', 'Traditional Manual Workflow');
hold on;
plot(1:numPatients, aiTotalTimes, '-s', 'Color', [0.1 0.6 0.2], 'LineWidth', 2, 'DisplayName', 'Proposed AI Edge Triage');
grid on;
title('Patient Turnaround Time per Visit', 'FontSize', 11, 'FontWeight', 'bold');
xlabel('Patient Arrival Index');
ylabel('Total Time in Clinic (Minutes)');
legend('Location', 'northwest');

% Plot 2: Average Wait Time Impact Bar Chart
subplot(1,2,2);
b = bar([avgManualWait, avgAIWait], 'FaceColor', 'flat');
b.CData(1,:) = [0.8 0.2 0.2]; % Red for manual
b.CData(2,:) = [0.1 0.6 0.2]; % Green for AI
grid on;
set(gca, 'XTickLabel', {'Manual Tele-consult', 'AI Edge Triage'});
ylabel('Average Wait Time (Minutes)');
title('Mean System Latency Reduction', 'FontSize', 11, 'FontWeight', 'bold');

% Add Data Labels on Bars
text(1, avgManualWait + 10, sprintf('%.1f min', avgManualWait), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(2, avgAIWait + 10, sprintf('%.1f min', avgAIWait), 'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'Color', [0 0.4 0]);