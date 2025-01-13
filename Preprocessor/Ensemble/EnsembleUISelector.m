%% Presents UI Selection for Ensemble Generation

classdef EnsembleUISelector
    methods(Static)
        % Returns Users Ensemble Selection
        function [selectionIndex] = ensemble_selection()
            list = {'Subject Ensemble','Combined Ensemble'};
            [selectionIndex, ~] = listdlg('PromptString',{'Select Ensemble Type'},'SelectionMode','single','ListString',list);
        end
    end
end
