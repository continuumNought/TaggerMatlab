% gettags
% Creates a fieldMap object for the existing tags in a data structure
%
% Usage:
%   >>  fMap = gettags(filename)
%   >>  fMap = gettags(filename, 'key1', 'value1', ...)
%
% Description:
% fMap = gettags(filename) creates a fieldMap object for the existing tags
% in a data structure
%
% fMap = gettags(filename, 'key1', 'value1', ...) specifies optional 
% name/value parameter pairs:
%
%   'ExcludeFields'  A cell array containing the field names to exclude
%   'Fields'         A cell array containing the field names to extract
%                    tags for.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for gettags:
%
%    doc gettags
%
% See also: tageeg, tageeg_input, pop_tageeg
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
% $Log: gettags.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function fMap = gettags(filename, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
         @(x) (iscellstr(x)));
    parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.parse(filename, varargin{:});
    p = parser.Results;  
    
    [keys, headers, descriptions] = getevents(p.FileName); %#ok<ASGLU>
    
    fMap = fieldMap('PreservePrefix', p.PreservePrefix);
    tMap = tagMap('Field', 'NonOrthogonal'); 
    for k = 1:length(keys)
        value = struct('label', keys{k}, 'description', ...
            descriptions{k}, tags, '');
        tMap.addValue(value, 'PreservePrefix', p.PreservePrefix);
    end
 
end % gettags