%% This class generates Ensembles for Movements Displayed in AMAP

classdef MovementEnsemble
    methods (Static)
        function individualMovementEnsemble(movement_cell_matrix,movement_name,trace_color,errorbar_color,subject_Type,movement_type)

            % Default Graphing Values
                % Velocity/Position
                axis_ratio_vergence = 5;
                axis_ratio_refraction = 3;

                % Default Refraction
                y_ref_lower_bound = -.5;
                y_ref_upper_bound = 6;

                % Default Type Convergence
                y_ver_lower_bound = -.5;
                y_ver_upper_bound = 6;

             % Validate Loaded Data
             if (~isempty(movement_cell_matrix))
                    % Preallocate Space
                    collated_movement_matrices = zeros(150,14,size(movement_cell_matrix,2));
                    % Capture Empty Indices
                    emptyData = [];
    
                    % Condenses Cell Array into 150x14xN Matrix
                    for cell_index = 1:size(movement_cell_matrix,2)
                        if(isempty(movement_cell_matrix{cell_index}))
                            emptyData = [emptyData;cell_index];
                        else
                            collated_movement_matrices(:,:,cell_index)=movement_cell_matrix{cell_index};
                        end
                    end
                    
                    % Remove Empty Indices
                    collated_movement_matrices(:,:,emptyData) = [];

                    % Generate Time Vector for Graphing
                    time_vector = linspace(0,size(collated_movement_matrices,1)/50,size(collated_movement_matrices,1));

            % Preallocate Space
                % Refraction
                mean_movement = zeros(size(collated_movement_matrices,1),1);
                mean_left_movement = zeros(size(collated_movement_matrices,1),1);
                mean_right_movement = zeros(size(collated_movement_matrices,1),1);
                mean_movement_peak_velocity = zeros(size(collated_movement_matrices,1),1);
                
                dev_movement = zeros(size(collated_movement_matrices,1),1);
                %dev_left_movement = zeros(size(collated_movement_matrices,1),1);
                %dev_right_movement = zeros(size(collated_movement_matrices,1),1);

                % Gaze
                combined_gaze_movement = zeros(size(collated_movement_matrices,1),1);
                mean_left_gaze = zeros(size(collated_movement_matrices,1),1);
                mean_right_gaze = zeros(size(collated_movement_matrices,1),1);
                combined_gaze_peak_velocity = zeros(size(collated_movement_matrices,1),1);
                
                dev_gaze = zeros(size(collated_movement_matrices,1),1);
                %dev_left_gaze = zeros(size(collated_movement_matrices,1),1);
                %dev_right_gaze = zeros(size(collated_movement_matrices,1),1);
                

            for row_movement = 1:length(collated_movement_matrices(:,1,1))
                % Refraction
                    % Average Refraction
                    mean_movement(row_movement,1) = mean((collated_movement_matrices(row_movement,1,:)/2+collated_movement_matrices(row_movement,8,:)/2),'omitnan');
                    dev_movement(row_movement,1) = std(((collated_movement_matrices(row_movement,1,:)/2+collated_movement_matrices(row_movement,8,:)/2)),'omitnan');
    
                    % Left Eye Average Refraction
                    mean_left_movement(row_movement,1) = mean((collated_movement_matrices(row_movement,1,:)),'omitnan');
                    %dev_left_movement(row_movement,1) = std((collated_movement_matrices(row_movement,1,:)),'omitnan');
    
                    % Right Eye Average Refraction
                    mean_right_movement(row_movement,1) = mean((collated_movement_matrices(row_movement,8,:)),'omitnan');
                    %dev_right_movement(row_movement,1) = std((collated_movement_matrices(row_movement,8,:)),'omitnan');
    
                    % Average Velocity
                    mean_movement_peak_velocity(row_movement,1) = mean((collated_movement_matrices(row_movement,2,:)/2+(collated_movement_matrices(row_movement,9,:)/2)),'omitnan')*50;
            
               % Gaze
                    % Average Gaze
                    combined_gaze_movement(row_movement,1) = mean((collated_movement_matrices(row_movement,4,:)+collated_movement_matrices(row_movement,11,:)),'omitnan');
                    dev_gaze(row_movement,1) = std(((collated_movement_matrices(row_movement,4,:)+collated_movement_matrices(row_movement,11,:))),'omitnan');
                    
                    % Left Eye Average Gaze
                    mean_left_gaze(row_movement,1) = mean((collated_movement_matrices(row_movement,4,:)),'omitnan');
                    %dev_left_movement(row_movement,1) = std((collated_movement_matrices(row_movement,1,:)),'omitnan');
                    
                    % Right Eye Average Gaze
                    mean_right_gaze(row_movement,1) = mean((collated_movement_matrices(row_movement,11,:)),'omitnan');
                    %dev_right_movement(row_movement,1) = std((collated_movement_matrices(row_movement,8,:)),'omitnan');
                    
                    % Average Velocity
                    combined_gaze_peak_velocity(row_movement,1) = mean((collated_movement_matrices(row_movement,5,:)+(collated_movement_matrices(row_movement,12,:))),'omitnan')*50;
            end

            % Refraction Figures
                % Ensemble + Mean + Deviation
                    ensemble_mean_refraction_dev_figure = figure('Renderer','painters','Visible','off','Tag','Average Deviation Refraction Ensemble Refraction Position');
                    ensemble_mean_refraction_dev_axes = axes(ensemble_mean_refraction_dev_figure);

                % Mean Refraction + Deviation
                    mean_refraction_figure = figure('Renderer','painters','Visible','off','Tag','Average Refraction Position');
                    mean_refraction_axes = axes(mean_refraction_figure);
        
                    mean_refraction_dev_figure = figure('Renderer','painters','Visible','off','Tag','Average Deviation Refraction Position');
                    mean_refraction_dev_axes = axes(mean_refraction_dev_figure);
    
                    mean_velocity_figure = figure('Renderer','painters','Visible','off','Tag','Average Refraction Velocity');
                    mean_velocity_axes = axes(mean_velocity_figure);
    
                % Left Refraction
                    left_refraction_figure = figure('Renderer','painters','Visible','off','Tag','Left Refraction Position');
                    left_refraction_axes = axes(left_refraction_figure);
    
                % Right Refraction
                    right_refraction_figure = figure('Renderer','painters','Visible','off','Tag','Right Refraction Position');
                    right_refraction_axes = axes(right_refraction_figure);

            % Gaze Figures
                % Ensemble + Combined + Deviation
                    ensemble_combined_gaze_dev = figure('Renderer','painters','Visible','off','Tag','Combined Gaze Ensemble Deviation Gaze Position');
                    ensemble_combined_gaze_dev_axes = axes(ensemble_combined_gaze_dev);

                % Mean Gaze + Deviation
                    combined_gaze_figure = figure('Renderer','painters','Visible','off','Tag','Combined Gaze Position');
                    combined_gaze_axes = axes(combined_gaze_figure);
        
                    combined_gaze_dev_figure = figure('Renderer','painters','Visible','off','Tag','Combined Deviation Gaze Position');
                    combined_gaze_dev_axes = axes(combined_gaze_dev_figure);
    
                    combined_gaze_velocity_figure = figure('Renderer','painters','Visible','off','Tag','Combined Gaze Velocity');
                    combined_gaze_velocity_axes = axes(combined_gaze_velocity_figure);
    
                % Left Gaze
                    left_gaze_figure = figure('Renderer','painters','Visible','off','Tag','Left Gaze Position');
                    left_gaze_axes = axes(left_gaze_figure);
    
                % Right Gaze
                    right_gaze_figure = figure('Renderer','painters','Visible','off','Tag','Right Gaze Position');
                    right_gaze_axes = axes(right_gaze_figure);

            % Plotting
                % Average Refraction
                yyaxis(mean_refraction_axes,'right')
                plot(mean_refraction_axes ,time_vector,mean_movement,'color',trace_color,'linewidth',2.5,'linestyle','-');

                % Average Refraction + Deviation
                yyaxis(mean_refraction_dev_axes,'right')  
                x = time_vector';
                y = mean_movement;
                dy = dev_movement;
            
                fill(mean_refraction_dev_axes,[x;flipud(x)],[y-dy;flipud(y+dy)],errorbar_color, 'linestyle','none', 'FaceAlpha', 0.25);
                line(mean_refraction_dev_axes,x,y,'Color',trace_color,'LineWidth',2.5)

                % Ensemble Refraction 
                for movement=1:size(collated_movement_matrices,3)
                    plot(ensemble_mean_refraction_dev_axes,time_vector,collated_movement_matrices(:,[1,8],movement),'Color',[.7 .7 .7]);
                    hold(ensemble_mean_refraction_dev_axes,"on")
                end
                hold(ensemble_mean_refraction_dev_axes,"on")
                plot(ensemble_mean_refraction_dev_axes,time_vector,mean_movement,'LineWidth',2,'Color',[0.39,0.83,0.07],'LineStyle','-')

                % Average Refraction Velocity  
                yyaxis(mean_velocity_axes,'left')
                plot(mean_velocity_axes,time_vector,mean_movement_peak_velocity,'LineStyle','--','LineWidth',2.5,'Color',trace_color);
                refraction_velocity_sign = mean_movement_peak_velocity((abs(mean_movement_peak_velocity) == max(abs(mean_movement_peak_velocity))));
                    
                % Left Refraction
                yyaxis(left_refraction_axes,'right')
                plot(left_refraction_axes ,time_vector,mean_left_movement,'color',trace_color,'linewidth',2.5,'linestyle','-');
                    
                % Right Refraction
                yyaxis(right_refraction_axes,'right')
                plot(right_refraction_axes ,time_vector,mean_right_movement,'color',trace_color,'linewidth',2.5,'linestyle','-');
                    
                % Combined Gaze
                yyaxis(combined_gaze_axes,'right')
                plot(combined_gaze_axes,time_vector,combined_gaze_movement,'color',trace_color,'linewidth',2.5,'linestyle','-');

                    
                % Combined Gaze + Deviation
                yyaxis(combined_gaze_dev_axes,'right')  

                x = time_vector';
                y = combined_gaze_movement;
                dy = dev_gaze;
            
                fill(combined_gaze_dev_axes,[x;flipud(x)],[y-dy;flipud(y+dy)],errorbar_color, 'linestyle','none', 'FaceAlpha', 0.25);
                line(combined_gaze_dev_axes,x,y,'Color',trace_color,'LineWidth',2.5,'LineStyle','-')

                % Ensemble Gaze with Mean + Deviation
                for movement=1:size(collated_movement_matrices,3)
                    plot(ensemble_combined_gaze_dev_axes,time_vector,collated_movement_matrices(:,4,movement)+collated_movement_matrices(:,11,movement),'Color',[.7 .7 .7]);
                    hold(ensemble_combined_gaze_dev_axes,"on")
                end
                hold(ensemble_combined_gaze_dev_axes,"on")
                plot(ensemble_combined_gaze_dev_axes,time_vector,combined_gaze_movement,'LineWidth',2,'Color',[0.39,0.83,0.07],'LineStyle','-')
                    
                % Combined Gaze Velocity 
                yyaxis(combined_gaze_velocity_axes,'left')
                plot(combined_gaze_velocity_axes,time_vector,combined_gaze_peak_velocity,'LineStyle','--','LineWidth',2.5,'Color',trace_color);
                gaze_velocity_sign = combined_gaze_peak_velocity((abs(combined_gaze_peak_velocity) == max(abs(combined_gaze_peak_velocity))));
                    
                % Left Gaze
                yyaxis(left_gaze_axes,'right')
                plot(left_gaze_axes,time_vector,mean_left_gaze,'color',trace_color,'linewidth',2.5,'linestyle','-');
                    
                % Right Gaze
                yyaxis(right_gaze_axes,'right')
                plot(right_gaze_axes,time_vector,mean_right_gaze,'color',trace_color,'linewidth',2.5,'linestyle','-');    

                % Subject ID
                subject_id = extractBefore(movement_name,"_Maddox");

                % Figure Names
                figure_names = ["Average_Refraction_Deviation","Average_Refraction","Average_Refraction_Velocity","Left_Refraction","Right_Refraction","Combined_Gaze_Deviation","Combined_Gaze","Combined_Gaze_Velocity","Left_Gaze","Right_Gaze","Gaze Ensemble", "Refraction Ensemble"];
                
                % Figure List
                figure_list = [mean_refraction_dev_figure,mean_refraction_figure,mean_velocity_figure,left_refraction_figure,right_refraction_figure,combined_gaze_dev_figure,combined_gaze_figure,combined_gaze_velocity_figure,left_gaze_figure,right_gaze_figure,ensemble_combined_gaze_dev,ensemble_mean_refraction_dev_figure];
    
                if gaze_velocity_sign < 0
                    temp_lower = y_ver_lower_bound;
                    y_ver_upper_bound = -1*y_ver_upper_bound;
                    y_ver_lower_bound = -1*temp_lower;
                end
                if refraction_velocity_sign < 0
                    temp_lower = y_ref_lower_bound;
                    y_ref_upper_bound = -1*y_ref_upper_bound;
                    y_ref_lower_bound = -1*temp_lower;
                end
    
                % Axis Formatting
                for figureIndex = 1:size(figure_list,2)
                    currentFigure = figure_list(figureIndex);
                    if(contains(currentFigure.Tag,'Gaze Ensemble'))
                        if(gaze_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[-6, .5]);
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[-6, .5]);
                        else
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[-.5,6]);
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[-.5,6]);
                        
                        end
                    elseif(contains(currentFigure.Tag,'Gaze Position'))
                        if(gaze_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ver_upper_bound, y_ver_lower_bound]);
                        else
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ver_lower_bound,y_ver_upper_bound]);
                        
                        end
                    elseif(contains(currentFigure.Tag,'Gaze Velocity'))
                        if(gaze_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ver_upper_bound, y_ver_lower_bound]);
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[y_ver_upper_bound*axis_ratio_vergence, y_ver_lower_bound*axis_ratio_vergence])
                        else
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ver_lower_bound,y_ver_upper_bound]);
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[y_ver_lower_bound*axis_ratio_vergence, y_ver_upper_bound*axis_ratio_vergence])
                        end
                    elseif(contains(currentFigure.Tag,'Refraction Ensemble'))
                        if(refraction_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[-3, .5]);
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[-3, .5]);
                        else
                            yyaxis(currentFigure.CurrentAxes,'left')
                            ylim(currentFigure.CurrentAxes,[-.5,3]);
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[-.5,3]);
                        end
                    elseif(contains(currentFigure.Tag,'Refraction Position'))
                        if(refraction_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ref_upper_bound, y_ref_lower_bound]);
                        else
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ref_lower_bound,y_ref_upper_bound]);
                        end
                    else
                        if(refraction_velocity_sign < 0)
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ref_upper_bound, y_ref_lower_bound]);
                            yyaxis(currentFigure.CurrentAxes ,'left')
                            ylim(currentFigure.CurrentAxes,[y_ref_upper_bound*axis_ratio_refraction, y_ref_lower_bound*axis_ratio_refraction])
                        else
                            yyaxis(currentFigure.CurrentAxes,'right')
                            ylim(currentFigure.CurrentAxes,[y_ref_lower_bound,y_ref_upper_bound]);
                            yyaxis(currentFigure.CurrentAxes ,'left')
                            ylim(currentFigure.CurrentAxes,[y_ref_lower_bound*axis_ratio_refraction, y_ref_upper_bound*axis_ratio_refraction])
                        end
    
                    end
                end
                EnsembleSave.saveEnsembleFigures(figure_list,figure_names,subject_id,movement_name,subject_Type,movement_type);
            end
        end
    end
end
