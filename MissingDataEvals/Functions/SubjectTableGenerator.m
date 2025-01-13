% Select Directory
selectedDirectory = uigetdir();

% Parse Directory Names
parentDirectoryNames = {dir(selectedDirectory).name}';
parentDirectoryNames = parentDirectoryNames(3:end);


% Subjects
subjects = parentDirectoryNames;

% Cues
% Baseline
BASELINE_BDP1 = zeros(size(parentDirectoryNames,1),1);
BASELINE_BLUR = zeros(size(parentDirectoryNames,1),1);
BASELINE_PROX = zeros(size(parentDirectoryNames,1),1);
BASELINE_CENT_DISP = zeros(size(parentDirectoryNames,1),1);
BASELINE_PER_DISP = zeros(size(parentDirectoryNames,1),1);
BASELINE_BLUR_PROX = zeros(size(parentDirectoryNames,1),1);
BASELINE_BLUR_DISP = zeros(size(parentDirectoryNames,1),1);
BASELINE_DISP_PROX = zeros(size(parentDirectoryNames,1),1);
BASELINE_BDP2 = zeros(size(parentDirectoryNames,1),1);

% Outcome
OUTCOME_BDP1 = zeros(size(parentDirectoryNames,1),1);
OUTCOME_BLUR = zeros(size(parentDirectoryNames,1),1);
OUTCOME_PROX = zeros(size(parentDirectoryNames,1),1);
OUTCOME_CENT_DISP = zeros(size(parentDirectoryNames,1),1);
OUTCOME_PER_DISP = zeros(size(parentDirectoryNames,1),1);
OUTCOME_BLUR_PROX = zeros(size(parentDirectoryNames,1),1);
OUTCOME_BLUR_DISP = zeros(size(parentDirectoryNames,1),1);
OUTCOME_DISP_PROX = zeros(size(parentDirectoryNames,1),1);
OUTCOME_BDP2 = zeros(size(parentDirectoryNames,1),1);


% Table Generation
diagnosticsTable = table(BASELINE_BDP1,BASELINE_BLUR,BASELINE_PROX,BASELINE_CENT_DISP,BASELINE_PER_DISP,BASELINE_BLUR_PROX,BASELINE_BLUR_DISP,BASELINE_DISP_PROX,BASELINE_BDP2,...
    OUTCOME_BDP1,OUTCOME_BLUR,OUTCOME_PROX,OUTCOME_CENT_DISP,OUTCOME_PER_DISP,OUTCOME_BLUR_PROX,OUTCOME_BLUR_DISP,OUTCOME_DISP_PROX,OUTCOME_BDP2, ...
    'RowNames',parentDirectoryNames,'DimensionNames',["Subject_ID","MovementData"]);


for directorySubjectNames = 1:size(parentDirectoryNames,1)
    if(contains(parentDirectoryNames{directorySubjectNames},"NIH"))
        childDirectory = {dir(fullfile(selectedDirectory,parentDirectoryNames{directorySubjectNames})).name}';
        childDirectory = childDirectory(3:end);
        for childFiles = 1:size(childDirectory,1)
            if(contains(childDirectory{childFiles},"NIH"))

                parsingString = strsplit(childDirectory{childFiles}, "_");

                if(size(parsingString,2)==6)
                    parsingString{4} = strcat(parsingString{4},'_',parsingString{5});
                end


                diagnosticsTable(parentDirectoryNames{directorySubjectNames},strcat(parsingString{3},"_",parsingString{4})) = {1};
 
            end
        end
    end
end

writetable(diagnosticsTable,fullfile(uigetdir(),"SubjectCueResponseTable.xlsx"),'WriteRowNames',true);
