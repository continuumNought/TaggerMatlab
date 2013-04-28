%% First execute the general ctagger setup to make paths are set
fprintf('Executing setup.m to set the paths\n');
setup;
   
%% Now call the GUI to get the credentials
credPath = createcreds();
fprintf('Your credentials path is: %s\n', credPath);
  
%% Now creating a database manager
try
     DB = edu.utsa.tagger.database.TagDBManager(credPath);
 catch me   % if database already exists, creation fails and warning is output
    error('setupdb:credentialsFailed', me.message);
end
fprintf('Database manager created\n');

%% Now attempt to create the database
try
    DB.setupDatabase(credPath);
catch me   % if database already exists, creation fails and warning is output
    warning('setupdb:creationfailed', me.message);
end


% 
% %% Set up the paths
% % Run from ctagger directory or have ctagger directory in your path
% configPath = which('eegplugin_ctagger.m');
% if isempty(configPath)
%     error('Cannot configure: change to ctagger directory');
% end
% dirPath = strrep(configPath, [filesep 'eegplugin_ctagger.m'],'');
% addpath(genpath(dirPath));
% 
% %% Now add java jar paths
% jarPath = [dirPath filesep 'jars' filesep];  % With jar
% warning off all;
% try
%     javaaddpath([jarPath 'ctagger.jar']);
%     javaaddpath([jarPath 'jackson.jar']);
%     javaaddpath([jarPath 'postgresql-9.2-1002.jdbc4.jar']);
% catch mex 
% end
% warning on all;