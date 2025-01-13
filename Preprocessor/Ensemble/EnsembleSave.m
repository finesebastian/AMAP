%% Intakes list of figure variables to be saved as split EMFs and FIGs

classdef EnsembleSave
    methods(Static)
        % Takes list of Figure Variables and iterate through saving them
        % into appropriate directories
        function saveEnsembleFigures(list_of_figures,list_of_figure_names, subject_id, movement_name,subject_Type,vergence_type)
            if(~isempty(list_of_figures))
                % Save Location
                save_pathway = fullfile('C:/AMAP_Output/EnsemblePlotData/',subject_Type,subject_id);

                % Evaluate Baseline/Outcome
                if(contains(movement_name,"OUTCOME"))
                    group_level_path = fullfile('C:/AMAP_Output/EnsemblePlotData/',subject_Type,'Outcome_Data',vergence_type);
                    save_pathway = strcat(save_pathway,'\',subject_id,'_Outcome');
                    movement_type = extractAfter(movement_name,"OUTCOME_"); 
                else
                    group_level_path = fullfile('C:/AMAP_Output/EnsemblePlotData/',subject_Type,'Baseline_Data',vergence_type);
                    save_pathway = strcat(save_pathway,'\',subject_id,'_Baseline');
                    movement_type = extractAfter(movement_name,"BASELINE_");
                end

                % String Split with "_" Pattern
                splitMovement = strsplit(movement_type, "_");

                % Movement Name Extraction
                if(size(splitMovement,2) == 3)
                    movement_type = strcat(splitMovement(1),"_",splitMovement(2));
                else
                    movement_type = splitMovement(1);
                end

                group_level_path = strcat(group_level_path,'\',movement_type);

                % Generate Group Level Directories
                mkdir(group_level_path);

                % GenPath EnsemblePlot
                addpath(genpath('EnsemblePlotData'));

                % Generate EMF Directory
                emf_directory = strcat(save_pathway,'\',subject_id,'_EMF','\',movement_type);
                mkdir(emf_directory);
                
                % Generate FIG Directory
                fig_directory = strcat(save_pathway,'\',subject_id,'_FIG','\',movement_type);
                mkdir(fig_directory);

                % Iterate through Figure List
                for currentFigureIndex = 1:(size(list_of_figures,2))
                    currentFigure = list_of_figures(currentFigureIndex);

                    % EMFs
                    exportgraphics(currentFigure,strcat(emf_directory,'\',movement_type,'_',vergence_type,'_',list_of_figure_names(currentFigureIndex),'.emf'))

                    % FIGS
                    saveas(currentFigure,strcat(fig_directory,'\',movement_type,'_',vergence_type,'_',list_of_figure_names(currentFigureIndex)),'fig')
                  
                    % Store Group-Level Plots in Parity
                    if(contains(currentFigure.Tag,"Average Refraction Position"))
                        % FIG
                        mkdir(strcat(group_level_path,'\','Refraction'))
                        saveas(currentFigure,strcat(group_level_path,'\','Refraction','\',movement_type,'_',list_of_figure_names(currentFigureIndex),'_',subject_id),'fig')

                    elseif(contains(currentFigure.Tag,"Average Refraction Velocity"))
                        % FIG
                        mkdir(strcat(group_level_path,'\','Refraction_Velocity'))
                        saveas(currentFigure,strcat(group_level_path,'\','Refraction_Velocity','\',movement_type,'_',list_of_figure_names(currentFigureIndex),'_',subject_id),'fig')

                    elseif(contains(currentFigure.Tag,"Combined Gaze Position"))
                        % FIG
                        mkdir(strcat(group_level_path,'\','Gaze'))
                        saveas(currentFigure,strcat(group_level_path,'\','Gaze','\',movement_type,'_',list_of_figure_names(currentFigureIndex),'_',subject_id),'fig')

                    elseif(contains(currentFigure.Tag,"Combined Gaze Velocity"))
                        % FIG
                        mkdir(strcat(group_level_path,'\','Gaze_Velocity'))
                        saveas(currentFigure,strcat(group_level_path,'\','Gaze_Velocity','\',movement_type,'_',list_of_figure_names(currentFigureIndex),'_',subject_id),'fig')               
                    else
                    end

                end
                % GenPath EnsemblePlot
                addpath('C:\AMAP_Output\EnsemblePlotData');
            end
        end
    end
end