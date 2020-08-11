%% BETA VS RND
% let's do some more stats for rnd vs beta low vs beta high

clear
cd('F:\Brown\Beta_v_Rnd')
load('rnd_50')
load('beta_low_50')
load('beta_high_50')
rnd=rnd_50;
high=beta_high_50;
low=beta_low_50;

plot_time=500;
Fs=600;
dt=1000/Fs;
tVec=[-plot_time/2:dt:plot_time/2];
Conds={'rnd','low','high'};

h = actxserver('PowerPoint.Application');
Presentation = h.Presentation.Add;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure%('units','normalized','outerposition', [0 0 1 1]);
SE_high_upper=[];
SE_high_lower=[];
SE_low_upper=[];
SE_low_lower=[];
SE_rnd_upper=[];
SE_rnd_lower=[];
for i=1:length(high)
    se_low=std(high(:,i))./sqrt(length(low(:,i)));
    SE_low_upper(i)=mean(low(:,i))+se_low;
    SE_low_lower(i)=mean(low(:,i))-se_low;
    
    se_high=std(high(:,i))./sqrt(length(high(:,i)));
    SE_high_upper(i)=mean(high(:,i))+se_high;
    SE_high_lower(i)=mean(high(:,i))-se_high;
    
    se_rnd=std(rnd(:,i))./sqrt(length(rnd(:,i)));
    SE_rnd_upper(i)=mean(rnd(:,i))+se_rnd;
    SE_rnd_lower(i)=mean(rnd(:,i))-se_rnd;
end

errorbars=1;
subs=0;

clf
hold on
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];

for conds=1:length(Conds)
    
    if subs
        subplot(3,1,conds)
        hold on
    end
    lines(conds)=plot(-plot_time/2:dt:plot_time/2, mean(eval(Conds{conds})),'Linewidth',2,'Color', colours{conds});
    %error bars
    if errorbars
        if conds==1
            tempy=[SE_rnd_upper,fliplr(SE_rnd_lower)];
        elseif conds==2
            tempy=[SE_low_upper,fliplr(SE_low_lower)];
        elseif conds==3
            tempy=[SE_high_upper,fliplr(SE_high_lower)];
        end

        A=fill(tempx,tempy,'k');
        A.EdgeColor=colours{conds};
        A.FaceColor=colours{conds};
        A.FaceAlpha=.2;
    end
end

legend(lines,'Rnd','Low','High')
high_ylim=ylim;
if subs
    subplot(3,1,1)
    ylim(high_ylim)
    subplot(3,1,2)
    ylim(high_ylim)
end
    
xlim([-plot_time/2 plot_time/2])
% 
% print('-dpng','-r150',strcat('temp','.png'));
% blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
% Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
% Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure%('units','normalized','outerposition', [0 0 1 1]);
for partic=1:size(rnd,1)
    clf
    hold on
    colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
    tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];

    for conds=1:length(Conds)
        data=eval(Conds{conds});
        lines(conds)=plot(-plot_time/2:dt:plot_time/2, data(partic,:),'Linewidth',2,'Color', colours{conds});
    end

    legend(lines,'Rnd','Low','High')
    xlim([-plot_time/2 plot_time/2])
    title(strcat('Partic',num2str(partic)))
    
    print('-dpng','-r150',strcat('temp','.png'));
    blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
    Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
    Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

end
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ANOVA per timepoint
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% first plot again

figure%('units','normalized','outerposition', [0 0 1 1])
errorbars=1;
clf
hold on
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
tempx=[[-plot_time/2:dt:plot_time/2],fliplr([-plot_time/2:dt:plot_time/2])];
for conds=1:length(Conds)
    lines(conds)=plot(-plot_time/2:dt:plot_time/2, mean(eval(Conds{conds})),'Linewidth',2,'Color', colours{conds});
    %error bars
    if errorbars
        if conds==1
            tempy=[SE_rnd_upper,fliplr(SE_rnd_lower)];
        elseif conds==2
            tempy=[SE_low_upper,fliplr(SE_low_lower)];
        elseif conds==3
            tempy=[SE_high_upper,fliplr(SE_high_lower)];
        end
        A=fill(tempx,tempy,'k');
        A.EdgeColor=colours{conds};
        A.FaceColor=colours{conds};
        A.FaceAlpha=.2;
    end
end

legend(lines,'Rnd','Low','High')   
xlim([-plot_time/2 plot_time/2])

%% now stats
% what are we testing?
TEST={'Amp','Slope'};
test=1;

slope_int=20;
within=table(categorical([0 1 2])','variablenames',{'Conds'}); 
% 0 rnd
% 1 low
% 2 high

%init
MainEffect_p=nan(1,length(rnd));
MainEffect_F=nan(1,length(rnd));
MainEffect_abs=nan(1,length(rnd));
LSD_abs.rnd_low=nan(1,length(rnd));
LSD_abs.rnd_high=nan(1,length(rnd));
LSD_abs.low_high=nan(1,length(rnd));
LSD_p.rnd_low=nan(1,length(rnd));
LSD_p.rnd_high=nan(1,length(rnd));
LSD_p.low_high=nan(1,length(rnd));

if test==1
    timepoints=1:length(rnd);
elseif test==2
    timepoints=slope_int/2/dt+1:length(rnd)-slope_int/dt/2-1;
end

for t=timepoints
    if test==1
        tab=table(rnd(:,t),low(:,t),high(:,t),'variablenames',{Conds{:}});
    elseif test==2
        time_oi=t-slope_int/dt/2:t+slope_int/dt/2;
        slope_rnd=[];
        slope_low=[];
        slope_high=[];
        for partic=1:size(rnd,1)
            P=polyfit(tVec(time_oi),rnd(partic,time_oi),1);
            slope_rnd(partic)=P(1);
            P=polyfit(tVec(time_oi),low(partic,time_oi),1);
            slope_low(partic)=P(1);
            P=polyfit(tVec(time_oi),high(partic,time_oi),1);
            slope_high(partic)=P(1);
        end
        tab=table(slope_rnd',slope_low',slope_high','variablenames',{Conds{:}});
    end
    

    rm=fitrm(tab, strcat(Conds{1},'-',Conds{end},' ~1'), 'WithinDesign',within);
    ranovatbl = ranova(rm,'withinmodel','Conds');
    
      
     if table2array(ranovatbl(3,5))<.05
         MainEffect_abs(t)=1;
            %FOLLOW UP
            lsd=multcompare(rm,'Conds','comparisonType','lsd');
            lsd=table2cell(lsd);
            if lsd{1,5}<.05
                LSD_abs.rnd_low(t)=1;
            end
            if lsd{2,5}<.05
                LSD_abs.rnd_high(t)=1;
            end
            if lsd{4,5}<.05
                LSD_abs.low_high(t)=1;
            end
            LSD_p.rnd_low(t)=lsd{1,5};
            LSD_p.rnd_high(t)=lsd{2,5};
            LSD_p.low_high(t)=lsd{4,5};
     end
        
     MainEffect_p(t)=table2array(ranovatbl(3,5));
     MainEffect_F(t)=table2array(ranovatbl(3,4));   
end


%% FDR
sorted={};
sort_i={};

[sorted.MainEffect_p, sort_i]=sort (MainEffect_p);
corrected_p=nan(1,length(sorted.MainEffect_p));
corrected_abs=nan(1,length(sorted.MainEffect_p));


for i=1:length(sorted.MainEffect_p)-1
    corrected_p(end-i)= sorted.MainEffect_p(end-i)*length(sorted.MainEffect_p)/(length(sorted.MainEffect_p)-i);
    if sorted.MainEffect_p(end-i)*length(sorted.MainEffect_p)/(length(sorted.MainEffect_p)-i) < 0.05
        corrected_abs(end-i)=1;
    end
end


%put into Main and unsort
keep_uncorrected=MainEffect_abs;
MainEffect_p(sort_i)=corrected_p;
MainEffect_abs(sort_i)=corrected_abs;

LSD_abs_temp=LSD_abs;
LSD_abs.rnd_low=nan(1,length(sorted.MainEffect_p));
LSD_abs.rnd_high=nan(1,length(sorted.MainEffect_p));
LSD_abs.low_high=nan(1,length(sorted.MainEffect_p));

LSD_abs.rnd_low(LSD_abs_temp.rnd_low==1 & MainEffect_abs==1)=1;
LSD_abs.rnd_high(LSD_abs_temp.rnd_high==1 & MainEffect_abs==1)=1;
LSD_abs.low_high(LSD_abs_temp.low_high==1 & MainEffect_abs==1)=1;


%% plot
%sort sig periods into continuous chunks
sig_inds=find(MainEffect_abs==1);
sig_inds_cell={};
sig_inds_cell{1}=[sig_inds(1)];
cell_count=1;
for i=2:length(sig_inds)-1
    if sig_inds(i)==sig_inds(i-1)+1
        if sig_inds(i)+1==sig_inds(i+1)
            %continue
        else
            sig_inds_cell{cell_count}(2)=sig_inds(i);
        end
        
    else %start new cell
        cell_count=cell_count+1;
        sig_inds_cell{cell_count}=[sig_inds(i)];
    end
end
 %plot them   
for i=1:length(sig_inds_cell)
    X= sig_inds_cell{i};
    if length(sig_inds_cell{i})==1
        X= [sig_inds_cell{i} sig_inds_cell{i}];
    end
    X=tVec(X);
    X=[X,fliplr(X)];   
    Y=[[high_ylim(1),high_ylim(1)],fliplr([high_ylim(2),high_ylim(2)])];
    A=fill(X,Y,[.2 .2 .2]) ;
	A.FaceColor=[.2 .2 .2];
    A.EdgeColor='None';
	A.FaceAlpha=.1;
end

%replot main data on top
for conds=1:length(Conds)
    lines(conds)=plot(-plot_time/2:dt:plot_time/2, mean(eval(Conds{conds})),'Linewidth',2,'Color', colours{conds});
end



% keep_uncorrected(keep_uncorrected==1)=high_ylim(1)+ (high_ylim(2)-high_ylim(1))/10;
% plot([-plot_time/2:dt:plot_time/2],keep_uncorrected,'.','Color',[.7 .7 .7]);

%% plot LSD 
LSD_abs.rnd_low(LSD_abs.rnd_low==1)=high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*5);
plot([-plot_time/2:dt:plot_time/2],LSD_abs.rnd_low,'.','Color','k');
tx=text(-plot_time/2+1,high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*5),'rnd v low' );
tx.Color=[.2 .2 .2];
tx.FontWeight='bold';
tx.FontSize=10;


LSD_abs.rnd_high(LSD_abs.rnd_high==1)=high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*10);
plot([-plot_time/2:dt:plot_time/2],LSD_abs.rnd_high,'.','Color','k');
tx=text(-plot_time/2+1,high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*10),'rnd v high' );
tx.Color=[.2 .2 .2];
tx.FontWeight='bold';
tx.FontSize=10;

LSD_abs.low_high(LSD_abs.low_high==1)=high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*15);
plot([-plot_time/2:dt:plot_time/2],LSD_abs.low_high,'.','Color','k');
tx=text(-plot_time/2+1,high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*15),'low v high' );
tx.Color=[.2 .2 .2];
tx.FontWeight='bold';
tx.FontSize=10;


legend(lines,'Rnd','Low','High')
title(TEST{test})
             

print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

                        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Summary stats
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% let's see when each changes direction?

%% let's just look at the fourier transform
figure
hold on

skip_high_outliers=0;
match_ylim=0;
name='';
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
for conds=1:length(Conds)
    subplot(3,1,conds)
    hold on
    power=[];
    data=eval(Conds{conds});
    for partic=1:(size(rnd,1))
        if skip_high_outliers & (partic==2 | partic==3| partic==6)
            if isempty(name)
                name=strcat(name,'- outliers skipped ');
            end
        else
            x=data(partic,:);
            fs=600;
            y = fft(x);
            n = length(x);          % number of samples
            f = (0:n-1)*(fs/n);     % frequency range
            power(partic,:) = abs(y).^2/n;    % power of the DFT
            plot(f,power,'Linewidth',2,'Color',colours{conds})
            xlim([0 50])
        end
    end
end
if match_ylim
    name=strcat(name,'- Y fixed ');
    high_ylim=ylim;
    subplot(3,1,1)
    ylim(high_ylim)
    subplot(3,1,2)
    ylim(high_ylim)
end
subplot(3,1,1)
title(strcat('Freq',name))

print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500

               


%% now TFR of Avg
figure('units','normalized','outerposition', [0 0 1 1]);
match_clim=0;
name='';
fVec=3:3:30;
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
for conds=1:length(Conds)
    data=eval(Conds{conds});
    subplot(2,3,conds)
    hold on    
    plot([-plot_time/2:dt:plot_time/2],mean(data),'Color',colours{conds},'Linewidth',2)
    xlim([-plot_time/2 plot_time/2])   
    
    subplot(2,3,conds+3)
    hold on
    S=mean(data);
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
    imagesc([-plot_time/2:dt:plot_time/2],fVec,TFR)
    ylim([fVec(1),fVec(end)])
    xlim([-plot_time/2 plot_time/2]);
    title(Conds{conds})    
    xlim([-plot_time/2,plot_time/2])
    cbar
end
if match_clim
    subplot(2,3,6)
    name=strcat(name,'- C fixed ');
    title(strcat(Conds{conds},name))
    high_clim=caxis;
    subplot(2,3,4)
    title(strcat(Conds{1},name))
    caxis(high_clim)
    subplot(2,3,5)
    title(strcat(Conds{2},name))
    caxis(high_clim)
end
   
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all








%% AVG of TFR
figure('units','normalized','outerposition', [0 0 1 1]);
match_clim=1;
name='';
fVec=3:3:30;
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};
for conds=1:length(Conds)
    data=eval(Conds{conds});
    subplot(2,3,conds)
    hold on    
    plot([-plot_time/2:dt:plot_time/2],mean(data),'Color',colours{conds},'Linewidth',2)
    xlim([-plot_time/2 plot_time/2])   
    
    subplot(2,3,conds+3)
    hold on
    TFR=nan(length(fVec),length(rnd),size(rnd,1));
    for partic=1:size(rnd,1)
        S=data(partic,:);
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
        TFR(:,:,partic) = B/size(S,1);    
    end
    TFR=mean(TFR,3);
    imagesc([-plot_time/2:dt:plot_time/2],fVec,TFR)
    ylim([fVec(1),fVec(end)])
    xlim([-plot_time/2 plot_time/2]);
    title(Conds{conds})    
    xlim([-plot_time/2,plot_time/2])
    cbar
end
if match_clim
    subplot(2,3,6)
    name=strcat(name,'- C fixed ');
    title(strcat(Conds{conds},name))
    high_clim=caxis;
    subplot(2,3,4)
    title(strcat(Conds{1},name))
    caxis(high_clim)
    subplot(2,3,5)
    title(strcat(Conds{2},name))
    caxis(high_clim)
end
   
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all




%% now TFR of Avg but delete trough
figure('units','normalized','outerposition', [0 0 1 1]);
match_clim=1;
name='';
fVec=3:3:30;
colours={[.25 .625 1], [1 .75 .5],[216 72 0]/250};

for conds=1:length(Conds)
    subplot(2,3,conds)
    hold on
    data=mean(eval(Conds{conds}));
    plot(tVec,data,'Color',colours{conds},'Linewidth',1)

    %find prev and post peaks
    trough_latency=find(tVec==0);
    trough_value=data(trough_latency);
    %from here, find peaks
    % firs time it changes direction to down I guessbackwards
    found_peak=0;
    temp=0;
    while found_peak==0
        temp=temp+1;
        latency=trough_latency-temp;
        if data(latency)<data(latency+1)
            prev_peak_latency=latency+1;
            prev_peak_value=data(prev_peak_latency);
            found_peak=1;
        end
    end
    %forwards
    found_peak=0;
    temp=0;
    while found_peak==0
        temp=temp+1;
        latency=trough_latency+temp;
        if data(latency)<data(latency-1)
            post_peak_latency=latency-1;
            post_peak_value=data(post_peak_latency);
            found_peak=1;
        end
    end

    %apply movign avg between the peaks
    %increase moving avg window as we approach the trough
    trough_period=[prev_peak_latency+5:post_peak_latency-5];
    halfway=floor(length(trough_period)/2);
    movingavg=[2 10];
    movingavg=round(linspace(movingavg(1),movingavg(2),halfway));
    movingavg=[movingavg,sort(movingavg,'descend')];
    if length(movingavg)<length(trough_period)
        movingavg(end+1)=movingavg(1);
    end
    for rounds=1:3
        count=0;
        for i=trough_period
            count=count+1;
            data(i)=mean(data(i-movingavg(count):i+movingavg(count)));
        end
    end
    plot(tVec,data,'Color',colours{conds},'Linewidth',2)

    % TFR
    subplot(2,3,conds+3)
    hold on
    S=data;
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
    imagesc([-plot_time/2:dt:plot_time/2],fVec,TFR)
    ylim([fVec(1),fVec(end)])
    xlim([-plot_time/2 plot_time/2]);
    title(Conds{conds})    
    xlim([-plot_time/2,plot_time/2])
    cbar
end
if match_clim
    subplot(2,3,6)
    name=strcat(name,'- C fixed ');
    title(strcat(Conds{conds},name))
    high_clim=caxis;
    subplot(2,3,4)
    title(strcat(Conds{1},name))
    caxis(high_clim)
    subplot(2,3,5)
    title(strcat(Conds{2},name))
    caxis(high_clim)
end
   
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Find Turning points (peaks/troughs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a giant pain in the butt. In the end I did two things
% 1) Autmatic turning point detection
%     - smooth each waveform using a moving avg
%     - get derivative of smoothed data
%     - find where derivative crosses zero (peaks)
%     - define turning points as abs max points within 5ms of those zwro crossings
%     - sort into peaks/troughs (max/mins) based on whether derivatives preceding this point were neg/pos
%     - saved as 'auto_turning_points'
% 
% 2) Manual turning point detection
%     - literally picked them by hand
%     - shockingly, not much better (but at least I get to make sure maxs and mins alternate)
%     - saved as 'turning_points'

%% smooth data using moving avg & get derivative
fig1=figure('units','normalized','outerposition', [0 0 1 1]);
fig2=figure('units','normalized','outerposition', [0 0 1 1]);
for conds=1:length(Conds)  
    for partic=1:size(rnd,1)

        data=eval(Conds{conds});
        figure(fig2)
        subplot(6,5,partic+(size(rnd,1)*(conds-1)))
        title(strcat('Partic',num2str(partic)))
        hold on
        figure(fig1)
        subplot(6,5,partic+(size(rnd,1)*(conds-1)))
        title(strcat('Partic',num2str(partic)))
        hold on
        data=data(partic,:);
        plot(tVec,data,'Color',colours{conds},'Linewidth',2)
        %smooth using moving avg
        movingavg=6; %10ms
        for i=movingavg+1:length(data)-(movingavg+1)
            data(i)=mean(data(i-movingavg:i+movingavg));
        end
        plot(tVec,data,'Color','k','Linewidth',1)
        
        figure(fig2)
        plot(tVec,data,'Color',colours{conds},'Linewidth',2)
        der=diff(data);
        der=[nan,der];
        %mydiff
        data1=[data,nan,nan];
        data2=[nan,nan,data];
        data3=data1-data2;
        yyaxis right
        plot(tVec,der,'Color','k','Linewidth',1)
        if conds==1
            smooth_rnd(partic,:)=data;
            der_rnd(partic,:)=der;
        elseif conds==2
            smooth_low(partic,:)=data;
            der_low(partic,:)=der;
        elseif conds==3
            smooth_high(partic,:)=data;
            der_high(partic,:)=der;
        end
    end
end
figure(fig1)
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
figure(fig2)
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all

        
%% define turning points based on derivative zero crossings
auto_turning_points=struct();
figure('units','normalized','outerposition', [0 0 1 1]);
for conds=1:length(Conds)  
    for partic=1:size(rnd,1)
        og_data=eval(Conds{conds});
        data=eval(strcat('smooth_',Conds{conds}));
        der=eval(strcat('der_',Conds{conds}));
        og_data=og_data(partic,:);
        data=data(partic,:);
        der=der(partic,:);
        %crop
        tVec_der=tVec(find(tVec==-200):find(tVec==+200));
        data=data(find(tVec==-200):find(tVec==+200));
        der=der(find(tVec==-200):find(tVec==+200));
        og_data=og_data(find(tVec==-200):find(tVec==+200));
        subplot(6,5,partic+(size(rnd,1)*(conds-1)))
        hold on
        yyaxis right
        title(strcat(Conds{conds},'- Partic',num2str(partic)))
        plot(tVec_der,der,'--','Color',[.7 .7 .7]);
        plot([tVec_der(1) tVec_der(end)],[0 0],':','Color', [.5 .5 .5])
        
        yyaxis left
        plot(tVec_der,data,'--','Color','k','Linewidth',1)
        plot(tVec_der,og_data,'Color',colours{conds},'Linewidth',2)

        %find derivative zero crossings
        zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);   
        zx=zci(der);
        %delete if too close together
        for j=1:length(zx)
            if j<length(zx)
                if zx(j+1)-zx(j)<4
                    temp=0;
                    while (zx(j+temp+1)-zx(j+temp)<4) & j+temp+1<length(zx)
                        temp=temp+1;
                    end
                    cont_x=j:j+temp;
                    [temp,max_i]=max(abs(data(cont_x)));
                    keep=cont_x(max_i);
                    zx(cont_x(cont_x~=keep))=[];
                end
            end
        end
        plot(tVec_der(zx), data(zx), 'ro');
        
        % find abs max in og_data within 5ms of detected zx
        og_zx=[];
        mins=[];
        maxs=[];
        within=5;%ms
        zx(find(zx<within/dt | zx>length(tVec_der)-within/dt))=[];
        for i=1:length(zx)
            [temp,temp_i]=max(abs(data(zx(i)-floor(within/2/dt):zx(i)+floor(within/2/dt))));
            og_zx(i)=zx(i)-floor(within/2/dt)-1+temp_i;
            % sort into trouhgs and peaks
            try %get mean of 3 points of derivative prior to this turning point
                opp=0;
                derest=mean(der(og_zx(i)-3:og_zx(i)-1));
            catch %if you can't get those, do the following points and apply the opposite logic
                opp=1;
                derest=mean(der(og_zx(i)+1:og_zx(i)+3));
            end
            if (opp==0 & derest>0) | (opp==1 & derest<0)
                maxs=[maxs,og_zx(i)];
            else
                mins=[mins,og_zx(i)];
            end
        end
        plot(tVec_der(og_zx), og_data(og_zx), 'bp');       
        plot(tVec_der(mins),og_data(mins),'r.','Markersize',20)
        plot(tVec_der(maxs),og_data(maxs),'g.','Markersize',20)
        
        
        auto_turning_points.(Conds{conds}).(strcat('P',num2str(partic)))=og_zx;
        auto_turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_mins'))=mins;
        auto_turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_maxs'))=maxs;
        
    end
    
end
% cd('F:\Brown\Beta_v_Rnd')
% save('auto_turning_points','auto_turning_points')
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all   

%% manually select turning points
% for conds=1:length(Conds)  
%     for partic=1:size(rnd,1)
%         clf
%         og_data=eval(Conds{conds});
%         og_data=og_data(partic,:);
%         hold on
%         title(strcat(Conds{conds},'- Partic',num2str(partic)))
%         plot(tVec,og_data,'Color',colours{conds},'Linewidth',2)
%         turning_point=input('turning_points- starting with min(x):');
%         turning_points.(Conds{conds}).(strcat('P',num2str(partic)))=turning_point;
%     end
% end
% cd('F:\Brown\Beta_v_Rnd')
% save('turning_points','turning_points')


%% load manually or automatically  selected turning points
cd('F:\Brown\Beta_v_Rnd')
auto=1;
load('turning_points')
if auto
    load('auto_turning_points')
    turning_points=auto_turning_points;
end
figure('units','normalized','outerposition', [0 0 1 1]);
clf
for conds=1:length(Conds)  
    for partic=1:size(rnd,1)
        subplot(6,5,partic+(size(rnd,1)*(conds-1)))
        og_data=eval(Conds{conds});
        og_data=og_data(partic,:);
        hold on
        title(strcat(Conds{conds},'- Partic',num2str(partic)))
        plot(tVec,og_data,'Color',colours{conds},'Linewidth',2)
        %max
        x=turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_maxs'));   
        for i=1:length(x)
            if auto               
                [temp, x(i)]=min(abs(round(tVec)-round(tVec_der(x(i)))));
            else
                [temp, x(i)]=min(abs(round(tVec)-round(x(i))));   
            end
            plot(tVec(x(i)), og_data(x(i)),'.','Markersize',20,'Color','g')
        end
        %mins
        x=turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_mins')); 
        for i=1:length(x)
            if auto               
                [temp, x(i)]=min(abs(round(tVec)-round(tVec_der(x(i)))));
            else
                [temp, x(i)]=min(abs(round(tVec)-round(x(i))));   
            end
            plot(tVec(x(i)), og_data(x(i)),'.','Markersize',20,'Color','r')
        end
    end
end
print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all


%% test turning point differences
% first let's take the first trough after midpoint and compare latencies
%%%%%%%%%%%%%%%%%%%%%
prev_or_post=2;   % peak/trough pre (1) or post (2) main trough
peak_or_trough=2; % peaks (1) or troughs (2)
auto=1;           % automatically (1) or manually (0) selected turning points
%%%%%%%%%%%%%%%%%%%%%

figure('units','normalized','outerposition', [0 0 1 1]);
clf
subplot(2,1,1)
hold on
if prev_or_post==1
    if peak_or_trough==1
        title('Prev Peaks')
    else
        title('Prev Troughs')
    end
elseif prev_or_post==2
    if peak_or_trough==1
        title('Post Peaks')
    else
        title('Post Troughs')
    end
end
cd('F:\Brown\Beta_v_Rnd')
load('turning_points')
if auto
    load('auto_turning_points')
    turning_points=auto_turning_points;
end
high_ylim=[-6.00000000000000e-08,3.00000000000000e-08];

post_trough_latency=[];
pre_trough_latency=[];
post_peak_latency=[];
pre_peak_latency=[];

for conds=1:length(Conds)  
    data=eval(Conds{conds});
    lines(conds)=plot(-plot_time/2:dt:plot_time/2, mean(data),'Linewidth',2,'Color', colours{conds});
    for partic=1:size(rnd,1)
        % convert turning points to indeces;
        if peak_or_trough==1
            x=turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_maxs'));
        else
            x=turning_points.(Conds{conds}).(strcat('P',num2str(partic),'_mins'));
        end
        for i=1:length(x)
            if auto               
                [temp, x(i)]=min(abs(round(tVec)-round(tVec_der(x(i)))));
            else
                [temp, x(i)]=min(abs(round(tVec)-round(x(i))));   
            end
        end
        if peak_or_trough==2
            % find turning min corresponding to main trough
            [temp, mini]=min(abs(tVec(x)));          
            if prev_or_post==1
                %prev trough
                trough_oi_i=x(mini-1);
                plot(tVec(trough_oi_i), high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*(5*conds)),'.','Markersize',20,'Color',colours{conds});       
                pre_trough_latency(conds,partic)=tVec(trough_oi_i);
                
            elseif prev_or_post==2
                %post trough
                trough_oi_i=x(mini+1);
                plot(tVec(trough_oi_i), high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*(5*conds)),'.','Markersize',20,'Color',colours{conds});       
                post_trough_latency(conds,partic)=tVec(trough_oi_i);
               
            end
        elseif peak_or_trough==1
            if prev_or_post==1
                trough_oi_i= x(tVec(x)<0);%first find all before 0
                trough_oi_i=max(trough_oi_i); %hten take mac
                plot(tVec(trough_oi_i), high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*(5*conds)),'.','Markersize',20,'Color',colours{conds});       
                pre_peak_latency(conds,partic)=tVec(trough_oi_i);
            elseif prev_or_post==2
                trough_oi_i= x(tVec(x)>0);%first find all after 0
                trough_oi_i=min(trough_oi_i); %hten take mac
                plot(tVec(trough_oi_i), high_ylim(1)+ ((high_ylim(2)-high_ylim(1))/100*(5*conds)),'.','Markersize',20,'Color',colours{conds});       
                post_peak_latency(conds,partic)=tVec(trough_oi_i);
            end
        end
    end
end
        
% [H p]=ttest(post_trough_latency(1,:),post_trough_latency(3,:));
if prev_or_post==1
    if peak_or_trough==1
        trough_oi_latency=pre_peak_latency;
    elseif peak_or_trough==2
        trough_oi_latency=pre_trough_latency;
    end
elseif prev_or_post==2
    if peak_or_trough==1
        trough_oi_latency=post_peak_latency;
    elseif peak_or_trough==2
        trough_oi_latency=post_trough_latency;
    end
end
%% bar chart
subplot(2,2,3)
hold on
title('Trough Latency (95CI)')
bar_x = 1:2;
data = mean(trough_oi_latency,2)';
data(2,:)=zeros(size(data));
hb = bar(bar_x,data)  ;
%CI
for conds=1:length(Conds)
    hb(conds).FaceColor = colours{conds}';
    x = trough_oi_latency(conds,:);                      % Create Data
    SEM = std(x)/sqrt(length(x));               % Standard Error
    ts = tinv([0.025  0.975],length(x)-1);      % T-Score
    CI = mean(x) + ts*SEM;                      % Confidence Intervals
    errhigh(conds) = [CI(2)];
    errlow(conds)  = [CI(1)];
end
er = errorbar([.8 1 1.2],data(1,:),errlow,errhigh);    
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlim([.5 1.5])
ax=gca;
ax.XTick=[];


%% ANOVA
subplot(2,2,4)
hold on
title('Stats')
within=table(categorical([0 1 2])','variablenames',{'Conds'}); 
tab=table(trough_oi_latency(1,:)',trough_oi_latency(2,:)',trough_oi_latency(3,:)','variablenames',{Conds{:}});
rm=fitrm(tab, strcat(Conds{1},'-',Conds{end},' ~1'), 'WithinDesign',within);
ranovatbl = ranova(rm,'withinmodel','Conds');
tx1=sprintf('\nANOVA: F = %2.2f, p = %2.3f\n\n',table2array(ranovatbl(3,4)),table2array(ranovatbl(3,5)));
tx2='';
if table2array(ranovatbl(3,5))<.05
    %FOLLOW UP
    lsd=multcompare(rm,'Conds','comparisonType','lsd');
    lsd=table2cell(lsd);
    if lsd{1,5}<.05
        LSD_abs.rnd_low=1;
    end
    if lsd{2,5}<.05
        LSD_abs.rnd_high=1;
    end
    if lsd{4,5}<.05
        LSD_abs.low_high=1;
    end
    LSD_p.rnd_low=lsd{1,5};
    LSD_p.rnd_high=lsd{2,5};
    LSD_p.low_high=lsd{4,5};
    
    tx2=sprintf('\n\nLSD follow up:\n\n\trnd - low: p = %2.3f\n\n\trnd - high: p = %2.3f\n\n\tlow - high: p = %2.3f\n\n',lsd{1,5},lsd{2,5},lsd{4,5});

end

tx=text(.1,.8,tx1);
tx.Color=[.2 .2 .2];
tx.FontWeight='bold';
tx.FontSize=10;
tx=text(.1,.5,tx2);

ax=gca;
ax.YTick=[];
ax.XTick=[];

print('-dpng','-r150',strcat('temp','.png'));
blankSlide = Presentation.SlideMaster.CustomLayouts.Item(7);
Slide1 = Presentation.Slides.AddSlide(1,blankSlide);
Image1 = Slide1.Shapes.AddPicture(strcat(cd,'/temp','.png'),'msoFalse','msoTrue',120,0,700,540);%10,20,700,500
close all



















