function eTags = tagstudy(studyFile, varargin)
    % Tag all of the EEG files in a study
    eTags = '';
    parser = inputParser;
    parser.addRequired('StudyFile', ...
        @(x) (~isempty(x) && exist(studyFile, 'file')));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x) && exist(x, 'file') && ...
            ~isempty(eventTags.loadTagsFile(x)))));
    parser.addParamValue('Match', 'code', ...
        @(x) any(validatestring(lower(x), {'code', 'label', 'both'})));
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('PreservePrefix', false, @islogical);
    parser.addParamValue('Synchronize', true, @islogical);
    parser.addParamValue('TagFileName', '', ...
         @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('UpdateType', 'tagsonly', ...
          @(x) any(validatestring(lower(x), ...
          {'merge', 'replace', 'onlytags', 'update', 'none'})));
    parser.addParamValue('UseGUI', true, @islogical);
    parser.parse(studyFile, varargin{:});
    p = parser.Results;
 
    [s, fPaths] = loadstudy(p.StudyFile);
    if isempty(s) 
        return;
    end
    
    % Merge the tags for the study
    for k = 1:length(fPaths) % Assemble the list
        eegTemp = pop_loadset(fPaths{k});
        eTagsNew = findtags(eegTemp, 'Match', p.Match, ...
                   'PreservePrefix', p.PreservePrefix);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagevents(eTags, 'BaseTags', baseTags, ...
        'Match', p.Match, 'PreservePrefix', p.PreservePrefix, ...
        'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI, ...
        'Synchronize', p.Synchronize);
  
    % Save the tags file for next step
    if ~isempty(p.TagFileName) || ...
        ~eventTags.saveTagFile(p.TagFileName, 'eTags')
        bName = tempname;
        warning('tagstudy:invalidFile', ...
            ['Couldn''t save eventTags to ' p.TagFileName]);
        eventTags.saveTagFile(bName, 'eTags')
    else 
        bName = p.TagFileName;
    end
 
    if isempty(fPaths) || strcmpi(p.UpdateType, 'none')
        return;
    end
    
    % Rewrite all of the EEG files with updated tag information
    for k = 1:length(fPaths) % Assemble the list
        teeg = pop_loadset(fPaths{k});
        teeg = tageeg(teeg, 'BaseTagsFile', bName, ...
              'Match', p.Match, 'PreservePrefix', p.PreservePrefix, ...
              'Synchronize', p.Synchronize,...
              'UpdateType', p.UpdateType, 'UseGUI', false);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
     
    function [s, fNames] = loadstudy(studyFile)
        % Set baseTags if tagsFile contains an eventTags object
        try
            t = load('-mat', studyFile);
            tFields = fieldnames(t);
            s = t.(tFields{1});
            sPath = fileparts(studyFile);
            fNames = getstudyfiles(s, sPath);
        catch ME %#ok<NASGU>
            warning('tagEEGStudy:loadStudyFile', 'Invalid study file');
            s = '';
            fNames = '';
        end
    end % loadstudy

    function fNames = getstudyfiles(study, sPath)
        % Set baseTags if tagsFile contains an eventTags object
        datasets = {study.datasetinfo.filename};
        paths = {study.datasetinfo.filepath};
        validPaths = true(size(paths));
        fNames = cell(size(paths));
        for ik = 1:length(paths)
            fName = fullfile(paths{ik}, datasets{ik}); % Absolute path
            if ~exist(fName, 'file')  % Relative to stored study path
                fName = fullfile(study.filepath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Relative to actual study path
                fName = fullfile(sPath, paths{ik}, datasets{ik});
            end
            if ~exist(fName, 'file') % Give up
                warning('tagEEGStudy:getStudyFiles', ...
                    ['Study file ' fname ' doesn''t exist']);
                validPaths(ik) = false;
            end
            fNames{ik} = fName;
        end
        fNames(~validPaths) = [];  % Get rid of invalid paths
    end % getstudyfiles
end % tagstudy