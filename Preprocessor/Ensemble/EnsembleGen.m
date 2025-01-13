%% Identifies subject type for their plot colors and axis limits
% Blue RGB (TBI Baseline): 170 170 220 | ErrorBars | 'b' Traces 
% Green RGB (Control): 159 250 142 | ErrorBars | 'g' Traces 
% Red RGB (TBI Active): 255 87 51 | ErrorBars | 'r' Traces

list = {'TBI Outcome','TBI Baseline','Control'};
[indx,tf] = listdlg('PromptString',{'Select Subject/Timing Type'},'SelectionMode','single','ListString',list);

switch indx
    case 1
        rgb_value = uint8([255 87 51]);
        color_val = uint8([209, 33, 19]);
    case 2
        rgb_value = uint8([170 170 220]);
        color_val = uint8([5, 26, 252]);
    case 3
        rgb_value = uint8([159 250 142]);
        color_val = uint8([18, 130, 48]);
end

mov_list = {'Vergence','Saccades'};
[mov_type,tf] = listdlg('PromptString',{'Select Type'},'SelectionMode','single','ListString',mov_list);

switch mov_type
    case 1
        axis_ratios = 5;
        %Default Convergence
        y_pos_lower_bound = -1.25;
        y_pos_upper_bound = 5;
    case 2
        axis_ratios = 40;
        %Default Version
        y_pos_lower_bound = -1.25;
        y_pos_upper_bound = 6;
end

figureNameInput = inputdlg('Plot Names');

ensemble_figure_Velocity = figure('Renderer','painters',"Name","Velocity");
merged_figure_Vel = axes(ensemble_figure_Velocity);

ensemble_figure_MeanMovement = figure('Renderer','painters',"Name","Mean Movement");
merged_figure_MeanMov = axes(ensemble_figure_MeanMovement);

ensemble_figure_MeanMovementDev = figure('Renderer','painters',"Name","Mean Movement +");
merged_figure_MeanMovDev = axes(ensemble_figure_MeanMovementDev);

[b,a]=butter(7,30/500,'low');
alllgreenlines=findall(groot,'Type','Line','Color','g');

if(~isempty(alllgreenlines))
    graphval=alllgreenlines.YData;
    siz=size(alllgreenlines);
    lines=siz(1,1);
    alllinesbnc=NaN(lines,size(graphval,2));
    meanlinebnc=NaN(lines,size(graphval,2));
    stdlinebnc=NaN(lines,size(graphval,2));
    time = linspace(0,(size(graphval,2))/500,size(graphval,2));
    for i = [1: lines]
        currentval=alllgreenlines(i,1);
        currentline=currentval.YData;
        alllinesbnc(i,:)=currentline;
    end
    
    meanlinebnc=mean(alllinesbnc,1,'omitnan');
    stdlinebnc=std(alllinesbnc,0,1,'omitnan');
    
    meanlinebnc = filter(b,a,meanlinebnc);
    
    velo=[0, diff(meanlinebnc)./.002;];
    
    velofiltered=filter(b,a,velo);
    
    time2=time;
    time2(1)=[];
    
    peakvelbnc=max(velofiltered);
    
    
    % This is the Velocity Section
    yyaxis(merged_figure_Vel,'left')
    average_velocity = plot(merged_figure_Vel ,time,velofiltered,'LineStyle','--','LineWidth',2.5,'Color',color_val);
    title(merged_figure_Vel,strcat(figureNameInput," Velocity"));
    
    % This is the Position Section
    % This is the Mean Movement + Deviation Section
    yyaxis(merged_figure_MeanMovDev,'right')
    %------------------------------------------------------------\/
    averaged_trace = plot(merged_figure_MeanMovDev ,time,meanlinebnc,'color',color_val,'linewidth',2,'linestyle','-');
    hold on
    
    error_bars = errorbar(merged_figure_MeanMovDev ,time,meanlinebnc,stdlinebnc,'color',rgb_value,'CapSize',0);
    error_bars.LineStyle = 'none';
    set([error_bars.Bar, error_bars.Line],'ColorType', 'truecoloralpha', 'ColorData', [error_bars.Line.ColorData(1:3); 255*.1])
    
    title(merged_figure_MeanMovDev ,strcat(figureNameInput," Mean + Deviation Trace"));
    
    % This is the Position Section
    % This is the Mean Movement
    yyaxis(merged_figure_MeanMov,'right')
    %------------------------------------------------------------\/
    averaged_trace = plot(merged_figure_MeanMov ,time,meanlinebnc,'color',color_val,'linewidth',2,'linestyle','-');
    title(merged_figure_MeanMov ,strcat(figureNameInput," Mean Trace"));
    
    movement_peak_velocity = velofiltered(abs(velofiltered) == max(abs(velofiltered)));
    
    if movement_peak_velocity < 0
        temp_lower = y_pos_lower_bound;
        y_pos_lower_bound = -1*y_pos_upper_bound;
        y_pos_upper_bound = -1*temp_lower;
    end
    
    % This Adjusts the Axis Boundaries
    if(movement_peak_velocity < 0 && y_pos_upper_bound < 0)
        % Divergence
    
        % Mean Movement + Deviation
        yyaxis(merged_figure_MeanMovDev ,'right')
        refraction_lower = linspace(0, y_pos_lower_bound,5);
        refraction_upper = linspace(y_pos_upper_bound, 0,10);
        refraction_ticks = [refraction_upper,refraction_lower(2:end)];
        ylim(merged_figure_MeanMovDev,[y_pos_upper_bound, y_pos_lower_bound]);
    
        % Mean Movement
        yyaxis(merged_figure_MeanMov ,'left')
        velocity_ticks = refraction_ticks*axis_ratios;
        ylim(merged_figure_MeanMov,[y_pos_lower_bound*axis_ratios, y_pos_upper_bound*axis_ratios])
        set(ensemble_figure_MeanMovement.CurrentAxes ,'YColor','k')
    
        yyaxis(merged_figure_MeanMov   ,'right')
        refraction_lower = linspace(0, y_pos_lower_bound,5);
        refraction_upper = linspace(y_pos_upper_bound, 0,10);
        refraction_ticks = [refraction_upper,refraction_lower(2:end)];
        ylim(merged_figure_MeanMov,[y_pos_upper_bound, y_pos_lower_bound]);
    %     yticks(merged_figure,refraction_ticks);
        
        % Velocity
        yyaxis(merged_figure_Vel ,'left')
        velocity_ticks = refraction_ticks*axis_ratios;
        ylim(merged_figure_Vel,[y_pos_upper_bound*axis_ratios, y_pos_lower_bound*axis_ratios])
    %     yticks(merged_figure,velocity_ticks)
    else
        % Convergence
    
        % Mean Movement + Deviation
        yyaxis(merged_figure_MeanMovDev ,'right')
        refraction_lower = linspace(y_pos_lower_bound,0,5);
        refraction_upper = linspace(0,y_pos_upper_bound,10);
        refraction_ticks = [refraction_lower,refraction_upper(2:end)];
        ylim(merged_figure_MeanMovDev,[y_pos_lower_bound,y_pos_upper_bound]);
        set(ensemble_figure_MeanMovementDev.CurrentAxes,'YColor','k')   
    %     yticks(merged_figure,refraction_ticks);
    
        % Mean Movement
        yyaxis(merged_figure_MeanMov ,'left')
        velocity_ticks = refraction_ticks*axis_ratios;
        ylim(merged_figure_MeanMov,[y_pos_lower_bound*axis_ratios, y_pos_upper_bound*axis_ratios])
        set(ensemble_figure_MeanMovement .CurrentAxes ,'YColor','k')
    
        yyaxis(merged_figure_MeanMov ,'right')
        refraction_lower = linspace(y_pos_lower_bound,0,5);
        refraction_upper = linspace(0,y_pos_upper_bound,10);
        refraction_ticks = [refraction_lower,refraction_upper(2:end)];
        ylim(merged_figure_MeanMov,[y_pos_lower_bound,y_pos_upper_bound]);
        set(ensemble_figure_MeanMovement.CurrentAxes,'YColor','k')
    %     yticks(merged_figure,refraction_ticks);
    
        % Velocity
        yyaxis(merged_figure_Vel ,'right')
        set(ensemble_figure_Velocity.CurrentAxes ,'YColor','k')
        yyaxis(merged_figure_Vel ,'left')
        velocity_ticks = refraction_ticks*axis_ratios;
        ylim(merged_figure_Vel,[y_pos_lower_bound*axis_ratios, y_pos_upper_bound*axis_ratios])
        set(ensemble_figure_Velocity.CurrentAxes ,'YColor','k')
    %     yticks(merged_figure,velocity_ticks)
    end   
    %  set(ensemble_figure.CurrentAxes,'SortMethod','Depth')
    set(ensemble_figure_Velocity.CurrentAxes,'color','none')
    set(ensemble_figure_MeanMovement.CurrentAxes,'color','none')
    set(ensemble_figure_MeanMovementDev.CurrentAxes,'color','none')
    
    selectedPath = uigetdir(fullfile('C:/AMAP_Output/'),'Select Save Location');
    
    saveFileNameInput = inputdlg('Save File As:');
    if(~isempty(saveFileNameInput))
        saveFileNameInput = saveFileNameInput{1}; 
        emf_directory = fullfile(selectedPath,strcat(saveFileNameInput,'_EMF'));
        fig_directory = fullfile(selectedPath,strcat(saveFileNameInput,'_FIG'));
        mkdir(emf_directory);
        mkdir(fig_directory);
        % EMFs
        % Velocity
        exportgraphics(ensemble_figure_Velocity,fullfile(emf_directory,strcat(saveFileNameInput,'_VelocityTrace','.emf')))
        % Mean Movements
        exportgraphics(ensemble_figure_MeanMovement,fullfile(emf_directory,strcat(saveFileNameInput,'_MeanMovementTrace','.emf')))
        % Mean Movements +
        exportgraphics(ensemble_figure_MeanMovementDev,fullfile(emf_directory,strcat(saveFileNameInput,'_MeanMovementDeviationTrace','.emf')))
        
        % FIGS
        % Velocity
        saveas(ensemble_figure_Velocity,fullfile(fig_directory,strcat(saveFileNameInput,'_VelocityTrace')),'fig')
        % Mean Movements
        saveas(ensemble_figure_MeanMovement,fullfile(fig_directory,strcat(saveFileNameInput,'_MeanMovementTrace')),'fig')
        % Mean Movements +
        saveas(ensemble_figure_MeanMovementDev,fullfile(fig_directory,strcat(saveFileNameInput,'_MeanMovementDeviationTrace')),'fig')
        
        % Clean Up Figures
        close all;
    end
end
    