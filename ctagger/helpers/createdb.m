% createdb
% Creates a community tagger database from credentials passed in from the
% user
%
% Usage:
%   >>  createdb(dbname, hostname, port, username, password)
%   >>  createdb(dbname, hostname, port, username, password, 'key1', ...
%       'value1', ...)
%
% Description:
% createdb(dbname, hostname, port, username, password) creates a
% community tagger database. The newly created database is empty.
%
% createdb(dbname, hostname, port, username, password, 'key1', ...
% 'value1') where the key-value pair is:
%
%   'sqlFile'            The name of the .sql file used to create the
%                        database
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for createdb:
%
%    doc createdb
%
% See also: createdbc, deletedb, deletedbc
%
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013,
% krobbins@cs.utsa.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%
% $Log: createdb.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%

function createdb(dbname, hostname, port, username, password, varargin)
parser = inputParser();
parser.addRequired('dbname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('hostname', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('port', @(x) isnumeric(x) && isscalar(x));
parser.addRequired('username', @(x) (~isempty(x) && ischar(x)));
parser.addRequired('password', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('sqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(dbname, hostname, port, username, password, varargin{:});
p = parser.Results;
edu.utsa.tagger.database.ManageDB.createDatabase(p.dbname, p.hostname, ...
    p.port, p.username, p.password, which(p.sqlFile));
end

