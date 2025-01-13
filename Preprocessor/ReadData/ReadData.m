%% Read Data Files

classdef ReadData
    methods (Static)
        function [cell_arrays] = read_CSV(list_of_full_file_paths)
            % Set up the Import Options
            opts = delimitedTextImportOptions("NumVariables", 36);

            % Specify range and delimiter
            opts.DataLines = [2, Inf];
            opts.Delimiter = ";";

            % Specify Column Names
            opts.VariableNames = ["Timems", "Segment", "Distancem", "Brightness", ...
                "PupilFoundL", "PupilSizeMMLXmm", "PupilSizeMMLYmm", "PupilDiameterMMLmm", ...
                "PupilBrightnessLDU", "PurkinjeSizeLXpx", "PurkinjeSizeLYpx", "DecentrationLXpx", ...
                "DecentrationLYpx", "GazeLX", "GazeLY", "RefractionLSphereDpt", "GetAverageRefractionLContents", ...
                "GetAverageRefractionLMeanDpt", "GetAverageRefractionLStdDeviationDpt", "PupilFoundR", ...
                "PupilSizeMMRXmm", "PupilSizeMMRYmm", "PupilDiameterMMRmm", "PupilBrightnessRDU", ...
                "PurkinjeSizeRXpx", "PurkinjeSizeRYpx", "DecentrationRXpx", "DecentrationRYpx", "GazeRX", ...
                "GazeRY", "RefractionRSphereDpt", "GetAverageRefractionRContents", "GetAverageRefractionRMeanDpt", ...
                "GetAverageRefractionRStdDeviationDpt", "InterpupDistmm", "InterpupAngle"];

            %Specifies all variables as doubles
            opts.VariableTypes = ["double", "double", "double", "double", "double", ...
                "double", "double", "double", "double", "double", "double", "double", "double", ...
                "double", "double", "double", "double", "double", "double", "double", "double", "double", ...
                "double", "double", "double", "double", "double", "double", "double", "double", "double", ...
                "double", "double", "double", "double", "double"];

            % Specify file level properties
            opts.ExtraColumnsRule = "ignore";
            opts.EmptyLineRule = "read";

            % Specify variable properties
            opts = setvaropts(opts, "Segment", "TrimNonNumeric", true);
            opts = setvaropts(opts, "Segment", "ThousandsSeparator", ",");

            %Checks Single File Condition
            if(numel(cellstr(list_of_full_file_paths)) == 1)
                list_of_full_file_paths = cellstr(list_of_full_file_paths);
            end

            %Preallocate Cell Array 
            cell_arrays = cell(1,length(list_of_full_file_paths));

            % Iterate through list of files provided by user
            for data_file_path_index = 1:length(list_of_full_file_paths)
                %Extract one file path 
                full_file_path = string(list_of_full_file_paths(:,data_file_path_index));
                temp_table = readtable(full_file_path,opts);

                %Temp_Table Converts to Cell Array for Storage
                cell_arrays{data_file_path_index} =  DataTypeConverter.table_to_array( ... 
                    temp_table(:,["RefractionLSphereDpt","PupilFoundL","GazeLX", "GazeLY", ...
                    "RefractionRSphereDpt","PupilFoundR","GazeRX","GazeRY"]));
            end

            % Clear temporary variables
            clear opts
        end
    end
end
