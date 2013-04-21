function eTags = geteegtags(EEG, varargin)
    % Return an eventTags object for the EEG structure

    parser = inputParser;
    parser.addRequired('EEG', @(x) (isempty(x) || ...
        isstruct(EEG) || isfield(EEG, 'event') || ...
        isstruct(EEG.event) || isfield(EEG.event, 'type') || ...
        isfield(EEG, 'urevent') || isstruct(EEG.urevent) && ...
        isfield(EEG.urevent, 'type')));
    parser.addParamValue('Match', 'code', ...
        @(x) (~isempty(x) && ischar(x) && ...
        sum(strcmpi(x, {'code', 'label', 'both'})) == 1));
    parser.addParamValue('PreservePrefix', false, ...
        @(x) validateattributes(x, {'logical'}, {}));
    parser.parse(EEG, varargin{:});
    p = parser.Results;
    % Check for EEG validity and return empty structure if not valid

    if ~isfield(EEG, 'etc')
        EEG.etc = struct('eventTags', '');
    elseif ~isstruct(EEG.etc)
        EEG.etc = struct('other', EEG.etc, 'eventTags', '');
    elseif ~isfield(EEG.etc, 'eventTags')
        EEG.etc.eventTags = '';
    end
    [hed, events] = eventTags.split(EEG.etc.eventTags, true);
    eTags = eventTags(hed, events, 'Match', p.Match, ...
                      'PreservePrefix', p.PreservePrefix);
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
end %geteegtags