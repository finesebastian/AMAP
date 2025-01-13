%% Compares filter lengths and resizes data to avoid boundary condition conflicts

classdef DataPrefilterConditioning
    methods(Static)

        % Returns resized data cells
        function [prepared_cells] = prefilter_cells(cell_array, refraction_window_lengths, gaze_window_lengths)

            % Preallocate Space for Cell Array
            prepared_cells = cell(1,length(cell_array));

            % Iterates through cell_array indices
            for cell_index = 1:length(cell_array)
    
                % Temp_Array Structure
                temp_array = DataTypeConverter.cell_to_array(cell_array(cell_index));
                % Refraction Windows
                refraction_filter_length = DataTypeConverter.cell_to_array(refraction_window_lengths(cell_index));
                % Gaze Windows
                gaze_filter_length = DataTypeConverter.cell_to_array(gaze_window_lengths(cell_index));

                if(refraction_filter_length > gaze_filter_length)
                    filter_boundary = ceil(refraction_filter_length/2);
                    
                else
                    filter_boundary = ceil(gaze_filter_length/2);
                end

                % Define starting index to append NaNs
                init_appending_index = 1;
                while(isnan(temp_array(init_appending_index,1)) || isnan(temp_array(init_appending_index,5)))
                    init_appending_index = init_appending_index + 1;
                end

                % Resize Data and Store in Cell Array
                prepared_cells{cell_index} = temp_array(init_appending_index:end-filter_boundary,:);
            end
        end
    end
end

