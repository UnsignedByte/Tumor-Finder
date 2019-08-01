Screen('Preference', 'SkipSyncTests', 1);
rng('Shuffle');
KbName('UnifyKeyNames');
init = ['user_' upper(input('Initials: ', 's'))];
[window, rect] = Screen('OpenWindow', 0, []);
HideCursor();
ww = rect(3); wh = rect(4);
Screen('BlendFunction', window,GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

trials = 250;
stimuliNum = 147;

order = randi(stimuliNum,1, trials+1);
responses = zeros(2,trials);

prev = zeros(3,3,3); %cur x response x prev, counts # of times of response when current tumor
prevRelative = zeros(3,3,3);

%1 = 0, 2 = 147/3, 3 = 2*147/3

file = 'Stimuli';
siz = [400 400];
sizz = siz(1)/2;
stimuli = cell(1,stimuliNum);
abc = zeros(1,3);
abc(1,1) = Screen('MakeTexture',window,imresize(imread(fullfile(file, ['Morph' num2str(stimuliNum) '.jpg'])),siz./2));
abc(1,2) = Screen('MakeTexture',window,imresize(imread(fullfile(file, ['Morph' num2str(stimuliNum/3) '.jpg'])),siz./2));
abc(1,3) = Screen('MakeTexture',window,imresize(imread(fullfile(file, ['Morph' num2str(2*stimuliNum/3) '.jpg'])),siz./2));

ar = ww/wh;
div = 4;
mag = 128;

noiseh = round(wh/div);
noisew = round(ar * noiseh);

noises = zeros(noiseh, noisew, trials);
for i = 1:trials
    noises(:,:,i) = (2.*rand(noiseh, noisew)-1);
    DrawFormattedText(window, ['Generating Noise: ' num2str(round(i/trials*100)) '%'], 'center', 'center');
    Screen('Flip', window);
end

for i = 1:stimuliNum
    stimuli{i} = double(imresize(rgb2gray(imread(fullfile(file, ['Morph' num2str(i) '.jpg']))),siz./div)) - 128;
    DrawFormattedText(window, ['Loading Stimuli: ' num2str(round(i/stimuliNum*100)) '%'], 'center', 'center');
    Screen('Flip', window);
end

global noises stimuli noisew noiseh ww wh

p = 0;
pR = 0;
xC = (1:3)/4;
yC = (wh/2)+zeros(1,3);
rects = [xC.*ww-sizz/2;yC-sizz/2;xC.*ww+sizz/2;yC+sizz/2];

DrawFormattedText(window, 'Remember these 3 tumors. You will respond with the number corresponding to the closest type of tumor for each trial (1, 2, 3 from left to right).', 'center', wh/4);
Screen('DrawTextures',window,abc,[],rects);
Screen('Flip', window);
KbStrokeWait();
RestrictKeysForKbCheck([KbName('1!'), KbName('2@'), KbName('3#')]); %Restrict to 1,2,3
corr = 0;
cursecs = now*24*60*60;
for i = 1:trials+1
    cur = order(i);
    Screen('DrawTexture', window, Screen('MakeTexture', window, makeTumor(i, mag, cur)));
    cursecs = now*24*60*60-cursecs;
    if cursecs < 0.3
        WaitSecs(0.3-cursecs);
    end
    Screen('Flip', window);
    [~, keyCode] = KbStrokeWait();
    % Note: The file Responses now holds the values of both the user % comp
    % data
    uAns = find(keyCode,1) - KbName('1!') + 1;
    cAns = mod(round(3*cur/stimuliNum),3)+1;
    corr = corr + (uAns == cAns);
    
    if i > 1
        responses(1,i-1) = uAns;
        responses(2,i-1) = cAns;
    end
    if p ~= 0
        prev(cAns,uAns,p) = prev(cAns,uAns,p)+1;
        prevRelative(cAns,uAns,pR) = prevRelative(cAns,uAns,pR)+1;
    end
    p = cAns;
    pR = uAns;
%     Screen('DrawTexture',window, noises(randi(noiseNum)));
    Screen('Flip',window);
    cursecs = now*24*60*60;
    if mod(i,10)==0
        mag = mag*(1+(corr/(10)-0.8));
        corr = 0;
    end
end

Screen('CloseAll');
if ~isfolder('Tumor Results') mkdir('Tumor Results'); end %saving
cd 'Tumor Results';
if ~isfolder(init) mkdir(init); end %saving
cd(init);
save('prev.mat', 'prev'); %3x3x3 matrix
save('prevRelative.mat', 'prevRelative');
save('order.mat', 'order');

save('responses.mat', 'responses');
cd ../..;

function textid = makeTumor(i, mag, tumorId)
    global noises stimuli noisew noiseh ww wh
    noise = 128+squeeze(noises(:,:,i)).*mag;
    
    imag = imrotate(stimuli{tumorId}, randi(360),'nearest','loose');
   
    locx = randi(noisew - size(imag,2)+1); locy = randi(noiseh - size(imag,2)+1);
    noise(locy:locy+size(imag,1)-1,locx:locx+size(imag,2)-1) = noise(locy:locy+size(imag,1)-1,locx:locx+size(imag,2)-1) + imag;
    textid = imresize(min(uint8(noise),255), [wh ww],'nearest');
end
