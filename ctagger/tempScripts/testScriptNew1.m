%%
load EEGEpoch.mat;

%%
EEG = cTagger.tagEEG(EEG, '', true);

%%
eTags1 = ctagger.getEEGEventTags(EEG1);
EEG2 = cTagger.tagEEG(EEG2, eTags1, false);