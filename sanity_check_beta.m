%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Init
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

partic=2;

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
    EEG = pop_epoch( EEG, { 'S  1' }, [1 3], 'epochinfo', 'yes');
end



bandfreq=[15 29];

%find electrode
for chan= 1:length(EEG.chanlocs)
    if length(EEG.chanlocs(chan).labels)==2
        if EEG.chanlocs(chan).labels==electr_oi
            electr_oi_i=chan;
        end
    end
end

%% where to get troughs



%let's define which random times we'll use for each trial 
plot_time =500;%(this is dofferent form interval because trough could sit onthe edge of interval time so plot windw would reach way further

%how long should the interval where we look for trough be
time_interval=100;
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

electrode=electr_oi_i;%randi(size(EEG.data,1))
trough_lock=[];
figure
hold on
for trial = 1:size(EEG.data,3)
   

%% if you wnat random data instead of EEG
%     EEG.data(electrode,:,trial)=rand(size(EEG.data(electrode,:,trial)))
    data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
    
    [trough,trough_i]=min(data);
    
    trough_i=trough_i+interval_i.(strcat('T',num2str(trial)))(1)-1;
    try

        trough_lock(trial,:)=EEG.data(electrode,[trough_i-round(plot_time/2): trough_i+round(plot_time/2)],trial);
    catch

        %might need to pad
        temp_data=[nan(1,plot_time),EEG.data(electrode,:,trial),nan(1,plot_time)];
        trough_lock(trial,:)=temp_data(trough_i-round(plot_time/2)+plot_time:trough_i+plot_time+round(plot_time/2));
    end
    plot(-plot_time/2:plot_time/2, trough_lock(trial,:),'Color',[.5 .5 .5])
end
plot(-plot_time/2:plot_time/2, nanmean(trough_lock),'Color','k','Linewidth',2)
     



%% TFR
rmpath(eeglab_dir)
addpath C:\Users\ckohl\Documents\fieldtrip-20190802\fieldtrip-20190802
ft_defaults
keep=EEG;
%EEG2=eeglab2fieldtrip(EEG,'timelockanalysis','none');
EEG=eeglab2fieldtrip(EEG,'preprocessing','none');


cfg = [];	                
cfg.method     = 'wavelet';                
cfg.width      = 7; %we want at least 4 apparently
cfg.output     = 'pow';	
cfg.foi        = 1:1:30;%for short segments, use 3 as starting req for toi and foi we can be pretty generous. nothing to do with the time window and stuff	
cfg.toi        = EEG.time{1};
cfg.keeptrials = 'yes';
cfg.channel    = 'C3';
TFR = ft_freqanalysis(cfg, EEG);
cfg.keeptrials = 'no';
TFR_avg=ft_freqanalysis(cfg, EEG);
     
