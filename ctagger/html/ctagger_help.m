%% EEGVIS viewer (|eegvis|)
% Create a two level-viewer with upper panel summaries and lower panel details
%
%% Syntax
%     eegvis(data)
%     eegvis(data, 'key1', 'value1', ....)
%     hfig = eegvis(...)
%
%% Description
%
% |eegvis(data)| creates a summary/detail viewer of |data|. The |data|
% parameter can be an array or an object of type |viscore.blockedData|.
%
% The resulting viewer is divided into two levels. The top portion 
% contains multiple summary views organized using tabs. The bottom 
% portion contains various detail panels, which display relatively 
% small portions of the data. 
%
% A user selects detail views by clicking 
% a summary view. The user can configure the arrangement of viewing 
% panels and how summary and detail panels link.
%
%
% |eegvis(data, 'name1', 'value1', ....)| specifies optional 
% name/value parameter pairs
%
% <html>
% <table>
% <thead><tr><td>Name</td><td>Value</td></tr></thead>
% <tr><td><tt>'Functions'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%          initial functions</td></tr>
% <tr><td><tt>'Plots'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%                     initial plots</td></tr>
% <tr><td><tt>'Properties'</tt></td>
%      <td><tt>dataManager</tt>, structure, or cell array of 
%                     initial properties</td></tr>
% </table>
% </html>
%
%
% |hFig= eegvis(data, 'name1', 'value1', ....)| returns a handle to
% the figure created for the visualization.
%
% The |eegvis| function creates an |visviews.dualView| object, but 
% returns a handle to the figure created by |visviews.dualView|, not a
% handle to the |visviews.dualView| object.
%
%% Configurable properties
% The visualization has five configurable parameters: 
%
% |BlockName| specifies base name of the windows in the block summaries
%    for non-epoched data.
%
% |BlockSize| specifies the number of frames in a block for non-epoched
%    data (e.g., |'Window'|).
%
% |ElementName| specifies the base name of an element (e.g., |'Channel'|).
%
% |EpochName| specifies the base name of the windows in block summaries
%    for epoched data.
%
% |VisName| specifies the prefix used for the name on the figure window 
%    title bar.
%
%% Example
% Create a viewer to show some data

   data = random('exp', 2, [32, 1000, 20]); % Create some random data
   eegvis(data);                            % View the data

%% Notes
%
% * Many summaries supported by this viewer are window or epoch oriented.
% * Some displays treat epoched data differently than non-epoched data.
% * Epoched data may not be continuous and cannot be reblocked by
%     changing the block size.
%
%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |eegvis|:
%
%    doc eegvis
%

%% See also
% <dualView_help.html |visviews.dualView|>,
% <eegbrowse_help.html |eegbrowse|>, and
% <eegplugin_eegvis_help.html |eegplugin_eegvis|>
%
%% 
% Copyright 2011 Kay A. Robbins, University of Texas at San Antonio