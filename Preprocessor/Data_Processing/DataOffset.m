%% Sets Data to 0 Offset by subtracting first row from Matrix

classdef DataOffset
    methods(Static)
        % Takes Array Converts to Matrix
        function [offset_cell_data_array] = zero_offset_data(cell_arrays_of_movements)
            
            % Preallocate Cell Array
            offset_cell_data_array = cell(1,length(cell_arrays_of_movements));

            % Iterate through indices in Cell Array
            for cell_index = 1:length(cell_arrays_of_movements())
                % Selects Current Cell Array to Matrix
                current_array = DataTypeConverter.cell_to_array(cell_arrays_of_movements(cell_index));

                % Parse Captured Movements
                for movement_index = 1:size(current_array,3)
                     current_movement_matrix = current_array(:,:,movement_index);
                     
                     % DC Offset Left Eye to 0
                     current_array(:,1,movement_index) = current_movement_matrix(:,1)  ... 
                        - current_movement_matrix(1,1);
                     % DC Offset Right Eye to 0
                     current_array(:,8, movement_index) = current_movement_matrix(:,8) ... 
                         - current_movement_matrix(1,8);

%                      % DC Offset Left Eye Velocity to 0
%                      current_array(:,2,movement_index) = current_movement_matrix(:,2)  ... 
%                         - current_movement_matrix(1,2);
%                      % DC Offset Right Eye Velocity to 0
%                      current_array(:,9, movement_index) = current_movement_matrix(:,9) ... 
%                          - current_movement_matrix(1,9);


                      % DC Offset Left Eye Gaze to 0
                     current_array(:,4,movement_index) = current_movement_matrix(:,4)  ... 
                        - current_movement_matrix(1,4);
                     % DC Offset Right Eye Gaze to 0
                     current_array(:,11, movement_index) = current_movement_matrix(:,11) ... 
                         - current_movement_matrix(1,11);
% 
%                      % DC Offset Left Eye Gaze Velocity to 0
%                      current_array(:,5,movement_index) = current_movement_matrix(:,5)  ... 
%                         - current_movement_matrix(1,5);
%                      % DC Offset Right Eye Gaze Velocity to 0
%                      current_array(:,12, movement_index) = current_movement_matrix(:,12) ... 
%                          - current_movement_matrix(1,12);
                end
                offset_cell_data_array{cell_index} = current_array;
            end
        end
    end
end


                



