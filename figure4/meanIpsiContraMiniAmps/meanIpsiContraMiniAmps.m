% The purpose of this code is to generate a connected scatter plot of mean
% mEPSP amplitudes for ipsi and Contra ORN inputs to each PN
%
% This code relies on the product of pullmEPSPs
%
% This code should generate figure 4 panel E

%% Load annotations and connectors

% Load annotations json. Generated by gen_annotation_map.py
annotations=loadjson('../../tracing/sid_by_annotation.json');

% Return all skeleton IDs for R and L ORNs
ORNs_Left=annotations.Left_0x20_ORN;
ORNs_Right=annotations.Right_0x20_ORN;
ORNs=[ORNs_Left, ORNs_Right];
            
%return all skeleton IDs of DM6 PNs
PNs=sort(annotations.DM6_0x20_PN);

%Load the connector structure
load('../../tracing/conns.mat')

%Base dir for simulation results
baseDir='../../nC_projects_lite/';

%%

% Collect the amplitude of ipsi and contra mEPSPs for R and L ORN-->PN
% pairs
        
    %loop over PNs
    for p=1:5
        
        if p<=3
            
            counter=1;
            for s=1:size(leftMEPSPs{p},1)
                
            indAmpsI{p}(counter)=max(leftMEPSPs{p}(s,:))-mean(leftMEPSPs{p}(s,1:40));
            counter=counter+1;
            
            end
            
            counter=1;
            for s=1:size(rightMEPSPs{p},1)
                
                indAmpsC{p}(counter)=max(rightMEPSPs{p}(s,:))-mean(rightMEPSPs{p}(s,1:40));
                counter=counter+1;
                
            end
            
            
            
        else
                
                
            counter=1;
            for s=1:size(leftMEPSPs{p},1)
                
            indAmpsC{p}(counter)=max(leftMEPSPs{p}(s,:))-mean(leftMEPSPs{p}(s,1:40));
            counter=counter+1;
            
            end
            
            counter=1;
            for s=1:size(rightMEPSPs{p},1)
                
                indAmpsI{p}(counter)=max(rightMEPSPs{p}(s,:))-mean(rightMEPSPs{p}(s,1:40));
                counter=counter+1;
                
            end
            
            
    
        end
        
        miniMeans(p,1)=mean(indAmpsI{p});
        miniMeans(p,2)=mean(indAmpsC{p});
        
        sem(p,1)=std(indAmpsI{p})/sqrt(length(indAmpsI{p}));
        sem(p,2)=std(indAmpsC{p})/sqrt(length(indAmpsC{p}));
    end
  

%% Plotting


figure()
set(gcf,'Color','w')

rightCounter=1;

for p=1:5
        
        errorbar([1 2],[miniMeans(p,1) miniMeans(p,2)],...
            [sem(p,1) sem(p,2)],...
            'Color','k', 'Marker', 'o', 'MarkerFaceColor','k')
        hold on
    
end

xlim([0.5 2.5])
ylim([.1 .4])

ax=gca;
ax.XTick=[1,2];
ax.XTickLabel={'Ipsi ORNs','Contra ORNs'};
ax.YTick=[.1:.1:.4];
ylabel('mean mEPSP Amplitude (mV)');

saveas(gcf,'meanIpsiContraMiniAmps');
saveas(gcf,'meanIpsiContraMiniAmps', 'epsc');

%% Stats

[h,p]=ttest(miniMeans(:,1),miniMeans(:,2))