%% Separates Movements Based On Local Max w/ 5 second recording assumption

% Matrix Format (Continuous Columns (1 -> 14)
% "RefractionLSphereDpt" | "RefractionLSphereDpt"dx | "PupilFoundL" | "GazeLX" | "GazeLX"dx | "GazeLY" | "GazeLY"dx | 
% "RefractionRSphereDpt" | "RefractionRSphereDpt"dx | "PupilFoundR" | "GazeRX" | "GazeRX"dx | "GazeRY" | "GazeRY"dx |

classdef IndividualMovementParser_v2
    methods(Static)
        % Takes Positon and Cell Array and Returns Array of Array of Movements
        function [array_of_movement_arrays,array_of_peak_velocity_indices] = parse_data_to_movements(position_velocity_cell_array)

            % Movement Separation 100 samples/50Hz) ~ 2 second in between
            movement_sample_separation = 100;

            % Preallocate Cell Array
            array_of_movement_arrays = cell(1,length(position_velocity_cell_array));
            array_of_peak_velocity_indices = cell(1,length(position_velocity_cell_array));

            % Iterate through indices in Cell Array
            for cell_index = 1:length(position_velocity_cell_array)

                % Selects Current Cell Array to Matrix
                current_array = DataTypeConverter.cell_to_array(position_velocity_cell_array(cell_index));

                % Window Length is 200 samples / 50 Hz ~ 4 Second Windows
                guassian_window_length = 200;

                % Threshold for Inflection Points
                inflection_point_threshold = .05;

                % Preallocate Matrix
                guassian_smoothed_velocity = zeros(size(current_array(:,2),1),2);

                % Extracts Velocity from Current Matrix and applies extreme
                % smoothing to isolate peak velocities
                % ABS makes creases for inflection points
                guassian_smoothed_velocity(:,1) = abs((smoothdata(current_array(:,2),'gaussian',guassian_window_length)))*100;
                guassian_smoothed_velocity(:,2) = abs((smoothdata(current_array(:,9),'gaussian',guassian_window_length)))*100;
                
                % Preallocate Matrix
                guassian_peak_velocity_indices = zeros(size(guassian_smoothed_velocity,1),2);

                % Finds ALL inflection points below threshold
                % Left Eye
                guassian_peak_velocity_indices(1:length(find(guassian_smoothed_velocity(:,1)<inflection_point_threshold)),1) = find(guassian_smoothed_velocity(:,1)<inflection_point_threshold);
                % Right Eye
                guassian_peak_velocity_indices(1:length(find(guassian_smoothed_velocity(:,2)<inflection_point_threshold)),2) = find(guassian_smoothed_velocity(:,2)<inflection_point_threshold);

                % Initialize Matrix
                true_movement_indices = 0;

                % Iterate through Left then Right Eye Velocities
                for eye_index = 1:size(guassian_peak_velocity_indices,2)

                    % Default Starting Index for Movements
                    number_of_recovered_movements = 1;
                    inflection_points = 1;

                    % Stimulus Presentation Length 
                    % (150 Samples / 50 Hz ~ 3 seconds)
                    % Buffer Length
                    % (25 Samples / 50Hz ~ .5 second)
                    stimulus_length_buffer = 175;

                    % Iterates through each found velocity inflection index
                    while inflection_points <= find(guassian_peak_velocity_indices(:,eye_index),1,'last')

                        % Check if index is in 1st Second or last 3 seconds
                        if(guassian_peak_velocity_indices(inflection_points,eye_index)<50 || ...
                                guassian_peak_velocity_indices(inflection_points,eye_index)>= (size(guassian_smoothed_velocity(:,eye_index),1)-stimulus_length_buffer))
                            inflection_points = inflection_points+1;

                        % Checks if index hasNext
                        % Checks if next index is within 100 Samples / 50
                        % Hz ~ 2 Seconds of previous
                        elseif(inflection_points+1 <= size(guassian_peak_velocity_indices(:,eye_index),1) && ...
                                guassian_peak_velocity_indices(inflection_points,eye_index)+movement_sample_separation > guassian_peak_velocity_indices(inflection_points+1,eye_index))

                            % Stores first index that is not overlapping
                            % and stores index value
                            true_movement_indices(number_of_recovered_movements,eye_index) = guassian_peak_velocity_indices(inflection_points,eye_index);
                            current_index = inflection_points;

                            % Iterates through indices until new index is
                            % found that is greater then previous or there
                            % are no further indices
                            while(inflection_points+1 <= size(guassian_peak_velocity_indices(:,eye_index),1) && ...
                                    guassian_peak_velocity_indices(current_index,eye_index)+movement_sample_separation > guassian_peak_velocity_indices(inflection_points+1,eye_index))
                                inflection_points = inflection_points+1;
                            end

                            % Steps forward to new index position and
                            % movement index
                            inflection_points = inflection_points+1;
                            number_of_recovered_movements = number_of_recovered_movements+1;

                        % Otherwise index is valid and stored 
                        else
                            true_movement_indices(number_of_recovered_movements,eye_index) = guassian_peak_velocity_indices(inflection_points,eye_index);
                            number_of_recovered_movements = number_of_recovered_movements+1;
                            inflection_points = inflection_points+1;
                        end
                    end
                end


                % Returns number of Non-Zero Indices found for each eye
                if(size(true_movement_indices,1) >= 1)
                    left_eye_num = size(find(true_movement_indices(:,1)),1);
                    right_eye_num = size(find(true_movement_indices(:,2)),1);
                end

                % Find the difference in movements found 
                movement_count_mismatch = left_eye_num - right_eye_num;
                
                % Reset Any Index Values
                reference_indices = 0;
                
                % Checks if mismatch exists and if either eye is imbalanced
                if (abs(movement_count_mismatch) > 0 || (mod(left_eye_num,30)~=0 || mod(right_eye_num,30)~=0))

                    % Checks left eye is correct and right eye is missing
                    % Checks if Left Eye is closer to 30/60 then right
                    if (((mod(left_eye_num,30) == 0) && (mod(right_eye_num,30) ~= 0)) || ((mod(right_eye_num,30) ~= 0) && (mod(abs(30-left_eye_num),30) < mod(abs(30-right_eye_num),30))))
                        reference_indices = true_movement_indices(true_movement_indices(:,1)~=0,1);

                    % Checks if right eye is correct and left is missing
                    % Checks if Right Eye is closer to 30/60 then left
                    elseif (((mod(left_eye_num,30) ~= 0) && (mod(right_eye_num,30) == 0)) || ((mod(left_eye_num,30) ~= 0) && (mod(abs(30-right_eye_num),30) < mod(abs(30-left_eye_num),30))))
                        reference_indices = true_movement_indices(true_movement_indices(:,2)~=0,2);

                    % Checks if there is a symmetric imbalance 
                    % (ie) Left - 29, Right - 31, Expected 30
                    % Takes the conservative data (below expected rather
                    % then having non-existent data)
                    elseif (mod(right_eye_num,30) == mod(left_eye_num,30) && left_eye_num < 30)
                        reference_indices = true_movement_indices(true_movement_indices(:,1)~=0,1);

                    % Checks if there is a symmetric imbalance 
                    % (ie) Left - 31, Right - 29, Expected 30
                    % Takes the conservative data (below expected rather
                    % then having non-existent data)
                    elseif (mod(right_eye_num,30) == mod(left_eye_num,30) && right_eye_num < 30)
                        reference_indices = true_movement_indices(true_movement_indices(:,2)~=0,1);

                    % Else Matched Imbalance
                    % (ie) Left - 31, Right 31
                    % Averages Rowwise Indices and Rounds Down then removes
                    % last index
                    else
                        reference_indices = floor(mean(true_movement_indices(true_movement_indices(:,1)~=0,1),2));     
                    end

%                     % Checks Reference Indice Outcomes
%                     if(mod(size(reference_indices,1),30)~=0)
%                         % Looks at the differences between all indices and
%                         % removes the nth smallest until mod(30)==0                        
%                         reference_indices(find((diff(reference_indices)==min(diff(reference_indices))),mod(size(reference_indices,1),30)))=[];
%                     end
                
                % Else matching Indices with 30
                % Average rowise and round down
                else
                    reference_indices = floor(mean(true_movement_indices,2));
                end
                
                % Preallocate PVI Space
                pvi = [];
                
                % Create Iterator Variable
                left_right_index = reference_indices;

                for intervals = 1:size(left_right_index,1)
                    try
                        [value,i] = max(guassian_smoothed_velocity([left_right_index(intervals):left_right_index(intervals+1)],1)+guassian_smoothed_velocity([left_right_index(intervals):left_right_index(intervals+1)],2));
                        pvi(intervals,1) = i+left_right_index(intervals);
                    catch
%                         [value,i] = max(guassian_smoothed_velocity([left_right_index(intervals):size(guassian_smoothed_velocity,1)],1)+guassian_smoothed_velocity([left_right_index(intervals):size(guassian_smoothed_velocity,1)],2));
%                         pvi(intervals,1) = i+left_right_index(intervals);
                    end
                end

                % 150 Samples / 50Hz ~ 3 Seconds Per Movement
                % 149 is required as MatLab is Inclusive
                time_forward = 149;
                
                % 25 Samples / 50Hz ~ .5 Seconds post inflection
                time_offset = -50;

                % Preallocate Array
                % 150 Samples in each row 
                % 150 Samples / 50 Hz ~ 3 Seconds
                parsed_movements_array = zeros(time_forward+1,size(current_array,2),length(pvi));
                
                % Iterate through indices of peak velocities
                for movement_index = 1:size(pvi,1)
                
                    % Selects First Peak Velocity Position with Time Offset
                    movement_starting_index = pvi(movement_index) + time_offset;

                    % Checks for end of file and pads 0's to fit window
                    if(movement_starting_index + time_forward >= size(current_array,1))
                        parsed_movements_array(:,:,movement_index) =  [current_array(movement_starting_index:size(current_array,1),:) ... 
                            ; zeros(((movement_starting_index + time_forward) - size(current_array,1)),size(current_array,2))];
                    % Else fill matrix with movement data and offset
                    else
                        parsed_movements_array(:,:,movement_index) = current_array([movement_starting_index:(movement_starting_index+time_forward)],:);
                    end
                end

                % Save Separated Movements to Cell Array
                array_of_movement_arrays{cell_index} = parsed_movements_array;

                % Save Peak Velocity Indices
                array_of_peak_velocity_indices{cell_index} = pvi;
            end
        end
    end
end
