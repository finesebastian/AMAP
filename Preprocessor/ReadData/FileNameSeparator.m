%% Intakes Files and Returns Filename from Path

classdef FileNameSeparator
    methods(Static)
        %Separates file path/name/extension
        function [cell_array_of_subject_ids,cell_array_of_file_names] = path_to_subject_id_and_filename(path, raw_file_paths)

            if(~iscell(raw_file_paths))
                raw_file_paths = cellstr(raw_file_paths);
            end
            % Preallocate Cell Arrays
            cell_array_of_subject_ids = cell(1,size(raw_file_paths,2));
            cell_array_of_file_names = cell(1,size(raw_file_paths,2));
            if(size(raw_file_paths,2)>1)
                for cell_index = 1:size(raw_file_paths,2)
                    raw_files = raw_file_paths(cell_index);
                    [path, file_name, file_ext] = fileparts(fullfile(path, raw_files));
                    subject_id = FileNameSeparator.subject_id_locator_from_path(path);
                    cell_array_of_subject_ids{cell_index} = subject_id;
                    cell_array_of_file_names{cell_index} = file_name;
                end
            else
                raw_files = raw_file_paths;
                [path, file_name, file_ext] = fileparts(fullfile(path, raw_files));
                subject_id = FileNameSeparator.subject_id_locator_from_path(path);
                cell_array_of_subject_ids{1} = subject_id;
                cell_array_of_file_names{1} = file_name;
            end
        end

         % Extracts Subject ID from File Path
         function [subject_id] = subject_id_locator_from_path(file_pathway)
            %Takes file path within subject folder to return subject ID
            subject_id = strcat('NIH',extractAfter(file_pathway,"\NIH"));
         end

         % Extracts Subject ID from File Path
         function [subject_id_experiment] = subject_id_experiment_locator_from_name(file_name)
            %Takes file name to return subject ID
            if(contains(file_name,"Maddox"))
                subject_id_experiment = extractBefore(file_name,"_S");
            else
                subject_id_experiment = extractBefore(file_name,"-");
            end
         end
    end
end



