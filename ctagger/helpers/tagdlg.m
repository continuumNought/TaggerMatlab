% tagdlg
% GUI helper for selectmaps
%
% Usage:
%   >>  response = tagdlg(fieldname, fieldValues)
%
% Description:
% response = tagdlg(fieldname, fieldValues) brings up a GUI that is a
% helper for selectmaps
%
% Function documentation:
% Execute the following in the MATLAB command window to view the function
% documentation for tagdlg:
%
%    doc tagdlg
% See also: tageeg, tagstudy, tagdir, tagcsv
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
% $Log: tagdlg.m,v $
% $Revision: 1.0 21-Apr-2013 09:25:25 krobbins $
% $Initial version $
%

function response = tagdlg(fieldname, fieldValues)

% Setup the variables used by the GUI
response = 'Cancel';
if isempty(fieldname) || isempty(fieldValues)
    return;
end
maxLines = 10;
theTitle = ['Do you want to tag ' fieldname ' field [' ...
    num2str(length(fieldValues)) ' value(s)]?'];
numFields = 1;
if isempty(fieldValues)
    displayFields = ' ';
elseif ischar(fieldValues)
    displayFields = fieldValues;
elseif iscellstr(fieldValues)
    numFields = min(maxLines, length(fieldValues));
    displayFields = fieldValues(1:numFields);
    if length(fieldValues) > maxLines
        displayFields{maxLines} = '. . . etc . . .';
    end
end
inputFig = figure( ...
    'MenuBar', 'none', ...
    'Name', theTitle, ...
    'NextPlot', 'add', ...
    'NumberTitle','off', ...
    'Resize', 'on', ...
    'Tag', theTitle, ...
    'Toolbar', 'none', ...
    'Visible', 'off', ...
    'WindowStyle', 'modal');
createLayout(inputFig);
movegui(inputFig); % Make sure it is visible
uiwait(inputFig);

    function buttons = createButtonPanel(parent)
        % Create the button panel on the side of GUI
        buttons = uiextras.Grid('Parent', parent, ...
            'Tag', 'SaveGrid', 'Spacing', 2, 'Padding', 1);
        uiextras.Empty('Parent', buttons);
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'TagButton', ...
            'String', 'Tag', 'Enable', 'on', 'Tooltip', ...
            ['Tag values associated with ' fieldname], ...
            'Callback', {@buttonCallback, 'Tag'});
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'RemoveButton', ...
            'String', 'Exclude', 'Enable', 'on', 'Tooltip', ...
            ['Exclude field ' fieldname ' from tagging'], ...
            'Callback', {@buttonCallback, 'Exclude'});
        uicontrol('Parent', buttons, ...
            'Style', 'pushbutton', 'Tag', 'CancelButton', ...
            'String', 'Cancel', 'Enable', 'on', 'Tooltip', ...
            'Cancel with no changes', ...
            'Callback', {@buttonCallback, 'Cancel'});
        uiextras.Empty('Parent', buttons);
        set(buttons, 'RowSizes', 30, 'ColumnSizes', [-1 100 100 100 -1]);
    end % createButtonPanel

    function createLayout(parent)
        % Create the layout for the GUI but do not display
        mainVBox = uiextras.VBox('Parent', parent, ...
            'Tag', 'MainVBox',  'Spacing', 5, 'Padding', 5);
        
        uiextras.Empty('Parent', mainVBox);
        panel = uiextras.Panel('Parent', mainVBox, 'Title', ...
            ['The ' fieldname ' field has values:'], 'Padding', 10);
        uicontrol('Parent', panel, ...
            'Style','text', 'String', displayFields, ...
            'HorizontalAlignment', 'Left');
        uiextras.Empty('Parent', mainVBox);
        createButtonPanel(mainVBox);
        uiextras.Empty('Parent', mainVBox);
        set(mainVBox, 'Sizes', [10, 20+30*numFields,  -1, 40, 10]);
        drawnow
    end % createLayout

    function buttonCallback(src, eventdata, responseValue) %#ok<INUSL>
        % Callback for browse button sets a directory for control
        response = responseValue;
        close(inputFig);
    end % buttonCtrlCallback

end % tagdlg