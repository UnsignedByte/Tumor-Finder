%% Get User Files
filePath = [cd, '/Tumor Results/'];
userData = dir([filePath '/user_*']);
userNum = length(userData);

%% Find Accuracy of Each User

for user=1:userNum
    
    % Record User Accuracy for Each of the 3 Shapes
    totalAccuracy = zeros(3,1);
    
    % Convert eah Shape Structure into a 3x3 Array
    userName = userData(user).name;
    prevData = load(fullfile([filePath, userName, '/prev.mat']), 'prev');
    prevData = cell2mat(struct2cell(prevData));
    
    for shapeClass=1:3
        % Set up the two Metrics of Comparison
        shapePrev = prevData(shapeClass,:,:);
        booldeanDiag = diag(repelem(1,3));
        
        % Find where User Response deviates from set Shape Class
        testXor = length(setxor(booldeanDiag, (shapePrev ./ shapePrev)));
        allShapes = sum(shapePrev);
        
        % Record Accuracy as Percentage Right for each Shape
        pctAccuracy = 1-(testXor/allShapes);
        totalAccuracy(shapeClass) = pctAccuracy;
            
            % Next -- Correlate all non-one totalAccuracy vals with
            % difference between shapeClass array val and its previous
            % values. Find the trend of the line and r. Use interpolation
            % to show relationship between difference between trials and
            % user response.
    end
    
    % Show Accuracy
    disp(totalAccuracy);
    
end
