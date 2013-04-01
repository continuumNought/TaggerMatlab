%% eegplugin_eegvis
% Makes |eegbrowse| and |eegvis| plug in to EEGLAB menus
%     
%% Syntax
%     eegplugin_eegvis(fig, trystrs, catchstrs);
%
%% Description
% |eegplugin_eegvis(fig, trystrs, catchstrs)| makes |eegvis| and |eegbrowse| 
% plugins for EEGLAB. The |eegvis| function displays the two-level viewer as a 
% visualization tool from the EEGLAB Plot menu. The |eegbrowse| function
% starts a previewer accessible from the EEGLAB File menu. 
% 
% The |fig|, |trystrs|, and |catchstrs| arguments follow the
% convention for plugins to EEGLAB. The |fig| argument holds the figure
% number of the main EEGLAB GUI. The |trystrs| and |catchstrs| arguments
% hold the try and catch strings for EEGLAB menu callbacks.
%
% Place the |eegvis| folder in the |plugins| subdirectory of EEGLAB.
% EEGLAB should detect the plugin on start up.  
%
%% Notes
%
% * See |Contents.m| for the contents of this plugin.
%
%% See also
% eeglab,
% <pop_eegvis_help.html, |pop_eegvis|>,
% <pop_eegbrowse_help.html |pop_eegbrowse|>,
% <eegbrowse_help.html, |eegbrowse|>, and
% <dualView_help.html |visviews.DualView|>
%