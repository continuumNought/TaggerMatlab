%% Run this script to set up your credentials file and/or database

%% Call the GUI to get the credentials
credPath = dbcreds();
fprintf('Your credentials path is: %s\n', credPath);
if isempty(credPath)
    return;
end
%% Do you want to create the database?
reply = input('Do you want to create a database ? Y/N [Y]: ', 's');
if ~isempty(reply) && ~strcmpi(reply, 'Y')
    return;
end
%% Now attempt to create the database
try
    edu.utsa.tagger.database.ManageDB.createDatabase(credPath, ...
        which('tags.sql'));
    fprintf('Database successfully created...\n');
catch me   % if database already exists, creation fails and warning is output
    warning('setupdb:creationfailed', me.message);
end
% Be sure to close the database
try
    DB.close();
catch me
end
