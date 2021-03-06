% plot classifer trained on part B (C vs E), to predict confidence.
%called from JOBS_ERPdecoder.m
getelocs;
cmap = flip(cbrewer('seq', 'RdPu', 5));
%%





job1.calcandconcat_PFX =1;
job1.plotGFX=1;





normON = 0; % normalize EEG data.





%%
if job1.calcandconcat_PFX ==1



GFX_DECA_Conf_corr_slid =nan(length(pfols), 28);
GFX_DecA_ScalpProj=nan(length(pfols), 64);

for ippant = 1:length(pfols)
    cd(basedir)
    cd(pfols(ippant).name);
    %% load the Classifer and behavioural data:
    load('Classifier_objectivelyCorrect');
    load('participant TRIG extracted ERPs.mat');
    load('Epoch information.mat');
    %%
    %
%     partBindx = contains({alltrials_matched.ExpType}, 'B');  % includes
%     practice trials.
    partBindx = sort([corBindx]); % correct only.
    
    partBdata = resplockedEEG(:,:,partBindx);
%     partBdata = stimlockedEEG(:,:,partBindx);
    [nchans, nsamps, ntrials] =size(partBdata);
    
    
    if normON==1
        data_norm = zeros(size(partBdata));
        for ichan = 1:nchans
            for itrial=1:ntrials
                temp = partBdata(ichan,:,itrial);
                % rescale
                temp=temp-(0.5*(min(temp)+max(temp)));
                if(min(temp)~=max(temp))
                    temp=temp/max(temp);
                end
                
                data_norm(ichan,:,itrial) = temp;
            end
        end
        partBdata= data_norm;
    end
    
    
    %%
    % collect confj for this dataset
    allconfj= zscore([alltrials_matched(partBindx).confj]);
%     allconfj= zscore([alltrials_matched(partBindx).rt]);
    
    
    
    
    
    %before continuing, we want to apply the spatial discrim to each trial.
    %% we are using the decoder from part A (correct vs Errors)
    v = DEC_Pe_window.discrimvector;
    
    %we want to take the probability, when this decoder is applied to a
    %sliding window across part B epochs.
    testdata = reshape(partBdata, nchans, nsamps* ntrials)';%
    %% multiply data by classifier:
    
    ytest_tmp = testdata* v(1:end-1) + v(end);
    
    
    %take the prob
        ytest_tmp= bernoull(1,ytest_tmp);
    
    % reshape for single trial decoding
    ytest_trials = reshape(ytest_tmp,nsamps,ntrials);
    
    %% now take correlation with confidence, in a sliding window:
    
    % set up the sliding window.
    movingwin = [.1, .05];
    Fs = 256;
    Nwin=round(Fs*movingwin(1)); % number of samples in window
    Nstep=round(movingwin(2)*Fs); % number of samples to step through
    
    winstart=1:Nstep:nsamps-Nwin+1;
    nw=length(winstart);
    %%
    outgoing =zeros(1,nw);
    
    
    for n=1:nw
        indx=winstart(n):winstart(n)+Nwin-1;
        
        %get mean decoder prob in this window, all trials.
        datawin = mean(ytest_trials(indx,:));
        %correlate with confidence (all trials)
        
        [R,p] = corrcoef(datawin, allconfj);
        
        %store sliding probability :
        outgoing(n)= R(1,2);
        
    end
    %%
    winmid=winstart+round(Nwin/2);
    t=winmid/Fs;
    %%
    set(gcf, 'units', 'normalized', 'position', [-0.5151    0.1380    0.5000    0.5512], 'color', 'w');
    clf
    subplot(1,3,1:2)
    plot(plotXtimes(winmid),outgoing, 'color', 'k', 'linew', 3);
    title({['P' num2str(ippant) ', Classifier trained on ERP A (C vs E) x ERP B'];[ExpOrder{1} '- ' ExpOrder{2} ]});
xlabel(['Time [ms] after response in part B']);
ylabel('performance x confidence, correlation, [r]')
ylim([-.2 .2])
hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
set(gca, 'fontsize', 15)

subplot(1,3,3)
 topoplot(DEC_Pe_window.scalpproj, biosemi64);
 title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']'])
 set(gca, 'fontsize', 15)
    
  %%

    
cd(basedir);
cd ../../Figures/
cd('Classifier Results')
cd('PFX_Trained on Correct part A, conf x sliding window part B');
printname = ['Participant ' num2str(ippant) ' Dec A sliding window confidence correlaiton' ExpOrder{1} '- ' ExpOrder{2} ' corronly'];
print('-dpng', printname)


%% store output participants:
  GFX_DECA_Conf_corr_slid(ippant,:) = outgoing;
  GFX_DecA_ScalpProj(ippant,:) = DEC_Pe_window.scalpproj;
end
save('GFX_DecA_slidingwindow_predictsConfidence', 'GFX_DECA_Conf_corr_slid', 'GFX_DecA_ScalpProj', 'winmid', 'plotXtimes');

end

if job1.plotGFX==1
%% plot results across participants:
showt1 = [200, 350];
for iorder =1%:3
    figure(1); clf
    switch iorder
        case 1            
            useppants = vis_first;
            ordert='visual-audio';
        case 2
            useppants = aud_first;
            ordert= 'audio-visual';
        case 3
            useppants = 1:size(GFX_DECA_Conf_corr_slid,1);
            ordert= 'all combined';
    end
    
    dataIN = squeeze(GFX_DECA_Conf_corr_slid(useppants,:));
    
Ste = CousineauSEM(dataIN);

subplot(1,3,1:2)
set(gcf, 'color', 'w')
  ylim([-.1 .1])  
%place patches (as background) first:
    ytx= get(gca, 'ylim');    
hold on
%plot topo patches.
ph=patch([showt1(1) showt1(1) showt1(2) showt1(2)], [ytx(1) ytx(2) ytx(2) ytx(1) ],  [1 .9 .9]);
ph.FaceAlpha=.4;
ph.LineStyle= 'none';
    
hold on
shadedErrorBar(plotXtimes(winmid), mean(dataIN,1), Ste, ['b'],1);
shg


xlabel(['Time [ms] after response in part B']);
ylabel('Part B (prob) and confidence [r]')
ylabel('Part B (prob) and rt [r]')

hold on; plot(xlim, [0 0 ], ['k:'], 'linew', 2)
hold on; plot([0 0 ], ylim, ['k:'], 'linew', 2)
set(gca, 'fontsize', 25)
title({['Classifier trained on ERP A (C vs E) x ERP B'];[ordert ', n=' num2str(length(useppants))]}, 'fontsize', 20)
title ''
box on
% add sig tests:
%ttests
pvals= nan(1, length(winmid));
%%
for itime = 1:length(winmid)
    [~, pvals(itime)] = ttest(dataIN(:,itime));
    
    if pvals(itime)<.05
        text(plotXtimes(winmid(itime)), [-.1], '*', 'color', 'k','fontsize', 25);
    end
end
%%
% add topoplot of discrim used to aid interpretation.
% 
subplot(1,3,3)
topoplot(mean(GFX_DecA_ScalpProj(useppants,:)), biosemi64);
title(['Classifier trained [' num2str(DEC_Pe_windowparams.training_window_ms) ']']);
set(gca, 'fontsize', 25)

set(gcf,'color', 'w')
%%
cd(basedir);
cd ../../Figures/
cd('Classifier Results')
cd('PFX_Trained on Correct part A, conf x sliding window part B');
printname = ['GFX Dec A sliding window confidence correlaiton, for ' ordert ' corr only'];
print('-dpng', printname)
end
end
%%
