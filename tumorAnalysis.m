%{
%% Get User Files
filePath = [cd, '/Tumor Results/'];
userData = dir([filePath '/user_*']);
userNum = length(userData);

plotNewGraph = cell(4,2);

allDeviations = zeros(3,1);
allCorrelations = zeros(3,1);

%% Find Accuracy of Each User

for user=1:userNum
    
    % Record User Accuracy for Each of the 3 Shapes
    totalAccuracy = zeros(3,1);
    
    % Convert eah Shape Structure into a 3x3 Array
    userName = userData(user).name;
    
    prevShapeData = load(fullfile(filePath, userName, 'prev.mat'), 'prev');
    prevShapeData = cell2mat(struct2cell(prevShapeData));
    
    shapeOrder = load(fullfile(filePath, userName, 'order.mat'), 'order');
    shapeOrder = cell2mat(struct2cell(shapeOrder));
    
    shapeResponses = load(fullfile(filePath, userName, 'responses.mat'), 'responses');
    shapeResponses = cell2mat(struct2cell(shapeResponses));
    
    for shapeClass=1:3
        
        % Set up the two Metrics of Comparison
        shapePrev = reshape(prevShapeData(shapeClass,:,:), 3, 3);
        
        plotNewGraph{shapeClass,1} = figure;
        bar3(shapePrev);
        
        allShapes = sum(reshape(shapePrev, 3^2, 1));
        
        ordIndices = find(responses(2,1:end-1) == shapeClass);
        meanDeviation = mean(((3*order(ordIndices)/147) - responses(1, ordIndices+1)));
        
        if allShapes > 0
            booldeanDiag = diag(repelem(1,3));

            % Find where User Response deviates from set Shape Class
            testXor = length(setxor(booldeanDiag, (shapePrev ./ shapePrev)));

            % Record Accuracy as Percentage Right for each Shape
            pctAccuracy = 1-(testXor/allShapes);
            totalAccuracy(shapeClass) = pctAccuracy;

            plotNewGraph{shapeClass} = figure;

            lenRowOne = length(shapePrev(1,:)); 
            lenRowTwo = length(shapePrev(2,:)); 
            lenRowThree = length(shapePrev(3,:)); 

            userX = zeros(1,1);
            userY = zeros(1,1);

            shapePrev = reshape(shapePrev, 3^2, 1);
            trueIndices = find(shapePrev > 0);

            userX(1:length(trueIndices)) = mod(trueIndices, 3)+1;
            plotX = userX;
            userY(1:length(trueIndices)) = 3-(floor(trueIndices/3)+1);
            
            [p,S] = polyfit(userX,userY,1); 
            predictFit = polyval(p, userX);
            
            hold on
            plot(plotX, predictFit);
            scatter(userX, userY);
            
            r = corrcoef(userX, userY);
            disp(['The correlation for Shape ' num2str(shapeClass) ...
                ' is: ' num2str(r(1,2))]);
            disp(['Mean Deviation is ' num2str(meanDeviation)]);
            
            allDeviations(shapeClass) = r(1,2);
            allCorrelations(shapeClass) = meanDeviation;
            
            hold off
        end
    end
    
    plotNewGraph{4, 1} = figure;
    
    hold on
    shapeData = horzcat(allDeviations(find(allDeviations ~= 0)), allCorrelations(find(allDeviations ~= 0)));
    shapeData = reshape(shapeData, 2, 2);
    
    title('For each Previous Shape A, B and C, the relation between the last image seen and the current user choice');
    bar([1:size(shapeData,2)], shapeData);
    hold off
    
    % Show Accuracy
    %disp(totalAccuracy);
    
end
%}
%% find P value 
data = prevRelative;
p0s = zeros(1,3); 
phats = zeros(1,3);
ns = zeros(1,3);
for i = 1:3
    ns(i) = sum(data(:,:,i),'all');
    p0s(i) = sum(data(:,i,:),'all')/trials;
    phats(i) = sum(data(:,i,i))/ns(i);
end
sds = (p0s.*(1-p0s)./ns).^0.5;
zs = (phats-p0s)./sds;
cdfs = normcdf(zs);
Pvals = 1-cdfs;

        
