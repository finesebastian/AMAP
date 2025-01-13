%% Median Filter 

classdef MedianFilter
    methods(Static)

        % Filter Refraction Data based on Provided Cell Array and Window
        function [filtered_cell_arrays] = median_refraction_filter(cell_array, cell_filter_window_lengths)

            % Preallocate Space for Cell Array
            filtered_cell_arrays = cell(1,length(cell_filter_window_lengths));

            % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" | "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"
            for cell_index = 1:length(cell_array)
                current_filter_length = DataTypeConverter.cell_to_array(cell_filter_window_lengths(cell_index));
                current_array = DataTypeConverter.cell_to_array(cell_array(cell_index));
                current_array(:,[1,5]) = medfilt1(current_array(:,[1,5]),current_filter_length,'omitnan','truncate');
                filtered_cell_arrays{cell_index} = current_array;
            end
        end


        % Filter Gaze Data based on Provided Cell Array and Window
        function [filtered_cell_arrays] = median_gaze_filter(cell_array, cell_filter_window_lengths)
            
            % Preallocate Space for Cell Array
            filtered_cell_arrays = cell(1,length(cell_filter_window_lengths));

            % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" | "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"
            for cell_index = 1:length(cell_array)
                current_filter_length = DataTypeConverter.cell_to_array(cell_filter_window_lengths(cell_index));
                current_array = DataTypeConverter.cell_to_array(cell_array(cell_index));
                current_array(:,[3,4,7,8]) = medfilt1(current_array(:,[3,4,7,8]),current_filter_length,'omitnan','truncate');
                filtered_cell_arrays{cell_index} = current_array;
            end
        end
    end
end
