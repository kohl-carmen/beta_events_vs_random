clear

ppt=1;
h = actxserver('PowerPoint.Application');
Presentation = h.Presentation.Add;

rng('shuffle')
Partic=[1:10];
trough_lock_all=[];
trough_lock_ryan_all=[];
peak_to_peak_latency_all=[];
trough_to_peak_amp_all=[];
trough_value_all=[];
post_peak_value_all=[];
prev_peak_value_all=[];
peak_to_peak_latency_ryan_all=[];
trough_to_peak_amp_ryan_all=[];
trough_value_ryan_all=[];
post_peak_value_ryan_all=[];
prev_peak_value_ryan_all=[];

for partic=1:length(Partic)

    clearvars -except partic Partic h Presentation trough_lock_all trough_lock_ryan_all peak_to_peak_latency_all trough_to_peak_amp_all trough_value_all post_peak_value_all prev_peak_value_all peak_to_peak_latency_ryan_all trough_to_peak_amp_ryan_all trough_value_ryan_all post_peak_value_ryan_all prev_peak_value_ryan_all
    data_path='F:\Brown\Shin Data\HumanDetection\';
    filename=strcat('prestim_humandetection_subject',num2str(Partic(partic)),'.mat');

    load(strcat(data_path,filename))





    % Fs: sampling rate (Hz)
    % prestim__yes_no: 1 second prestimulus trace. 
    % prestim_TFR_yes_no: 1 second prestimulus time-frequency representation (TFR). 1st dimension is frequency, 2nd dimension is time, 3rd dimension is trials
    % fVec: frequeTFRncy vector corresponding to 1st dimension in prestim_TFR_yes_no (Hz)
    % tVec: time vector corresponding to 2nd dimension in prestim_TFR_yes_no (ms)
    % YorN: behavior outcome of each trial corresponding to 3rd dimension in prestim_TFR_yes_no.
    % YorN==1 trials correspond to detected trials and YorN==0 trials correspond to non-detected trials

    data=prestim_raw_yes_no';
    nr_trials=size(data,2);

    Fs=600;
    dt=1000/600;
    X{1}=data;
    tVec_assumed=linspace(1/Fs,1,Fs);
    %% Spectral events
    alphaband=[8 13];
    betaband=[15 29];
    ryan='C:\Users\ckohl\Documents\MATLAB\Ryan';
    addpath(ryan)
    eventBand=betaband;
    %% O
    fVec=3:3:30;
    findMethod=1;
    vis=0;
    classLabels{1}=1;
    tVec_assumed=linspace(1/Fs,1,Fs);
    [specEv_struct,TFRs,X] = spectralevents(eventBand,fVec,Fs,findMethod,vis,X,classLabels);

    event_trial=[];
    event_max=[];
    event_onset=[];
    event_offset=[];

    % sub_count=0;       
    % figure('units','normalized','outerposition', [0 0 1 1]);
    %for trial=unique(specEv_struct.Events.Events.trialind)'  

    %% take only the N_keep events with highest power
    % 
    N_keep=100;
    [sorted_power, sort_power_i]=sort(specEv_struct.Events.Events.maximapower, 'descend');
    event_i_tokeep=sort(sort_power_i(1:N_keep));


    %let's define which random times we'll use for each trial 
    plot_time =500;%(this is dofferent form interval because trough could sit onthe edge of interval time so plot windw would reach way further
    
    % so far I've selected a time interval which varied in length per
    % trial, but to be consistent with prev papers, I'll just make them
    % 100ms;
    %how long should the interval where we look for trough be
    time_interval=100; % beta events tend to be like 150 (70-500)
    time_interval_per_trial=ones(nr_trials,1).*time_interval;
    duration_jitter=0; %shall we have the time interal constant or not
    if duration_jitter
        temp=randi(2);
        if temp==1
            time_interval_per_trial=time_interval_per_trial+(rand(nr_trials,1).*time_interval_per_trial);
        else
            time_interval_per_trial=time_interval_per_trial+(rand(nr_trials,1).*time_interval_per_trial*-1);
        end
    end
    half_time_interval_per_trial=floor(time_interval_per_trial/2);
    % now let's pick where to put this intevral for each trial
    start=nan(N_keep,1);
    interval_i=struct();% has to be struct because if there's jitter, won't be the same size
    %before, I'd find one per trial, but now I want to match this to the
    %number of beta events I'm keeping, so I'll make a random selection of
    %trials
    trials_for_rnd=randperm(nr_trials);
    trials_for_rnd=sort(trials_for_rnd(1:N_keep));
    for trial=1:length(trials_for_rnd)
        start(trials_for_rnd(trial))=randi([ceil(half_time_interval_per_trial(trials_for_rnd(trial)))+1,length(tVec)-ceil(half_time_interval_per_trial(trials_for_rnd(trial)))-1],1,1);
        interval_i.(strcat('T',num2str(trials_for_rnd(trial))))= [-half_time_interval_per_trial(trials_for_rnd(trial)):half_time_interval_per_trial(trials_for_rnd(trial))]+start(trials_for_rnd(trial));
    end



    %% now let's plot the sanity betas to ryans betas
    %% Plot beta peaks and me troughs to see if they overlap
    % before I usually had an event and a fake one per trial. nowI don't.
    % I'll just plot all the events and if there happens to be a rnd one
    % I'll plot it, and if not I won't
    sub_count=0;       
    figure('units','normalized','outerposition', [0 0 1 1]);
    %for trial=unique(specEv_struct.Events.Events.trialind)'  
    for trial=1:N_keep
        this_event_trial=specEv_struct.Events.Events.trialind(event_i_tokeep(trial));

        sub_count=sub_count+1;
        if sub_count==1
           clf
           hold on
        end
        subplot(4,1,sub_count)
            %% plot ryan stuff
            %% O
            this_TFR=squeeze(TFRs{1}(find(fVec==(eventBand(1))):find(fVec-eventBand(end)==min(abs(fVec-(eventBand(end))))),:,this_event_trial));
            imagesc([tVec(1) tVec(end)],eventBand,this_TFR)
    %             imagesc([EEG.times(1) EEG.times(end)]],[fVec(1) fVec(end)],TFRs{1}(:,:,trial))
            colormap jet
            cb = colorbar;         
            % Overlay locations of event peaks and the waveform corresponding with each trial
            hold on
            max_t=specEv_struct.Events.Events.maximatiming(specEv_struct.Events.Events.trialind==this_event_trial);
            max_f=specEv_struct.Events.Events.maximafreq(specEv_struct.Events.Events.trialind==this_event_trial);
            max_t_realtime=[];
            for i=1:length(max_t)
                max_t_realtime(i)=tVec(find(round(tVec_assumed,3)==round(max_t(i),3)));
            end
             plot(max_t_realtime,max_f,'.','Color',[.5 .5 .5],'Markersize',20) %Add points at event maxima
             
             
             % find the event we're actually here for
             max_t=specEv_struct.Events.Events.maximatiming(event_i_tokeep(trial));
             max_t_realtime=tVec(find(round(tVec_assumed,3)==round(max_t,3)));
             max_f=specEv_struct.Events.Events.maximafreq(event_i_tokeep(trial));
                  
             plot(max_t_realtime,max_f,'w.','Markersize',30) 

            %plot timeseries
            yyaxis right
            plot(tVec,X{1}(:,this_event_trial),'w','Linewidth',2)

            title(strcat('Trial ',num2str(this_event_trial)))


            %% plot my stuff
            if any(this_event_trial== trials_for_rnd)
    %         data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
                this_data=data(interval_i.(strcat('T',num2str(this_event_trial))),this_event_trial);

                [trough,trough_i]=min(this_data);

                trough_i=trough_i+interval_i.(strcat('T',num2str(this_event_trial)))(1)-1; 

                %% see if its near beta, redraw a new time
                while any(abs(max_t_realtime-trough_i)<50) %still use all events to exclude rnd
                       start(this_event_trial)=randi([ceil(half_time_interval_per_trial(this_event_trial))+1,length(tVec)-ceil(half_time_interval_per_trial(this_event_trial))-1],1,1);
                       interval_i.(strcat('T',num2str(this_event_trial)))= [-half_time_interval_per_trial(this_event_trial):half_time_interval_per_trial(this_event_trial)]+start(this_event_trial);
                       %refind trough
                       this_data=data(interval_i.(strcat('T',num2str(this_event_trial))),this_event_trial);
                       [trough,trough_i]=min(this_data);
                       trough_i=trough_i+interval_i.(strcat('T',num2str(this_event_trial)))(1)-1;
                end
                
                trough_i=tVec(trough_i);
                plot(trough_i,trough,'r.','Markersize',30)   
            end

                if sub_count==4 | trial==specEv_struct.Events.Events.trialind(end)
        %             print('-dpng','-r150',strcat('temp','.png'));
        %             blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
        %             Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
        %             Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

                    sub_count=0;
                end

    end
    close all    

    
    %% we just plotted all betas and chucked in a rnd if there was one, now we'll do the opposite just to check
    sub_count=0;       
    figure('units','normalized','outerposition', [0 0 1 1]);
    %for trial=unique(specEv_struct.Events.Events.trialind)'  
    for trial=1:N_keep
        this_event_trial=trials_for_rnd(trial);

        sub_count=sub_count+1;
        if sub_count==1
           clf
           hold on
        end
        subplot(4,1,sub_count)
        
        
            %% plot ryan stuff
            %% O
            this_TFR=squeeze(TFRs{1}(find(fVec==(eventBand(1))):find(fVec-eventBand(end)==min(abs(fVec-(eventBand(end))))),:,this_event_trial));
            imagesc([tVec(1) tVec(end)],eventBand,this_TFR)
    %             imagesc([EEG.times(1) EEG.times(end)]],[fVec(1) fVec(end)],TFRs{1}(:,:,trial))
            colormap jet
            cb = colorbar;         
            % Overlay locations of event peaks and the waveform corresponding with each trial
            hold on
            max_t=specEv_struct.Events.Events.maximatiming(specEv_struct.Events.Events.trialind==this_event_trial);
            max_f=specEv_struct.Events.Events.maximafreq(specEv_struct.Events.Events.trialind==this_event_trial);
            max_t_realtime=[];
            for i=1:length(max_t)
                max_t_realtime(i)=tVec(find(round(tVec_assumed,3)==round(max_t(i),3)));
            end
             plot(max_t_realtime,max_f,'.','Color',[.5 .5 .5],'Markersize',20) %Add points at event maxima
             
             
             % find the event we're actually here for (if there sis one)
             if any(this_event_trial== specEv_struct.Events.Events.trialind(event_i_tokeep))

                 max_t=specEv_struct.Events.Events.maximatiming(event_i_tokeep(specEv_struct.Events.Events.trialind(event_i_tokeep)==this_event_trial));
                 max_t_realtime=[];
                 for i=1:length(max_t)
                     max_t_realtime(i)=tVec(find(round(tVec_assumed,3)==round(max_t(i),3)));
                 end
                  max_f=specEv_struct.Events.Events.maximafreq(event_i_tokeep(specEv_struct.Events.Events.trialind(event_i_tokeep)==this_event_trial));
                  
                plot(max_t_realtime,max_f,'w.','Markersize',30) 
             end

            %plot timeseries
            yyaxis right
            plot(tVec,X{1}(:,this_event_trial),'w','Linewidth',2)

            title(strcat('Trial ',num2str(this_event_trial)))


            %% plot my stuff
%         data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
            this_data=data(interval_i.(strcat('T',num2str(this_event_trial))),this_event_trial);

            [trough,trough_i]=min(this_data);

            trough_i=trough_i+interval_i.(strcat('T',num2str(this_event_trial)))(1)-1; 

            %% see if its near beta, redraw a new time
            while any(abs(max_t_realtime-trough_i)<50) %still use all events to exclude rnd
                   start(this_event_trial)=randi([ceil(half_time_interval_per_trial(this_event_trial))+1,length(tVec)-ceil(half_time_interval_per_trial(this_event_trial))-1],1,1);
                   interval_i.(strcat('T',num2str(this_event_trial)))= [-half_time_interval_per_trial(this_event_trial):half_time_interval_per_trial(this_event_trial)]+start(this_event_trial);
                   %refind trough
                   this_data=data(interval_i.(strcat('T',num2str(this_event_trial))),this_event_trial);
                   [trough,trough_i]=min(this_data);
                   trough_i=trough_i+interval_i.(strcat('T',num2str(this_event_trial)))(1)-1;
            end

            trough_i=tVec(trough_i);
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
    ylim_timelock=[-1 1].*10^-7;%[-20 20];
    ylim_betapower=[0 3].*10^-16;%[.5 4];
    ylim_alphapower=[0 2].*10^-16;%[1 4];

    % electrode=electr_oi_i;%randi(size(EEG.data,1))
    lost_trials_ryan=[];
    lost_trials=[];
    trough_powspctrm=nan(N_keep,1,size(TFRs{1},1),floor(plot_time/dt)+1);
    trough_powspctrm_ryan=nan(N_keep,1,size(TFRs{1},1),floor(plot_time/dt)+1);
    trough_lock=nan(N_keep,floor(plot_time/dt)+1);
    padded_trials=[];
    alphapowerlock=nan(N_keep,floor(plot_time/dt)+1);
    betapowerlock=nan(N_keep,floor(plot_time/dt)+1);
    trough_lock_ryan=nan(N_keep,floor(plot_time/dt)+1);
    alphapowerlock_ryan=nan(N_keep,floor(plot_time/dt)+1);
    betapowerlock_ryan=nan(N_keep,floor(plot_time/dt)+1);
    figure('units','normalized','outerposition', [0 0 1 1]);
    hold on
    for trial_count = 1:N_keep
        %% mine
        trial=trials_for_rnd(trial_count);
    %     data=EEG.data(electrode,interval_i.(strcat('T',num2str(trial))),trial);
        this_data=data(interval_i.(strcat('T',num2str(trial))),trial);

        [trough,trough_i]=min(this_data);   
        trough_i=trough_i+interval_i.(strcat('T',num2str(trial)))(1)-1;
        try
                 
            
            
            
            
            
            trough_lock(trial_count,:)=data([trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2)],trial);
            trough_powspctrm(trial_count,1,1:size(TFRs{1},1),1:plot_time/dt+1)=TFRs{1}(:,[trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2)],trial);
            betapowerlock(trial_count,:)=mean(TFRs{1}((find(fVec==(betaband(1))):find(fVec-betaband(end)==min(abs(fVec-(betaband(end)))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);
            alphapowerlock(trial_count,:)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);

            
            
            
            
            
        catch
            
            time_oi=[max(1,trough_i-round(plot_time/dt/2)): min(trough_i+round(plot_time/dt/2),length(tVec))];
            if time_oi(1)==1
                time_in_mat=abs(trough_i-round(plot_time/dt/2))+2:floor(plot_time/dt)+1;
            elseif time_oi(end)==length(tVec)
                time_in_mat=1:length(time_oi);
            end
            
            trough_lock(trial_count,time_in_mat)=data(time_oi,trial);
            trough_powspctrm(trial_count,1,1:size(TFRs{1},1),time_in_mat)=TFRs{1}(:,time_oi,trial);
            betapowerlock(trial_count,time_in_mat)=mean(TFRs{1}((find(fVec==(betaband(1))):find(fVec-betaband(end)==min(abs(fVec-(betaband(end)))))),time_oi,trial),1);
            alphapowerlock(trial_count,time_in_mat)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),time_oi,trial),1);    
            
        end
        subplot(6,2,[1,3])
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Timeseries Random')
        plot(-plot_time/2:dt:plot_time/2, trough_lock(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,5)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Beta Power Random')
        plot(-plot_time/2:dt:plot_time/2, betapowerlock(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,7)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Alpha Power Random')
        plot(-plot_time/2:dt:plot_time/2, alphapowerlock(trial_count,:),'Color',[.5 .5 .5])



        %% ryan
        % from now on, we'll look within 100ms of peak power for trough
        trial=specEv_struct.Events.Events.trialind(event_i_tokeep(trial_count));
            
         max_t=specEv_struct.Events.Events.maximatiming(event_i_tokeep(trial_count));
         max_t_realtime=tVec(find(round(tVec_assumed,3)==round(max_t,3)));

         [trough,trough_i]=min(X{1}(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)),trial));  
            

        temp=1:length(tVec);
        temp=temp(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)));
        trough_i=temp(trough_i);

        try
            trough_lock_ryan(trial_count,:)=X{1}(trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial);
            %alpha and beta power
            betapowerlock_ryan(trial_count,:)=mean(TFRs{1}(find(fVec-betaband(1)==min(abs(fVec-(betaband(1))))):find(abs(fVec-betaband(end))==min(abs(fVec-(betaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);
            alphapowerlock_ryan(trial_count,:)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);       
            trough_powspctrm_ryan(trial_count,1,1:size(TFRs{1},1),1:plot_time/dt+1)=TFRs{1}(:,[trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2)],trial);

        catch
            
            time_oi=[max(1,trough_i-round(plot_time/dt/2)): min(trough_i+round(plot_time/dt/2),length(tVec))];
            if time_oi(1)==1
                time_in_mat=abs(trough_i-round(plot_time/dt/2))+2:floor(plot_time/dt)+1;
            elseif time_oi(end)==length(tVec)
                time_in_mat=1:length(time_oi);
            end
            
            trough_lock_ryan(trial_count,time_in_mat)=X{1}(time_oi,trial);
            trough_powspctrm_ryan(trial_count,1,1:size(TFRs{1},1),time_in_mat)=TFRs{1}(:,time_oi,trial);
            betapowerlock_ryan(trial_count,time_in_mat)=mean(TFRs{1}((find(fVec==(betaband(1))):find(fVec-betaband(end)==min(abs(fVec-(betaband(end)))))),time_oi,trial),1);
            alphapowerlock_ryan(trial_count,time_in_mat)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),time_oi,trial),1);    
            

            
            
            
            
        end
        subplot(6,2,[2,4])
        hold on
        title('Timeseries Beta Events')
        plot(-plot_time/2:dt:plot_time/2, trough_lock_ryan(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,6)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Beta Power Events')
        plot(-plot_time/2:dt:plot_time/2, betapowerlock_ryan(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,8)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Alpha Power Events')
        plot(-plot_time/2:dt:plot_time/2, alphapowerlock_ryan(trial_count,:),'Color',[.5 .5 .5])



    end
    %mine
    subplot(6,2,[1,3])
    title(strcat('Timeseries Random - NrTrials=',num2str(N_keep-length(lost_trials))))
    plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock),'Color','k','Linewidth',2)
    ylim(ylim_timelock)

    subplot(6,2,[5])
    plot(-plot_time/2:dt:plot_time/2, nanmean(betapowerlock),'Color','k','Linewidth',2)
    ylim(ylim_betapower)

    subplot(6,2,[7])
    plot(-plot_time/2:dt:plot_time/2, nanmean(alphapowerlock),'Color','k','Linewidth',2)
    ylim(ylim_alphapower)
   
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
    cb = colorbar; 
    % caxis([0.3 1.8])

    %ryan
    subplot(6,2,[2,4])
    title(strcat('Timeseries Events - NrTrials=',num2str(N_keep-length(lost_trials_ryan))))
    plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock_ryan),'Color','k','Linewidth',2)
    ylim(ylim_timelock)
    subplot(6,2,[6])
    plot(-plot_time/2:dt:plot_time/2, nanmean(betapowerlock_ryan),'Color','k','Linewidth',2)
    ylim(ylim_betapower)
    subplot(6,2,[8])
    plot(-plot_time/2:dt:plot_time/2, nanmean(alphapowerlock_ryan),'Color','k','Linewidth',2)
    ylim(ylim_alphapower)
    %  
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
     cb = colorbar;    
%     caxis_tfr=caxis;

    %apply this caxis to the other tfr
%     subplot(6,2,[9,11])
    % caxis(caxis_tfr)









    print('-dpng','-r150',strcat('temp','.png'));
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
    Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
    Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
















    % compare directly
    figure%('units','normalized','outerposition', [0 0 .5 .5]);
    %remove nan
%     trough_lock(isnan(trough_lock(:,1)),:)=[];
    SE_upper=[];
    SE_lower=[];
    for i=1:plot_time/dt+1
        se=nanstd(trough_lock(:,i))./sqrt(N_keep);
        SE_upper(i)=nanmean(trough_lock(:,i))+se;
        SE_lower(i)=nanmean(trough_lock(:,i))-se;
    end


    clf
    hold on
    colour=[.25 .625 1];
    lines(1)=plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock),'Linewidth',2,'Color', colour);
    %error bars
    tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
    tempy=[SE_upper,fliplr(SE_lower)];
    A=fill(tempx,tempy,'k');
    A.EdgeColor=colour;
    A.FaceColor=colour;
    A.FaceAlpha=.2;


    colour=[1 .625 .25];
%     trough_lock_ryan(isnan(trough_lock_ryan(:,1)),:)=[];
    SE_upper=[];
    SE_lower=[];
    for i=1:plot_time/dt+1
        se=nanstd(trough_lock_ryan(:,i))./sqrt(N_keep);
        SE_upper(i)=nanmean(trough_lock_ryan(:,i))+se;
        SE_lower(i)=nanmean(trough_lock_ryan(:,i))-se;
    end
    lines(2)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_ryan),'Linewidth',2,'Color', colour);
    %error bars
    tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
    tempy=[SE_upper,fliplr(SE_lower)];
    A=fill(tempx,tempy,'k');
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
            this_data=trough_lock_ryan;
        else
            colour=[.25 .625 1];
            this_data=trough_lock;
        end

    for trial=1:size(this_data,1)
        %find the centre trough
        trough_latency(trial)=plot_time/2+1;
        trough_value(trial)=this_data(trial,trough_latency(trial));
        %from here, find peaks
        % firs time it changes direction to down I guess
        %backwards
        found_peak=0;
        temp=0;
        while found_peak==0
            temp=temp+1;
            latency=trough_latency(trial)-temp;
            if this_data(trial,latency)<this_data(trial,latency+1)
                prev_peak_latency(trial)=latency+1;
                prev_peak_value(trial)=this_data(trial,prev_peak_latency(trial));
                found_peak=1;
            elseif isnan(this_data(trial,latency))
                prev_peak_latency(trial)=nan;
                prev_peak_value(trial)=nan;
                found_peak=1;
            end
        end
         %forwards
        found_peak=0;
        temp=0;
        while found_peak==0
            temp=temp+1;
            latency=trough_latency(trial)+temp;
            if this_data(trial,latency)<this_data(trial,latency-1)
                post_peak_latency(trial)=latency-1;
                post_peak_value(trial)=this_data(trial,post_peak_latency(trial));
                found_peak=1;
            elseif isnan(this_data(trial,latency))
                post_peak_latency(trial)=nan;
                post_peak_value(trial)=nan;
                found_peak=1;
            end
            
        end

        peak_to_peak_latency(trial)=post_peak_latency(trial)-prev_peak_latency(trial);
        trough_to_peak_amp(trial)=mean([post_peak_value(trial),prev_peak_value(trial)])-trough_value(trial);
    end

    if p==1
        peak_to_peak_latency_ryan_all(partic)=nanmean(peak_to_peak_latency);
        trough_to_peak_amp_ryan_all(partic)=nanmean(trough_to_peak_amp);
        trough_value_ryan_all(partic)=nanmean(trough_value);
        post_peak_value_ryan_all(partic)=nanmean(post_peak_value);
        prev_peak_value_ryan_all(partic)=nanmean(prev_peak_value);
    else
        peak_to_peak_latency_all(partic)=nanmean(peak_to_peak_latency);
        trough_to_peak_amp_all(partic)=nanmean(trough_to_peak_amp);
        trough_value_all(partic)=nanmean(trough_value);
        post_peak_value_all(partic)=nanmean(post_peak_value);
        prev_peak_value_all(partic)=nanmean(prev_peak_value);
    end

    xtext=sprintf(['Peak2Peak-Lat:  %2.2f (%2.2f) \n'...
        'Freq-P2P:  %i Hz\n'...
        'Trough2Peak-Amp:  %2.2f (%2.2f) \n'...
        'Trough-Amp:  %2.2f (%2.2f) \n'...
        'Peak-Amp:  %2.2f (%2.2f) \n'...
        'Peak-Amp Diff:  %2.2f (%2.2f) \n'],...
        mean(peak_to_peak_latency),nanstd(peak_to_peak_latency),...
        round(1000/nanmean(peak_to_peak_latency)),...
        mean(trough_to_peak_amp),nanstd(trough_to_peak_amp),...
        mean(trough_value),nanstd(trough_value),...
        mean(nanmean([post_peak_value;prev_peak_value])),nanstd(nanmean([post_peak_value;prev_peak_value])),...
        mean([post_peak_value-prev_peak_value]),nanstd([post_peak_value-prev_peak_value]));

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
                    S = nanmean(trough_lock_ryan,1);
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
                    S = nanmean(trough_lock,1);
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

    %             tVec = (1:size(S,2))/Fs;  

                B = zeros(length(fVec),size(S,2)); 
                width=7;

                for i=1:size(S,1)          
                    for j=1:length(fVec)

                        f=fVec(j);
                        s=detrend(S(i,:));

                        dt_s = 1/Fs;
                        sf = f/width;
                        st = 1/(2*pi*sf);

                        t=-3.5*st:dt_s:3.5*st;
                        A = 1/(st*sqrt(2*pi));
                        m = A*exp(-t.^2/(2*st^2)).*exp(1i*2*pi*f.*t);

                        y = conv(s,m);
                        y = 2*(dt_s*abs(y)).^2;
                        y = y(ceil(length(m)/2):length(y)-floor(length(m)/2));




                        B(j,:) = y + B(j,:);
                    end
                end
                TFR = B/size(S,1);     



                imagesc([-plot_time/2:dt:plot_time/2],band,TFR((find(fVec-band(1)==min(abs(fVec-(band(1))))):find(abs(fVec-band(end))==min(abs(fVec-(band(end)))))),:));
                ylim(band);
                colormap jet;
                cb = colorbar;   
                if p==1
                    if o==1
                        caxis_beta=caxis;
                    else
                        caxis_alpha=caxis;
                    end
                else
                    if o==1
    %                     caxis(caxis_beta);
                    else
    %                     caxis(caxis_alpha);
                    end
                end


                yyaxis right
                plot([-plot_time/2:dt:plot_time/2],S,'w','Linewidth',2);
                xlim([-plot_time/2 plot_time/2]);
                if p==1 & o==1
                    get_ts_ylim=ylim;
                elseif p==2
                    ylim(get_ts_ylim);
                end
        end

    end




    print('-dpng','-r150',strcat('temp','.png'));
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
    Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
    Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

    close all

    trough_lock_all(partic,:)=nanmean(trough_lock);
    trough_lock_ryan_all(partic,:)=nanmean(trough_lock_ryan);
end
















trough_lock=trough_lock_all;
trough_lock_ryan=trough_lock_ryan_all;
% compare directly
figure%('units','normalized','outerposition', [0 0 .5 .5]);
%remove nan
trough_lock(isnan(trough_lock(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock(:,i))./sqrt(length(trough_lock(:,i)));
    SE_upper(i)=mean(trough_lock(:,i))+se;
    SE_lower(i)=mean(trough_lock(:,i))-se;
end


clf
hold on
colour=[.25 .625 1];
lines(1)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;


colour=[1 .625 .25];
trough_lock_ryan(isnan(trough_lock_ryan(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock_ryan(:,i))./sqrt(length(trough_lock_ryan(:,i)));
    SE_upper(i)=mean(trough_lock_ryan(:,i))+se;
    SE_lower(i)=mean(trough_lock_ryan(:,i))-se;
end
lines(2)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_ryan),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;
ylims=ylim;

legend(lines,'Random','Event')



%% stats
   disp('Avg over difficulties')
[H,P,CI,STATS]=ttest(post_peak_value_all);
[H,P,CI,STATS]=ttest(prev_peak_value_all);
[H,P,CI,STATS]=ttest(post_peak_value_ryan_all);
[H,P,CI,STATS]=ttest(prev_peak_value_ryan_all);
    
[H,P,CI,STATS]=ttest(peak_to_peak_latency_all,peak_to_peak_latency_ryan_all)
[H,P,CI,STATS]=ttest(trough_to_peak_amp_all,trough_to_peak_amp_ryan_all)
[H,P,CI,STATS]=ttest(trough_value_all,trough_value_ryan_all)
[H,P,CI,STATS]=ttest(prev_peak_value_all,prev_peak_value_ryan_all)


trough_to_peak_amp_ryan_all=[];
trough_value_ryan_all=[];
post_peak_value_ryan_all=[];
prev_peak_value_ryan_all=[];



h=[];
p=[];
for i=1:301
    [h(i),p(i),CI,STATS]=ttest(trough_lock_all(:,i),trough_lock_ryan_all(:,i));
end
h(h==0)=nan;
h(h==1)=0;
plot([-plot_time/2:dt:plot_time/2],h,'k*')







    sort_i={};
    data_length=301
    corrected_p=nan(size(p));
    corrected_abs=nan(size(p));

        [sorted_p, sort_i]=sort(p);

            for i=1:length(p)-1
                corrected_p(end-i)= sorted_p(end-i)*data_length/(data_length-i);
                if sorted_p(end-i)*data_length/(data_length-i) < 0.05
                    corrected_abs(end-i)=1;
                end
            end
            
            h(sort_i)=corrected_abs;
plot([-plot_time/2:dt:plot_time/2],h-1,'r*')


    