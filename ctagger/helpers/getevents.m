function [keys, headers, descriptions] = getevents(filename, varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    parser = inputParser;
    parser.addRequired('FileName', @(x) (~isempty(x) && ischar(x)));
    parser.addParamValue('EventColumns', [], ...
        @(x)(isnumeric(x) && (isscalar(x) || isvector(x))));
    parser.addParamValue('DescriptionColumn', 0, ...
        @(x)(isnumeric(x) && isscalar(x)));
    parser.parse(filename, varargin{:});
    p = parser.Results;
   
    descriptions = {};
    values = linesplit(p.FileName);

    headers = values{1};
    keys = cell(length(values) - 1, 1);
    descriptions = cell(length(values) - 1, 1);
    for k = 2:length(values);
        [keys{k-1}, descriptions{k-1}] = makekey(values{k});
    end
    for k = 1:length(headers)   
        fprintf('k=%d, header= %s\n', k, length(headers{k}));
    end
    for k = 1:length(keys)
        fprintf('k=%d, key= %s\n', k, keys{k});
    end
%     header = linesplit(fid);
%     if isempty(header)
%         return;
%     elseif isempty(p.EventColumns)
%         eColumns = 1:length(header);
%     end
%     keys
% 
% fclose(fid);

end

function values = linesplit(filename)
    values = {};
    fid = fopen(filename);
    lineNum = 0;
    tline = fgetl(fid);
    while ischar(tline)
        fprintf('tline=%s\n', tline);
        lineNum = lineNum + 1;
        values{lineNum} = strtrim(regexp(tline, ',', 'split')); %#ok<AGROW>
        tline = fgetl(fid);
    end
    fclose(fid);
end % linesplit  

function [key, description] = makekey(value)
   key = value{1};
   description = '';
   for j = 2:length(value)
       key = [key ',' value{j}]; %#ok<AGROW>
   end
end % makekey

