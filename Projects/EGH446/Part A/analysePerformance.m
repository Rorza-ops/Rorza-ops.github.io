close all
%clc


%Mission Time
minutes = floor(Ts(end) / 60);
seconds = rem(Ts(end), 60);
fprintf('Mission Time Taken: %d minutes and %.0f seconds\n', minutes, seconds);

%Mean capture error
meanCapError = mean(captureErrors(:,1));
fprintf('Mean Capture Error: %.4fm\n', meanCapError);

%Max capture error
maxCapError = max(captureErrors(:,1));
fprintf('Max Capture Error: %.4fm\n', maxCapError);

%Mean absolute error
MAE  = sum(offsetError)/length(offsetError);
fprintf('Mean Absolute Error: %.4fm\n', MAE);

%Root mean square error
RMSE = sqrt(mean(offsetError.^2));
fprintf('Root Mean Square Error: %.4fm\n', RMSE);



figure(2)
hold on
%Plot start point
plot(Waypoints(1, 1), Waypoints(1, 2),'yo','MarkerSize',10,'MarkerFaceColor', 'y');
%Plot final waypoint
plot(Waypoints(end, 1), Waypoints(end, 2),'ro','MarkerSize',10, 'MarkerFaceColor', 'r');
%Plot all other waypoints
plot(Waypoints(2:end-1, 1), Waypoints(2:end-1, 2),'bo', 'MarkerSize',10,'MarkerFaceColor', 'b');
%Plot connecting paths
plot(Waypoints(:, 1), Waypoints(:, 2),'r--','LineWidth', 3);
%Plot traveled path
plot(estimatePose(:,1), estimatePose(:,2), 'g', 'LineWidth', 2)
for i = 1:length(captureErrors)
    plot([captureErrors(i,2),Waypoints(i+1,1)], [captureErrors(i,3), Waypoints(i+1,2)], 'k-', 'LineWidth', 2);
    rectangle('Position',[Waypoints(i+1, 1)-captureDistance Waypoints(i+1, 2)-captureDistance captureDistance*2 captureDistance*2],'Curvature',[1,1]);
end
axis([-500 500 -500 500])
%title('Capture Error, Expand and zoom to view')

originalFig = figure(2);

% Create a new figure for the subplot
newFig = figure;

for i = 1:length(captureErrors)
    subplot(3, 3, i);

    copyobj(allchild(get(originalFig, 'CurrentAxes')), gca);

    axis([Waypoints(i+1, 1)-captureDistance Waypoints(i+1, 1)+captureDistance Waypoints(i+1, 2)-captureDistance Waypoints(i+1, 2)+captureDistance])

    title(['Waypoint ', num2str(i)]);
end

%{
figure

subplot(3,1,1)
hold on
plot(abs(noisyPose(:,1)-realPose(:,1)));
plot(abs(estimatePose(:,1)-realPose(:,1)));

subplot(3,1,2)
hold on
plot(abs(noisyPose(:,2)-realPose(:,2)));
plot(abs(estimatePose(:,2)-realPose(:,2)));

subplot(3,1,3)
hold on
plot(abs(noisyPose(:,2)-realPose(:,2)));
plot(abs(estimatePose(:,3)-realPose(:,3)));
hold off
%}

figure
plot(Ts, offsetError)
title('Mean Absolute Error over Time')
xlabel('Time [s]');
ylabel('Crosstack Error [m]');