%% cTagger.getEEGEventTags
% Create a summary eventTags object for the EEG files in a directory tree
%
%% Syntax
%     eTags = cTagger.getEEGEventTags(EEG)

%% Description
% |eTags = cTagger.getEEGEventTags(EEG)| returns an eventTags object 
% called |eTags| that the events of the EEGLAB |EEG| structure, including
% the ones that have already been tagged. This function takes the
% |EEG.etc.hedEventTags| string, if it exists, and uses it as the starting
% point for the tagging. It merges the tag hierarchy contained in 
% |EEG.etc.hedEventTags| with the default hierarchy and creates new
% event entries for any codes in the |EEG.event| or |EEG.urevent|
% structures. 

%% Example 1
% Consolidate the events from EEG datasets in the current directory tree
   load 'EEGEpoch.mat';
   eTags = cTagger.getEEGEventTags(EEGEpoch);

%%
% The |eTags| eventTags object will contain all of the unique event
% codes present in the |EEG.events| and |EEG.urevents| structures of 
% the |.set| file present in the current working directory. The function
% also merges events, tags, and the hed hierarchies present in the
% |EEG.etc.hedEventTags| strings of these files.
%

%% Class documentation
% Execute the following in the MATLAB command window to view the class 
% documentation for |cTagger|:
%
%    doc cTagger
%
%% See also
% <cTagger_getEEGDirEventTags_help.html |cTagger.getEEGDirEventTags|>,
% <cTagger_tagEEG_help.html |cTagger.tagEEG|>, 
% <cTagger_tagEEGDir_help.html |cTagger.tagEEGDir|>, 
% <cTagger_tagThis_help.html |cTagger.tagThis|>, 
%

%% 
% Copyright 2013 Thomas C. Rognon and Kay A. Robbins, University of Texas at San Antonio