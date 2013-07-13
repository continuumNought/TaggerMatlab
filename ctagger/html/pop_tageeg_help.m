%% pop_eegvis
% Opens an eegbrowse GUI for EEGLAB
%
%% Syntax
%     EEGOUT = pop_eegvis(EEG)
%
%% Description
% |EEGOUT = pop_eegvis(EEG)| provides a graphical display of the 
% current EEG dataset. 
%
%% Notes
%
% * |pop_eegvis| is meant to be used as the callback for a visualizate
% item under the the EEGLAB Plot menu. It is a singleton and clicking
% the menu item again will not create a new window if one already
% exists.
%
%% See also
% eeglab, <eegvis_help.html |eegvis|>, and <visviews.dualView_help.html
% |visviews.dualView|>
%