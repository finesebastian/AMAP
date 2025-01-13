%% Takes Velocity Indices as Parameter to Extrapolate Vergence Type

classdef VergenceType
    methods(Static)
        % Returns Arrays of Convergent and Divergent Movements
        function [convergent_movements_array, divergent_movements_array] = vergence_movement_separator(position_velocity_cell_array)

            % Iterate through indices in Cell Array
            for cell_index = 1:length(position_velocity_cell_array)
                convergent_offset = 0;
                divergent_offset = 0;
                convergent_movements_array{1} = [];
                divergent_movements_array{1} = [];

                % Selects Current Cell Array to Matrix
                current_array = DataTypeConverter.cell_to_array(position_velocity_cell_array(cell_index));

                % Preallocate Matrix for Filling
                convergent_parsed_movement_matrices = zeros(size(current_array,1),size(current_array,2));
                divergent_parsed_movement_matrices = zeros(size(current_array,1),size(current_array,2));
                
                % Index Vergence Counters
                convergent_movement_count = 0;
                divergent_movement_count = 0;

                if (size(current_array,3) > 0)
                    % Iterate through all found movements
                    for page_index = 1:size(current_array,3)
    
                        % Select Current Movement from Page
                        current_movement = current_array(:,:,page_index);
                       
                        % Negative Velocity - Convergent
                        if(mean(current_movement(:,1)+current_movement(:,8)) < 0)
                            convergent_movement_count = convergent_movement_count + 1;
                            convergent_parsed_movement_matrices(:,:,convergent_movement_count) = current_movement;
                            convergent_parsed_movement_matrices(:,[1,2,8,9,11,12],convergent_movement_count) = -1 * convergent_parsed_movement_matrices(:,[1,2,8,9,11,12],convergent_movement_count);

                        % Positive Velocity - Divergent
                        else
                            divergent_movement_count = divergent_movement_count + 1;
                            divergent_parsed_movement_matrices(:,:,divergent_movement_count) = current_movement;
                            divergent_parsed_movement_matrices(:,[1,2,8,9,11,12],divergent_movement_count) = -1 * divergent_parsed_movement_matrices(:,[1,2,8,9,11,12],divergent_movement_count);
                        end
                    end
                end

                % Validate Data Movements for Storage
                % Convergent and Divergent Matrices Have Values
                if (convergent_movement_count > 0 && divergent_movement_count > 0)
                    convergent_movements_array{cell_index - convergent_offset} = convergent_parsed_movement_matrices;
                    divergent_movements_array{cell_index - divergent_offset} = divergent_parsed_movement_matrices;
                % Convergent is Empty
                elseif (convergent_movement_count == 0 && divergent_movement_count > 0)
                    divergent_movements_array{cell_index - divergent_offset} = divergent_parsed_movement_matrices;
                    convergent_offset = convergent_offset + 1;
                % Divergent is Empty
                elseif (convergent_movement_count > 0 && divergent_movement_count == 0)
                    convergent_movements_array{cell_index - convergent_offset} = convergent_parsed_movement_matrices;
                    divergent_offset = divergent_offset +1;
                end
                  
            end
        end
    end
end


                               

