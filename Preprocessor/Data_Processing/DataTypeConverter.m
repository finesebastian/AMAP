%% Accepts File and Path outputs Full File Paths

classdef DataTypeConverter
    methods(Static)       
        % Inputs MatLab Table and Returns Cell Array
        function [array_data] = table_to_array(list_of_tables)
           array_data = table2array(list_of_tables);
        end
        
        %Inputs Cell Array and Returns MatLab Matrix
        function [array_data] = cell_to_array(cell)
                array_data = cell2mat(cell);
        end
    end
end
