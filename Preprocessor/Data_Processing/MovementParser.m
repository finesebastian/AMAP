%% Separates Movements Based On Local Max w/ 5 second recording assumption

% Matrix Format (Continuous Columns (1 -> 14)
% "RefractionLSphereDpt" | "RefractionLSphereDpt"dx | "PupilFoundL" | "GazeLX" | "GazeLX"dx | "GazeLY" | "GazeLY"dx | 
% "RefractionRSphereDpt" | "RefractionRSphereDpt"dx | "PupilFoundR" | "GazeRX" | "GazeRX"dx | "GazeRY" | "GazeRY"dx |

classdef MovementParser
    methods(Static)
        % Takes Positon and Cell Array and Returns Array of Array of Movements
        function [array_of_movement_arrays] = parse_data_to_movements(position_velocity_cell_array)

            %Enables Maximum Number of Movements to be 31 (30 Viable)
            num_movements = 31;

            % Movement Separation 225 samples/50Hz) ~ 4.5second in between
            movement_sample_separation = 225;

            % Preallocate Cell Array
            array_of_movement_arrays = cell(1,length(position_velocity_cell_array));

            % Iterate through indices in Cell Array
            for cell_index = 1:length(position_velocity_cell_array)

                % Selects Current Cell Array to Matrix
                current_array = DataTypeConverter.cell_to_array(position_velocity_cell_array(cell_index));
    
                %Find Local Maximas (Refraction), Offsets 1 Seconds
                % From Beginning nd End
                % 50 Samples / 50Hz ~ 1 second
                refractive_maxima_left_right = islocalmax(current_array(:,[2,9]), ...
                    'MinSeparation',movement_sample_separation, ...
                    'MaxNumExtrema',num_movements);


                % Removes any Index that is within the first
                % 25 Samples / 50 Hz ~ .5 Sec
                refractive_maxima_left_right([1:25],:)=0;

                % Removes any Index that is within the last
                % 25 Samples / 50 Hz ~ .5 Sec
                refractive_maxima_left_right([end-25:end],:)=0;
                
                % Assigns individual movement indices per eye
                % First Column (1) - Left Eye | Second Column (2) - Right Eye
                left_eye_indices = find(refractive_maxima_left_right(:,1));
                right_eye_indices = find(refractive_maxima_left_right(:,2));
                
                % Gets Max Index Sizes
                left_eye_indices_size = size(left_eye_indices,1);
                right_eye_indices_size = size(right_eye_indices,1);

%                 % Assess Number of Movements Detected
%                 size_mismatch = left_eye_indices_size - right_eye_indices_size;
% 
%                 % Compares Lengths of Max Indices 
%                 % then Differences in Indices for Consistency
%                 if (abs(size_mismatch) > 0)
%                     
%                     % Checks Sizes (Left Size Larger)
%                     if(size_mismatch > 0)
% 
%                         % Left eye was detected late
%                         if (left_eye_indices(1) - right_eye_indices(1) >= movement_sample_separation)
%                             left_eye_indices(1:size_mismatch) = [];
% 
%                         % The Left eye was detected too early
%                         else
%                             left_eye_indices(end) = [];
%                         end
% 
%                     % Else (Right Size Larger)
%                     else
%                         % Right eye was detected late
%                         if (right_eye_indices(1) - left_eye_indices(1) >= movement_sample_separation)
%                             right_eye_indices(1:abs(size_mismatch)) = [];
% 
%                         % The Right eye was detected too early
%                         else
%                             right_eye_indices(end) = [];
%                         end
%                     end
% 
%                 % Data is too inconsistent 
%                 % (More then 1 Movement Difference Detected)
%                 elseif (abs(size_mismatch) > 1)
%                     warndlg('Bad Data','Parsing Failed');
% 
%                 end

                % Merges Left and Right Max Indices
                peak_velocity_indices = [left_eye_indices,right_eye_indices];

                % Average Max Velocity Indices to Separate Movement
                % Row Averages and Floors Average
                left_right_index = floor(mean(peak_velocity_indices,2));
                
                % Iterate through indices of peak velocities
                for movement_index = 1:size(left_right_index,1)-1

                    % 250 Samples / 50Hz ~ 5 Seconds Per Movement
                    time_forward = 250;
                    
                    % 25 Samples / 50Hz ~ .5 Seconds prior to localmax
                    time_offset = 25;

                    % Selects First Peak Velocity Position with Time Offset
                    movement_starting_index = left_right_index(movement_index) - time_offset;
                
                    %Checks if first index is negative with offset applied
                    if(movement_starting_index < 0)
                        % Adjusts forward sample window from index 
                        time_forward = time_forward + time_offset + movement_starting_index;
                        % Sets First Index to 0 (to avoid negative index)
                        movement_starting_index = 0;
                    end

                    %Checks to see if the Index + Time Forward is greater then the
                    %next movement index (i.e if not -> choppy data)
                    % Assumes first index is true value
                    if(movement_index+1 < size(left_right_index,1) && movement_starting_index + time_forward > left_right_index(movement_index+1))
                        % Treats Next Overlapping Movement as Noise 
                        % Removes Index
                        left_right_index(movement_index+1)=[];
                    end

                    % Checks for end of file and pads 0's to fit window
                    if(movement_starting_index + time_forward >= size(current_array,1))
                        parsed_movements_array(:,:,movement_index) =  [current_array(movement_starting_index:size(current_array,1),:) ... 
                            ; zeros((movement_starting_index + time_forward - size(current_array,1)),size(current_array,2))];
                    % Else fill matrix with movement data and offset
                    else
                        parsed_movements_array(:,:,movement_index) = current_array([movement_starting_index:(movement_starting_index+time_forward)],:);
                    end
                end

                % Save Separated Movements to Cell Array
                array_of_movement_arrays{cell_index} = parsed_movements_array;
            end
        end
    end
end
