% Community event tagger
% Version 0.5 (beta)
%
% The Community Event Tagger is a GUI for supporting user assignment of
% tags
%
% Authors: Thomas Rognon and Kay Robbins, UTSA 2012-2013
%
%
% Top-level functions
%   createTags        - MATLAB interface to Gui for tagging a list of events 
%   testScript        - Script demonstrating use for simple examples
%
% Helpers
%   extractEEGEvents  - extract event types from an EEGLAB EEG structure
%   mergeTagLists     - merge two lists of tags, removing duplicate prefixes
%   mergeEventTags    - combined two lists of tagged events
%   parseEvent        - parses an event string into its components
%
% Other Helpers
%   hedManager        - utility provided by Nima Bidely Shamlo UCSD for
%                       managing the XML hierarchy
% 