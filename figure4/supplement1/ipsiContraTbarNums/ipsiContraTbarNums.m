%% This script generates Figure 4–figure supplement 1 panel B
%
% The goal of this code is to generate a figure showing the number of tbars
% formed by ipsi and contra axons

%% Load annotations and connectors

% Load annotations json. Generated by gen_annotation_map.py
annotations=loadjson('../../../tracing/sid_by_annotation.json');

% Return all skeleton IDs for R and L ORNs
ORNs_Left=annotations.Left_0x20_ORN;
ORNs_Right=annotations.Right_0x20_ORN;

% include unilateral ORNs for now
ORNs=[ORNs_Left, ORNs_Right];

% return all skeleton IDs of DM6 PNs
PNs=sort(annotations.DM6_0x20_PN);

%% %% Load postsynaptic skeleton info


load('../../../data/ipsiContraPolyady/rightPostSkelsBySyn')
load('../../../data/ipsiContraPolyady/leftPostSkelsBySyn')



% For each ORN collect its total number of connections within each
% glomerulus as well as the total number of PN connections


leftCounter=1;
rightCounter=1;

for o=1:length(ORNs)
    
      if isempty(leftPostSkelsBySyn{o})==1
        
    else
    tbarsLeft(leftCounter)=length(leftPostSkelsBySyn{o});
    leftCounter=leftCounter+1;
    
    end
    
    if isempty(rightPostSkelsBySyn{o})==1
        
    else
    tbarsRight(rightCounter)=length(rightPostSkelsBySyn{o});
    rightCounter=rightCounter+1;
    end
    
end


%% Plotting

figure()
set(gcf, 'Color', 'w')

h=boxplot([tbarsLeft(1:27), tbarsRight(27:end),...
  tbarsLeft(28:end), tbarsRight(1:26) ]', [ones(53,1); 2*ones(51,1)], 'Color', 'k', 'notch','on');
ax=gca;
ax.XTickLabel={'Ipsi Axons','Contra Axons'};
ylabel('Total Tbars Number', 'Fontsize',16)
ylim([0 90])
ax.YTick=[0:30:90];
ax.FontSize=16;
axis square

saveas(gcf,'ipsiContraTbarNums')
saveas(gcf,'ipsiContraTbarNums','epsc')

%% Permutation test
nPerm = 10000;

% t-bar num p < 0.0001, 10000 perms
sa = [tbarsLeft(1:27), tbarsRight(27:end)]';
sb = [tbarsLeft(28:end), tbarsRight(1:26)]';

sh0 = [sa; sb];

m = length(sa); 
n = length(sb); 

d_empirical = mean(sa) - mean(sb);

sa_rand = zeros(m,nPerm);
sb_rand = zeros(n,nPerm);
tic
for ii = 1:nPerm
    sa_rand(:,ii) = randsample(sh0,m);%,true);
    sb_rand(:,ii) = randsample(sh0,n);%,true);
end
toc
% Now we compute the differences between the means of these resampled
% samples.
% d = median(sb_rand) - median(sa_rand);
d = mean(sa_rand) - mean(sb_rand);

%
figure;
% [nn,xx] = hist(d,100);
% bar(xx,nn/sum(nn))
histogram(d,'Normalization','probability')
ylabel('Probability of occurrence')
xlabel('Difference between means')
hold on
%

y = get(gca,'yLim'); % y(2) is the maximum value on the y-axis.
x = get(gca,'xLim'); % x(1) is the minimum value on the x-axis.
plot([d_empirical,d_empirical],y*.99,'r-','lineWidth',2)

% Probability of H0 being true = 
% (# randomly obtained values > observed value)/total number of simulations
p = sum(abs(d) > abs(d_empirical))/length(d);
text(x(1)+(.01*(abs(x(1))+abs(x(2)))),y(2)*.95,sprintf('H0 is true with %4.4f probability.',p))