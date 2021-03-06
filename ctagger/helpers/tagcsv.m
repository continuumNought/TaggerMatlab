% tagcsv
% Allows a user to tag a csv file of event code specifications
%
% Usage:
%   >>  fMap = tagcsv(filename)
%   >>  fMap = tagcsv(filename, 'key1', 'value1', ...)
%
% Description:
% fMap = tagcsv(filename) extracts a fieldMap object from the csv
% file and then presents a GUI for choosing which fields to tag.
% The ctagger GUI is displayed so that users can
% edit/modify the tags. The GUI is launched in asynchronous mode.
% Finally the tags are rewritten to the csv file.
%
% The final, consolidated and edited fieldMap object is returned in fMap.
% If fPaths is empty, then fMap will not contain any tag information.
%
% fMap = tagcsv(inDir, 'key1', 'value1', ...) specifies
% optional name/value parameter pairs:
%   'BaseMap'        A fieldMap object or the name of a file that contains
%                    a fieldMap object to be used to initialize tag
%                    information.
%   'DbCreds'        Name of a property file containing the database
%                    credentials. If this argument is not provided, a
%                    database is not used. (See notes.)
%   'Delimiter'      A string containing the delimiter separating event
%                    code components.
%   'DescriptionColumn'   A non-negative integer specifying the column
%                    that corresponds to the event code description.
%                    Users should provide detailed documentation of
%                    exactly what this code means with respect to the
%                    particular experiment.
%   'EventColumns'   Either a non-negative integer or a vector of positive
%                    integers specifying the column(s) that correspond
%                    to event code components. If the value is 0, then
%                    it's assumed that all columns correspond to event
%                    codes.
%   'PreservePrefix' If false (default), tags for the same field value that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'RewriteFile'    File name of tagged csv file with the result of tags
%                    and description written in the file.
%   'SaveMapFile'    A string representing the file name for saving the
%                    final, consolidated fieldMap object that results from
%                    the tagging process.
%   'Synchronize'    If false (default), the CTAGGER GUI is run with
%                    synchronization done using the MATLAB pause. If true,
%                    synchronization is done within Java. This latter
%                    option is usually reserved when not calling the GUI
%                    from MATLAB.
%   'TagsColumn'     A non-negative integer specifying the column
%                    that corresponds to the tags that are currently
%                    assigned to the event code combination of that
%                    row of the csv file.
%   'UseGui'         If true (default), the CTAGGER GUI is displayed after
%                    initialization.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagcsv:
%
%    doc tagcsv
%
% See also: pop_tagcsv and tagcsv_input
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
% $Log: tagcsv.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function fMap = tagcsv(filename, varargin)
% Parse the input arguments
parser = inputParser;
parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
parser.addParamValue('BaseMap', '', @(x)(ischar(x)));
parser.addParamValue('DbCreds', '', @(x)(ischar(x)));
parser.addParamValue('Delimiter', '|', @(x) (ischar(x)));
parser.addParamValue('DescriptionColumn', 0, ...
    @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
parser.addParamValue('EventColumns', 0, ...
    @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
parser.addParamValue('PreservePrefix', false, @islogical);
parser.addParamValue('RewriteFile', '', @(x)(ischar(x)));
parser.addParamValue('SaveMapFile', '', @(x)(ischar(x)));
parser.addParamValue('Synchronize', false, @islogical);
parser.addParamValue('TagsColumn', 0, ...
    @(x)(isnumeric(x) && (isscalar(x) || isempty(x))));
parser.addParamValue('UseGui', true, @islogical);
parser.parse(filename, varargin{:});
p = parser.Results;
fMap = fieldMap('PreservePrefix',  p.PreservePrefix);
cMap = csvMap(filename, 'Delimiter', p.Delimiter, ...
    'DescriptionColumn', p.DescriptionColumn, ...
    'EventColumns', p.EventColumns, ...
    'TagsColumn', p.TagsColumn);
if isempty(cMap.getType())
    return;
end

% Add the event and other information to the map
fMap.addValues(cMap.getType(), cMap.getEvents());
if isa(p.BaseMap, 'fieldMap')
    baseTags = p.BaseMap;
else
    baseTags = fieldMap.loadFieldMap(p.BaseMap);
end
fMap.merge(baseTags, 'Merge', {}, fMap.getFields());

fMap = editmaps_db(fMap, 'DbCreds', p.DbCreds, 'PreservePrefix', ...
    p.PreservePrefix, 'Synchronize', p.Synchronize, 'UseGui', p.UseGui);

% Save the tags file for next step
if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, ...
        fMap)
    warning('tagcsv:invalidFile', ...
        ['Couldn''t save fieldMap to ' p.SaveMapFile]);
end

if ~isempty(p.RewriteFile)
    cMap.writeTags(fMap.getMap(cMap.getType()), p.RewriteFile);
end

end % tagcsv