%% First execute the general ctagger setup to make paths are set
fprintf('Executing setup.m to set the paths\n');
setup;
   
%% Now call the GUI to get the credentials
credPath = createcreds();
fprintf('Your credentials path is: %s\n', credPath);
  
%% Now creating a database manager
try
     DB = edu.utsa.tagger.database.TagsDBManager(credPath);
 catch me   % if database already exists, creation fails and warning is output
    error('setupdb:credentialsFailed', me.message);
end
fprintf('Database manager created\n');

%% Now attempt to create the database
try
    dbScript = char(which('tags.sql'));
    DB.setupDatabase(dbScript);
catch me   % if database already exists, creation fails and warning is output
    warning('setupdb:creationfailed', me.message);
    DB.close();
end
DB.close();
