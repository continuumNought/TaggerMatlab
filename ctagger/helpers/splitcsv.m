% splitcsv
% Return a cell array of cell strings from parsing a csv file
%
% Usage:
%   >>  values = splitcsv(filename)
%
% Description:
% values = splitcsv(filename) opens and reads the csv file specified by
% filename and returns the individual lines of the file as elements of the
% values cell array. Each element of values is a cellstr array giving the
% individual comma-separated tokens. If the file doesn't exist or there is
% an error, values is an empty cell array.
%
function values = splitcsv(filename)
    fid = '';
    try 
        values = {};
        fid = fopen(filename);
        lineNum = 0;
        tline = fgetl(fid);
        while ischar(tline)   
            lineNum = lineNum + 1;
            values{lineNum} = strtrim(regexp(tline, ',', 'split')); %#ok<AGROW>
            tline = fgetl(fid);
        end   
    catch ME %#ok<NASGU>
        values = {};
    end 
    
    try % Attempt to close the file regardless of errors
        fclose(fid);
    catch ME %#ok<NASGU>
    end
end % splitcsv