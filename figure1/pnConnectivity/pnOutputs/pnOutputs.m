% The code here should generate and save the portion of figure 1 panel F
% summarizing PN target identity.
% relies on the
% package JSONLab: https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files

%% Load annotations and connectors
clear

% Load annotations json. Generated by Wei's code gen_annotation_map.py
annotations=loadjson('~/tracing/sid_by_annotation.json');

% Return all skeleton IDs for R and L ORNs

ORNs_Left=annotations.Left_0x20_ORN;
ORNs_Right=annotations.Right_0x20_ORN;

ORNs=[ORNs_Left, ORNs_Right];

%return all skeleton IDs of DM6 PNs
PNs=sort(annotations.DM6_0x20_PN);

%Load the connector structure
load('~/tracing/conns.mat')

%gen conn fieldname list
connFields=fieldnames(conns);

%% Collect a list of postsynaptic profile skeleton IDs for each PN

%Loop over all PNs

for p=1:length(PNs)
    
    postSkel{p}=[];
    
    %loop over all connectors
    for i= 1 : length(connFields)
        
        %Make sure the connector doesnt have an empty presynaptic field
        if isempty(conns.(cell2mat(connFields(i))).pre) == 1
            
            % or an empty postsynaptic field, if its empty it will be a cell
            
        elseif iscell(conns.(cell2mat(connFields(i))).post) == 1
            
        else
            
            %Check to see if the current PN is presynaptic at this connector
            if PNs(p) == conns.(cell2mat(connFields(i))).pre
                
                %record the postsynaptic skel IDs
                postSkel{p}=[postSkel{p}, conns.(cell2mat(connFields(i))).post];
                
            else
                
                
            end

        end
    end
end




%% This block of code is written to see how many PN postsynaptic profiles have at least one annotation

annFields=fieldnames(annotations);

annSkels=[];

for a=1: length(annFields)
    annSkels=[annSkels, annotations.(cell2mat(annFields(a)))];
end

for p=1:5
    
    for s=1:length(postSkel{p})
       annCheck{p}(s)=ismember(postSkel{p}(s), annSkels);
    end
    
    fractAnn(p)=sum(annCheck{p})/length(postSkel{p})
end



%% Categorize presynaptic profiles

% Loop over each PN
for p=1:length(PNs)
    
    
    %loop over each presynaptic profile
    for s=1:length(postSkel{p})
        
        if ismember(postSkel{p}(s), ORNs) == 1
            
            postSynID{p}(s)=1;
            
            
        elseif ismember(postSkel{p}(s), PNs) == 1
            
            postSynID{p}(s)=2;
       
        else
            postSynID{p}(s)=3;%4;
            
        end
        
    end
end


%% Plotting


%For each PN
for p=1:length(PNs)
    
    %for each category
    for id=1:3%4
        
        idenCounts(p,id)=sum(postSynID{p}==id);
        
    end
    
end

[v i]=sort(sum(idenCounts), 'descend');

labels={'ORN','PN','Multi-glomerular'};
% order=[5,1,2,3,4];  
order=[1,2,5,4,3]; % 151230 WCL corresponded to catmaid2
pnLabels={'PN1 LS', 'PN2 LS', 'PN3 LS', 'PN1 RS','PN2 RS'};

myC= [1 1 1 
  0.87 0.80 0.47
  0 0 1]; % y: ORN, b: PN, w: multi

%Raw Numbers
figure()
h=bar(idenCounts(order,i),.6,'stacked');
legend(labels(i),'Location', 'NorthWest')


for k =1:3
    set(h(k),'facecolor',myC(k,:))
    set(h(k),'edgecolor','k')
end

ax=gca;
ax.XTickLabel=pnLabels;
ax.FontSize=11;
ax.XLim=[.5 5.5];
set(gcf,'color','w')
ylabel('Postsynaptic Profile Num')


%% Fractions

%Normalize the postynaptic identity counts by tot number of postsynaptic
%profiles

for t=1:length(PNs)
    normIden(t,:)=idenCounts(order(t),i)./sum(idenCounts(order(t),i));
end

figure()
set(gcf, 'Color', 'w')

h=bar(normIden,.6,'stacked');
% legend(labels(i),'Location', 'NorthWest')

for k =1:3
    set(h(k),'facecolor',myC(k,:))
    set(h(k),'edgecolor','k')
end

ax=gca;
% ax.XTickLabel=pnLabels;
ax.XTick=[];
ax.FontSize=11;
ax.YLim=[0, 1.2];
ax.XLim=[.5 5.5];

set(gcf,'color','w')
ylabel('Fraction Postsynaptic')
saveas(gcf,'pnPostCategorization_fract','epsc')
saveas(gcf,'pnPostCategorization_fract')
%% Pie chart of average across PNs

figure()
h=pie(mean(normIden));
% title('Average Fractional Input')
set(gcf,'color','w')

hp = findobj(h, 'Type', 'patch');
set(hp(1), 'facecolor', 'w');
set(hp(2), 'facecolor', [0.87 0.80 0.47]);
set(hp(3), 'facecolor', 'b');

textInds=[2:2:8];

for i=1:3%4
    h(textInds(i)).FontSize=16;
end



