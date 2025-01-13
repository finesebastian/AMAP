%% Determines Longest Length of NaNs for Filter Window Length

classdef FilterWindowLength
    methods(Static)

        % Determine Refraction Window Length from NaNs
        function [cell_array_filter_lengths] = determine_refraction_filter_window_length(cell_array)
            % Generates window length for filtering based on the largest
            % consecutive number of NaN values

            % Preallocate Space for Cell Array
            cell_array_filter_lengths = cell(1,length(cell_array));

            % Iterates through cell_array indices
            for cell_index = 1:length(cell_array)
    
                % Default Length = 3
                longest_nan_length = 3;
    
                % Temp_Array Structure
                % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" | "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"
                temp_array = DataTypeConverter.cell_to_array(cell_array(cell_index));

                % Collapse to Single Column of data for NaNs
                refraction_data = temp_array(:,1) + temp_array(:,5);

                % Set Identified NaN Locations
                nan_boolean = isnan(refraction_data(1:end-50));
                nan_bool_location = find(nan_boolean== 1);

                % Set Iterator
                nan_length = 1;
    
                % Determine Longest NaN Length w/o last second of data (50Hz @ 1 Sec = 50 points)
                while (nan_length < length(nan_bool_location))
                    temp_nan_length = 1;
                    % Look at NaN Indices and Iterate 
                    if(nan_length < length(nan_bool_location) && nan_bool_location(nan_length)==nan_bool_location(nan_length+1)-1)
                        while(nan_length < length(nan_bool_location) && nan_bool_location(nan_length)==nan_bool_location(nan_length+1)-1)
                            temp_nan_length = temp_nan_length +1;
                            nan_length = nan_length + 1;
                        end
                    elseif (nan_length < length(nan_bool_location))
                        nan_length = nan_length + 1;
                    end

                    if(temp_nan_length > longest_nan_length)
                        longest_nan_length = temp_nan_length;
                    end
                end
                
                %Determine Minimum Odd Filter Length
                if(~mod(longest_nan_length,2))
                    filter_window_length = (longest_nan_length)+3;
                else
                    filter_window_length = (longest_nan_length)+2;
                end
                cell_array_filter_lengths{cell_index} = filter_window_length;
            end
        end

        % Determine Gaze Window Length from NaNs
        function [cell_array_filter_lengths] = determine_gaze_filter_window_length(cell_array)

            % Preallocate Space for Cell Array
            cell_array_filter_lengths = cell(1,length(cell_array));
            
            % Iterates through cell_array indices
            for cell_index = 1:length(cell_array)

                % Default Length = 3
                longest_nan_length = 3;

                % Temp_Array Structure
                % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" | "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"
                temp_array = DataTypeConverter.cell_to_array(cell_array(cell_index));

                % Collapse to Single Column of data for NaNs
                refraction_data = temp_array(:,3) + temp_array(:,4) + temp_array(:,7) + temp_array(:,8);

                % Set Identified NaN Locations
                nan_boolean = isnan(refraction_data(1:end-50));
                nan_bool_location = find(nan_boolean== 1);
                    
                % Set Iterator
                nan_length = 1;
    
                % Determine Longest NaN Length w/o last second of data (50Hz @ 1 Sec = 50 points)
                while (nan_length < length(nan_bool_location))
                    temp_nan_length = 1;
                    % Look at NaN Indices and Iterate 
                    if(nan_length < length(nan_bool_location) && nan_bool_location(nan_length)==nan_bool_location(nan_length+1)-1)
                        while(nan_length < length(nan_bool_location) && nan_bool_location(nan_length)==nan_bool_location(nan_length+1)-1)
                            temp_nan_length = temp_nan_length +1;
                            nan_length = nan_length + 1;
                        end
                    elseif (nan_length < length(nan_bool_location))
                        nan_length = nan_length + 1;
                    end

                    if(temp_nan_length > longest_nan_length)
                        longest_nan_length = temp_nan_length;
                    end
                end
                %Determine Minimum Odd Filter Length
                if(mod(longest_nan_length,2)==0)
                    filter_window_length = (longest_nan_length)+3;
                else
                    filter_window_length = (longest_nan_length)+2;
                end
                cell_array_filter_lengths{cell_index} = filter_window_length;
            end
        end
    end
end
