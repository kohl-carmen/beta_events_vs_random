%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

partic=4;

TEP_data=0;% if not TEP data, SEP data (can segment those as I please)

if TEP_data
    data_path='F:\Brown\TMS\Pilot\';
else
    data_path='C:\Users\ckohl\Desktop\Current\EEG\';
end
Partic=[2,4];
dt=1;

TESAICA=0; %if 0, runICA for blink, if 1 TESAICA automatic (not done here but pick which preprocessed file you want)
electr_oi='C3';




%% PPT
ppt=1;
h = actxserver('PowerPoint.Application');
Presentation = h.Presentation.Add;



fieldtrip_dir='C:\Users\ckohl\Documents\fieldtrip-20190802\fieldtrip-20190802';
eeglab_dir='C:\Users\ckohl\Documents\MATLAB\eeglab2019_0';
rmpath(fieldtrip_dir)
addpath(eeglab_dir)
eeglab
close all
%% load data
if TESAICA
    name='TESA';
else
    name='run';
end
if TEP_data
    data=load(strcat(data_path,strcat('Beta0',num2str(partic),'_TEP_1k_',name,'ICA_filt100')));
    EEG=data.EEG;
    EEG = pop_epoch( EEG, { 'S  1' }, [-1 0], 'epochinfo', 'yes');
else
    data=load(strcat(data_path,strcat('Beta0',num2str(partic),'_preproc')));
    EEG=data.EEG;
%     EEG = pop_epoch( EEG, { 'S  1' }, [1 6], 'epochinfo', 'yes');
    EEG = pop_epoch( EEG, { 'S  2' }, [-1 0], 'epochinfo', 'yes');
end


% 
% %% TFR
% rmpath(eeglab_dir)
% addpath C:\Users\ckohl\Documents\fieldtrip-20190802\fieldtrip-20190802
% ft_defaults
% keep=EEG;
% %EEG2=eeglab2fieldtrip(EEG,'timelockanalysis','none');
% EEG=eeglab2fieldtrip(EEG,'preprocessing','none');
% 
% 
% cfg = [];	                
% cfg.method     = 'wavelet';                
% cfg.width      = 7; %we want at least 4 apparently
% cfg.output     = 'pow';	
% cfg.foi        = 1:1:30;%for short segments, use 3 as starting req for toi and foi we can be pretty generous. nothing to do with the time window and stuff	
% cfg.toi        = EEG.time{1};
% cfg.keeptrials = 'yes';
% cfg.channel    = 'C3';
% TFR = ft_freqanalysis(cfg, EEG);
% % cfg.keeptrials = 'no';
% % TFR_avg=ft_freqanalysis(cfg, EEG);
% 
% 
% % figure('units','normalized','outerposition', [0 0 1 1]);
% % cfg=[];      
% %     cfg.parameter='powspctrm';
% %     cfg.colormap=jet;
% %     cfg.colorbar='yes';
% %     cfg.channel='C3';
% % %         cfg.baseline=[-1 0];
% % %         cfg.baselinetype ='relative';
% %     cfg.title = strcat('Avg');
% % ft_singleplotTFR(cfg,TFR_avg)


%% now crop EEG 
% if ~TEP_data
%     timetokeep=[2000 5000];
%     % EEG=keep;
%     keep_i=[find(EEG.times==timetokeep(1)):find(EEG.times==timetokeep(end)-1)];
%     EEG.times=[1:timetokeep(end)-timetokeep(1)];
%     EEG.data=EEG.data(:,keep_i,:);
% end
% keep_i=[find(TFR.time==timetokeep(1)/1000):find(TFR.time==timetokeep(end)/1000)-1];
% TFR.time=EEG.times/1000;
% TFR.powspctrm=TFR.powspctrm(:,:,:,keep_i);
% 
% %% base
% cfg=[];
% cfg.baseline=[TFR.time(1) TFR.time(end)];
% TFR=ft_freqbaseline(cfg,TFR);

alphaband=[8 13];
betaband=[15 29];

%find electrode
for chan= 1:length(EEG.chanlocs)
    if length(EEG.chanlocs(chan).labels)==2
        if EEG.chanlocs(chan).labels==electr_oi
            electr_oi_i=chan;
        end
    end
end
electrode=electr_oi_i;

%% Spectral events
ryan='C:\Users\ckohl\Documents\MATLAB\Ryan';
addpath(ryan)
eventBand=betaband;
fVec=1:30;
Fs=1000;
findMethod=2;
vis=0;
X{1}=squeeze(EEG.data(electr_oi_i,:,:));
classLabels{1}=1;
if TEP_data
    tVec_assumed=linspace(1/Fs,1,Fs);
else
%     tVec_assumed=linspace(0,3,Fs*3);
    tVec_assumed=linspace(1/Fs,1,Fs);
end
[specEv_struct,TFRs,X] = spectralevents(eventBand,fVec,Fs,findMethod,vis,X,classLabels);

event_trial=[];
event_max=[];
event_onset=[];
event_offset=[];

% sub_count=0;       
% figure('units','normalized','outerposition', [0 0 1 1]);
%for trial=unique(specEv_struct.Events.Events.trialind)'  
for trial=1:size(EEG.data,3)
        max_t=specEv_struct.Events.Events.maximatiming(specEv_struct.Events.Events.trialind==trial);
        max_f=specEv_struct.Events.Events.maximafreq(specEv_struct.Events.Events.trialind==trial);
        max_t_realtime=[];
             %% for later - only keep the event closest to time 0
             
             onset=specEv_struct.Events.Events.onsettiming(specEv_struct.Events.Events.trialind==trial);
             offset=specEv_struct.Events.Events.offsettiming(specEv_struct.Events.Events.trialind==trial);
             onset_realtime=[];
             offset_realtime=[];
             for i=1:length(max_t)
                 onset_realtime(i)=EEG.times(find(round(tVec_assumed,3)==round(onset(i),3)));
                 offset_realtime(i)=EEG.times(find(round(tVec_assumed,3)==round(offset(i),3)));
             end
             event_onset=[event_onset, max(onset_realtime)];
             event_offset=[event_offset,max(offset_realtime)];
             
             if ~isempty(onset_realtime)
                 event_trial=[event_trial,trial];
             end
           
end
close all    


%% where to get troughs



%let's define which random times we'll use for each trial 
plot_time =500;%(this is dofferent form interval because trough could sit onthe edge of interval time so plot windw would reach way further

%how long should the interval where we look for trough be
time_interval=200; % beta events tend to be like 150 (70-500)
time_interval_per_trial=ones(size(EEG.data,3),1).*time_interval;
duration_jitter=1; %shall we have the time interal constant or not
if duration_jitter
    temp=randi(2);
    if temp==1
        time_interval_per_trial=time_interval_per_trial+(rand(size(EEG.data,3),1).*time_interval_per_trial);
    else
        time_interval_per_trial=time_interval_per_trial+(rand(size(EEG.data,3),1).*time_interval_per_trial*-1);
    end
end
half_time_interval_per_trial=floor(time_interval_per_trial/2);
% now let's pick where to put this intevral for each trial
start=[];
interval_i=struct();% has to be struct because if there's jitter, won't be the same size
for trial=1:size(EEG.data,3)
    start(trial)=randi([ceil(half_time_interval_per_trial(trial))+1,size(EEG.data,2)-ceil(half_time_interval_per_trial(trial))-1],1,1);
    interval_i.(strcat('T',num2str(trial)))= [-half_time_interval_per_trial(trial):half_time_interval_per_trial(trial)]+start(trial);
end



%% now let's plot the sanity betas to ryans betas
%% Plot beta peaks and me troughs to see if they overlap

sub_count=0;       
figure('units','normalized','outerposition', [0 0 1 1]);
%for trial=unique(specEv_struct.Events.Events.trialind)'  
for trial=1:size(EEG.data,3)
    sub_count=sub_count+1;
    if sub_count==1
       clf
       hold on
    end
    subplot(4,1,sub_count)
        %% plot ryan stuff
        imagesc([EEG.times(1) EEG.times(end)],eventBand,TFRs{1}(eventBand(1):eventBand(end),:,trial))
%             imagesc([EEG.times(1) EEG.times(end)]],[fVec(1) fVec(end)],TFRs{1}(:,:,trial))
        colormap jet
        cb = colorbar;         
        % Overlay locations of event peaks and the waveform corresponding with each trial
        hold on
        max_t=specEv_struct.Events.Events.maximatiming(specEv_struct.Events.Events.trialind==trial);
        max_f=specEv_struct.Events.Events.maximafreq(specEv_struct.Events.Events.trialind==trial);
        max_t_realtime=[];
        for i=1:length(max_t)
            max_t_realtime(i)=EEG.times(find(round(tVec_assumed,3)==round(max_t(i),3)));
        end
         plot(max_t_realtime,max_f,'w.','Markersize',30) %Add points at event maxima
         
                  
        yyaxis right
        plot(EEG.times,X{1}(:,trial),'w','Linewidth',2)
           
        title(strcat('Trial ',num2str(trial)))
        
        
        %% plot my stuff
        data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
    
        [trough,trough_i]=min(data);

        trough_i=trough_i+interval_i.(strcat('T',num2str(trial)))(1)-1; 
%         if TEP_data
            trough_i=EEG.times(trough_i);
%         end
        
        %% see if its near beta, redraw a new time
        while any(abs(max_t_realtime-trough_i)<50)
               start(trial)=randi([ceil(half_time_interval_per_trial(trial))+1,size(EEG.data,2)-ceil(half_time_interval_per_trial(trial))-1],1,1);
               interval_i.(strcat('T',num2str(trial)))= [-half_time_interval_per_trial(trial):half_time_interval_per_trial(trial)]+start(trial);
               %refind trough
               data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
               [trough,trough_i]=min(data);
               trough_i=trough_i+interval_i.(strcat('T',num2str(trial)))(1)-1;
        end
        plot(trough_i,trough,'r.','Markersize',30)   
            
        if sub_count==4 | trial==specEv_struct.Events.Events.trialind(end)
%             print('-dpng','-r150',strcat('temp','.png'));
%             blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
%             Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
%             Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

            sub_count=0;
        end
           
end
close all    









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot everything togehter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ylim_timelock=[-20 20];
ylim_betapower=[.5 4];
ylim_alphapower=[1 4];

electrode=electr_oi_i;%randi(size(EEG.data,1))
lost_trials_ryan=[];
lost_trials=[];
trough_powspctrm=nan(size(EEG.data,3),1,size(TFRs{1},1),plot_time+1);
trough_powspctrm_ryan=nan(size(EEG.data,3),1,size(TFRs{1},1),plot_time+1);
trough_lock=nan(size(EEG.data,3),plot_time+1);
padded_trials=[];
alphapowerlock=nan(size(EEG.data,3),plot_time+1);
betapowerlock=nan(size(EEG.data,3),plot_time+1);
trough_lock_ryan=nan(size(EEG.data,3),plot_time+1);
alphapowerlock_ryan=nan(size(EEG.data,3),plot_time+1);
betapowerlock_ryan=nan(size(EEG.data,3),plot_time+1);
figure('units','normalized','outerposition', [0 0 1 1]);
hold on
for trial = 1:size(EEG.data,3)
    %% mine
    data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
    [trough,trough_i]=min(data);   
    trough_i=trough_i+interval_i.(strcat('T',num2str(trial)))(1)-1;
    try
        trough_lock(trial,:)=EEG.data(electrode,[trough_i-round(plot_time/2): trough_i+round(plot_time/2)],trial);
        trough_powspctrm(trial,1,1:size(TFRs{1},1),1:plot_time+1)=TFRs{1}(:,[trough_i-round(plot_time/2): trough_i+round(plot_time/2)],trial);
        betapowerlock(trial,:)=mean(TFRs{1}(betaband(1):betaband(end),trough_i-round(plot_time/2): trough_i+round(plot_time/2),trial),1);
        alphapowerlock(trial,:)=mean(TFRs{1}(alphaband(1):alphaband(end),trough_i-round(plot_time/2): trough_i+round(plot_time/2),trial),1);
        
    catch
        lost_trials=[lost_trials, trial];
    end
    subplot(6,2,[1,3])
    xlim([-plot_time/2 plot_time/2])
    hold on
    title('Timeseries Random')
    plot(-plot_time/2:plot_time/2, trough_lock(trial,:),'Color',[.5 .5 .5])
    
    subplot(6,2,5)
    xlim([-plot_time/2 plot_time/2])
    hold on
    title('Beta Power Random')
    plot(-plot_time/2:plot_time/2, betapowerlock(trial,:),'Color',[.5 .5 .5])
    
    subplot(6,2,7)
    xlim([-plot_time/2 plot_time/2])
    hold on
    title('Alpha Power Random')
    plot(-plot_time/2:plot_time/2, alphapowerlock(trial,:),'Color',[.5 .5 .5])
    
    
    
    %% ryan
    % we'll just take the last event for no partiuclar reason    
    if sum(event_trial==trial)>0
        [trough,trough_i]=min(X{1}(find(EEG.times==event_onset(event_trial==trial)):find(EEG.times==event_offset(event_trial==trial)),trial));  
        temp=1:length(EEG.times);
        temp=temp(find(EEG.times==event_onset(event_trial==trial)):find(EEG.times==event_offset(event_trial==trial)));
        trough_i=temp(trough_i);

        try
            trough_lock_ryan(trial,:)=X{1}(trough_i-round(plot_time/2): trough_i+round(plot_time/2),trial);
            %alpha and beta power
            betapowerlock_ryan(trial,:)=mean(TFRs{1}(betaband(1):betaband(end),trough_i-round(plot_time/2): trough_i+round(plot_time/2),trial),1);
            alphapowerlock_ryan(trial,:)=mean(TFRs{1}(alphaband(1):alphaband(end),trough_i-round(plot_time/2): trough_i+round(plot_time/2),trial),1);       
            trough_powspctrm_ryan(trial,1,1:size(TFRs{1},1),1:plot_time+1)=TFRs{1}(:,[trough_i-round(plot_time/2): trough_i+round(plot_time/2)],trial);

        catch
            lost_trials_ryan=[lost_trials_ryan, trial];
        end
    end
    subplot(6,2,[2,4])
    hold on
    title('Timeseries Beta Events')
    plot(-plot_time/2:plot_time/2, trough_lock_ryan(trial,:),'Color',[.5 .5 .5])
    
    subplot(6,2,6)
    xlim([-plot_time/2 plot_time/2])
    hold on
    title('Beta Power Events')
    plot(-plot_time/2:plot_time/2, betapowerlock_ryan(trial,:),'Color',[.5 .5 .5])
    
    subplot(6,2,8)
    xlim([-plot_time/2 plot_time/2])
    hold on
    title('Alpha Power Events')
    plot(-plot_time/2:plot_time/2, alphapowerlock_ryan(trial,:),'Color',[.5 .5 .5])
    

    
end
%mine
subplot(6,2,[1,3])
title(strcat('Timeseries Random - NrTrials=',num2str(size(EEG.data,3)-length(lost_trials))))
plot(-plot_time/2:plot_time/2, nanmean(trough_lock),'Color','k','Linewidth',2)
ylim(ylim_timelock)

subplot(6,2,[5])
plot(-plot_time/2:plot_time/2, nanmean(betapowerlock),'Color','k','Linewidth',2)
ylim(ylim_betapower)

subplot(6,2,[7])
plot(-plot_time/2:plot_time/2, nanmean(alphapowerlock),'Color','k','Linewidth',2)
ylim(ylim_alphapower)
% Trough_TFR=TFR;  
% Trough_TFR.time=-plot_time/2:plot_time/2;
% Trough_TFR.powspctrm=trough_powspctrm;
% 
% % Trough_TFR_avg=Trough_TFR;
% % Trough_TFR_avg.powspctrm=mean(Trough_TFR.powspctrm,1);
% % Trough_TFR_avg.dimord='chan_freq_time';
% 
% subplot(6,2,[9,11])
% ylim([4 30])
% xlim([-plot_time/2 plot_time/2])
% hold on
% 
% cfg=[];      
%     cfg.parameter='powspctrm';
%     cfg.colormap=jet;
%     cfg.colorbar='no';
%     cfg.channel='C3';
% %      cfg.baseline=[-250 250];
% % 	cfg.baselinetype ='relative';
%     cfg.trials=[1:100]%size(EEG.data,3)];
%     cfg.trials(padded_trials)=[];
%     cfg.title = strcat('Avg TFR Random');
% ft_singleplotTFR(cfg,Trough_TFR)
% set(gca, 'YDir','reverse')
% ylim([5 30])
% hold on
subplot(6,2,[9,11])
imagesc([-plot_time/2 plot_time/2], fVec,squeeze(nanmean(trough_powspctrm,1)))
hold on
title('Avg TFR Random')
ylim([5 30])
plot([-plot_time/2 plot_time/2],[alphaband(1), alphaband(1)],'k:','Linewidth',2)
plot([-plot_time/2 plot_time/2],[alphaband(2), alphaband(2)],'k:','Linewidth',2)
plot([-plot_time/2 plot_time/2],[betaband(1), betaband(1)],'k--','Linewidth',2)
plot([-plot_time/2 plot_time/2],[betaband(2), betaband(2)],'k--','Linewidth',2)
%  colormap jet
% cb = colorbar; 
caxis([0.3 1.8])
        
%ryan
subplot(6,2,[2,4])
title(strcat('Timeseries Events - NrTrials=',num2str(size(EEG.data,3)-length(lost_trials_ryan))))
plot(-plot_time/2:plot_time/2, nanmean(trough_lock_ryan),'Color','k','Linewidth',2)
ylim(ylim_timelock)
subplot(6,2,[6])
plot(-plot_time/2:plot_time/2, nanmean(betapowerlock_ryan),'Color','k','Linewidth',2)
ylim(ylim_betapower)
subplot(6,2,[8])
plot(-plot_time/2:plot_time/2, nanmean(alphapowerlock_ryan),'Color','k','Linewidth',2)
ylim(ylim_alphapower)
 
subplot(6,2,[10,12])
imagesc([-plot_time/2 plot_time/2], fVec,squeeze(nanmean(trough_powspctrm_ryan,1)))
hold on
title('Avg TFR Event')
ylim([5 30])
plot([-plot_time/2 plot_time/2],[alphaband(1), alphaband(1)],'k:','Linewidth',2)
plot([-plot_time/2 plot_time/2],[alphaband(2), alphaband(2)],'k:','Linewidth',2)
plot([-plot_time/2 plot_time/2],[betaband(1), betaband(1)],'k--','Linewidth',2)
plot([-plot_time/2 plot_time/2],[betaband(2), betaband(2)],'k--','Linewidth',2)
colormap jet
% cb = colorbar;    
caxis_tfr=caxis;

%apply this caxis to the other tfr
subplot(6,2,[9,11])
caxis(caxis_tfr)

print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500



% compare directly
figure%('units','normalized','outerposition', [0 0 .5 .5]);
%remove nan
trough_lock(isnan(trough_lock(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time+1
    se=std(trough_lock(:,i))./sqrt(length(trough_lock(:,i)));
    SE_upper(i)=mean(trough_lock(:,i))+se;
    SE_lower(i)=mean(trough_lock(:,i))-se;
end


clf
hold on
colour=[.25 .625 1]
lines(1)=plot(-plot_time/2:plot_time/2, mean(trough_lock),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:plot_time/2],fliplr([-plot_time/2:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k')
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;


colour=[1 .625 .25];
trough_lock_ryan(isnan(trough_lock_ryan(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time+1
    se=std(trough_lock_ryan(:,i))./sqrt(length(trough_lock_ryan(:,i)));
    SE_upper(i)=mean(trough_lock_ryan(:,i))+se;
    SE_lower(i)=mean(trough_lock_ryan(:,i))-se;
end
lines(2)=plot(-plot_time/2:plot_time/2, mean(trough_lock_ryan),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:plot_time/2],fliplr([-plot_time/2:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k')
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;
ylims=ylim;

legend(lines,'Random','Event')

% 
% 
% print('-dpng','-r150',strcat('temp','.png'));
% blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
% Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
% Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
% 


%% now I want to actually compare the two waveforms (random vs event)
%let's look at the width
for p=1:2
    if p==1 %beta
        colour=[1 .625 .25];
        data=trough_lock_ryan;
    else
        colour=[.25 .625 1]
        data=trough_lock;
    end

for trial=1:size(data,1)
    %find the centre trough
    trough_latency(trial)=plot_time/2+1;
    trough_value(trial)=data(trial,trough_latency(trial));
    %from here, find peaks
    % firs time it changes direction to down I guess
    %backwards
    found_peak=0;
    temp=0;
    while found_peak==0
    	temp=temp+1;
        latency=trough_latency(trial)-temp;
        if data(trial,latency)<data(trial,latency+1)
            prev_peak_latency(trial)=latency+1;
            prev_peak_value(trial)=data(trial,prev_peak_latency(trial));
            found_peak=1;
        end
    end
     %forwards
    found_peak=0;
    temp=0;
    while found_peak==0
    	temp=temp+1;
        latency=trough_latency(trial)+temp;
        if data(trial,latency)<data(trial,latency-1)
            post_peak_latency(trial)=latency-1;
            post_peak_value(trial)=data(trial,post_peak_latency(trial));
            found_peak=1;
        end
    end

    peak_to_peak_latency(trial)=post_peak_latency(trial)-prev_peak_latency(trial);
    trough_to_peak_amp(trial)=mean([post_peak_value(trial),prev_peak_value(trial)])-trough_value(trial);
end
 



xtext=sprintf(['Peak2Peak-Lat:  %2.2f (%2.2f) \n'...
    'Freq-P2P:  %i Hz\n'...
    'Trough2Peak-Amp:  %2.2f (%2.2f) \n'...
    'Trough-Amp:  %2.2f (%2.2f) \n'...
    'Peak-Amp:  %2.2f (%2.2f) \n'...
    'Peak-Amp Diff:  %2.2f (%2.2f) \n'],...
    mean(peak_to_peak_latency),std(peak_to_peak_latency),...
    round(1000/mean(peak_to_peak_latency)),...
    mean(trough_to_peak_amp),std(trough_to_peak_amp),...
    mean(trough_value),std(trough_value),...
    mean(mean([post_peak_value;prev_peak_value])),std(mean([post_peak_value;prev_peak_value])),...
    mean([post_peak_value-prev_peak_value]),std([post_peak_value-prev_peak_value]));

    if p==1
        tx=text(-plot_time/2/3-150,ylims(1)+(ylims(2)-ylims(1))/4,xtext );
    else
        tx=text((plot_time/2/3)-50,ylims(1)+(ylims(2)-ylims(1))/4,xtext );
    end
    tx.Color=colour;
    tx.FontWeight='bold';
    tx.FontSize=10;
end


print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500


%% plot TFR of AVG (rahter than avg of tfr)

figure('units','normalized','outerposition', [0 0 1 1]);
for p=1:2 %beta or random
    for o=1:2 %alpha or beta shown
            if p==1
                S = mean(trough_lock_ryan,1);
                if o==1
                    subplot(2,2,2)                   
                    title('TFR of Avg - Event - Beta')
                    hold on
                    band=[15 30];
                    
                else
                    subplot(2,2,4)
                    title('TFR of Avg - Event - Alpha')
                    hold on
                    
                    band=[8 13];
                end
            else
                S = mean(trough_lock,1);
                if o==1
                    subplot(2,2,1) 
                    title('TFR of Avg - Random - Beta')
                    hold on
                    band=[15 30];
                else
                    subplot(2,2,3)
                    title('TFR of Avg - Random - Alpha')
                    hold on
                    band=[8 13];
                end
            end

            tVec = (1:size(S,2))/Fs;  

            B = zeros(length(fVec),size(S,2)); 
            width=7;

            for i=1:size(S,1)          
                for j=1:length(fVec)

                    f=fVec(j);
                    s=detrend(S(i,:));

                    dt = 1/Fs;
                    sf = f/width;
                    st = 1/(2*pi*sf);

                    t=-3.5*st:dt:3.5*st;
                    A = 1/(st*sqrt(2*pi));
                    m = A*exp(-t.^2/(2*st^2)).*exp(1i*2*pi*f.*t);

                    y = conv(s,m);
                    y = 2*(dt*abs(y)).^2;
                    y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));




                    B(j,:) = y + B(j,:);
                end
            end
            TFR = B/size(S,1);     


            
            imagesc([-plot_time/2:plot_time/2],band,TFR(band(1):band(end),:))
            ylim(band)
            colormap jet
            cb = colorbar;   
            if p==1
                if o==1
                    caxis_beta=caxis;
                else
                    caxis_alpha=caxis;
                end
            else
                if o==1
                    caxis(caxis_beta)
                else
                    caxis(caxis_alpha)
                end
            end
            % Overlay locations of event peaks and the waveform corresponding with each trial
            hold on
            max_t=specEv_struct.Events.Events.maximatiming(specEv_struct.Events.Events.trialind==trial);
            max_f=specEv_struct.Events.Events.maximafreq(specEv_struct.Events.Events.trialind==trial);
            max_t_realtime=[];
            for i=1:length(max_t)
                max_t_realtime(i)=EEG.times(find(round(tVec_assumed,3)==round(max_t(i),3)));
            end
        

            yyaxis right
            plot([-plot_time/2:plot_time/2],S,'w','Linewidth',2)
            xlim([-plot_time/2 plot_time/2])
            if p==1 & o==1
                get_ts_ylim=ylim;
            elseif p==2
                ylim(get_ts_ylim)
            end
    end

end




print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
