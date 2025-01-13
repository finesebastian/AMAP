%% Creates Ensemble Plots of Data

    time_vector = linspace(0,size(current_data,1)/50,size(current_data,1));
    
    % Combined Accommodation Ensembles
    for movement = 1:length(current_data(1,1,:))
        plot(time_vector, current_data(:,1,movement)+current_data(:,8,movement),'g')
        hold on
    end
    
    % Combined Accommodation
    for row_movement = 1:length(current_data(:,1,1))
        mean_movement(row_movement,1) = mean((current_data(row_movement,1,:)+(current_data(row_movement,8,:))),'omitnan');
        dev_movement(row_movement,1) = std((current_data(row_movement,1,:)+current_data(row_movement,8,:)),'omitnan');
    end
    plot(time_vector,mean_movement,'k',LineWidth=3)
    hold on
    
    % Standard Deviations for Combined Accommodation
    for row_movement = 1:length(current_data(:,1,1))
        sample_to_time = time_vector(row_movement);
        plot([sample_to_time, sample_to_time],[-dev_movement(row_movement,1)+mean_movement(row_movement,1), ...
            dev_movement(row_movement,1)+mean_movement(row_movement,1)],'Color', ...
            [validatecolor(uint8([192,192,192])),.5],LineWidth=5)
        hold on
    end
    
    for movement = 1:length(current_data(:,1,1))
        mean_left_movement(movement,1) = mean((current_data(movement,1,:)),'omitnan');
        dev_left_movement(movement,1) = std((current_data(movement,1,:)),'omitnan');
    end
    plot(time_vector, mean_left_movement,'b',LineWidth=3)
    hold on
    
    for movement = 1:length(current_data(1,1,:))
        plot(time_vector, current_data(:,1,movement),'Color', ...
            [validatecolor(uint8([0,0,255])),.2])
        hold on
    end
    
    for row_movement = 1:length(current_data(:,1,1))
        sample_to_time = time_vector(row_movement);
        plot([sample_to_time, sample_to_time],[-dev_left_movement(row_movement,1)+mean_left_movement(row_movement,1), ...
            dev_left_movement(row_movement,1)+mean_left_movement(row_movement,1)],'Color', ...
            [validatecolor(uint8([0,0,255])),.2],LineWidth=5)
        hold on
    end
    
    for movement = 1:length(current_data(:,8,1))
        mean_right_movement(movement,1) = mean((current_data(movement,8,:)),'omitnan');
        dev_right_movement(movement,1) = std((current_data(movement,8,:)),'omitnan');
    end
    plot(time_vector, mean_right_movement,'r',LineWidth=3)
    hold on
    
    for movement = 1:length(current_data(1,1,:))
        plot(time_vector, current_data(:,8,movement),'Color', ...
            [validatecolor(uint8([255,0,0])),.2])
        hold on
    end
    
    for row_movement = 1:length(current_data(:,1,1))
        sample_to_time = time_vector(row_movement);
        plot([sample_to_time, sample_to_time],[-dev_right_movement(row_movement,1)+mean_right_movement(row_movement,1), ...
            dev_right_movement(row_movement,1)+mean_right_movement(row_movement,1)],'Color', ...
            [validatecolor(uint8([255,0,0])),.2],LineWidth=5)
        hold on
    end
    
    xticks(0:1:5);
    ylim([-1 4]);
    title('Baseline ADP2');
    xlabel('Time (Seconds)');
    ylabel('Refraction (Diopters)');
    
    % Velocity Axis
    
    yyaxis right;
    ylim([-.1 .4]);
    ylabel('Refractive Velocity (Diopters/Sec)');
    grid on;
    
    % Velocity
    for row_movement = 1:length(current_data(:,2,1))
        mean_movement_peak_velocity(row_movement,1) = mean((current_data(row_movement,2,:)+(current_data(row_movement,9,:))),'omitnan');
        dev_movement_peak_velocity(row_movement,1) = std((current_data(row_movement,2,:)+current_data(row_movement,9,:)),'omitnan');
    end
    plot(time_vector,mean_movement_peak_velocity,'m',LineWidth=3)
    hold on
    
    % % Velocity Deviation
    % for row_movement = 1:length(current_data(:,1,1))
    %     sample_to_time = time_vector(row_movement);
    %     plot([sample_to_time, sample_to_time],[-dev_movement_peak_velocity(row_movement)+mean_movement_peak_velocity(row_movement), ...
    %         dev_movement_peak_velocity(row_movement)+mean_movement_peak_velocity(row_movement)],'Color', ...
    %         [validatecolor(uint8([255,0,255])),.1],LineWidth=3)
    %     hold on
    % end
    
    
    hold off
