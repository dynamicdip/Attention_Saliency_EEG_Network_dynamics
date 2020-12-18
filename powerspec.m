%% About: This code plots figures presented in Fig 3 of Ghosh, Roy, Banerjee 2020

%% Workspace requirement: load the mat file timeser&rt.mat in the workspace which has the following variables 
% 'wt_static'  %preprocessed EEG time series of trials without saliency of static stimulus
% 'st_static'  %preprocessed EEG time series of trials with saliency of static stimulus
% 'nt_static'  %preprocessed EEG time series of neutral trials of static stimulus
% 'wt_dynamic' %preprocessed EEG time series of trials without saliency of dynamic stimulus
% 'st_dynamic' %preprocessed EEG time series of trials with saliency of dynamic stimulus
% 'nt_dynamic' %preprocessed EEG time series of neutral trials of dynamic stimulus
% 'elec_loc'   %standard 64-channel electrode location file required for generating topoplots

%% Output: Power spectra plots and topoplots of static and dynamic stimulus

% Written by Priyanka Ghosh on Dec,2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ----------------------- Power-spectrum analysis (Use Chronux toolbox) ------------------------------------------------------------------
load timeser&rt.mat % Loading all data

AR_BUt=st_static([151:end],:,:); AR_TDt=wt_static([151:end],:,:); AR_Nt=nt_static([151:end],:,:); %extracting time-points post onset of saliency
AR_BUt=(AR_BUt-mean(st_static([41:140],:,:),1))./std(st_static([41:140],:,:));  %for trials with saliency(ST)
AR_TDt=(AR_TDt-mean(wt_static([41:140],:,:),1))./std(wt_static([41:140],:,:));  %for trials without saliency(WT)
AR_Nt=(AR_Nt-mean(nt_static([41:140],:,:),1))./std(nt_static([41:140],:,:));    %for neutral trials(NT)

%Change variables to st_dynamic/wt_dynamic/nt_dynamic from st_static/wt_static/nt_static for dynamic stimulus

spec_bu=[]; spec_td=[]; spec_n=[];
 for ch=1:size(AR_BUt,2);
     for tr = 1:size(AR_BUt,3);
        params.tapers=[3 5];
        params.Fs=1000;
        params.fpass = [0.1 80];
        [spec_bu(:,ch,tr),freq] = mtspectrumc(AR_BUt(:,ch,tr),params);
        [spec_td(:,ch,tr),freq] = mtspectrumc(AR_TDt(:,ch,tr),params);
        [spec_n(:,ch,tr),freq] = mtspectrumc(AR_Nt(:,ch,tr),params);
     end
 end

Pspecbu=spec_bu; Pspectd=spec_td; Pspecn=spec_n;
figure; plot(freq, mean(mean(Pspectd,3),2), 'b', 'LineWidth',1.5); hold on; plot(freq, mean(mean(Pspecbu,3),2), 'r', 'LineWidth',1.5);  hold on; plot(freq, mean(mean(Pspecn,3),2), 'c', 'LineWidth',1.5);
title 'power-spectra for task'; ylabel 'Power(μV)'; xlabel 'Frequency(Hz)';
clearvars -except Pspecbu Pspectd Pspecn freq AR_BUt AR_TDt AR_Nt 

%% ------------- To remove the aperiodic component from the power spectra -----------------------

logbu=log(Pspecbu); logtd=log(Pspectd); logn=log(Pspecn); freq=(log(freq))';
for j=1:size(logbu,3);
    for  i=1:size(logbu,2);
    m=polyfit(freq,logbu(:,i,j),1); n=polyfit(freq,logtd(:,i,j),1); o=polyfit(freq,logn(:,i,j),1);
    y_bu(:,i,j)=exp(m(1,2)+m(1,1)*freq); y_td(:,i,j)=exp(n(1,2)+n(1,1)*freq); y_n(:,i,j)=exp(o(1,2)+o(1,1)*freq);
    clear m n o
    end 
end
Ebu=Pspecbu-y_bu; Etd=Pspectd-y_td; En=Pspecn-y_n;
freq=exp(freq);
%clearvars -except Pspec_bu Pspec_td freq Ebu Etd En AR_BUt AR_TDt AR_Nt

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ------------------------Code to generate 1/f trend removed powerspectrum plots-----------------------------------------------------------------------------

figure; plot(freq(5:16), mean(mean(Etd(5:16,:,:),3),2), 'LineWidth',1.5); hold on; plot(freq(5:16), mean(mean(Ebu(5:16,:,:),3),2), 'LineWidth',1.5); hold on; plot(freq(5:16), mean(mean(En(5:16,:,:),3),2), 'c', 'LineWidth',1.5); xlim ([5 16]);
title 'power-spectra for task'; ylabel 'Power(μV)'; xlabel 'Frequency(Hz)';

%% ------------------------Code to generate topoplots ---------------------------------------------------------------------------------------------------------
% Add EEGLAB toolbox to the path to use the topoplot function
load timeser&rt.mat elec_loc
figure; topoplot(mean(Ebu(9,:,:)-Etd(9,:,:),3), elec_loc, 'electrodes', 'labels'); %elec_loc is a 64-channel EEG template with electrode coordinates provided by EEGLAB
%This step generates topoplots that show enhanced alpha power at 9Hz in ST i.e.,Ebu wrt WT i.e., Etd 