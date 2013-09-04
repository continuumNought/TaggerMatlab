function filewrite(tMap, filename)
fid = fopen(filename,'w');
numValues = length(tMap.values);
for a = 1: numValues
    tags = tMap.values(a).tags;
    numTags = length(tags);
    if numTags > 0
        for b = 1: numTags
            fprintf(fid, '%s,', tags{1,b});
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);
end