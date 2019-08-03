initialize; config;
% Push.pushNote(Push.Devices, 'MATLAB Assist', sprintf('''%s'' is running', mfilename));
%% R-E region samples
% try
    for iCase = 1: Variable.nRxCases
        Transceiver.rx = Variable.rx(iCase);
        % generate the tap delay and gains based on HIPERLAN/2 model B
        [Channel] = hiperlan2_B(Transceiver, Channel);
        % plot_response;
        % obtain the channel amplitude corresponding to the carrier frequency
        [Channel] = channel_response(Transceiver, Channel);
        % reshape channel matrix to 2-D
        [Transceiver, Channel] = preprocessing(Transceiver, Channel);
        % initialize algorithms
        [SolutionMimo, ~] = initialize_algorithm(Transceiver, Channel);
        for iSample = 1: Variable.nSamples
            Transceiver.rateThr = Variable.rateThr(iSample);
            [SolutionMimo] = wipt_mimo(Transceiver, Channel, SolutionMimo);
            % invalid solution cannot be used for iterations
            if isnan(ratePapr(iCase, iSample))
                [SolutionMimo, ~] = initialize_algorithm(Transceiver, Channel);
            end
        end
    end
% catch
%     Push.pushNote(Push.Devices, 'MATLAB Assist', 'Houston, we have a problem');
% end
