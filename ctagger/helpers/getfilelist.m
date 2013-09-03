% getfilelist
% Gets a list of the files in a directory tree
%
% Parameters:
%    inDir        Root directory of tree
%    fileExt      Optional string containing file extension (e.g., '.set')
%    doSubDirs    Optional logical indicating whether to traverse
%                 subdirectories - true (default) - recurse subdirectories
%    fpaths       (output) Full pathnames of the files in this directory
%
function fPaths = getfilelist(inDir, fileExt, doSubDirs)
fPaths = {};
directories = {inDir};
while ~isempty(directories)
    nextDir = directories{end};
    files = dir(nextDir);
    fileNames = {files.name}';
    fileDirs = cell2mat({files.isdir}');
    compareIndex = ~strcmp(fileNames, '.') & ~strcmp(fileNames, '..');
    subDirs = strcat([nextDir filesep], fileNames(compareIndex & fileDirs));
    fileNames = fileNames(compareIndex & ~fileDirs);
    if nargin > 1 && ~isempty(fileExt) && ~isempty(fileNames);
        fileNames = processExts(fileNames, fileExt);
    end
    fileNames = strcat([nextDir filesep], fileNames);
    directories = [directories(1:end-1); subDirs(:)];
    fPaths = [fPaths(:); fileNames(:)];
    if nargin > 2 && ~doSubDirs
        break;
    end
end
end % getFileList

function fileNames = processExts(fileNames, fileExt)
% Return a cell array of file names with the specified file extension
fExts = cell(length(fileNames), 1);
for k = 1:length(fileNames)
    [x, y, fExts{k}] = fileparts(fileNames{k}); %#ok<ASGLU>
end
matches = strcmp(fExts, fileExt);
fileNames = fileNames(matches);
end % processExts
