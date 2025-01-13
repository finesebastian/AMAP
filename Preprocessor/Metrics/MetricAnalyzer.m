%% Evaluate Set of Movements within Cell Array

classdef MetricAnalyzer
    methods(Static)

         % Determine: Peak Velocity, Response Amplitude, Final Amplitude
         function [movement_metrics_cell_array] = metric_analysis_tool(cell_array_of_movements)

            % Preallocate Space for Cell Arrays
            movement_metrics_cell_array = cell(1,length(cell_array_of_movements));

            % Iterates through Cell Array
            for cell_index = 1:length(cell_array_of_movements)

                if(isempty(cell_array_of_movements{cell_index}))
                    % Do Nothing %
                else
                    % Convert Cell Array to Matrix
                    current_array = DataTypeConverter.cell_to_array(cell_array_of_movements(cell_index));
                
                    % Preallocate Space for Cell Arrays
                    metrics = nan(3,12,size(current_array,3));
                    
                    % Iterate through all found movements
                    for page_index = 1:size(current_array,3)
                    
                        % Selects movement from page index
                        current_movement = current_array(:,:,page_index); 
                    
                        % Returns Peak Velocity Indices within the first 
                        % 1 Samples / 50 Hz ~ .02 Seconds (first sample) to 
                        % 100 Samples / 50 Hz ~ 2 Seconds
                        peak_vel_ind_left = find(abs(current_movement((1:125),2))== max(abs(current_movement((1:125),2))),1);
                        peak_vel_ind_right = find(abs(current_movement((1:125),9))== max(abs(current_movement((1:125),9))),1);
                        peak_vel_ind_average = find(abs((current_movement((1:125),2)+current_movement((1:125),9)))/2 == max(abs((current_movement((1:125),2)+current_movement((1:125),9)))/2),1);

                        % Acceleration Data
                        acc_left = [0; diff(current_movement(:,2))];
                        acc_right = [0; diff(current_movement(:,9))];
                        acc_average = [0; diff((current_movement(:,2)+current_movement(:,9))/2)];
                        
                        % Response Amplitude Indicies based on Acceleration
                        resp_amp_ind_left = find(sign(acc_left((peak_vel_ind_left+2):end)) == -sign(acc_left(peak_vel_ind_left+2)),1)+peak_vel_ind_left;
                        resp_amp_ind_right = find(sign(acc_right((peak_vel_ind_right+2):end)) == -sign(acc_right(peak_vel_ind_right+2)),1)+peak_vel_ind_right;
                        resp_amp_ind_average = find(sign(acc_average(peak_vel_ind_average+2:end)) == -sign(acc_average(peak_vel_ind_average+2)),1)+peak_vel_ind_average;
                        
                        % Evaluate Response Amplitude Indices
                        % Substitute Empty for Other Eye Index
                        if(isempty(resp_amp_ind_left))
                            resp_amp_ind_left = resp_amp_ind_right;
                        elseif(isempty(resp_amp_ind_right))
                            resp_amp_ind_right = resp_amp_ind_left;
                        end

                        %Find where Velocity Starts
                        peak_vel_starting_ind_left = peak_vel_ind_left - find(sign(acc_left(peak_vel_ind_left:-1:1)) ~= sign(acc_left(peak_vel_ind_left)),1);
                        peak_vel_starting_ind_right = peak_vel_ind_right - find(sign(acc_right(peak_vel_ind_right:-1:1)) ~= sign(acc_right(peak_vel_ind_right)),1);
                        peak_vel_starting_ind_average = peak_vel_ind_average - find(sign(acc_average(peak_vel_ind_average:-1:1)) ~= sign(acc_average(peak_vel_ind_average)),1);
                        
                        % Evaluate Index Values
                        % If Starting Index is at the beginning of the movement
                        % default value is set to 1
                        if(peak_vel_starting_ind_left == 0)
                            peak_vel_starting_ind_left = 1;
                        end
                        if (peak_vel_starting_ind_right == 0)
                            peak_vel_starting_ind_right = 1;
                        end
                        if(peak_vel_starting_ind_average == 0)
                            peak_vel_starting_ind_average =1;
                        end
    
                        % Make Temp Velocity Matrix
                        vel_left = current_movement(:,2);
                        vel_right = current_movement(:,9);
                        vel_average = (current_movement(:,2) + current_movement(:,9))/2;
                    
                        % Create Default Values for Integration
                        response_amplitude_left = NaN;
                        response_amplitude_right = NaN;
                        response_amplitude_average = NaN;
                    
                        % Response Amplitude via Culmulative Trapezoidal Sums
                        % Boundaries based on inflection points of Acceleration Pre/Post Peak
                        % Velocity
                        response_amplitude_left = cumtrapz(vel_left(peak_vel_starting_ind_left:resp_amp_ind_left));
                        response_amplitude_right = cumtrapz(vel_right(peak_vel_starting_ind_right:resp_amp_ind_right));
                        response_amplitude_average = cumtrapz(vel_average(peak_vel_starting_ind_average:resp_amp_ind_average));
                    
                        % Make Temporary Refraction Matrix
                        refraction_left = current_movement(:,1);
                        refraction_right = current_movement(:,8);
                        refraction_average = (current_movement(:,1) + current_movement(:,8))/2;
                        
                        % Final Amplitude
                        final_amp_left = mean(refraction_left(end-25:end,1));
                        final_amp_right = mean(refraction_right(end-25:end,1));
                        final_amp_average = mean(refraction_average(end-25:end,1));
                    
                        % Velocity default unit -> diopters/sample
                        % 50 Samples/Second (Hz) Capture Rate
                        % X diopters/sample * 50 Hz -> X diopters/second

                        % RSI
                        if (isempty(peak_vel_starting_ind_average))
                            average_eye_RSI = 10/50;
                        else
                            average_eye_RSI = peak_vel_starting_ind_average/50;
                        end

                         % RSI
                        if (isempty(peak_vel_starting_ind_left))
                            left_eye_RSI = average_eye_RSI;
                        else
                            left_eye_RSI = peak_vel_starting_ind_left/50;
                        end
                        % RSI
                        if (isempty(peak_vel_starting_ind_right))
                            right_eye_RSI = average_eye_RSI;
                        else
                            right_eye_RSI = peak_vel_starting_ind_right/50;
                        end

                        % PVI
                        if (isempty(peak_vel_ind_average))
                            average_eye_PVI = 10/50;
                        else
                            average_eye_PVI = peak_vel_ind_average/50;
                        end
                        % PVI
                        if (isempty(peak_vel_ind_left))
                            left_eye_PVI = average_eye_PVI;
                        else
                            left_eye_PVI = peak_vel_ind_left/50;
                        end
                        % PVI
                        if (isempty(peak_vel_ind_right))
                            right_eye_PVI = average_eye_PVI;
                        else
                            right_eye_PVI = peak_vel_ind_right/50;
                        end

                        % REI
                        if (isempty(resp_amp_ind_average))
                            average_eye_REI = 10/50;
                        else
                            average_eye_REI = resp_amp_ind_average/50;
                        end
                        % REI
                        if (isempty(resp_amp_ind_left))
                            left_eye_REI = average_eye_REI;
                        else
                            left_eye_REI = resp_amp_ind_left/50;
                        end
                        % REI
                        if (isempty(resp_amp_ind_right))
                            right_eye_REI = average_eye_REI;
                        else
                            right_eye_REI = resp_amp_ind_right/50;
                        end

                        % Average Eye Metrics
                        % Velocity
                        if (isempty(vel_average(uint8(average_eye_PVI*50))))
                            average_eye_PV = nan;
                        else
                            average_eye_PV = vel_average(uint8(average_eye_PVI*50))*50;
                        end

                        % Left Eye Metrics
                        % Velocity
                        if (isempty(vel_left(uint8(left_eye_PVI*50))))
                            left_eye_PV = vel_left(uint8(average_eye_PVI*50))*50;
                        else
                            left_eye_PV = vel_left(uint8(left_eye_PVI*50))*50;
                        end
                        % Right Eye Metrics
                        % Velocity
                        if (isempty(vel_right(uint8(right_eye_PVI*50))))
                            right_eye_PV = vel_right(uint8(average_eye_PVI*50))*50;
                        else
                            right_eye_PV = vel_right(uint8(right_eye_PVI*50))*50;
                        end
                        
                        % Response Amplitude
                        if (isempty(response_amplitude_average))
                            average_eye_RA = nan;
                        else
                            average_eye_RA = response_amplitude_average(end);
                        end
                        % Response Amplitude
                        if (isempty(response_amplitude_left))
                            left_eye_RA = nan;
                        else
                            left_eye_RA = response_amplitude_left(end);
                        end
                        % Response Amplitude
                        if (isempty(response_amplitude_right))
                            right_eye_RA = nan;
                        else
                            right_eye_RA = response_amplitude_right(end);
                        end 


                        % Gaze Metrics
                        [gaze_vel_left,gaze_vel_ind_left] = max(abs(current_movement((1:(left_eye_PVI*50+25)),5)));
                        gaze_vel_left = current_movement(gaze_vel_ind_left,5)*50;
                        [gaze_vel_right,gaze_vel_ind_right] = max(abs(current_movement((1:(right_eye_PVI*50+25)),12)));
                        gaze_vel_right = current_movement(gaze_vel_ind_right,12)*50;
                        [gaze_vel_combined,gaze_vel_ind_combined] = max(abs((current_movement((1:(average_eye_PVI*50+25)),5)+current_movement((1:(average_eye_PVI*50+25)),12))));
                        gaze_vel_combined = (current_movement(gaze_vel_ind_combined,5)+current_movement(gaze_vel_ind_combined,12))*50;

                        % Gaze Response Amplitude REI
                        % Left Gaze
                        if (~isempty(gaze_vel_ind_left))
                            gaze_left_resp_amp_REI =((gaze_vel_ind_left + (find(sign(current_movement(gaze_vel_ind_left:end,5)) ~= sign(current_movement(gaze_vel_ind_left,5)),1)))+1)/50;
                        elseif(~isempty(gaze_vel_ind_right))
                            gaze_left_resp_amp_REI =((gaze_vel_ind_right + (find(sign(current_movement(gaze_vel_ind_right:end,5)) ~= sign(current_movement(gaze_vel_ind_right,5)),1)))+1)/50;
                        end
                        % Right Gaze
                        if (~isempty(gaze_vel_ind_right))
                            gaze_right_resp_amp_REI =((gaze_vel_ind_right + (find(sign(current_movement(gaze_vel_ind_right:end,12)) ~= sign(current_movement(gaze_vel_ind_right,12)),1)))+1)/50;
                        elseif(~isempty(gaze_vel_ind_left))
                            gaze_right_resp_amp_REI =((gaze_vel_ind_left + (find(sign(current_movement(gaze_vel_ind_left:end,12)) ~= sign(current_movement(gaze_vel_ind_left,12)),1)))+1)/50;
                        end
                        % Combined Gaze
                        if (~isempty(gaze_vel_ind_combined))
                            gaze_combined_resp_amp_REI =((gaze_vel_ind_combined + (find(sign(current_movement(gaze_vel_ind_combined:end,5)+current_movement(gaze_vel_ind_combined:end,12)) ~= sign(current_movement(gaze_vel_ind_combined,5)+current_movement(gaze_vel_ind_combined,12)),1)))+1)/50;
                        elseif(gaze_vel_ind_left>=gaze_vel_ind_right)
                            gaze_combined_resp_amp_REI =((gaze_vel_ind_left + (find(sign(current_movement(gaze_vel_ind_left:end,5)+current_movement(gaze_vel_ind_left:end,12)) ~= sign(current_movement(gaze_vel_ind_left,5)+current_movement(gaze_vel_ind_left,12)),1)))+1)/50;
                        else
                            gaze_combined_resp_amp_REI =((gaze_vel_ind_right + (find(sign(current_movement(gaze_vel_ind_right:end,5)+current_movement(gaze_vel_ind_right:end,12)) ~= sign(current_movement(gaze_vel_ind_right,5)+current_movement(gaze_vel_ind_right,12)),1)))+1)/50;
                        end

                        % Gaze REI Validation
                        % Left REI
                        if (isempty(gaze_left_resp_amp_REI))
                            gaze_left_resp_amp_REI = .02;
                        elseif(gaze_left_resp_amp_REI > 3)
                            gaze_left_resp_amp_REI = 3;
                        end
                        % Right REI
                        if (isempty(gaze_right_resp_amp_REI))
                            gaze_right_resp_amp_REI = .02;
                        elseif(gaze_right_resp_amp_REI > 3)
                            gaze_right_resp_amp_REI = 3;
                        end
                        % Combined REI
                        if (isempty(gaze_combined_resp_amp_REI))
                            gaze_combined_resp_amp_REI = .02;
                        elseif(gaze_combined_resp_amp_REI > 3)
                            gaze_combined_resp_amp_REI = 3;
                        end

                        % Gaze Response Amplitude RSI
                        gaze_left_resp_amp_RSI = 5;
                        gaze_right_resp_amp_RSI = 5;
                        gaze_combined_resp_amp_RSI = 5;
                        
                        % Gaze Response Amplitude RSI (to Seconds)
                        gaze_left_resp_amp_RSI = ((gaze_vel_ind_left - (find(sign(current_movement(gaze_vel_ind_left:-1:1,5)) ~= sign(current_movement(gaze_vel_ind_left,5)),1)))+1)/50;
                        gaze_right_resp_amp_RSI = ((gaze_vel_ind_right - (find(sign(current_movement(gaze_vel_ind_right:-1:1,12)) ~= sign(current_movement(gaze_vel_ind_right,12)),1)))+1)/50;
                        

                        if(isempty(gaze_left_resp_amp_RSI) && ~isempty(gaze_right_resp_amp_RSI))
                            gaze_left_resp_amp_RSI = gaze_right_resp_amp_RSI;
                        elseif(isempty(gaze_right_resp_amp_RSI) && ~isempty(gaze_left_resp_amp_RSI))
                            gaze_right_resp_amp_RSI = gaze_left_resp_amp_RSI;
                        elseif(isempty(gaze_left_resp_amp_RSI) && isempty(gaze_right_resp_amp_RSI))
                            gaze_left_resp_amp_RSI = 10/50;
                            gaze_right_resp_amp_RSI = gaze_left_resp_amp_RSI;
                        end

                        if(~isempty(gaze_vel_ind_combined))
                             gaze_combined_resp_amp_RSI = ((gaze_vel_ind_combined - (find(sign((current_movement(gaze_vel_ind_combined:-1:1,5)+current_movement(gaze_vel_ind_combined:-1:1,12))) ~= (sign(current_movement(gaze_vel_ind_combined,5)+current_movement(gaze_vel_ind_combined,12))),1)))+1)/50;
                        elseif(gaze_vel_ind_left>=gaze_vel_ind_right)
                            gaze_combined_resp_amp_RSI = ((gaze_vel_ind_left - (find(sign((current_movement(gaze_vel_ind_left:-1:1,5)+current_movement(gaze_vel_ind_left:-1:1,12))) ~= (sign(current_movement(gaze_vel_ind_left,5)+current_movement(gaze_vel_ind_left,12))),1)))+1)/50;
                        else
                            gaze_combined_resp_amp_RSI = ((gaze_vel_ind_right - (find(sign((current_movement(gaze_vel_ind_right:-1:1,5)+current_movement(gaze_vel_ind_right:-1:1,12))) ~= (sign(current_movement(gaze_vel_ind_right,5)+current_movement(gaze_vel_ind_right,12))),1)))+1)/50;
                        end

                        if(isempty(gaze_combined_resp_amp_RSI) && gaze_vel_ind_left>=gaze_vel_ind_right)
                            gaze_combined_resp_amp_RSI = ((gaze_vel_ind_right - (find(sign((current_movement(gaze_vel_ind_right:-1:1,5)+current_movement(gaze_vel_ind_right:-1:1,12))) ~= (sign(current_movement(gaze_vel_ind_right,5)+current_movement(gaze_vel_ind_right,12))),1)))+1)/50;
                        elseif(isempty(gaze_combined_resp_amp_RSI) && gaze_vel_ind_left<gaze_vel_ind_right)
                            gaze_combined_resp_amp_RSI = ((gaze_vel_ind_left - (find(sign((current_movement(gaze_vel_ind_left:-1:1,5)+current_movement(gaze_vel_ind_left:-1:1,12))) ~= (sign(current_movement(gaze_vel_ind_left,5)+current_movement(gaze_vel_ind_left,12))),1)))+1)/50;
                        end

                        if(isempty(gaze_combined_resp_amp_RSI))
                            gaze_combined_resp_amp_RSI = (gaze_right_resp_amp_RSI+gaze_left_resp_amp_RSI)/2;
                        end

                        % Gaze Final Amplitude
                        % Final Amplitude
                        gaze_final_amp_left = mean(current_movement(end-25:end,4));
                        gaze_final_amp_right = mean(current_movement(end-25:end,11));
                        gaze_final_amp_combined = mean(current_movement(end-25:end,4)) + mean(current_movement(end-25:end,11));

                        % Gaze Response Amplitude
                        gaze_left_resp_amp = current_movement(uint8(gaze_left_resp_amp_REI*50),4) - current_movement(uint8(gaze_left_resp_amp_RSI*50),4);
                        gaze_right_resp_amp = current_movement(uint8(gaze_right_resp_amp_REI*50),11) - current_movement(uint8(gaze_right_resp_amp_RSI*50),11);
                        gaze_combined_resp_amp = (current_movement(uint8(gaze_combined_resp_amp_REI*50),4)+current_movement(uint8(gaze_combined_resp_amp_REI*50),11)) - (current_movement(uint8(gaze_combined_resp_amp_RSI*50),4)+current_movement(uint8(gaze_combined_resp_amp_RSI*50),11));

                        % Gaze Metric Evaluations
                        % Velocity
                        if (isempty(gaze_vel_left))
                            gaze_vel_left = 0;
                        end
                        % Right Eye Metrics
                        % Velocity
                        if (isempty(gaze_vel_right))
                            gaze_vel_right = 0;
                        end
                        % Average Eye Metrics
                        % Velocity
                        if (isempty(gaze_vel_combined))
                            gaze_vel_combined = 0;
                        end
                        % Response Amplitude
                        if (isempty(gaze_left_resp_amp))
                            gaze_left_resp_amp = 0;
                        end
                        % Response Amplitude
                        if (isempty(gaze_right_resp_amp))
                            gaze_right_resp_amp = 0;
                        end 
                         % Response Amplitude
                        if (isempty(gaze_combined_resp_amp))
                            gaze_combined_resp_amp = 0;
                        end

                        % PVI
                        if (isempty(gaze_vel_ind_left))
                            gaze_vel_ind_left = 0;
                        else
                            gaze_vel_ind_left = gaze_vel_ind_left/50;
                        end
                        % PVI
                        if (isempty(gaze_vel_ind_right))
                            gaze_vel_ind_right = 0;
                        else
                            gaze_vel_ind_right = gaze_vel_ind_right/50;
                        end
                        % PVI
                        if (isempty(gaze_vel_ind_combined))
                            gaze_vel_ind_combined = 0;
                        else
                            gaze_vel_ind_combined = gaze_vel_ind_combined/50;
                        end

                        %Left
                        metrics(1,:,page_index) = [left_eye_PV,left_eye_RA,final_amp_left,left_eye_RSI,left_eye_PVI,left_eye_REI,gaze_vel_left,gaze_left_resp_amp,gaze_final_amp_left,gaze_left_resp_amp_RSI,gaze_vel_ind_left,gaze_left_resp_amp_REI];
                        %Right
                        metrics(2,:,page_index) = [right_eye_PV,right_eye_RA,final_amp_right,right_eye_RSI,right_eye_PVI,right_eye_REI,gaze_vel_right,gaze_right_resp_amp,gaze_final_amp_right,gaze_right_resp_amp_RSI,gaze_vel_ind_right,gaze_right_resp_amp_REI];
                        %Average
                        metrics(3,:,page_index) = [average_eye_PV,average_eye_RA,final_amp_average,average_eye_RSI,average_eye_PVI,average_eye_REI,gaze_vel_combined,gaze_combined_resp_amp,gaze_final_amp_combined,gaze_combined_resp_amp_RSI,gaze_vel_ind_combined,gaze_combined_resp_amp_REI];
                    end
    
                    % Save Metric Matrix to Cell Array
                    movement_metrics_cell_array{cell_index} = metrics;
                end
            end
        end
    end
end


