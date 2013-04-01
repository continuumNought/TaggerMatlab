function [eTags, fPaths] = tagEEGDir(inDir, varargin)
    % Tag all of the EEG files in a directory tree
    parser = inputParser;
    parser.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('BaseTagsFile', '', ...
        @(x)(isempty(x) || (ischar(x) && exist(x, 'file') && ...
            ~isempty(eventTags.loadTagsFile(x)))));
    parser.addParamValue('DoSubDirs', true, @islogical);
    parser.addParamValue('OnlyType', true, @islogical);
    parser.addParamValue('TagFileName', '', ...
         @(x)(isempty(x) || (ischar(x))));
    parser.addParamValue('UpdateType', 'TagsOnly', ...
          @(x) any(validatestring(x, ...
          {'Merge', 'Replace', 'TagsOnly', 'Update', 'NoUpdate'})));
    parser.addParamValue('UseGUI', true, @islogical);
    parser.parse(inDir, varargin{:});
    p = parser.Results;
    % Consolidate all of the tags from the input directory and base
    fPaths = getFileList(p.InDir, '.set', p.DoSubDirs);
    eTags = getEEGGroupEventTags(fPaths);
    baseTags = eventTags.loadTagFile(p.BaseTagsFile);
    eTags = tagEvents(eTags, 'BaseTags', baseTags, ...
        'UpdateType', p.UpdateType, 'UseGUI', p.UseGUI);

    % Save the tags file for next step
    if ~isempty(p.TagFileName) || ...
        ~eventTags.saveTagFile(p.TagFileName, 'eTags')
        bName = tempname;
        warning('tagEEGDir:invalidFile', ...
            ['Couldn''t save eventTags to ' p.TagFileName]);
        eventTags.saveTagFile(bName, 'eTags')
    else 
        bName = p.TagFileName;
    end
 

    if isempty(fPaths) || strcmpi(p.UpdateType, 'NoUpdate')
        return;
    end
    % Rewrite all of the EEG files with updated tag information
    for k = 1:length(fPaths) % Assemble the list
        teeg = pop_loadset(fPaths{k});
        teeg = tagEEG(teeg, 'BaseTagsFile', bName, ...
              'UpdateType', p.UpdateType, 'UseGUI', false);
        pop_saveset(teeg, 'filename', fPaths{k});
    end
end % tagEEGDir