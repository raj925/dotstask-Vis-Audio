% JOBS_ERP_decoder
clear variables
close all
addpath('/Users/mdavidson/Documents/MATLAB/dotstask-Vis-Audio/Analysis')

behdatadir = '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/Exp_output/DotsandAudio_behaviour/ver2';

basedir= '/Users/mdavidson/Desktop/dotstask- Vis+Audio EXP/EEG/ver2';
cd(basedir);
pfols = dir([pwd filesep 'p_*']);

% which participants had visual stim first? Needs to be updated.
    vis_first = [2,3,6,7,8,9,10,11,12];
    aud_first = [1,4,5];
    
    %%
job.trainclassifierpartA_CvsE=0;

job.plot_A_vs_Untrainedtrials= 0;       %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.
job.plot_A_vs_Untrainedtrials_GFX= 0;    %  GFX_ of above


job.plot_A_vs_RTtercile =0; % see if classifier accuracy in A, is affected by RT (implying capture of confidence).


%plot results from classifier trained on part B of exp, on predicting
%confidence.
job.plot_A_vs_RTsinA =1;

job.plot_A_vs_Confidence_corr=0;  % using the A vector, multiple part B ERP, and see check performance correlation with confidence over time..
job.plot_A_vs_Confidence_split=0;  % using the A vector, multiple part B ERP, and see if we see quantile definition in confidence.

job.plot_B_vs_Confidence =0; % uses the amplitude of discriminator performance (in quantiles), to collect confidence

%%

 cmap = flip(cbrewer('div', 'Spectral', 4));
 getelocs;
    
 
if job.trainclassifierpartA_CvsE==1
    Call_classifer_VIS_AUDIO;
end



if job.plot_A_vs_Untrainedtrials==1
    %  PFX_ Plots the results of discrim component Cor vs Err in A, on all response locked ERP.    
  Plot_decA_vs_untrained;
end

if job.plot_A_vs_Untrainedtrials_GFX==1   
    Plot_decA_vs_untrained_GFX;
end


% if job.plot_A_vs_RTtercile ==1 % using ROC to compare RT affect on classifier accuracy.    
% Plot_decA_vs_RTsinA_ROC; % unfinished.
% end

if job.plot_A_vs_RTsinA==1
 Plot_decA_vs_RTsinA_correlation;
end
%%
if job.plot_A_vs_Confidence_corr==1
 Plot_decA_vs_Confidence;
end

if job.plot_A_vs_Confidence_split==1
 Plot_decA_vs_Confidence_split;
end
%%
if job.plot_B_vs_Confidence ==1
  
    Plot_decB_vs_Confidence;
end