%% Takes Derivatives of Provided Data 

classdef Differentiator
    methods(Static)
        % Takes cell arrays and differentiates based on order
        function [differentiated_cell_arrays] = diff_data(derivative_order, cell_arrays)

            % Take Diff() Across Array Data based on Provided Information
            % (Original)
            % "RefractionLSphereDpt" | "PupilFoundL" | "GazeLX" | "GazeLY" |
            % "RefractionRSphereDpt" | "PupilFoundR" | "GazeRX" | "GazeRY"

            % Velocity Columns added after position
            % (Post)
            % "RefractionLSphereDpt" | "RefractionLSphereDpt"dx | "PupilFoundL" | "GazeLX" | "GazeLX"dx | "GazeLY" | "GazeLY"dx | 
            % "RefractionRSphereDpt" | "RefractionRSphereDpt"dx | "PupilFoundR" | "GazeRX" | "GazeRX"dx | "GazeRY" | "GazeRY"dx |

            % Allocate Space for Cell Array
            differentiated_cell_arrays = cell(1,length(cell_arrays));

            % Fixed Indices for Velocity
            velocity_column_positions = [2,5,7,9,12,14];

            % New Indices for Position
            new_position_indices = [1,3,4,6,8,10,11,13];

            %Iterate through Cell arrays
            for cell_index = 1:length(cell_arrays)
                % Selects Current Cell Array to Matrix
                current_array = DataTypeConverter.cell_to_array(cell_arrays(cell_index));

                % Allocate New Matrix to Fill with Position and Velocity
                position_velocity_matrix = zeros(size(current_array,1),size(current_array,2)+length(velocity_column_positions));

                % Creates Derivative buffers first value with 0
                position_to_velocity = vertcat(zeros(1,6), diff(current_array(:,[1,3,4,5,7,8]),derivative_order,1));
                
                % Fill Velocity Data 
                position_velocity_matrix(:,velocity_column_positions) = position_to_velocity;

                % Fill Position Data
                position_velocity_matrix(:,new_position_indices) = current_array;

                % Generate Cell Array
                differentiated_cell_arrays{cell_index} = position_velocity_matrix;
            end
        end
    end
end
