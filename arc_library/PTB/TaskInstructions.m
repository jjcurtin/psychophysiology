function TaskInstructions(Path, Nslides, Port, DIO, W, FileType, Dimensions)
%Usage:  TaskInstructions(Path, Nslides, Port, DIO, W, FileType, Dimensions)
%Path = location of image files with task instructions
%NSlides = number of slides in task instructions
%Port = Typically PortA in CurtinLab, Input button box
%DIO = digital IO device
%W = Window
%FileType = image file extension (optional, JPG by default)
%Dimensions = Pixel dimensions of JPG files
%Instruction jpg files must all follow the following naming convention:
%'Instruction1.jpg', 'Instruction2.jpg', etc
%OR 'Instruction1_960x540.JPG', 'Instruction1_960x540.JPG', etx

%% Check N Arguments
if nargin < 5
    error('Must provide all arguements other than FileType and Dimensions')
end

if nargin < 6
    FileType = 'JPG';
end

if nargin < 7
    Dimensions = [];
else
    Dimensions = ['_' Dimensions];
end

%Create path to local CurtinLibrary PTB folder
if ispc
    LocalPath = 'C:\toolbox\CurtinLibrary\PTB\';
elseif isunix
    LocalPath = '/home/ra/CurtinLibrary/PTB/';
end

%% Load Instruction images into cell array
Instructions = cell(Nslides,1);
for i=1:Nslides
    Instructions{i,1} =  imread([Path 'Instruction' num2str(i) Dimensions '.' FileType], FileType);
end

%Covert image matrices in cell array to textures and save in vector
InstructTextures = zeros(Nslides);
for i=1:Nslides
    InstructTextures(i) =  Screen('MakeTexture', W, Instructions{i,1});
end
clear Instructions  %clear image cell array after textures are made

%% Present Task Instructions
StartSlide = 1;
i = StartSlide;
while StartSlide  %if > 0 TRUE
    while i <= Nslides %from Slide 1 to NSlides
        WaitSecs(1); % Wait .5s between each slide minimum
        Screen('DrawTexture', W, InstructTextures(i)); %post image slide to the screen
        Screen('DrawingFinished', W); %to mark the end of all drawing commands
        now = Screen('Flip', W);
        %KbWait;  % In case we decide to use keyboard
        %         if ispc
        [~, reply] = GetResponse(now, 600, 1, 7, Port, DIO,1,1);  %timeout = 600s, correct response = 1, mask for lines 0,1,2; CHECK THIS
        if reply == 1 && i > 1 %Repeat Slide if RIGHT Button key pressed
            i = i - 1;
        else %Advance to next slide if any other button pressed
            i = i+1;
        end
        %         elseif isunix
        %             [~, reply] = GetResponse(now, 600, 1, 7, Port, DIO,1,0);  %timeout = 600s, correct response = , mask for lines 0,1,2;
        %             if reply == 4 && i > 1 %Repeat Slide if RIGHT SHIFT key pressed
        %                 i = i - 1;
        %             else %Advance to next slide if any other key pressed
        %                 i = i+1;
        %             end
        %         end
    end
    
    InsFinal1 = imread([LocalPath 'InstructFinal1' Dimensions '.' FileType], FileType); % Repeat press right, continue press left button
    WaitSecs(1);
    TheTexture1 = Screen('MakeTexture', W, InsFinal1);
    Screen('DrawTexture', W, TheTexture1); %post image slide to the screen
    Screen('DrawingFinished', W); %to mark the end of all drawing commands
    now = Screen('Flip', W);
    %KbWait;  % In case we decide to use keyboard
    
    %   if ispc
    [~, reply] = GetResponse(now, 600, 1, 7, Port, DIO,1,1);  %timeout = 600s, correct response = , mask for lines 0,1,2;
    
    if reply == 1 % If right BUTTON press, then repeat instructions starting at slide 2
        StartSlide = 2;
        i = StartSlide;
    else
        StartSlide = 0; % If SHIFT BUTTON or LEFT SHIFT press, continue to finish instructions (do not repeat)
    end
    
    %     elseif isunix
    %         [~, reply] = GetResponse(now, 600, 1, 7, Port, DIO,1,0);  %timeout = 600s, correct response = , mask for lines 0,1,2;
    %
    %         if reply == 4 % If right SHIFT KEY press, then repeat instructions starting at slide 2
    %             StartSlide = 2;
    %             i = StartSlide;
    %         else
    %             StartSlide = 0; % If SHIFT BUTTON or LEFT SHIFT press, continue to finish instructions (do not repeat)
    %         end
    %
    %    end
end

InsFinal2 = imread([LocalPath 'InstructFinal2' Dimensions '.' FileType], FileType); % Black screen
TheTexture2 = Screen('MakeTexture', W, InsFinal2);
Screen('DrawTexture', W, TheTexture2); %post image slide to the screen
Screen('DrawingFinished', W); %to mark the end of all drawing commands
Screen('Flip', W); % Flip to black screen

%Final clean-up
Screen('Close', InstructTextures); % Clear  instruction textures from memory
Screen('Close', [TheTexture1 TheTexture2]) %clear last three textures from memory

clear InsFinal1 % Clear instructions image from memory
clear InsFinal2 % Clear instructions image from memory

end