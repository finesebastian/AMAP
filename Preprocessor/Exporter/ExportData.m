%% Export Processed Mat Files to Excel

classdef ExportData
    % Select .m Files from DATA>Processed
    methods(Static)
        function [export_directory] = get_export_directory()
                export_directory = uigetdir('C:/AMAP_Output/','Processed Metrics Export');
        end
        
        function [data_table,average_table] = export_directory(export_directory, isFilterExport)
            list_of_unprocessed_files(1) = [""];
            num_failed_files = 1;
            if(export_directory(1) ~= 0)
                % Creates Struct from selected dir 
                directory_hierarchy = dir(export_directory);
                directorySize = size(directory_hierarchy,1);
                data_export = [];
                average_table = [];
                for data=1:directorySize
                    % Removes Sys Files
                    if(contains(directory_hierarchy(data).name,'NIH'))
                        % Evaluates if Subject Folder (isdir == 1)
                        if(directory_hierarchy(data).isdir)
                            % Unpack Directory to its Subject Files
                            internal_dir = dir(fullfile(directory_hierarchy(data).folder,directory_hierarchy(data).name));
                            internal_dir_cell_array = struct2cell(internal_dir);

                            % Names of Each File Contained within Directory
                            completeFileNames = string(internal_dir_cell_array(1,cell2mat(internal_dir_cell_array(5,:))~=1));
                            
                            % Formatting Conformity for Folder Pathing
                            filePath = char(string(internal_dir_cell_array(2,1))+'\');

                            for export_files = 1:size(completeFileNames,2)
                                export_matrix_data = struct2array(ExportData.open_matrix(filePath,completeFileNames(export_files)));
                                if(isFilterExport)
                                    [export_table_data,export_table_data_averages] = ExportData.generate_filter_table(export_matrix_data,completeFileNames(export_files), directory_hierarchy(data).name);
                                else
                                    vergenceType = strsplit(directory_hierarchy(data).name,"_");
                                    vergenceType = vergenceType{2};
                                    [export_table_data,export_table_data_averages] = ExportData.generate_table(export_matrix_data,completeFileNames(export_files),vergenceType);
                                end
                                data_export = [data_export;export_table_data];
                                average_table = [average_table;export_table_data_averages];
                            end
                        end
                    end
                end
                data_table = data_export;
            end
        end

        function export(isFilterExport)
            % Check isFilter condition to modify Excel Table
            if(isFilterExport)
                inputName = "FilterExport";
                dataDirectory = 'C:\AMAP_Output\DATA\FilterWindows';
            else
                inputName = "MetricExport";
                dataDirectory = ExportData.get_export_directory();
            end

            % Decomposes Directory Heirarchies to get File Names and Pathing 
            if(dataDirectory(1) ~= 0)
                [data_table_export, data_table_export_averages] = ExportData.export_directory(dataDirectory, isFilterExport);
                pathName = char('C:/AMAP_Output/' + inputName + "_" + string(datetime('today','InputFormat','yyyy-MM-dd')) + ".xlsx");
                if(isfile(pathName))
                    writetable(data_table_export,pathName,'WriteMode','Append','WriteRowNames',true,'WriteVariableNames',false,'Sheet','Raw_Movements','PreserveFormat',true);
                    writetable(data_table_export_averages,pathName,'WriteMode','Append','WriteRowNames',true,'WriteVariableNames',false,'Sheet','Movement_Averages','PreserveFormat',true);
                else
                    writetable(data_table_export,pathName,'WriteRowNames',true,'WriteVariableNames',true,'Sheet','Raw_Movements','PreserveFormat',true);
                    writetable(data_table_export_averages,pathName,'WriteRowNames',true,'WriteVariableNames',true,'Sheet','Movement_Averages','PreserveFormat',true);
                end
            end
        end

        function data_matrix = open_matrix(filepath,filename)
            data_matrix = load(fullfile(filepath,filename));
        end

        function [export_table,export_table_averages] = generate_table(export_matrix,file_name,vergence_type)
            combined_array = [];
            movement_name = [];
            spss_conforming_matrix = zeros(1,39);
            movement_averages = [];
            decomposed_filename = strsplit(file_name,"_");

            if(size(decomposed_filename,2) == 6)
                decomposed_filename(4) = strcat(decomposed_filename(4),"_",decomposed_filename(5));
            end

            for movement_count = 1:size(export_matrix,3)
                current_movement = export_matrix(:,:,movement_count);
                current_movement(:,end) = [];
                transposed_matrix = reshape(current_movement,[1,39]);
                transposed_matrix(1,40) = movement_count;
                spss_conforming_matrix = [decomposed_filename(1),decomposed_filename(3),decomposed_filename(4),vergence_type,transposed_matrix];
                combined_array = vertcat(combined_array,spss_conforming_matrix);
                movement_name = vertcat(movement_name,strcat(file_name,"_",int2str(movement_count)));

                if(current_movement(end,end)==1)
                    movement_averages = [movement_averages;current_movement(3,1:end-1)];
                end
            end
                metric_averages = mean(movement_averages,1);
                spss_conforming_average_matrix = [decomposed_filename(1),decomposed_filename(3),decomposed_filename(4),vergence_type,metric_averages,size(export_matrix,3)];

            export_table = array2table(combined_array,"RowNames",movement_name,'VariableNames', {'Subject_ID','Timing','Cue','Movement_Type', ...
                'Left_Peak_Velocity_Diopters_per_Sec', 'Right_Peak_Velocity_Diopters_per_Sec', 'Average_Peak_Velocity_Diopters_per_Sec', ...
                'Left_Response_Amplitude_Diopters', 'Right_Response_Amplitude_Diopters', 'Average_Response_Amplitude_Diopters', ...
                'Left_Final_Amplitude_Diopters', 'Right_Final_Amplitude_Diopters', 'Average_Final_Amplitude_Diopters', ...
                'Left_RSI_Seconds', 'Right_RSI_Seconds', 'Average_RSI_Seconds', ...
                'Left_PVI_Seconds', 'Right_PVI_Seconds', 'Average_PVI_Seconds', ...
                'Left_REI_Seconds', 'Right_REI_Seconds', 'Average_REI_Seconds', ...
                'Left_Gaze_Peak_Velocity_Degrees_per_Sec', 'Right_Gaze_Peak_Velocity_Degrees_per_Sec', 'Combined_Gaze_Peak_Velocity_Degrees_per_Sec', ...
                'Left_Gaze_Response_Amplitude_Degrees', 'Right_Gaze_Response_Amplitude_Degrees', 'Combined_Gaze_Response_Amplitude_Degrees', ...
                'Left_Gaze_Final_Amplitude_Degrees', 'Right_Gaze_Final_Amplitude_Degrees', 'Combined_Gaze_Final_Amplitude_Degrees', ...
                'Left_Gaze_RSI_Seconds', 'Right_Gaze_RSI_Seconds', 'Combined_Gaze_RSI_Seconds', ...
                'Left_Gaze_PVI_Seconds', 'Right_Gaze_PVI_Seconds', 'Combined_Gaze_PVI_Seconds', ...
                'Left_Gaze_REI_Seconds', 'Right_Gaze_REI_Seconds', 'Combined_Gaze_REI_Seconds', ...
                'Left_Classification_0_Bad_1_Good', 'Right_Classification_0_Bad_1_Good', 'Binocular_Classification_0_Bad_1_Good', ...
                'Movement_Index'});
        
            export_table = convertvars(export_table,{'Left_Peak_Velocity_Diopters_per_Sec', 'Right_Peak_Velocity_Diopters_per_Sec', 'Average_Peak_Velocity_Diopters_per_Sec', ...
                'Left_Response_Amplitude_Diopters', 'Right_Response_Amplitude_Diopters', 'Average_Response_Amplitude_Diopters', ...
                'Left_Final_Amplitude_Diopters', 'Right_Final_Amplitude_Diopters', 'Average_Final_Amplitude_Diopters', ...
                'Left_RSI_Seconds', 'Right_RSI_Seconds', 'Average_RSI_Seconds', ...
                'Left_PVI_Seconds', 'Right_PVI_Seconds', 'Average_PVI_Seconds', ...
                'Left_REI_Seconds', 'Right_REI_Seconds', 'Average_REI_Seconds', ...
                'Left_Gaze_Peak_Velocity_Degrees_per_Sec', 'Right_Gaze_Peak_Velocity_Degrees_per_Sec', 'Combined_Gaze_Peak_Velocity_Degrees_per_Sec', ...
                'Left_Gaze_Response_Amplitude_Degrees', 'Right_Gaze_Response_Amplitude_Degrees', 'Combined_Gaze_Response_Amplitude_Degrees', ...
                'Left_Gaze_Final_Amplitude_Degrees', 'Right_Gaze_Final_Amplitude_Degrees', 'Combined_Gaze_Final_Amplitude_Degrees', ...
                'Left_Gaze_RSI_Seconds', 'Right_Gaze_RSI_Seconds', 'Combined_Gaze_RSI_Seconds', ...
                'Left_Gaze_PVI_Seconds', 'Right_Gaze_PVI_Seconds', 'Combined_Gaze_PVI_Seconds', ...
                'Left_Gaze_REI_Seconds', 'Right_Gaze_REI_Seconds', 'Combined_Gaze_REI_Seconds', ...
                'Left_Classification_0_Bad_1_Good', 'Right_Classification_0_Bad_1_Good', 'Binocular_Classification_0_Bad_1_Good', ...
                'Movement_Index'},'double');


            export_table_averages = array2table(spss_conforming_average_matrix,"RowNames",file_name,'VariableNames', {'Subject_ID','Timing','Cue','Movement_Type', ...
                'Peak_Velocity_Diopters_per_Second', ...
                'Response_Amplitude_Diopters', ...
                'Final_Amplitude_Diopters', ...
                'RSI_Seconds', ...
                'PVI_Seconds', ...
                'REI_Seconds', ...
                'Gaze_Peak_Velocity_Degrees_per_Second', ...
                'Gaze_Response_Amplitude_Degrees', ...
                'Gaze_Final_Amplitude_Degrees', ...
                'Gaze_RSI_Seconds', ...
                'Gaze_PVI_Seconds', ...
                'Gaze_REI_Seconds', ...
                'N'});

            export_table_averages = convertvars(export_table_averages,{'Peak_Velocity_Diopters_per_Second', ...
                'Response_Amplitude_Diopters', ...
                'Final_Amplitude_Diopters', ...
                'RSI_Seconds', ...
                'PVI_Seconds', ...
                'REI_Seconds', ...
                'Gaze_Peak_Velocity_Degrees_per_Second', ...
                'Gaze_Response_Amplitude_Degrees', ...
                'Gaze_Final_Amplitude_Degrees', ...
                'Gaze_RSI_Seconds', ...
                'Gaze_PVI_Seconds', ...
                'Gaze_REI_Seconds', ...
                'N'},'double');
        end

        function [export_table,export_table_averages] = generate_filter_table(export_matrix, file_name, parent_folder)
            combined_array = [];
            movement_name = [];
            spss_conforming_matrix = zeros(1,5);
            movement_averages = [];
            decomposed_filename = strsplit(file_name,"_");
            filterType = strsplit(string(parent_folder),"_");

            if(size(decomposed_filename,2) == 6)
                decomposed_filename(4) = strcat(decomposed_filename(4),"_",decomposed_filename(5));
            end

            for movement_count = 1:size(export_matrix)
                transposed_matrix = export_matrix(movement_count);
                spss_conforming_matrix = [filterType(2), decomposed_filename(1), decomposed_filename(3), decomposed_filename(4), int16(transposed_matrix)];
                combined_array = vertcat(combined_array,spss_conforming_matrix);
                movement_name = vertcat(movement_name,strcat(file_name,"_",filterType(2)));
                movement_averages = [movement_averages;export_matrix(movement_count)];
            end

            metric_averages = mean(movement_averages,1);
            spss_conforming_average_matrix = [filterType(2), decomposed_filename(1), decomposed_filename(3), decomposed_filename(4), metric_averages];

            export_table = array2table(combined_array,"RowNames",movement_name,'VariableNames',{'Filter Type','Subject_ID','Timing','Movement_Type', 'Filter Window Length'});
        
            export_table = convertvars(export_table,{'Filter Window Length'},'double');

            export_table_averages = array2table(spss_conforming_average_matrix,"RowNames",strcat(file_name, "_", parent_folder),'VariableNames',{'Filter Type','Subject_ID','Timing','Movement_Type', 'Filter Window Length'});

            export_table_averages = convertvars(export_table_averages,{'Filter Window Length'},'double');
        end
    end
end