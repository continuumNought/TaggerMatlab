% createdbc
% Creates a community tagger database from a property file that contains 
% database credentials 
% Usage:
%   >>  createdbc(credPath)
%   >>  createdbc(credPath, 'key1', 'value1', ...)
% Description:
% createdbc(credPath) creates a community tagger database from a property
% file containing the database credentials. The newly created database is 
% empty.
%
% obj = createdbc(dbname, hostname, port, username, password, 'key1', ...
%       'value1') where the key-value pair is:
%
%   'sqlFile'            The name of the .sql file used to create the
%                        database
% 
% Fucntion documentation:
% Execute the following in the MATLAB command window to view the class
% documentation for csvMap:
%
%    doc createdbc
%
% See also: createdb, deletedb, deletedbc
%
%
% Copyright (C) Kay Robbins and Thomas Rognon, UTSA, 2011-2013, krobbins@cs.utsa.edu
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
% $Log: createdbc.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%
function createdbc(credPath, varargin)
parser = inputParser;
parser.addRequired('credPath', @(x) (~isempty(x) && ischar(x)));
parser.addOptional('SqlFile', 'tags.sql', @(x) (~isempty(x) && ischar(x)));
parser.parse(credPath, varargin{:});
p = parser.Results;
edu.utsa.tagger.database.ManageDB.createDatabase(p.credPath, ...
    which(p.SqlFile));
end

