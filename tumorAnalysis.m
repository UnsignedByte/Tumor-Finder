%% Get User Files
filePath = [cd, '/Tumor Results/'];
userData = dir([filePath '/user_*']);
userNum = length(userData);

plotNewGraph = cell(4);

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
        allShapes = sum(reshape(shapePrev, 3^2, 1));
        
        ordIndices = find(responses(2,1:end-1) == shapeClass);
        
        meanDeviation = shapeClass-mean((order(ordIndices+1)/147));
        
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
    
    plotNewGraph{shapeClass} = figure;
    
    hold on
    scatter(allDeviations(find(allDeviations ~= 0)), allCorrelations(find(allDeviations ~= 0)));
    hold off
    
    % Show Accuracy
    %disp(totalAccuracy);
    
end

%% find P value 
data = prevRelative;
numSkewed = 0;
numWrong = 0;
for i = 1:3
    col = data(:,i,i);
    inc = sum(col) - col(i);
    numSkewed = numSkewed + inc;
    a = mod(i,3)+1; b = mod(i+1,3)+1; 
    numWrong = numWrong + inc + data(a,b,i) + data(b,a,i);
end
p0 = 0.5; 
phat = numSkewed/numWrong;
sd = (p0*(1-p0)/numWrong)^0.5;
z = (phat-p0)/sd;
cdf = normcdf(z);
Pval = 1-cdf;

        
