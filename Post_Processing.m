function plot1 = Post_Processing

% This section allows the user to select the SCORED.txt files and the
% EEGPh.mat files 
[file] = uigetfile({'*SCORED.txt'},...
                          'Select SCORED EEG output file');
EEG_File = readtable(file, 'ReadVariableNames',false') ;        % We have readvariable names set to false because we allocate our own below on line 52

[file1] = uigetfile({'*EEGPh.mat'},...
                          'Select alligned EEGPh.mat file');
loadfile = load(file1) ;
EEGPh = loadfile.EEGPh ;

% Here we ask the user which figures they want us to make
% Ask the user if they would like to plot transition figures
% Save the answer as a variable named transition_plot
answer1 = questdlg('Would you like me to plot state transitions (line plots and heatmaps)?', ...
	'Transition Plots', ...
	'Yes please, Computer','Not today thank you, Computer','Yes please, Computer');
% Handle response
switch answer1
    case 'Yes please, Computer'
        transition_plot = 1;
    case 'Not today thank you, Computer'
        transition_plot = 2;
end

% Ask the user if/which kind of session figures they would like plotted
% Save the answer as a variable named session_plot
answer2 = questdlg('I can plot the whole session too - I can either plot it with the background changing color or the plotted line changing color according to the sleep/wake state (only available for 3 states). Which would you like?', ...
	'Session Plots', ...
	'Background changing color','Line changing color','Neither for me thanks, Computer','Background changing color');
% Handle response
switch answer2
    case 'Background changing color'
        session_plot = 1;
    case 'Line changing color'
        session_plot = 2;
    case 'Neither for me thanks, Computer'
        session_plot = 0;
end

% This section pulls out the folder names and makes a new folder to save
% the transition data into
mainFolder = pwd ;
foldername = strsplit(file,'_') ;
foldername = strcat(foldername(1,1),'_',foldername(1,2),'_',foldername(1,3)) ;
mkdir(foldername{1})

if ispc 
    newfolder = strcat(mainFolder, '\',foldername) ;
elseif ismac
    newfolder = strcat(mainFolder, '/',foldername) ;
end

% This section sets the variable names of our EEG_File table appropriately
EEG_File.Properties.VariableNames = {'Var1','State','sec','DateTime','StartCode','StateCode'} ;

% This gives us the number of rows in the EEG_File table and then creates a
% series of 'transition names' by taking every second state code and
% conjoining it to the state code in the cell below it - hyphenated with a '_'
transitionnames = strings(size(EEG_File,1),1) ;
for i = (2:2:size(EEG_File.State,1)-1)
    transitionnames(i+1,1) = strcat(EEG_File.State{i},'_',EEG_File.State{i+1}) ;
end

% Next we find out how many unique transition types there are by using
% unique() 
transitiontypes = unique(transitionnames) ;
transitiontypes = transitiontypes(2:end,1) ;
transitions = NaN(size(EEG_File,1),size(transitiontypes,1)) ;
newvars = cell(1,size(transitiontypes,1)) ;

for i = 1:size(transitiontypes,1)
    newvars{1,i} = transitiontypes(i,1) ;
end

EEG_File.Transitions = transitionnames ;

for t = 1:size(transitiontypes,1) 
    for r = 1:size(EEG_File,1)
        if EEG_File.Transitions(r) == transitiontypes(t,1) 
            transitions(r,t) = EEG_File.sec(r) ;
        end
    end
end

% Add the transition types to our EEG_File
transitiontable = array2table(transitions);
transitiontable.Properties.VariableNames = {transitiontypes{:,1}} ;
EEG_File = [EEG_File transitiontable];
writetable(EEG_File, strcat(file(1,1:end-4),'.csv'));   % This command saves our EEG_File table as a csv file

%%

Trans = table2array(EEG_File(:,end-(size(transitiontypes,1)-1):end));         % This pulls out your transition times as numeric values

nrow = size(Trans,1);                               % This determines the number of rows in the variable Trans
ncol = size(transitiontypes,1);                               % This determines the number of columns in the variable Trans

% This code section is a user input interface for the user to give us the
% sampling rate used - it defaults to 256
prompt = {'Enter sampling rate used (default = 256):'};
title1 = 'User Input';
dims = [1 35];
definput = {'256'};
answer = inputdlg(prompt,title1,dims,definput) ;
r1 = str2double(answer(1,1)) ;

cd(newfolder{1,1})

for c = 1:ncol                                      % for every column in the variable Trans ...
    dFF_align = double.empty(0,0);                      % this makes an empty matrix to save your transition data into
    dFF_col = 1;                                        % this sets the current column of interest to the first colum
    for r = 1:nrow                                      % for every single row in the variable Trans
         if isnan(Trans(r,c))                                   % if the cell contains NaN (not a number) continue without doing anything
            continue
         elseif 10<= Trans(r,c) && Trans(r,c) <= 2390           % but if the cell contains a number between 10 and 2390
            ts = round((Trans(r,c)-10)*r1)+1;                  % cut from 10s before the transition, sampling rate 256
            te = round((Trans(r,c)+10)*r1);                    % to 10s after the transition, sampling rate 256
            dFF_align(1:te-ts+1,dFF_col) = EEGPh(ts:te,3);      % and save it into a new variable called dFF_align
            dFF_col = dFF_col+1;                                % Now you have finished the first column so this bumps the column of interest up to the next one to start the loop again
         end
    end       
    csvwrite(strcat(strrep(transitiontypes(c,1),'_','-'),'.csv'), dFF_align);      % This line saves the different transistion files into their own csv file
end            

%% Figure me up, bitch! N.B. Gramm figures require you to have the @gramm folder either in your current folder or your matlab path
% Before you start this you want to have @gramm in your PATH or in the
% folder you are making figures from

excel_files = dir('*.csv');         % This gives us a list of all of the excel files in the current folder

for i = 1:size(excel_files,1)                                               % for every excel file in the current folder ...
    if excel_files(i).bytes >= 1                                                % if the file size is bigger than or equal to 1 (otherwise it is empty and there were no transitions for that transition type)
        filename = excel_files(i).name(1:end-4) ;                                       % make a variable called filename that we will use as our figure title
        data = csvread(excel_files(i).name) ;                                       % read the csv file and save it in the workspace as a variable called data
        data = data' ;                                                              % flip it - this switche the certically alligned transitions to horizontal transitions because MATLAB like them better that way
        dataheight = size(data,1) ;                                                 % How many rows are there in the data?
        datawidth = size(data,2) ;                                                  % How many columns are there in the data?
        gcolors = ones(dataheight,1)*i ;                                            % If you were graphing multiple transitions on one graph this is the color grouping variable to make them different colors
        cd(mainFolder)

        %make our transition figure
        if transition_plot == 1
            g = gramm('x',-10:(20/(datawidth-1)):10,'y',data, 'color', gcolors) ;       % This is the gramm command to select the data and color groupings you want in your graph
            g.stat_summary('type', 'sem') ;                                             % This is the gramm command to plot a line with shaded error bars of your mean and standard error as calulted across the rows
            g.set_names('x','Time (seconds)','y','dF/F (%)');                           % This sets the X and Y axis titles 
            g.geom_abline('intercept', 0, 'slope', 0, 'style', 'k--');                  % This plots a dashed horizontal line at dF/F = 0
            g.geom_abline('intercept', 0, 'slope', 1000000 , 'style', 'k--');           % This plots a dashed vertical line at the transition point
            g.set_title(filename);                                                      % Set the figure title to be the title of the Excel sheet
            g.set_color_options('map', 'brewer1');                                      % Sets the color map to brewer1 - there are a bunch of color maps to choose from and you can make your own, I just like brewer1
            g.set_order_options('color',i);                                             % If you had multiple groups per graph this would make them different colors (you don't, in this case, I have just left it here in case you need to later)
            figure('Position',[100 100 800 400]);                                       % Set your figure position (where on the screen your figure pops up)

            g.draw();                                                                   % DRAW THIS BITCH

        % Make our heatmap figure
        % NB This needs the function plot_heatmap.m in the current folder
            h = plot_heatmap(data,filename);  % Make a heat map out of it toooooo
            size(h,1) ; % this line is a useless piece of code and will change nothing if it is deleted
        end
        cd(newfolder{1,1})
    end
end

%% Make a figure of the whole session

% before you start
% import EEG+Photometry data (variable name: EEGPh)
% import entire alligned & scored excel sheet as a string variable (variable name: TransData)

statetypes = unique(EEG_File.State) ;
EEG_File.sec = round(EEG_File.sec)*r1 ;
EEG_File.sec(1) = 1 ;           % Here I have changed the first time variable from 0 to 1 as 0 is not indexable
figuredata = [EEGPh (1:size(EEGPh,1))' NaN(size(EEGPh,1),size(statetypes,1)+1)] ;

for i = 1:size(statetypes,1) 
    for j = 1:2:size(EEG_File,1)
        if EEG_File.State{j} == statetypes{i,1}
            figuredata(EEG_File.sec(j):EEG_File.sec(j+1),5) = i ;
            figuredata(EEG_File.sec(j):EEG_File.sec(j+1),5+i) = figuredata(EEG_File.sec(j):EEG_File.sec(j+1),3) ;
        end
    end
end
figuredata = figuredata(1:size(EEGPh,1),:) ;

Ymin = min(figuredata(:,3))-.5 ;
Ymax = max(figuredata(:,3))+.5 ;
    
%% Run this section for a figure with the color of the background showing the different sleep states

holdxlabels = string(0:round(size(figuredata,1)/60000)) ;
y = [-30 -30 50 50]; %  Patch heights [min min max max]
colours = [{[221 81 67]/255};{[141 108 171]/255};{[0 160 220]/255};{[234 171 0]/255};{[83 40 79]/255};{[0 155 118]/255};{[77 79 83]/255};{[46 45 41]/255}] ;
% Other colors to choose from can be found at the end of this script
if session_plot == 1
    figure('units', 'normalized', 'pos', [0, .4, 1, .4], ... 
        'Name', 'Background color indicates behavior')
        ylim([Ymin Ymax]);
        xlim([1 size(figuredata,1)]) ;
        title('Title')
        xlabel('Time');
        ylabel('dF/F (%)');
        xticks(0:60000:(round(size(figuredata,1)/60000)*60000));
        xticklabels({holdxlabels}) ;
        hold on;

        for i = 1:size(statetypes,1)
            holder = EEG_File(string(EEG_File.State) == statetypes{i},:) ;
           for r = 1:2:size(holder,1) 
               x = [holder.sec(r) holder.sec(r+1) holder.sec(r+1) holder.sec(r)] ;
               patch (x, y, colours{i,1}, 'EdgeColor', 'none','FaceAlpha',.5) ;
           end
        end

        plot(figuredata(:,4), figuredata(:,3), 'k', 'LineWidth', 1.5) ;

        hold off ;
end
    
%% Run this section for a figure with the color of the line showing the different sleep states
%     Plot colored line

if session_plot == 2
    x = figuredata(:,4) ;
    y1 = figuredata(:,6) ;
    y2 = figuredata(:,7) ;
    y3 =  figuredata(:,8) ;

    figure('units', 'normalized', 'pos', [0, .4, 1, .4], ... 
        'Name', 'Background color indicates behavior')
        ylim([Ymin Ymax]);
        xlim([1 size(figuredata,1)]) ;
        title('Title')
        xlabel('Time');
        ylabel('dF/F (%)');
        xticks(0:60000:(round(size(figuredata,1)/60000)*60000));
        xticklabels({holdxlabels}) ;
        hold on;

        plot1 = plot(x, y1, 'k', x, y2, 'b', x, y3, 'r', ...
            'LineWidth', 1.5) ; 
        set(plot1(1),...
        'Color',[46 45 41]/255);
        set(plot1(2),'Color',[0 118 98]/255);
        set(plot1(3),...
        'Color',[140 21 21]/255);
        legend(statetypes{1, 1}  ,statetypes{2, 1}  ,statetypes{3, 1}) ;
end

%% Other colors to choose from
    % patch (x, y, [COLOR CODE], 'EdgeColor', 'none') ;
    % Replace COLOR CODE in any of the R/N/W for loops above with any of 
    % the following color codes:
    % [1 0.76 0.58] orange
    % [0.99 0.73 0.63] lightest red
    % [0.99 0.57 0.45] medium red
    % [0.78 0.86 0.94] lightest blue5
    % [0.62 0.79 0.88] blue4
    % [0.42 0.68 0.84] blue3
    % [0.85 0.85 0.85] gray5
    % [0.74 0.74 0.86] light purple
    % [0.63 0.85 0.61] medium green
    % [0.78 0.91 0.75] light green
    % [0.39 0.39 0.39] dark gray
    
% Stanford Colors to see a palette go to:
% https://identity.stanford.edu/color.html#print-color 
    % [140 21 21]/255 Cardinal Red
    % [255 255 255]/255 White
    % [77 79 83]/255 Cool Grey
    % [46 45 41]/255 Black
    % [177 4 14]/255 Bright Red
    % [47 36 36]/255 Chocolate
    % [84 73 72]/255 Stone
    % [244 244 244]/255 Fog
    % [249 246 239]/255 Light Sandstone
    % [210 194 149]/255 Sandstone
    % [63 60 48]/255 Warm Grey
    % [157 149 115]/255 Beige
    % [199 209 197]/255 Light Sage
    % [95 87 79]/255 Clay
    % [218 215 203]/255 Cloud
    % [182 177 169]/255 Driftwood
    % [146 139 129]/255 Stone
    % [179 153 93]/255 Sandhill
    % [23 94 84]/255 Palo Alto
    % [0 80 92]/255 Teal
    % [83 40 79]/255 Purple
    % [141 60 30]/255 Redwood
    % [94 48 50]/255 Brown
    % [0 152 219]/255 Sky
    % [0 124 146]/255 Lagunita
    % [0 155 118]/255 Mint
    % [178 111 22]/255 Gold
    % [234 171 0]/255 Sun
    % [233 131 0]/255 Poppy
end
