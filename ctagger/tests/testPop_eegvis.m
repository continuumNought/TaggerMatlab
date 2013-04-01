function test_suite = testPop_eegvis %#ok<STOUT>
% Unit tests for pop_eegvis
initTestSuite;

function values = setup %#ok<DEFNU>
values.deleteFigures = true;

function teardown(values) %#ok<INUSD,DEFNU>
% Function executed after each test

function  testNormalConstructor(values) %#ok<DEFNU>
% Unit test for pop_eegvis constructor
fprintf('\nUnit tests for pop_eegvis valid constructor\n');

fprintf('It creates a valid visualization when passed an EEG structure\n');

p = which('eeglab.m');
a = strfind(p, 'eeglab.m');
p = [p(1:a-2) filesep 'sample_data'];
dfile = 'eeglab_data.set';
EEG = pop_loadset('filename', dfile, 'filepath', p);
EEGOUT = pop_eegvis(EEG);
assertEqual(EEG, EEGOUT);

if values.deleteFigures
    h = findobj('Parent', 0, '-and', 'Tag', 'EEGLAB:DualVisPlotMenu');
    if ~isempty(h) && ishandle(h)
        delete(h);
    end
end



