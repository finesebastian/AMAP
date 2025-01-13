%% The Preprocessor imports raw data, removes signal saturation values, and separates movements

classdef Preprocessor
    % This is the Preprocessor Class
    methods(Static)

        function preprocess_raw_data(batchBoolean, raw_files, path,targetFigure)
            % This is the caller functions which is able to step through
            % the preprocessing of inputted raw data, rejected data, and
            % periodically save data to given directories.
            
            if(~batchBoolean)
                % Requests Raw Data and Path
                [raw_files, path] = ImportData.get_raw_csv_data();
            end
            
            % Checks Validity of File Import (Not Empty)
            if (~isequal(str2num(raw_files{1}),0))
                %Add path to MATLAB
                addpath(genpath(path));

                try
                    switch batchBoolean
                        % Subject-Wise Preprocessing
                        case false
                                % Create Waitbar for Visualization of Progress
                                preprocessing_waitbar = uiprogressdlg(targetFigure,"Title",'Preprocessing','Value',0,'ShowPercentage','on');
                                preprocessing_waitbar.Value = 1/26;
                                preprocessing_waitbar.Message = "Starting Preprocessor";
                                % Separates Paths into Subject IDs and Filenames
                                [cell_array_subject_ids, cell_array_filenames] = FileNameSeparator.path_to_subject_id_and_filename(path, raw_files);
                
                                preprocessing_waitbar.Value = 2/26;
                                preprocessing_waitbar.Message = "Processing Data ...";
                                % Parses Tables into Cell Arrays
                                [cell_arrays] = ReadData.read_CSV(raw_files);
                    
                                preprocessing_waitbar.Value = 3/26;
                                % Save Raw Data and Directory
                                SaveProgress.save_progress_to_mat(cell_arrays,cell_array_filenames,cell_array_subject_ids,"Raw","Raw");
                    
                                preprocessing_waitbar.Value = 4/26;
                                % Standardize Missing Values within Cell Arrays
                                [standardized_cells,noise_percentage_cells,cell_array_filenames,cell_array_subject_ids,rejected_standardized_cells, rejected_noise_percentage_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids] = StandardizeMissingValues.standardize_missing_values(cell_arrays,cell_array_filenames,cell_array_subject_ids);
                
                                if(isequal(standardized_cells{1},0))
                                    preprocessing_waitbar.Value = 20/26;
                                    pause(1);
                                    preprocessing_waitbar.Value = 26/26;
                                    preprocessing_waitbar.Message = "Saving Rejected Data!";
                                    close(preprocessing_waitbar);
                                    %Save Preprocessed Data
                                    SaveProgress.save_progress_to_mat(rejected_standardized_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids,"Rejected","Rejected");
                                    
                                    % Failure Message
                                    uialert(targetFigure,'Data Rejected','Preprocessing','Icon','error')
                                elseif(isequal(rejected_standardized_cells{1},0))
                                    preprocessing_waitbar.Value = 5/26;
                                    % Determine largest filter window for Refraction Data PER file (L/R)
                                    [refraction_filter_window_lengths] = FilterWindowLength.determine_refraction_filter_window_length(standardized_cells);
                        
                                    preprocessing_waitbar.Value = 6/26;
                                    % Determine largest filter winfow for Gaze PER file (L/R)
                                    [gaze_filter_window_lengths] = FilterWindowLength.determine_gaze_filter_window_length(standardized_cells);

                                    % Clip Data to avoid boundary conditions related to NaNs
                                    [prepared_cells] = DataPrefilterConditioning.prefilter_cells(standardized_cells, refraction_filter_window_lengths, gaze_filter_window_lengths);

                                    % Save Filter Lengths
                                    SaveProgress.save_progress_to_mat(refraction_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","RefractionFilters");
                                    SaveProgress.save_progress_to_mat(gaze_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","GazeFilters");

                                    % Output Filter Lengths to Excel.
                                    ExportData.export(true);
                        
                                    preprocessing_waitbar.Value = 7/26;
                                    % Filter Refraction Data
                                    [filtered_refraction_cells] = MedianFilter.median_refraction_filter(prepared_cells,refraction_filter_window_lengths);
                        
                                    preprocessing_waitbar.Value = 8/26;
                                    % Filter Gaze Data
                                    [filtered_refraction_gaze_cells] = MedianFilter.median_gaze_filter(filtered_refraction_cells,gaze_filter_window_lengths);
                        
                                    preprocessing_waitbar.Value = 9/26;
                                    % Low Pass Butter Worth 5th Order, 20Hz FC, 50 FS
                                    [fully_filtered_cells] = ButterFilter.low_pass_filter(5,20,50,filtered_refraction_gaze_cells);
                        
                                    preprocessing_waitbar.Value = 10/26;
                                    %Save Preprocessed Data
                                    SaveProgress.save_progress_to_mat(fully_filtered_cells,cell_array_filenames,cell_array_subject_ids,"Filtered","Filtered");
                                    
                                    preprocessing_waitbar.Value = 11/26;
                                    % Take Derivative of Array Data 
                                    [differentiated_cell_arrays] = Differentiator.diff_data(1, fully_filtered_cells);
                    
                                    preprocessing_waitbar.Value = 12/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(differentiated_cell_arrays,cell_array_filenames,cell_array_subject_ids,"Differentiated","Derivative")
                    
                                    preprocessing_waitbar.Value = 13/26;
                                    % Parse Movements
                                    [parsed_movement_arrays, peak_velocity_indices] = IndividualMovementParser_v2.parse_data_to_movements(differentiated_cell_arrays);
                    
                                    preprocessing_waitbar.Value = 14/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(parsed_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Parsed","Parsed")
                    
                                    preprocessing_waitbar.Value = 15/26;
                                    % Parse Movements
                                    [offset_movement_arrays] = DataOffset.zero_offset_data(parsed_movement_arrays);
                    
                                    preprocessing_waitbar.Value = 16/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(offset_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Calibrated","Offset")
                    
                                    preprocessing_waitbar.Value = 17/26;
                                    % Parse Vergence Type
                                    [convergent_movements,divergent_movements] = VergenceType.vergence_movement_separator(offset_movement_arrays);
                    
                                    preprocessing_waitbar.Value = 18/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(convergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","CONV")
                
                                    preprocessing_waitbar.Value = 19/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(divergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","DIV")
                
                                    preprocessing_waitbar.Value = 20/26;
                                    [convergent_metrics] = MetricAnalyzer.metric_analysis_tool(convergent_movements);
                
                                    preprocessing_waitbar.Value = 21/26;
                                    [divergent_metrics] = MetricAnalyzer.metric_analysis_tool(divergent_movements);
                
                                    preprocessing_waitbar.Value = 22/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(convergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","CONV")
                
                                    preprocessing_waitbar.Value = 24/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(divergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","DIV")
                    
                                    preprocessing_waitbar.Value = 26/26;
                                    preprocessing_waitbar.Message = "Preprocessing Complete!";
                                    pause(1)
                                    % Close Wait Bar
                                    close(preprocessing_waitbar);
                                    % Success Message
                                    uialert(targetFigure,'Subject Processing Complete!','Preprocessing','Icon','success')
                                else
                                    preprocessing_waitbar.Value = 5/26;
                                    %Save Rejected Data Data
                                    SaveProgress.save_progress_to_mat(rejected_standardized_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids,"Rejected","Rejected");
                
                                    preprocessing_waitbar.Value = 6/26;
                                    % Determine largest filter window for Refraction Data PER file (L/R)
                                    [refraction_filter_window_lengths] = FilterWindowLength.determine_refraction_filter_window_length(standardized_cells);
                        
                                    preprocessing_waitbar.Value = 7/26;
                                    % Determine largest filter winfow for Gaze PER file (L/R)
                                    [gaze_filter_window_lengths] = FilterWindowLength.determine_gaze_filter_window_length(standardized_cells);

                                    % Clip Data to avoid boundary conditions related to NaNs
                                    [prepared_cells] = DataPrefilterConditioning.prefilter_cells(standardized_cells, refraction_filter_window_lengths, gaze_filter_window_lengths);
                        
                                    % Save Filter Lengths
                                    SaveProgress.save_progress_to_mat(refraction_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","RefractionFilters");
                                    SaveProgress.save_progress_to_mat(gaze_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","GazeFilters");

                                    % Output Filter Lengths to Excel
                                    ExportData.export(true);

                                    preprocessing_waitbar.Value = 8/26;
                                    % Filter Refraction Data
                                    [filtered_refraction_cells] = MedianFilter.median_refraction_filter(prepared_cells,refraction_filter_window_lengths);
                        
                                    preprocessing_waitbar.Value = 9/26;
                                    % Filter Gaze Data
                                    [filtered_refraction_gaze_cells] = MedianFilter.median_gaze_filter(filtered_refraction_cells,gaze_filter_window_lengths);
                        
                                    preprocessing_waitbar.Value = 10/26;
                                    % Low Pass Butter Worth 5h Order, 20Hz FC, 50 FS
                                    [fully_filtered_cells] = ButterFilter.low_pass_filter(5,20,50,filtered_refraction_gaze_cells);
                        
                                    preprocessing_waitbar.Value = 11/26;
                                    %Save Preprocessed Data
                                    SaveProgress.save_progress_to_mat(fully_filtered_cells,cell_array_filenames,cell_array_subject_ids,"Filtered","Filtered");
                                    
                                    preprocessing_waitbar.Value = 12/26;
                                    % Take Derivative of Array Data 
                                    [differentiated_cell_arrays] = Differentiator.diff_data(1, fully_filtered_cells);
                    
                                    preprocessing_waitbar.Value = 13/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(differentiated_cell_arrays,cell_array_filenames,cell_array_subject_ids,"Differentiated","Derivative")
                    
                                    preprocessing_waitbar.Value = 14/26;
                                    % Parse Movements
                                    [parsed_movement_arrays, peak_velocity_indices] = IndividualMovementParser_v2.parse_data_to_movements(differentiated_cell_arrays);
                    
                                    preprocessing_waitbar.Value = 15/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(parsed_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Parsed","Parsed")
                    
                                    preprocessing_waitbar.Value = 16/26;
                                    % Parse Movements
                                    [offset_movement_arrays] = DataOffset.zero_offset_data(parsed_movement_arrays);
                    
                                    preprocessing_waitbar.Value = 17/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(offset_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Calibrated","Offset")
                    
                                    preprocessing_waitbar.Value = 18/26;
                                    % Parse Vergence Type
                                    [convergent_movements,divergent_movements] = VergenceType.vergence_movement_separator(offset_movement_arrays);
                    
                                    preprocessing_waitbar.Value = 19/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(convergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","CONV")
                    
                                    preprocessing_waitbar.Value = 20/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(divergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","DIV")
                
                                    preprocessing_waitbar.Value = 21/26;
                                    [convergent_metrics] = MetricAnalyzer.metric_analysis_tool(convergent_movements);
                
                                    preprocessing_waitbar.Value = 22/26;
                                    [divergent_metrics] = MetricAnalyzer.metric_analysis_tool(divergent_movements);
                
                                    preprocessing_waitbar.Value = 23/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(convergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","CONV")
                
                                    preprocessing_waitbar.Value = 24/26;
                                    % Save Progress
                                    SaveProgress.save_progress_to_mat(divergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","DIV")
                
                                    preprocessing_waitbar.Value = 26/26;
                                    preprocessing_waitbar.Message = "Preprocessing Complete!";
                                    pause(1)
                                    % Close Wait Bar
                                    close(preprocessing_waitbar);
            
                                    % Success Message
                                    uialert(targetFigure,'Subject Processing Complete!','Preprocessing','Icon','success','Modal',true)
                                end
                        % Parallel Preprocessing
                        % Removes uiprogressbar 
                        case true
                            % Separates Paths into Subject IDs and Filenames
                            [cell_array_subject_ids, cell_array_filenames] = FileNameSeparator.path_to_subject_id_and_filename(path, raw_files);
            
                            % Parses Tables into Cell Arrays
                            [cell_arrays] = ReadData.read_CSV(raw_files);
                
                            % Save Raw Data and Directory
                            SaveProgress.save_progress_to_mat(cell_arrays,cell_array_filenames,cell_array_subject_ids,"Raw","Raw");

                            % Standardize Missing Values within Cell Arrays
                            [standardized_cells,noise_percentage_cells,cell_array_filenames,cell_array_subject_ids,rejected_standardized_cells, rejected_noise_percentage_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids] = StandardizeMissingValues.standardize_missing_values(cell_arrays,cell_array_filenames,cell_array_subject_ids);
            
                            if(isequal(standardized_cells{1},0))
                                %Save Preprocessed Data
                                SaveProgress.save_progress_to_mat(rejected_standardized_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids,"Rejected","Rejected");
                                
                            elseif(isequal(rejected_standardized_cells{1},0))
                                % Determine largest filter window for Refraction Data PER file (L/R)
                                [refraction_filter_window_lengths] = FilterWindowLength.determine_refraction_filter_window_length(standardized_cells);

                                % Determine largest filter winfow for Gaze PER file (L/R)
                                [gaze_filter_window_lengths] = FilterWindowLength.determine_gaze_filter_window_length(standardized_cells);

                                % Clip Data to avoid boundary conditions related to NaNs
                                [prepared_cells] = DataPrefilterConditioning.prefilter_cells(standardized_cells, refraction_filter_window_lengths, gaze_filter_window_lengths);

                                % Save Filter Lengths
                                SaveProgress.save_progress_to_mat(refraction_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","RefractionFilters");
                                SaveProgress.save_progress_to_mat(gaze_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","GazeFilters");

                                % Filter Refraction Data
                                [filtered_refraction_cells] = MedianFilter.median_refraction_filter(prepared_cells,refraction_filter_window_lengths);

                                % Filter Gaze Data
                                [filtered_refraction_gaze_cells] = MedianFilter.median_gaze_filter(filtered_refraction_cells,gaze_filter_window_lengths);

                                % Low Pass Butter Worth 5th Order, 20Hz FC, 50 FS
                                [fully_filtered_cells] = ButterFilter.low_pass_filter(5,20,50,filtered_refraction_gaze_cells);

                                %Save Preprocessed Data
                                SaveProgress.save_progress_to_mat(fully_filtered_cells,cell_array_filenames,cell_array_subject_ids,"Filtered","Filtered");

                                % Take Derivative of Array Data 
                                [differentiated_cell_arrays] = Differentiator.diff_data(1, fully_filtered_cells);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(differentiated_cell_arrays,cell_array_filenames,cell_array_subject_ids,"Differentiated","Derivative")

                                % Parse Movements
                                [parsed_movement_arrays, peak_velocity_indices] = IndividualMovementParser_v2.parse_data_to_movements(differentiated_cell_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(parsed_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Parsed","Parsed")

                                % Parse Movements
                                [offset_movement_arrays] = DataOffset.zero_offset_data(parsed_movement_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(offset_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Calibrated","Offset")

                                % Parse Vergence Type
                                [convergent_movements,divergent_movements] = VergenceType.vergence_movement_separator(offset_movement_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(convergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","CONV")

                                % Save Progress
                                SaveProgress.save_progress_to_mat(divergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","DIV")

                                [convergent_metrics] = MetricAnalyzer.metric_analysis_tool(convergent_movements);

                                [divergent_metrics] = MetricAnalyzer.metric_analysis_tool(divergent_movements);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(convergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","CONV")

                                % Save Progress
                                SaveProgress.save_progress_to_mat(divergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","DIV")

                            else
                                %Save Rejected Data Data
                                SaveProgress.save_progress_to_mat(rejected_standardized_cells,rejected_cell_array_filenames,rejected_cell_array_subject_ids,"Rejected","Rejected");

                                % Determine largest filter window for Refraction Data PER file (L/R)
                                [refraction_filter_window_lengths] = FilterWindowLength.determine_refraction_filter_window_length(standardized_cells);

                                % Determine largest filter winfow for Gaze PER file (L/R)
                                [gaze_filter_window_lengths] = FilterWindowLength.determine_gaze_filter_window_length(standardized_cells);

                                % Clip Data to avoid boundary conditions related to NaNs
                                [prepared_cells] = DataPrefilterConditioning.prefilter_cells(standardized_cells, refraction_filter_window_lengths, gaze_filter_window_lengths);

                                % Save Filter Lengths
                                SaveProgress.save_progress_to_mat(refraction_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","RefractionFilters");
                                SaveProgress.save_progress_to_mat(gaze_filter_window_lengths,cell_array_filenames,cell_array_subject_ids,"FilterWindows","GazeFilters");
                    
                                % Filter Refraction Data
                                [filtered_refraction_cells] = MedianFilter.median_refraction_filter(prepared_cells,refraction_filter_window_lengths);

                                % Filter Gaze Data
                                [filtered_refraction_gaze_cells] = MedianFilter.median_gaze_filter(filtered_refraction_cells,gaze_filter_window_lengths);

                                % Low Pass Butter Worth 5th Order, 20Hz FC, 50 FS
                                [fully_filtered_cells] = ButterFilter.low_pass_filter(5,20,50,filtered_refraction_gaze_cells);

                                %Save Preprocessed Data
                                SaveProgress.save_progress_to_mat(fully_filtered_cells,cell_array_filenames,cell_array_subject_ids,"Filtered","Filtered");

                                % Take Derivative of Array Data 
                                [differentiated_cell_arrays] = Differentiator.diff_data(1, fully_filtered_cells);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(differentiated_cell_arrays,cell_array_filenames,cell_array_subject_ids,"Differentiated","Derivative")

                                % Parse Movements
                                [parsed_movement_arrays, peak_velocity_indices] = IndividualMovementParser_v2.parse_data_to_movements(differentiated_cell_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(parsed_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Parsed","Parsed")

                                % Parse Movements
                                [offset_movement_arrays] = DataOffset.zero_offset_data(parsed_movement_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(offset_movement_arrays,cell_array_filenames,cell_array_subject_ids,"Calibrated","Offset")

                                % Parse Vergence Type
                                [convergent_movements,divergent_movements] = VergenceType.vergence_movement_separator(offset_movement_arrays);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(convergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","CONV")
                                SaveProgress.save_progress_to_mat(divergent_movements,cell_array_filenames,cell_array_subject_ids,"Vergence","DIV")

                                % Metric Analysis
                                [convergent_metrics] = MetricAnalyzer.metric_analysis_tool(convergent_movements);
                                [divergent_metrics] = MetricAnalyzer.metric_analysis_tool(divergent_movements);

                                % Save Progress
                                SaveProgress.save_progress_to_mat(convergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","CONV")
            
                                % Save Progress
                                SaveProgress.save_progress_to_mat(divergent_metrics,cell_array_filenames,cell_array_subject_ids,"Metrics","DIV")
                            end
                    end
                catch ME
                    report = getReport(ME);

                    % Error Message
                    if(batchBoolean)
                        uialert(uifigure,report,'Error Processing','Interpreter','html')
                    else
                        uialert(targetFigure,report,'Error Processing','Interpreter','html')
                    end
                end
            else
                uialert(targetFigure,'File Processing Cancelled!','Process Cancellation','Icon','warning','Modal',true)
            end
        end
    end
end


