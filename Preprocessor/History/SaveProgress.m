%% File Save Functions

classdef SaveProgress
    methods(Static)

        % Saves Cells into .mat files with Cell Array of Names
        function save_progress_to_mat(cell_array_of_data, cell_array_of_file_names, cell_array_of_subject_ids, directory_title, progress_title)

            %Generates Directory Path List for Storing Subject Data 
            list_of_directory_paths = DirectoryGenerator.generate_directory(cell_array_of_subject_ids, directory_title, progress_title);

            %Generates Translated File Names
            translated_filenames = FilenameInterpreter.interpret_filename(cell_array_of_file_names);

            for cell_index = 1:size(cell_array_of_data,2)
                if (~isempty(DataTypeConverter.cell_to_array(cell_array_of_data(cell_index))))
                    % Current Directory to Store Data
                    current_directory = string(list_of_directory_paths{cell_index});
    
                    % Current Filename to Save As
                    current_filename = string(translated_filenames{cell_index});
    
                    % Current Data to Save from Cell Array
                    current_data = DataTypeConverter.cell_to_array(cell_array_of_data(cell_index));
    
                    % Processing Time
                    batch_unix_timestamp = string(ceil(posixtime(datetime('now','TimeZone','local'))));
    
                    % Generate Full Path
                    save_path = fullfile(current_directory,strcat(current_filename,batch_unix_timestamp,".mat"));
                    
                    % Save File and Data
                    save(save_path,'current_data','-mat');
                end
            end
        end
    end
end

                
