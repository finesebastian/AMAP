%% Select Subject and Timing Type

classdef EnsembleColorSelector
    methods(Static)
        function [errorBar_ColorSelection,trace_ColorSelection,subject_type,movement_type] = color_selection(movement_name)

         % Evaluate Baseline/Outcome
            % Outcome - Red
            % Baseline - Blue
            if(contains(movement_name,"OUTCOME"))
                errorBar_ColorSelection = uint8([255 87 51]);
                trace_ColorSelection = uint8([209, 33, 19]);
            else
                errorBar_ColorSelection = uint8([170 170 220]);
                trace_ColorSelection = uint8([5, 26, 252]);
            end

        % Presents User with Subject Type
            list = {'CI','Control'};
            [indx, ~] = listdlg('PromptString',{'Select Subject Type'},'SelectionMode','single','ListString',list);
            if(~isempty(indx))
                switch indx
                    case 1
                        subject_type = "CI";
                    case 2
                        subject_type = "Control";
                end
    
            % Presents User with Movement Type
                list = {'Convergence','Divergence'};
                [indx, ~] = listdlg('PromptString',{'Select Vergence Type'},'SelectionMode','single','ListString',list);
                
                if(~isempty(indx))
                    switch indx
                        case 1
                            movement_type = "Conv";
                        case 2
                            movement_type = "Div";
                    end
                else
                    errorBar_ColorSelection = [];
                    trace_ColorSelection = [];
                    subject_type = [];
                    movement_type = [];
                end
            else
                errorBar_ColorSelection = [];
                trace_ColorSelection = [];
                subject_type = [];
                movement_type = [];
            end
        end
    end
end