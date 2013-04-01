classdef tagGroups
    properties (Constant = true)
        DefaultHED = 'HED Specification 1.3.xml';
        DefaultSchema = 'HEDSchema.xsd';
    end % constant
    
    properties (Access = private)
        HedSchema            % String containing the XML Hed schema
        HedXML               % HED hierarchy as an XML string
        Match                % String 'label', 'code', or 'both' (default 'code')
        PreservePrefix       % If true, don't eliminate duplicate prefixes (default false)
        TagMap               % Map for matching event codes
    end % private properties
    
    methods
        function obj = tagGroups(hedString, events, varargin)
            % Constructor parses parameters and sets up initial data
            if isempty(varargin)
                obj.parseParameters(hedString, events);
            else
                obj.parseParameters(hedString, events, varargin{:});
            end
        end % tagGroups constructor
        
    end %public methods
        methods(Access = private)
        
        function parseParameters(obj, hedString, events, varargin)
            % Parse parameters provided by user in constructor
            parser = eventTags.getParser();
            parser.parse(hedString, events, varargin{:})
            pdata = parser.Results;
            obj.Match = pdata.Match;
            obj.PreservePrefix = pdata.PreservePrefix;
            obj.reset(pdata.HedString, pdata.Events)
        end % parseParameters
        
 
    end % private methods
end

