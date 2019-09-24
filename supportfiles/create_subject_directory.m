% prompt dubject info
prompt = {'Subject ID:','Gender(m/f):','Age:',...
    'hand(r/l): ', ...
    'Experiment restarted? Yes=1 or No=0: '};

answer = inputdlg(prompt);


subject.id          = answer{1};
subject.gender      = answer{2};
subject.age         = str2num(answer{3});
subject.hand        = answer{4};
subject.restart     = str2num(answer{5});
subject.date        = date;
subject.start_time  = clock;
subject.name        = num2str(subject.id);  
subject.screen      = 0;

cfg.debugging       =0;

% testing mode
if isempty(subject.id) 
    warning('TESTING MODE');
    subject.male            = NaN;
    subject.age             = NaN;
    subject.right_handed    = NaN;
    subject.screen          = 0; % small size screen:1
    subject.name            = 'test';
    subject.id              = 999;
            
end
if isempty(subject.name)
    subject.name = 'test';
end


%% saving directory
% Unique filename depending on computer clock (avoids overwriting)
subject.fileName = [num2str(round(datenum(subject.start_time)*100000)) '_' num2str(subject.id)];
%% create directory if does not already exist
if ~exist([savedir  filesep 'DotsandAudio_behaviour'], 'dir')        
    mkdir([savedir filesep 'DotsandAudio_behaviour']);
end
%make participants outpath.
mkdir([[savedir filesep 'DotsandAudio_behaviour' filesep subject.fileName filesep 'behaviour']]);

ppantsavedir=[savedir filesep 'DotsandAudio_behaviour' filesep subject.fileName ];

%% note that the experiment order (V-A or A-V) is predetermined.
% 
% try to load a previously generated experiment order:
expfile = dir([pwd filesep  'ExperimentOrder*']);
try load(expfile(1).name, 'randExpOrder')
catch
    %first ppant. so generate block design   
    while ~exist('df_order', 'var')
        % randomize participant trial types
        % 1= V-A; 2= A-V
        randExpOrder=randi(2,1,32);
        
        %break when even numbers
        if length(randExpOrder(randExpOrder==1))>12
            df_order=1;
            dt=date;
            save(['ExperimentOrder set ' date], 'randExpOrder')
            break
        end
        
        %set experiment type:
        if subject.id < 999 % i.e. if not debugging.
            %change experiment based on subject order
            switch randExpOrder(subject.id)
                case 1
                    cfg.df_order='vA'; % visual - then audio
                    
                case 2
                    cfg.df_order='aV' ;% audio- then visual discrimination
            end
        end
        
    end
end
    