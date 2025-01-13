%% Creates Directorys for provided Data

classdef DirectoryGenerator
    methods(Static)
        function [list_of_directory_paths] = generate_directory(cell_array_of_subject_ids, directory_title, progress_title)

            % Disable Warnings for Existing Directories
            warning('off')

            % Preallocate Cell Array Space
            list_of_directory_paths = cell(1,length(cell_array_of_subject_ids));

            % Generate Directory to populate
            parent_directory = fullfile('C:\AMAP_Output\DATA\',directory_title);
            mkdir(parent_directory);
            addpath(parent_directory);

            if(~isempty(progress_title))
                % Iterates through each subject to create directory
                for cell_index = 1:length(cell_array_of_subject_ids)
                    current_subject = cell_array_of_subject_ids{cell_index};
                    directory_name = strcat(current_subject,'_',progress_title);
                    list_of_directory_paths{cell_index} = fullfile(parent_directory,directory_name);
                    mkdir(fullfile(parent_directory,directory_name));
    
                    % Add Parent Directory Path
                    addpath(genpath('DATA'));
                end
            else
                list_of_directory_paths = parent_directory;
            end
        end
    end
end

                