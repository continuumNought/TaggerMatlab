% tageeg
% Allows a user to tag an EEGLAB EEG structure
%
% Usage:
%   >>  [EEG, fMap, excluded] = tageeg(EEG)
%   >>  [EEG, fMap, excluded] = tageeg(EEG, 'key1', 'value1', ...)
%
%% Description
% [EEG, fMap, excluded] = tageeg(EEG) creates an fieldMap object called
% fMap. First all of the tag information and potential fields are
% extracted from EEG.event, EEG.urevent, and EEG.etc.tags structures. 
% After existing event tags are extracted and merged with an optional
% input fieldMap, the user is presented with a GUI to accept or exclude
% potential fields from tagging. Then the user is presented with the 
% ctagger GUI to edit and tag. Finally, the tags are rewritten to
% the EEG structure. 
%
% [EEG, fMap, excluded] = tageeg(EEG, 'key1', 'value1', ...) specifies 
% optional name/value parameter pairs:
%   'BaseMapFile'    A file containing a fieldMap object to be used
%                    for initial tag information. The default is an 
%                    fieldMap object with the default HED XML and no tags.
%   'DbCredsFile'    Name of a property file containing the database
%                    credentials. If this argument isnot provided, a
%                    database is not used. (See notes.)
%   'ExcludeFields'  Cell array of field names in the .event structure
%                    to ignore during the tagging process. By default
%                    the following fields are ignored: 'latency', ...
%                    'epoch', 'urevent', 'hedtags', 'usertags'. The user
%                    can over-ride these tags using this name-value
%                    parameter.
%   'Fields'         Cell array of field names of the fields to include
%                    in the tagging. If this parameter is non-empty
%                    (default), only these fields are tagged.
%   'PreservePrefix' If false (default), tags of the same event type that
%                    share prefixes are combined and only the most specific
%                    is retained (e.g., /a/b/c and /a/b become just
%                    /a/b/c). If true, then all unique tags are retained.
%   'RewriteOption'  String indicating how tag information should be
%                    written to the datasets. The options are 'Both',
%                    'Individual', 'None', 'Summary'. See the notes for
%                    additional information.
%   'SaveMapFile'    File name for saving the final, consolidated fieldMap
%                    object that results from the tagging process.
%   'SelectOption'   If true (default), the user is presented with a GUI 
%                    that allows users to select which fields to tag.
%   'Synchronize'    If false (default), the ctagger GUI is run with
%                    synchronization done using the MATLAB pause. If
%                    true, synchronization is done within Java. This
%                    latter option is usually reserved when not calling
%                    the GUI from MATLAB.
%                    no other MATLAB commands can be issued until this GUI
%   'UseGui'         If true (default), the ctagger GUI is displayed after
%                    initialization.
%
% Notes on tag rewrite:
%   The tags are written to the data files in two ways. In both cases
%   the dataset x is assumed to be a MATLAB structure: 
%   1) If the 'RewriteOption' is either 'Both' or 'Summary', the tags
%      are written to the dataset in the x.etc.tags field:
%            x.etc.tags.xml
%            x.etc.tags.map.field1
%            x.etc.tags.map.field2 ...
%      
%
%   2) If the 'RewriteOption' is either 'Both' or 'Individual', the tags
%      are also written to x.event.usertags based on the individual 
%      values of their events.
%
% Notes on the database:  Database is not deployed.
%
% See also: tagdir and tagstudy
%

%1234567890123456789012345678901234567890123456789012345678901234567890

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
% $Log: tageeg.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%
function [EEG, fMap, excluded] = tageeg(EEG, varargin)
    % Parse the input arguments
    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || isstruct(EEG)));
    parser.addParamValue('BaseMapFile', '', ...
        @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('DbCredsFile', '', ...
        @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('ExcludeFields', ...
            {'latency', 'epoch', 'urevent', 'hedtags', 'usertags'}, ...
            @(x) (iscellstr(x)));
    parser.addParamValue('Fields', {}, @(x) (iscellstr(x)));
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('RewriteOption', 'both', ...
          @(x) any(validatestring(lower(x), ...
          {'Both', 'Individual', 'None', 'Summary'})));
    parser.addParamValue('SaveMapFile', '', @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('SelectOption', true, @islogical);
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('UseGui', true, @islogical);
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    
    % Get the existing tags for the EEG
    fMap = findtags(p.EEG, 'PreservePrefix', p.PreservePrefix, ...
        'ExcludeFields', p.ExcludeFields, 'Fields', p.Fields);
    
    % Exclude the appropriate tags from baseTags
    excluded = p.ExcludeFields;
    baseTags = fieldMap.loadFieldMap(p.BaseMapFile);
    if ~isempty(baseTags) && ~isempty(p.Fields)
        excluded = setdiff(baseTags.getFields(), p.Fields);
    end;        
    fMap.merge(baseTags, 'Merge', excluded);
    if p.SelectOption
       [fMap, exc] = selectmaps(fMap, 'Fields', p.Fields);
       excluded = union(excluded, exc);
    end
    if p.UseGui
        fMap = editmaps(fMap, 'PreservePrefix', p.PreservePrefix, ...
             'Synchronize', p.Synchronize);
    end
    
    % Save the fieldmap 
    if ~isempty(p.SaveMapFile) && ~fieldMap.saveFieldMap(p.SaveMapFile, fMap)
        warning('tageeg:invalidFile', ...
            ['Couldn''t save fieldMap to ' p.SaveMapFile]);
    end   
    
    % Now finish writing the tags to the EEG structure
    EEG = writetags(EEG, fMap, 'ExcludeFields', excluded, ...
                    'PreservePrefix', p.PreservePrefix, ...
                    'RewriteOption', p.RewriteOption);
end % tageeg