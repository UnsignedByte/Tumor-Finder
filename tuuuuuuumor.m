Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = ['user_' upper(input('Initials: ', 's'))];
[window, rect] = Screen('OpenWindow', 0, []);
HideCursor();
ww = rect(3); wh = rect(4);
Screen('BlendFunction', window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

trials = 5;
stimuliNum = 147;
ord = randperm(150,trials);
responses = zeros(1,trials);
error = zeros(1,trials);
prev = zeros(3,3,3); %cur x response x prev

tid = zeros(1,stimuliNum);

file = 'Stimuli\';
siz = [256 256];
stimuli = cell(1,stimuliNum);

for i = 1:stimuliNum
    stimuli{1,i} = imresize(imread([file 'Morph' num2str(i) '.jpg']),siz);
    tid(1,i) = Screen('MakeTexture', window, stimuli{1,i});
end

p = 0;
for i = 1:trials
    cur = ord(i);
    Screen('DrawTexture', window, Screen('MakeTexture', window, min(uint8(double(stimuli{1,cur}) + generate_noise(siz(1))),255)));
    Screen('Flip', window);
    WaitSecs(1);
    Screen('Flip', window);
    [x,~,clicks] = GetMouse();
    while clicks(1,1) == 1
        [x,y,clicks] = GetMouse();
    end
    offset = randi(stimuliNum);   
    while ~clicks(1,1)
        [x,~,clicks] = GetMouse();
        response = mod(floor(x)+offset, stimuliNum)+1;
        Screen('DrawTexture', window , tid(response));    
        Screen('Flip', window);
    end  
    Screen('Flip', window); 
    responses(1,i) = response;
    uAns = mod(round(3*response/147),3)+1;
    cAns = mod(round(3*cur/147),3)+1;
    if p ~= 0
        prev(cAns,uAns,p) = prev(cAns,uAns,p)+1;
    end
    p = cAns;
    WaitSecs(1);
end

Screen('CloseAll');
if ~isfolder('Tumor Results') mkdir('Tumor Results'); end %saving
cd 'Tumor Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('prev.mat', 'prev');
save('order.mat', 'order');
save('responses.mat', 'responses');
cd ../..;

        
    
    

    
    
    


