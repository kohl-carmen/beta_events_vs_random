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
