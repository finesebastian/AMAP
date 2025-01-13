%% Provides parallel-processing capabilities for accommodative movement analysis.

classdef BatchProcessor
   % Enables User to select Complete "Raw" Directories for Preprocessing
    methods (Static)
        % Decomposes Directory Heirarchies to get File Names and
        % Pathing for individual PreProcessor Calls (Modularity)
        function batch_process(targetFigure)
            % Select Directory
            selected_directory = uigetdir();

            if(selected_directory(1) ~= 0)
                % Add path to MATLAB
                addpath(selected_directory);
    
                preprocessing_waitbar = uiprogressdlg(targetFigure,"Title",'Preprocessing','Value',0,'ShowPercentage','on');
                list_of_unprocessed_files(1) = [""];
            
                % Creates Struct from selected dir 
                directory_hierarchy = dir(selected_directory);
                directorySize = size(directory_hierarchy,1);

                % Initializing Notification
                preprocessing_waitbar.Message = "Spooling Parallel Workers";
                preprocessing_waitbar.Indeterminate ='on';

                % Start Parallel Worker Pool
                parWorkers = parpool(feature('numcores'));

                % Begin Parallel Operations
                preprocessing_waitbar.Message = "Processing ... "+directorySize+" Participants Identified";

                % Start Parallel Loop
                parfor(data=1:directorySize)
                    % Removes Sys Files
                    if(contains(directory_hierarchy(data).name,'NIH'))
                        % Evaluates if Subject Folder (isdir == 1)
                        if(directory_hierarchy(data).isdir)
                            % Unpack Directory to its Subject Files
                            internal_dir = dir(fullfile(directory_hierarchy(data).folder,directory_hierarchy(data).name));
                            internal_dir_cell_array = struct2cell(internal_dir);
                            completeFileNames = string(internal_dir_cell_array(1,cell2mat(internal_dir_cell_array(5,:))~=1));
                            
                            % Formatting Conformity for Preprocessor
                            filePath = char(string(internal_dir_cell_array(2,1))+'\');
                            try
                                Preprocessor.preprocess_raw_data(true, completeFileNames, filePath,[])
                            catch ME
                                disp(ME)
                                disp(directory_hierarchy(data).name)
                            end
                        end
                    end
                end

                % Delete Worker Pool
                delete(parWorkers)

                % Output Filter Lengths to Excel
                ExportData.export(true);

                % Successful Processing Progression
                preprocessing_waitbar.Indeterminate ='off';
                preprocessing_waitbar.Value = 1;

                % Close UIProgress Bar
                close(preprocessing_waitbar)

                % Success Prompt
                uialert(targetFigure,'Batch Processing Complete!','Preprocessing','Icon','success','Modal',true)
            else
                uialert(targetFigure,'Batch Processing Cancelled!','Process Cancellation','Icon','warning','Modal',true)
            end
        end
    end
end
