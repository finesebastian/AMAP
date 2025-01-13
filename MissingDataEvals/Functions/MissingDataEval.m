% Select Directory
selectedDirectory = uigetdir();

% Parse Directory Names
parentDirectoryNames = {dir(selectedDirectory).name}';

dataPercentCell = {};

for directorySubjectNames = 1:size(parentDirectoryNames,1)
    if(contains(parentDirectoryNames{directorySubjectNames},"NIH"))
        childDirectory = {dir(fullfile(selectedDirectory,parentDirectoryNames{directorySubjectNames})).name}';
        for childFiles = 1:size(childDirectory,1)
            if(contains(childDirectory{childFiles},"NIH"))
                temp_data = load(fullfile(selectedDirectory,parentDirectoryNames{directorySubjectNames},childDirectory{childFiles}));
                temp_data = temp_data.current_data;

                % Left Eye
                missing_refraction_data_l_percent = size(find(temp_data(:,1)==-100 | isnan(temp_data(:,1))),1) / size(temp_data,1)*100;
                missing_pupilfound_boolean_l_percent = size(find(temp_data(:,2)==0 | isnan(temp_data(:,2))),1) / size(temp_data,1)*100;
                missing_gaze_data_l_percent = size(find(abs(temp_data(:,3))>5 | isnan(temp_data(:,3))),1) / size(temp_data,1)*100;

                % Right Eye
                missing_refraction_data_r_percent = size(find(temp_data(:,5)==-100 | isnan(temp_data(:,5))),1) / size(temp_data,1)*100;
                missing_pupilfound_boolean_r_percent = size(find(temp_data(:,6)==0 | isnan(temp_data(:,6))),1) / size(temp_data,1)*100;
                missing_gaze_data_r_percent = size(find(abs(temp_data(:,7))>5 | isnan(temp_data(:,7))),1) / size(temp_data,1)*100;
                
                parsingString = strsplit(childDirectory{childFiles}, "_");

                if(size(parsingString,2)==6)
                    parsingString{4} = strcat(parsingString{4},'_',parsingString{5});
                end

                if(size(dataPercentCell,1)==0)
                    rowIndex = 1;
                else
                    rowIndex = rowIndex +1 ;
                end

                % Subject, Timing, Movement, Right Missing %, Left Missing %
                dataPercentCell{rowIndex,1} = parsingString{1};
                dataPercentCell{rowIndex,2} = parsingString{3};
                dataPercentCell{rowIndex,3} = parsingString{4};
                dataPercentCell{rowIndex,4} = round(missing_refraction_data_l_percent,2);
                dataPercentCell{rowIndex,5} = round(missing_pupilfound_boolean_l_percent,2);
                dataPercentCell{rowIndex,6} = round(missing_gaze_data_l_percent,2);
                dataPercentCell{rowIndex,7} = round(missing_refraction_data_r_percent,2);
                dataPercentCell{rowIndex,8} = round(missing_pupilfound_boolean_r_percent,2);
                dataPercentCell{rowIndex,9} = round(missing_gaze_data_r_percent,2);
            end
        end
    end
end

writetable(cell2table(dataPercentCell,"VariableNames",{'SubjectName','Timing','MovementType','Left Missing Refraction Data %', 'Left Missing PupilBoolean Data %', 'Left Missing Gaze Data %', ...
    'Right Missing Refraction Data %', 'Right Missing PupilBoolean Data %', 'Right Missing Gaze Data %'}),fullfile(uigetdir(),"RawDataMissingValuesEvaluation.xlsx"));
