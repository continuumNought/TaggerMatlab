function eTags = getEEGGroupEventTags(fPaths)
    % Assemble EEG files and extract a summary eventTags object
    eTags = eventTags('', '');
    for k = 1:length(fPaths) % Assemble the list
        eegTemp = pop_loadset(fPaths{k});
        eTagsNew = getEEGEventTags(eegTemp);
        eTags.mergeEventTags(eTagsNew, 'Merge');
    end
end % getEEGGroupEventTags