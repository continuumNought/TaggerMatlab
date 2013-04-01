function test_suite = testEegplugin_eegvis %#ok<STOUT>
% Unit tests for eegplugin_eegvis
initTestSuite;

function testEegplugin_eegvisNormalConstructor %#ok<DEFNU>
% Unit test for normal eegplugin_eegvis constructor
fprintf('\nUnit tests for eegplugin_eegvis valid constructor\n');

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab; %#ok<NASGU,ASGLU>
eeglabfig = gcf;
delete(eeglabfig);

