function [eTags, fPaths] = getEEGDirEventTags(inDir, varargin)
    % Assemble EEG files and extract a summary eventTags object
    p = inputParser;
    p.addRequired('InDir', @(x) (~isempty(x) && ischar(x)));
    p.addParamValue('DoSubDirs', true, @islogical);
    p.parse(inDir, varargin{:});        
    fPaths = getFileList(p.Results.InDir, '.set', p.Results.DoSubDirs);
    eTags = eventTags('', '');
    if isempty(fPaths)
        return;
    end
    for k = 1:length(fPaths) % Assemble the list
        EEG = pop_loadset(fPaths{k});
        eTagsNew = getEEGEventTags(EEG);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
end % tagEEGDir