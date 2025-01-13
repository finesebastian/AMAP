%% Butter Worth Filter

classdef ButterFilter
    methods(Static)
        function [low_pass_filtered_cell_arrays] = low_pass_filter(filter_order, fc, fs, unfiltered_cell_arrays)
            
            % Filter All Array Data based on Provided Information
            % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" | "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"
            [b,a] = butter(filter_order,fc/fs/2);
            
            % Allocate Space for Cell Array
            low_pass_filtered_cell_arrays = cell(1,length(unfiltered_cell_arrays));

            %Iterate through arrays
            for cell_index = 1:length(unfiltered_cell_arrays)
                current_array = DataTypeConverter.cell_to_array(unfiltered_cell_arrays(cell_index));
                low_pass_filtered_cell_arrays{cell_index} = filter(b,a,current_array);
            end
        end
    end
end