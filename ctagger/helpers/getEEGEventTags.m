function eTags = getEEGEventTags(EEG)
    % Return and eventTags object for the EEG structure

    % Check for EEG validity and return empty structure if not valid
    if isempty(EEG) || ~isstruct(EEG) || ~isfield(EEG, 'event') || ...
            ~isstruct(EEG.event) || ~isfield(EEG.event, 'type') || ...
            ~isfield(EEG, 'urevent') || ~isstruct(EEG.urevent) && ...
            ~isfield(EEG.urevent, 'type')
        eTags = eventTags('', '');  % Start with an empty object
        return;
    elseif ~isfield(EEG, 'etc')
        EEG.etc = struct('eventTags', '');
    elseif ~isstruct(EEG.etc)
        EEG.etc = struct('other', EEG.etc, 'eventTags', '');
    elseif ~isfield(EEG.etc, 'eventTags')
        EEG.etc.eventTags = '';
    end
    [hed, events] = eventTags.split(EEG.etc.eventTags, true);
    eTags = eventTags(hed, events);
    typesE =  unique(cellfun(@num2str, {EEG.event.type}, 'UniformOutput', false));
    typesURE =  unique(cellfun(@num2str, {EEG.urevent.type}, 'UniformOutput', false));
    types = union(typesE, typesURE);
    if isempty(types)
        return;
    end

    events = struct('code', types, 'label', types, ...
        'description', '', 'tags', '');
    for k = 1:length(events)
        eTags.addEvent(events(k), 'Merge');
    end
end %getEEGEvents