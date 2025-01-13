%% Imports Data Files

classdef ImportData
    methods(Static)
        %Returns List of File Names, and Directory Path to CSV
        function [list_of_file_paths, path] = get_raw_csv_data()

            % Creates UI that allows multiselect of .csv files
            [list_of_file_paths, path] = uigetfile("MultiSelect","on", ...
                {'*_Maddox_*.csv*','RAW CSV Files'}, ...
                'Raw Data Import',fullfile("/EASE/Raw/"));
            list_of_file_paths = string(list_of_file_paths);
        end

        %Returns List of File Names, and Directory Path to CSV
        function [list_of_file_paths, path] = get_raw_calibration_data(raw_data_path)

            % Creates UI that allows multiselect of .csv files
            [list_of_file_paths, path] = uigetfile("MultiSelect","off", ...
                {'*_plusoptixCal-*.csv*','RAW Cal CSV'}, ...
                'Raw Calibration Import',fullfile(raw_data_path));
            list_of_file_paths = string(list_of_file_paths);
        end

        %Import Preprocessed Data
        function [file_list] = import_preprocessed_data()
            % Calls UI that allows multi-select on .m files
            [file_list, path] = uigetfile("MultiSelect", "on",...
                {'*.m*', 'Preprocessed Files (.m)'},...
                'Preprocessed Data Import');
            file_list = fullfile(path,file_list);
        end
    end
end

