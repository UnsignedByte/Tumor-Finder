clear all
close all

%% Get User Files
filePath = [cd, '/Tumor Results/'];
userData = dir([filePath '/user_*']);
userNum = length(userData);

% Go through each User

for user=1:userNum
    
    % Get User Data
    userName = userData(user).name;
    load(fullfile(filePath, userName, 'prevRelative.mat'));
    
    shapeResponses = load(fullfile(filePath, userName, '/responses.mat'), 'responses');
    shapeResponses = cell2mat(struct2cell(shapeResponses));
    
    shapeIndices = load(fullfile([filePath, userName, '/order.mat']), 'order');
    shapeIndices = cell2mat(struct2cell(shapeIndices));
    
    trials = size(shapeResponses, 2);
    binNum = ceil(trials/10);
    
    userShapes = shapeResponses(1,:);
    trueShapes = shapeResponses(2,:);
    
    % Find Shape Variance and User Correctness per trial
    shapeDiffList = abs(shapeIndices(2:end) - shapeIndices(1:end-1));
    correctList = userShapes == trueShapes;
    
    % Graph the Data
    histList = vertcat(shapeDiffList, correctList);
    histList = sortrows(histList', 1)';
    
    bins = [1:binNum];
    binLabels = zeros(binNum,2);
    
    histVals = zeros(binNum, 1);
    errVals = zeros(binNum, 1);
    
    for bin=1:binNum-1
        %Get mean accuracy
        histVals(bin) = mean(histList(2, 10*(bin-1)+1:10*bin));
        % Get Error
        errVals(bin) = std(histList(2, 10*(bin-1)+1:10*bin))./sqrt(trials);
        % Get least and greatest value for bin
        binLabels(bin, :) = [histList(1, 10*(bin-1)+1), histList(1, 10*bin)];
    end
    % Get final bin (rounding)
    histVals(binNum) = mean(histList(2, 10*(binNum-1)+1:end));
    errVals(binNum) = std(histList(2, 10*(binNum-1)+1:end))./sqrt(trials); 
    binLabels(binNum, :) = [histList(1, 10*(binNum-1)+1), histList(1, end)];
        
    hold on
    
    title('Difference in shape morphs, from one trial to the next, vs. user accuracy')
	bar(bins, histVals);
	xlabel('Differences between previous and current shape appearance, from least to greatest')
	ylabel('Mean accuracy from 0 to 1')
    
    screenLimit = 2880; 
    set(gcf,'position',[50,50,min(6*trials, screenLimit),500])
    
    somenames = num2str(bins.*10);
    xticks([1:1:binNum])
    visualBins = cell(binNum,1);
    
    for bin=1:binNum
        visualBins{bin} = [num2str(binLabels(bin,1)), '-', num2str(binLabels(bin,2))];
    end
    xticklabels(visualBins);

    er = errorbar(bins,histVals,-errVals,errVals);    
    er.Color = [0 0 0];                            
    er.LineStyle = 'none';  
    
    %% GET Z-Scores
    p0s = zeros(1,3); 
    phats = zeros(1,3);
    ns = zeros(1,3);
    for i = 1:3
        ns(i) = sum(prevRelative(:,:,i),'all');
        p0s(i) = sum(prevRelative(:,i,:),'all')/trials;
        phats(i) = sum(prevRelative(:,i,i))/ns(i);
    end
    sds = (p0s.*(1-p0s)./ns).^0.5;
    zs = (phats-p0s)./sds;
    cdfs = normcdf(zs);
    Pvals = 1-cdfs;
    save(fullfile(filePath, userName, 'pvals.mat'), 'Pvals');
end
