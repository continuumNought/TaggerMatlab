% deletedbc
% Deletes a community tagger database from a property file that contains 
% database credentials 
%
% Usage:
%   >>  deletedbc(DbCreds)
%
% Description:
% deletedbc(DbCreds) deletes a community tagger database. 
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for deletedbc:
%
%    doc deletedbc
%
% See also: createdb, createdbc, deletedb
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
% $Log: deletedbc.m,v $
% $Revision: 1.00 15-Feb-2013 08:03:48 krobbins $
% $Initial version $
%
function deletedbc(DbCreds)
parser = inputParser;
parser.addRequired('DbCreds', @(x) (~isempty(x) && ischar(x)));
parser.parse(DbCreds);
p = parser.Results;
edu.utsa.tagger.database.ManageDB.deleteDatabase(p.DbCreds);
end