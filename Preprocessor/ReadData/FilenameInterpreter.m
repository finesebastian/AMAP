%% Separates File Names based on Dictionaries

classdef FilenameInterpreter
    methods(Static)
        % Takes raw file names and creates array of information
        function [translated_filenames] = interpret_filename(cell_array_of_filenames)
            if(contains(cell_array_of_filenames{1},"BASELINE") || contains(cell_array_of_filenames{1},"OUTCOME"))
                translated_filenames{1}=extractBefore(cell_array_of_filenames{1},"_1")+"_";
            else
                % Hard Coded Dictionary Pattern for Mapping
                keys = ["S1","S2","_1","_2","_3","_4","_5","_6","_7","_8","_9","_plusoptixCal"];
                values = ["BASELINE","OUTCOME","BDP1_","BLUR_","PROX_","CENT_DISP_","PER_DISP_","BLUR_PROX_","BLUR_DISP_","DISP_PROX_","BDP2_","Calibration_"];
    
                % Preallocate Space for Arrays
                translation_logical_array = false(length(keys));
                translated_filenames = cell(1,size(cell_array_of_filenames,2));
    
                % Iterate through list of filenames
                for cell_index = 1:length(cell_array_of_filenames)
                    current_filename = cell_array_of_filenames{cell_index};
                    current_subject_experiment = FileNameSeparator.subject_id_experiment_locator_from_name(current_filename);
    
                    for key_index = 1:length(values)
                        test_value_pattern = keys(key_index);
                        translation_logical_array(key_index) = contains(current_filename, test_value_pattern);
                    end
       
                    translated_filenames{cell_index} = join([current_subject_experiment,values(translation_logical_array)],"_");
                end
            end
        end
    end
end










            

