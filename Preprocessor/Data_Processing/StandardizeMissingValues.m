%% Identifies Missing Values Replaces with NaNs

classdef StandardizeMissingValues
    methods(Static)

        % Standardizes Missing Values from Cell Array Data
        function [standardized_cells_array, noise_percentage_cell_array,cell_array_filenames,cell_array_subject_ids, rejected_standardized_cells_array, rejected_noise_percentage_cell_array,rejected_cell_array_filenames,rejected_cell_array_subject_ids] = standardize_missing_values(cell_array,array_filenames,array_subject_ids)
            % Evaluates provided cell data arrays and assesses if missing
            % values (0 or -100) are present. 

            % Missing Values for Plusoptix are 0 for PupilFound and -100
            % for the Refraction
            missing_values = [0,-100];

            % Counts for Each Data Type Index
            rejected_index = 1;
            passed_index = 1;

            % Default Values 
            rejected_noise_percentage_cell_array{1} = 0;
            rejected_standardized_cells_array{1} = 0;
            rejected_cell_array_filenames{1} = 0;
            rejected_cell_array_subject_ids{1} =0;
            standardized_cells_array{1} = 0;
            noise_percentage_cell_array{1} = 0;
            cell_array_filenames{1} = 0;
            cell_array_subject_ids{1} = 0;

            % Iterates through Cell Array, Converts to Matrix for Missing
            % Values and stores as Cell Array
            for cell_index = 1:length(cell_array)

                % Default Boolean Check Value
                emptyDataFile = false;
                emptyEyeData = false;

                temp_array = DataTypeConverter.cell_to_array(cell_array(cell_index));

                % Isolates L/R Pupil Found
                temp_pupil_l_found = temp_array(:,2);
                temp_pupil_r_found = temp_array(:,6);

                % Sets Gaze X/Y for L/R to NaN when PupilFound == 0
                temp_array(temp_pupil_l_found == 0, [3,4]) = nan;
                temp_array(temp_pupil_r_found == 0, [7,8]) = nan;

                % Sets Gaze X/Y for L/R to NaN when Refraction == -100
                % Edited 07/22/2022
                temp_array(temp_array(:,1) == -100, [3,4]) = nan;
                temp_array(temp_array(:,5) == -100, [7,8]) = nan;

                % Sets Gaze X/Y for L/R to NaN when > 5 Degrees away from
                % Mean Value
                % Edited 07/22/2022
                temp_array(abs(temp_array(:,4) - mean(temp_array(:,4),'omitnan')) >= 5, [3,4]) = nan;
                temp_array(abs(temp_array(:,8) - mean(temp_array(:,8),'omitnan')) >= 5, [7,8]) = nan;

                % Sets -100 Refraction and PupilFound == 0 to NaN
                temp_array(:,[1,2,5,6]) = standardizeMissing(temp_array(:,[1,2,5,6]), missing_values);            


                % AMENDEMENT 04-17-2023
                % ----------- %
                total_nan_count = sum(isnan(temp_array(:,[1,2,5,6])));
                if(numel(total_nan_count) > 1)
                    % Left-Right Eye Data Replacement for missing signal
                    leftEyeSignalIntegrityBoolean = round((total_nan_count(1) / size(temp_array,1))*100,3) > 25;
                    rightEyeSignalIntegrityBoolean = round((total_nan_count(3) / size(temp_array,1))*100,3) > 25;
    
                    % Exclusive or (XOR) to switch eye data correspondingly
                    if(xor(leftEyeSignalIntegrityBoolean,rightEyeSignalIntegrityBoolean))
                        if(rightEyeSignalIntegrityBoolean)
                                temp_array(:,[5,6,7,8]) = temp_array(:,[1,2,3,4]);
                        else
                                temp_array(:, [1,2,3,4]) = temp_array(:, [5,6,7,8]);
                        end
                        % Recount NaNs
                        total_nan_count = sum(isnan(temp_array(:,[1,2,5,6])));
                    end
                    % ----------- %
                end


                % ~~~~~~~~~~~~~~~~~~~NaN Length Assessment SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~
                % Creates Temporary Array of Data to 
                temp_eval = isnan(temp_array(:,[1,5]));
                temp_eval_cell{1} = temp_eval(:,1);
                temp_eval_cell{2} = temp_eval(:,2);
                
                % For Values of NaN that are continuous
                % they will have a value of 1 for start and -1 for ends
                temp_diff = diff(temp_eval(:,:));
                
                % Creates Logic Array to Find Block Ends
                temp_nan_block_logic = temp_diff == -1;

                % Check if there is a Singular Data Line
                if(length(temp_nan_block_logic)==1 && size(temp_array,1)==1)
                    emptyDataFile = true;
                % Check if Left Eye is Empty (all NaNs)
                elseif(sum(temp_nan_block_logic(:,1) == 0) == size(temp_nan_block_logic(:,1),1))
                    emptyEyeData = true;
                % Check if Right Eye is Empty (all NaNs)
                elseif(sum(temp_nan_block_logic(:,2) == 0) == size(temp_nan_block_logic(:,2),1))
                    emptyEyeData = true;
                else
                    % Find Block End Indices
                    % Ends are Denoted by -1 which means the value ahead was
                    % not a NaN
                    nan_block_indices{1} = [0; find(temp_nan_block_logic(:,1))];
                    nan_block_indices{2} = [0; find(temp_nan_block_logic(:,2))];
    
                    % Initialize NaN Cell Arrays
                    nan_lengths = cell(1,2);
                    
                    % Stores Length of NaNs and their End Index
                    % 1 - Left 2 - Right
                    for eye_index = 1:size(nan_block_indices,2)
                        % Segments of NaN Index Positions
                        nan_temp = nan_block_indices{eye_index};
                        % Stores Logic Results for isNaN()
                        temp_mat_values = temp_eval_cell{eye_index};
                        nan_blocks = zeros(size(nan_temp,1)-1,2);
                        % Iterates through Left (1) and Right (2) Eyes
                        for block_number = 2:size(nan_temp,1)
                            % Creates a Value, Index Position
                            % Takes Index of NaN Block - Previous Index 
                            % Sums total 1s within block (1 -> NaNs)
                            % Stores Total Number of NaNs, Index
                            nan_blocks(block_number,:) = [sum(temp_mat_values(1:(nan_temp(block_number)-nan_temp(block_number-1)))), ...
                                nan_temp(block_number)-sum(temp_mat_values(1:(nan_temp(block_number)-nan_temp(block_number-1))))-1];
                            % Removes Segment from following calculation
                            temp_mat_values([1:(nan_temp(block_number)-nan_temp(block_number-1))]) = [];
                        end
                        % Store NaN Totals, Index Pairs
                        nan_lengths{eye_index} = nan_blocks;
                    end
                    
                    % Default Values
                    max_nan_left = 9999;
                    max_nan_right = 9999;
                    
                    % Checks if any NaN length is >= 225 Samples
                    % 225 Samples / 50 Hz ~ (4.5 Seconds)
                    if(max(nan_lengths{1}(:,1) >= 225) || max(nan_lengths{2}(:,1) >= 225))
                        max_nan_left = nan_lengths{1}(find(nan_lengths{1}(:,1) >= 225,1),2);
                        max_nan_right = nan_lengths{2}(find(nan_lengths{2}(:,1) >= 225,1),2);

                        % Checks Index of Left/Right to append at LOWER index
                        if(max_nan_left <= max_nan_right)
                            temp_array = temp_array(1:max_nan_left,:);
                        elseif (isempty(max_nan_left) && ~isempty(max_nan_right))
                            temp_array = temp_array(1:max_nan_right,:);
                        elseif (isempty(max_nan_right) && ~isempty(max_nan_left))
                            temp_array = temp_array(1:max_nan_left,:);
                        else
                            temp_array = temp_array(1:max_nan_right,:);
                        end

                        % Recount NaNs
                        total_nan_count = sum(isnan(temp_array(:,[1,2,5,6])));
                    end
                end

                % Not an Empty File can have analysis of NaNs
                if(~emptyDataFile)
    
                    % ~~~~~~~~~~~~~~~~~~~END OF SECTION ~~~~~~~~~~~~~~~~~~~~~~~~~
                        
                    % Determines Percent NaN for Each Eye
                    % 1 - Left % 
                    % 2 - Right %
                    nan_percent_matrix(1,1) = round((total_nan_count(1) / size(temp_array,1))*100,3);
                    nan_percent_matrix(1,2) = round((total_nan_count(3) / size(temp_array,1))*100,3);
                end

                

                % Quick Length of NaN Analysis

                % Evaluates Signal/Noise Ratio
                % Set Threshold to 25% Missing, File has to have 15 Seconds
                % worth of data 
                if (emptyDataFile || emptyEyeData || round((total_nan_count(1) / size(temp_array,1))*100,3) > 25 || round((total_nan_count(3) / size(temp_array,1))*100,3) > 25 || size(temp_array,1) < 750)
                    % Store Rejected Matrices in Cell Array
                    rejected_noise_percentage_cell_array{rejected_index} = nan_percent_matrix;
                    rejected_standardized_cells_array{rejected_index} = temp_array;
                    rejected_cell_array_filenames{rejected_index} = array_filenames{cell_index};
                    rejected_cell_array_subject_ids{rejected_index} = array_subject_ids{cell_index};
                    
                    % Checks if Temp Array is Empty 
                    % Index 1 (START) has >= 225 NaNs 
                    if (isempty(temp_array))
                        rejected_standardized_cells_array{rejected_index} = DataTypeConverter.cell_to_array(cell_array(cell_index));
                    end
                    rejected_index = rejected_index + 1;

                else
                    % Store Passed Matrices in Cell Array
                    noise_percentage_cell_array{passed_index} = nan_percent_matrix;
                    standardized_cells_array{passed_index} = temp_array;
                    cell_array_filenames{passed_index} = array_filenames{cell_index};
                    cell_array_subject_ids{passed_index} = array_subject_ids{cell_index};
                    passed_index = passed_index + 1;
                end
            end
        end
    end
end
