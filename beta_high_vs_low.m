
clear

ppt=1;
h = actxserver('PowerPoint.Application');
Presentation = h.Presentation.Add;

alphaband=[8 13];
betaband=[15 29];
plot_time =500;

    

rng('shuffle')
Partic=[1:10];
trough_lock_low_all=[];
trough_lock_high_all=[];
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

    clearvars -except partic Partic h Presentation trough_lock_low_all trough_lock_high_all peak_to_peak_latency_all trough_to_peak_amp_all trough_value_all post_peak_value_all prev_peak_value_all peak_to_peak_latency_ryan_all trough_to_peak_amp_ryan_all trough_value_ryan_all post_peak_value_ryan_all prev_peak_value_ryan_all alphaband betaband plot_time highestpower lowestpower
    %% load data
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
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Define Events
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    Fs=600;
    dt=1000/600;
    X{1}=data;
    tVec_assumed=linspace(1/Fs,1,Fs);
    
    %% get beta events
    ryan='C:\Users\ckohl\Documents\MATLAB\Ryan';
    addpath(ryan)
    eventBand=betaband;
    fVec=3:3:30;
    findMethod=1;
    vis=0;
    classLabels{1}=1;
    tVec_assumed=linspace(1/Fs,1,Fs);
    [specEv_struct,TFRs,X] = spectralevents(eventBand,fVec,Fs,findMethod,vis,X,classLabels);

     fprintf('\n\nPartic: %d \nTrials: %d \nEvents: %d',partic,nr_trials,size(specEv_struct.Events.Events.maximapower,1))

    %% take only the N_keep events with highest power
    N_keep=50;
    time_interval=100;

    [sorted_power, sort_power_i]=sort(specEv_struct.Events.Events.maximapower, 'descend');
     high_event_i_tokeep=sort(sort_power_i(1:N_keep));

    [sorted_power, sort_power_i]=sort(specEv_struct.Events.Events.maximapower, 'ascend');
    low_event_i_tokeep=sort(sort_power_i(1:N_keep));



    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot everything togehter
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ylim_timelock=[-1 1].*10^-7;%[-20 20];
    ylim_betapower=[0 3].*10^-16;%[.5 4];
    ylim_alphapower=[0 2].*10^-16;%[1 4];

    % electrode=electr_oi_i;%randi(size(EEG.data,1))
    trough_powspctrm_low=nan(N_keep,1,size(TFRs{1},1),floor(plot_time/dt)+1);
    trough_powspctrm_high=nan(N_keep,1,size(TFRs{1},1),floor(plot_time/dt)+1);
    trough_lock_low=nan(N_keep,floor(plot_time/dt)+1);
    alphapowerlock_low=nan(N_keep,floor(plot_time/dt)+1);
    betapowerlock_low=nan(N_keep,floor(plot_time/dt)+1);
    trough_lock_high=nan(N_keep,floor(plot_time/dt)+1);
    alphapowerlock_high=nan(N_keep,floor(plot_time/dt)+1);
    betapowerlock_high=nan(N_keep,floor(plot_time/dt)+1);
    figure('units','normalized','outerposition', [0 0 1 1]);
    hold on
    for trial_count = 1:N_keep
        % go through high
        trial=specEv_struct.Events.Events.trialind(high_event_i_tokeep(trial_count));
        
    
         max_t=specEv_struct.Events.Events.maximatiming(high_event_i_tokeep(trial_count));
         max_t_realtime=tVec(find(round(tVec_assumed,3)==round(max_t,3)));

         [trough,trough_i]=min(X{1}(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)),trial));  
            

        temp=1:length(tVec);
        temp=temp(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)));
        trough_i=temp(trough_i);

        try
            trough_lock_high(trial_count,:)=X{1}(trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial);
            %alpha and beta power
            betapowerlock_high(trial_count,:)=mean(TFRs{1}(find(fVec-betaband(1)==min(abs(fVec-(betaband(1))))):find(abs(fVec-betaband(end))==min(abs(fVec-(betaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);
            alphapowerlock_high(trial_count,:)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);       
            trough_powspctrm_high(trial_count,1,1:size(TFRs{1},1),1:plot_time/dt+1)=TFRs{1}(:,[trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2)],trial);

        catch
            
            time_oi=[max(1,trough_i-round(plot_time/dt/2)): min(trough_i+round(plot_time/dt/2),length(tVec))];
            if time_oi(1)==1
                time_in_mat=abs(trough_i-round(plot_time/dt/2))+2:floor(plot_time/dt)+1;
            elseif time_oi(end)==length(tVec)
                time_in_mat=1:length(time_oi);
            end
            
            trough_lock_high(trial_count,time_in_mat)=X{1}(time_oi,trial);
            trough_powspctrm_high(trial_count,1,1:size(TFRs{1},1),time_in_mat)=TFRs{1}(:,time_oi,trial);
            betapowerlock_high(trial_count,time_in_mat)=mean(TFRs{1}((find(fVec==(betaband(1))):find(fVec-betaband(end)==min(abs(fVec-(betaband(end)))))),time_oi,trial),1);
            alphapowerlock_high(trial_count,time_in_mat)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),time_oi,trial),1);    
        end
        subplot(6,2,[2,4])
        hold on
        title('Timeseries High Beta Events')
        plot(-plot_time/2:dt:plot_time/2, trough_lock_high(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,6)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Beta Power High Events')
        plot(-plot_time/2:dt:plot_time/2, betapowerlock_high(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,8)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Alpha Power High Events')
        plot(-plot_time/2:dt:plot_time/2, alphapowerlock_high(trial_count,:),'Color',[.5 .5 .5])
        
        
        
        
        
        % go through low
        trial=specEv_struct.Events.Events.trialind(low_event_i_tokeep(trial_count));
        
    
         max_t=specEv_struct.Events.Events.maximatiming(low_event_i_tokeep(trial_count));
         max_t_realtime=tVec(find(round(tVec_assumed,3)==round(max_t,3)));

         [trough,trough_i]=min(X{1}(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)),trial));  
            

        temp=1:length(tVec);
        temp=temp(max(1,find(tVec==max_t_realtime)-time_interval/2/dt):min(find(tVec==max_t_realtime)+time_interval/2/dt,length(tVec)));
        trough_i=temp(trough_i);

        try
            trough_lock_low(trial_count,:)=X{1}(trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial);
            %alpha and beta power
            betapowerlock_low(trial_count,:)=mean(TFRs{1}(find(fVec-betaband(1)==min(abs(fVec-(betaband(1))))):find(abs(fVec-betaband(end))==min(abs(fVec-(betaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);
            alphapowerlock_low(trial_count,:)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2),trial),1);       
            trough_powspctrm_low(trial_count,1,1:size(TFRs{1},1),1:plot_time/dt+1)=TFRs{1}(:,[trough_i-round(plot_time/dt/2): trough_i+round(plot_time/dt/2)],trial);

        catch
            
            time_oi=[max(1,trough_i-round(plot_time/dt/2)): min(trough_i+round(plot_time/dt/2),length(tVec))];
            if time_oi(1)==1
                time_in_mat=abs(trough_i-round(plot_time/dt/2))+2:floor(plot_time/dt)+1;
            elseif time_oi(end)==length(tVec)
                time_in_mat=1:length(time_oi);
            end
            
            trough_lock_low(trial_count,time_in_mat)=X{1}(time_oi,trial);
            trough_powspctrm_low(trial_count,1,1:size(TFRs{1},1),time_in_mat)=TFRs{1}(:,time_oi,trial);
            betapowerlock_low(trial_count,time_in_mat)=mean(TFRs{1}((find(fVec==(betaband(1))):find(fVec-betaband(end)==min(abs(fVec-(betaband(end)))))),time_oi,trial),1);
            alphapowerlock_low(trial_count,time_in_mat)=mean(TFRs{1}(find(fVec-alphaband(1)==min(abs(fVec-(alphaband(1))))):find(abs(fVec-alphaband(end))==min(abs(fVec-(alphaband(end))))),time_oi,trial),1);    
        end
        subplot(6,2,[1,3])
        hold on
        title('Timeseries Low Beta Events')
        plot(-plot_time/2:dt:plot_time/2, trough_lock_low(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,5)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Beta Power Low Events')
        plot(-plot_time/2:dt:plot_time/2, betapowerlock_low(trial_count,:),'Color',[.5 .5 .5])

        subplot(6,2,7)
        xlim([-plot_time/2 plot_time/2])
        hold on
        title('Alpha Power Low Events')
        plot(-plot_time/2:dt:plot_time/2, alphapowerlock_low(trial_count,:),'Color',[.5 .5 .5])



    end
    %mine
    subplot(6,2,[1,3])
    title(strcat('Timeseries Low'))
    plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock_low),'Color','k','Linewidth',2)
    ylim(ylim_timelock)

    subplot(6,2,[5])
    plot(-plot_time/2:dt:plot_time/2, nanmean(betapowerlock_low),'Color','k','Linewidth',2)
    ylim(ylim_betapower)

    subplot(6,2,[7])
    plot(-plot_time/2:dt:plot_time/2, nanmean(alphapowerlock_low),'Color','k','Linewidth',2)
    ylim(ylim_alphapower)
   
    subplot(6,2,[9,11])
    imagesc([-plot_time/2 plot_time/2], fVec,squeeze(nanmean(trough_powspctrm_low,1)))
    hold on
    title('Avg TFR Low')
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
    title(strcat('Timeseries High'))
    plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock_high),'Color','k','Linewidth',2)
    ylim(ylim_timelock)
    subplot(6,2,[6])
    plot(-plot_time/2:dt:plot_time/2, nanmean(betapowerlock_high),'Color','k','Linewidth',2)
    ylim(ylim_betapower)
    subplot(6,2,[8])
    plot(-plot_time/2:dt:plot_time/2, nanmean(alphapowerlock_high),'Color','k','Linewidth',2)
    ylim(ylim_alphapower)
    %  
    subplot(6,2,[10,12])
    imagesc([-plot_time/2 plot_time/2], fVec,squeeze(nanmean(trough_powspctrm_high,1)))
    hold on
    title('Avg TFR High')
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














    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot avg waveforms: beta and rnd
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % compare directly
    figure%('units','normalized','outerposition', [0 0 .5 .5]);
    % get SE
    SE_upper=[];
    SE_lower=[];
    for i=1:plot_time/dt+1
        se=nanstd(trough_lock_low(:,i))./sqrt(N_keep);
        SE_upper(i)=nanmean(trough_lock_low(:,i))+se;
        SE_lower(i)=nanmean(trough_lock_low(:,i))-se;
    end

    clf
    hold on
    colour=[.25 .625 1];
    lines(1)=plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock_low),'Linewidth',2,'Color', colour);
    %error bars
    tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
    tempy=[SE_upper,fliplr(SE_lower)];
    A=fill(tempx,tempy,'k');
    A.EdgeColor=colour;
    A.FaceColor=colour;
    A.FaceAlpha=.2;

    %get SE
    colour=[1 .625 .25];
    SE_upper=[];
    SE_lower=[];
    for i=1:plot_time/dt+1
        se=nanstd(trough_lock_high(:,i))./sqrt(N_keep);
        SE_upper(i)=nanmean(trough_lock_high(:,i))+se;
        SE_lower(i)=nanmean(trough_lock_high(:,i))-se;
    end
    lines(2)=plot(-plot_time/2:dt:plot_time/2, nanmean(trough_lock_high),'Linewidth',2,'Color', colour);
    %error bars
    tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
    tempy=[SE_upper,fliplr(SE_lower)];
    A=fill(tempx,tempy,'k');
    A.EdgeColor=colour;
    A.FaceColor=colour;
    A.FaceAlpha=.2;
    ylims=ylim;

    legend(lines,'Low','High')

    % 
    % 
    % print('-dpng','-r150',strcat('temp','.png'));
    % blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
    % Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
    % Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
    % 

    
    
    
    
    
    

    %% same thign again but print some numbers (and keep for later)
    %let's look at the width
    for p=1:2
        if p==1 %beta
            colour=[1 .625 .25];
            this_data=trough_lock_high;
        else
            colour=[.25 .625 1];
            this_data=trough_lock_low;
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

%         if p==1
%             tx=text(-plot_time/2/3-150,ylims(1)+(ylims(2)-ylims(1))/4,xtext );
%         else
%             tx=text((plot_time/2/3)-50,ylims(1)+(ylims(2)-ylims(1))/4,xtext );
%         end
%         tx.Color=colour;
%         tx.FontWeight='bold';
%         tx.FontSize=10;
    end


    print('-dpng','-r150',strcat('temp','.png'));
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
    Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
    Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500


    
    
    
    
   

    trough_lock_low_all(partic,:)=nanmean(trough_lock_low);
    trough_lock_high_all(partic,:)=nanmean(trough_lock_high);
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot Grand Average
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trough_lock_low=trough_lock_low_all;
trough_lock_high=trough_lock_high_all;
% compare directly
figure%('units','normalized','outerposition', [0 0 1 1]);
%remove nan
trough_lock_low(isnan(trough_lock_low(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock_low(:,i))./sqrt(length(trough_lock_low(:,i)));
    SE_upper(i)=mean(trough_lock_low(:,i))+se;
    SE_lower(i)=mean(trough_lock_low(:,i))-se;
end


clf
hold on
colour=[.25 .625 1];
lines(1)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_low),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;


colour=[1 .625 .25];
trough_lock_high(isnan(trough_lock_high(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock_high(:,i))./sqrt(length(trough_lock_high(:,i)));
    SE_upper(i)=mean(trough_lock_high(:,i))+se;
    SE_lower(i)=mean(trough_lock_high(:,i))-se;
end
lines(2)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_high),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;
ylims=ylim;

legend(lines,'Low','High')
grandavgy=ylim;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Let's do some stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% are all positive peaks greater than 0?
[H,P,CI,STATS]=ttest(post_peak_value_all);
[H,P,CI,STATS]=ttest(prev_peak_value_all);
[H,P,CI,STATS]=ttest(post_peak_value_ryan_all);
[H,P,CI,STATS]=ttest(prev_peak_value_ryan_all);
 
%compare beta and rnd summary stats
[H,P,CI,STATS]=ttest(peak_to_peak_latency_all,peak_to_peak_latency_ryan_all)
[H,P,CI,STATS]=ttest(trough_to_peak_amp_all,trough_to_peak_amp_ryan_all)
[H,P,CI,STATS]=ttest(trough_value_all,trough_value_ryan_all)
[H,P,CI,STATS]=ttest(prev_peak_value_all,prev_peak_value_ryan_all)



%% amp ttest per timepoint
h=[];
p=[];
for i=1:length(trough_lock_low_all)
    [h(i),p(i),CI,STATS]=ttest(trough_lock_low_all(:,i),trough_lock_high_all(:,i));
end
h(h==0)=nan;
h(h==1)=grandavgy(1);
plot([-plot_time/2:dt:plot_time/2],h,'.','Color',[.4 .4 .4])
title('Amp')


% FDR correction
sort_i={};
data_length=length(trough_lock_low_all);
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
h(h==1)=grandavgy(1);
plot([-plot_time/2:dt:plot_time/2],h,'k.','Markersize',20)
legend(lines,'Low','High')
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500


%% slope ttest per timepoint

slope_int=20;
h=nan(length(trough_lock_low_all),1);
p=nan(length(trough_lock_low_all),1);
for i=slope_int/2/dt+1:length(trough_lock_low_all)-slope_int/dt/2-1
    time_oi=i-slope_int/dt/2:i+slope_int/dt/2;
    slope_rnd=[];
    slope_ryan=[];
    for partic=1:length(Partic)
        P=polyfit(tVec(time_oi),trough_lock_low_all(partic,time_oi),1);
        slope_rnd(partic)=P(1);
        P=polyfit(tVec(time_oi),trough_lock_high_all(partic,time_oi),1);
        slope_ryan(partic)=P(1);
    end
    
    [h(i),p(i),CI,STATS]=ttest(slope_rnd,slope_ryan);
end

h(h==0)=nan;
h(h==1)=grandavgy(1);

% compare directly
figure%('units','normalized','outerposition', [0 0 1 1]);
%remove nan
trough_lock_low(isnan(trough_lock_low(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock_low(:,i))./sqrt(length(trough_lock_low(:,i)));
    SE_upper(i)=mean(trough_lock_low(:,i))+se;
    SE_lower(i)=mean(trough_lock_low(:,i))-se;
end


clf
hold on
colour=[.25 .625 1];
lines(1)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_low),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;


colour=[1 .625 .25];
trough_lock_high(isnan(trough_lock_high(:,1)),:)=[];
SE_upper=[];
SE_lower=[];
for i=1:plot_time/dt+1
    se=std(trough_lock_high(:,i))./sqrt(length(trough_lock_high(:,i)));
    SE_upper(i)=mean(trough_lock_high(:,i))+se;
    SE_lower(i)=mean(trough_lock_high(:,i))-se;
end
lines(2)=plot(-plot_time/2:dt:plot_time/2, mean(trough_lock_high),'Linewidth',2,'Color', colour);
%error bars
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
tempy=[SE_upper,fliplr(SE_lower)];
A=fill(tempx,tempy,'k');
A.EdgeColor=colour;
A.FaceColor=colour;
A.FaceAlpha=.2;
ylims=ylim;

legend(lines,'Random','Event')
title('Slope')
plot([-plot_time/2:dt:plot_time/2],h,'.','Color',[.4 .4 .4])



% FDR correction
sort_i={};
data_length=length(trough_lock_low_all);
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
h(h==1)=grandavgy(1);
plot([-plot_time/2:dt:plot_time/2],h,'k.','Markersize',20)
legend(lines,'Low','High')

print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

    
