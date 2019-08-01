clear all
close all

%% Get User Files
filePath = [cd, '/Tumor Results/'];
userData = dir([filePath '/user_*']);
userNum = length(userData);

figureCell = cell(userNum, 2);

% Go through each User

for user=1:userNum
    
    % Get User Data
    userName = userData(user).name;
    load(fullfile(filePath, userName, 'prevRelative.mat'));
    
    shapeResponses = load(fullfile(filePath, userName, '/responses.mat'), 'responses');
    shapeResponses = cell2mat(struct2cell(shapeResponses));
    
    shapeIndices = load(fullfile(filePath, userName, '/order.mat'), 'order');
    shapeIndices = cell2mat(struct2cell(shapeIndices));
    
    trials = size(shapeResponses, 2);
    binNum = 10;
    
    userShapes = shapeResponses(1,:);
    trueShapes = shapeResponses(2,:);
    
    % Find Shape Variance and User Correctness per trial
    shapeDiffList = abs(shapeIndices(2:end) - shapeIndices(1:end-1));
    correctList = userShapes == trueShapes;
    
    % Graph the Data
    figureCell{user, 1} = figure;
    
    histList = vertcat(shapeDiffList, correctList);
    histList = sortrows(histList', 1)';
    
    bins = [1:binNum];
    binLabels = zeros(binNum,2);
    
    histVals = zeros(binNum, 1);
    errVals = zeros(binNum, 1);
    
    for bin=1:binNum-1
        %Get mean accuracy
        histVals(bin) = mean(histList(2, round(trials*(bin-1)/binNum)+1:round(trials*bin/binNum)));
        % Get Error
        errVals(bin) = std(histList(2, round(trials*(bin-1)/binNum)+1:round(trials*bin/binNum)))./sqrt(trials);
        % Get least and greatest value for bin
        binLabels(bin, :) = [histList(1, round(trials*(bin-1)/binNum)+1), histList(1, round(trials*bin/binNum))];
    end
    % Get final bin (rounding)
    histVals(binNum) = mean(histList(2, round(trials*bin/binNum)+1:end));
    errVals(binNum) = std(histList(2, round(trials*bin/binNum)+1:end))./sqrt(trials); 
    binLabels(binNum, :) = [histList(1, round(trials*bin/binNum)), histList(1, end)];
        
    hold on
    
    title('Difference in shape morphs, from one trial to the next, vs. user accuracy')
	bar(bins, histVals);
	xlabel('Differences between previous and current shape appearance, from least to greatest')
	ylabel('Mean accuracy from 0 to 1')
    
    screenLimit = 2880; 
    set(gcf,'position',[50,50,min(75*binNum, screenLimit),500])
    
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
    
    % Plot difficulty over accuracy
    figureCell{user, 2} = figure;
    
    corrchunks = load(fullfile(filePath, userName, '/corrchunks.mat'));
    corrchunks = cell2mat(struct2cell(corrchunks));
    
    corrmags = load(fullfile(filePath, userName, '/corrmags.mat'));
    corrmags = cell2mat(struct2cell(corrmags));
    
    hold on
    
    title('Over all the trials, the user accuracy versus the difficulty setting')
    
    %yyaxis left
    %plot([1:length(corrmags)], corrmags);
    
    %yyaxis right
    plot([1:length(corrchunks)], corrchunks);
    
    %% GET Z-Scores
    p1s = zeros(1,3); 
    p2s = zeros(1,3);
    ns = zeros(1,3);
    for i = 1:3
        ns(i) = sum(prevRelative(:,:,i),'all');
        p1s(i) = sum(prevRelative(:,i,:),'all')/trials;
        p2s(i) = sum(prevRelative(:,i,i))/ns(i);
    end
    ses = ((p1s.*(1-p1s)./ns)+(p2s.*(1-p2s)./trials)).^0.5;
    zs = (p2s-p1s)./ses;
    cdfs = normcdf(zs);
    Pvals = 1-cdfs;
    save(fullfile(filePath, userName, 'pvals.mat'), 'Pvals');
end
