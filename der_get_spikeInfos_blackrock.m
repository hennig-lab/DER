function [spikeInfos] = der_get_spikeInfos_blackrock(clusterAlgorithm, fileInfo)
%get_spikeInfos
%   get_spikeInfos collects list of region, bundleID, channelID, threshold,
%   clusterID, unitClass, spike-times and spike-shapes for each spike in a 
%   session. Adjusted to data structure from Blackrock
%
%
%   Input:
%   clusterAlgorithm: define the cluster-algorithm with that the data are 
%       preprocessed; Combinato, Wave_clus
%   fileInfo: struct array containing information about each channel:
%    - channel = channel number
%    - channel_name = name of the channel
%    - timesfile = path to the times.mat file for the channel
%    - spikesfile = path to the spikes.mat file for the channel
%    - bundle = bundle number the channel belongs to
%
%   Output: spikeInfos (table) containing the following information for each
%   spike:
%   region: hemisphere and region of each channel
%   bundleID: number of bundle
%   channelID: number of channel
%   threshold: threshold for spike-detection in µV
%   clusterID: number of cluster of current channel
%   unitClass: classification of unit in SU (single-), MU (multi-unit) or A
%       (artifact)
%   index_TS: time of amplitude of a spike in milliseconds
%   SpikeShapes: shape of spike (in our setup using combinato: 64 samples)
%
%
%   Licence:
%   This source code form is subject to the terms of the Mozilla Public
%   Licence, v. 2.0. if a copy of the MPL was not distributed with this file,
%   you can optain one at http://mozilla.org/MPL/2.0/.
dbstop if error
if ~exist('clusterAlgorithm','var')
    error('not enough input argumemts: "clusterAlgorithm" is missing');
end

% get all spikeshapes, peaktimes and indices of bundle
region = [];
bundleID = [];
channelID = [];
threshold = [];
clusterID = [];
unitClass = [];
timeStamps = [];
SpikeShapes = [];

% sort fileInfo by channel number
[~, idx] = sort([fileInfo.channel]);
fileInfo = fileInfo(idx);

disp('DER Version 1.0: using WaveClus will only separate into multi-units and artifacts');

% loop over channels
for chan = 1:numel(fileInfo)
    chanId = fileInfo(chan).channel;
    chanName = fileInfo(chan).channel_name;
    timesfile = fileInfo(chan).timesfile;
    spikefile = fileInfo(chan).spikesfile;
    currBundle = fileInfo(chan).bundle;

    if exist(timesfile,'file')
        load(timesfile, 'cluster_class', 'spikes')
        timeStamps = [timeStamps; cluster_class(:,2)]; % time-stamp of spike event amplitude (sample 20)
        SpikeShapes = [SpikeShapes; spikes]; % shape of individual spike events
        channelID = [channelID; ones(size(cluster_class,1),1) + chanId]; % channel number of each individual spike event
        bundleID = [bundleID; zeros(size(cluster_class,1),1) + currBundle]; % bundle number of each individual spike event
        clusterID = [clusterID; cluster_class(:,1)]; % cluster number of each individual spike event

        currChnname = cell(size(spikes,1),1);
        currChnname(:) = {chanName};
        region = [region; currChnname];

        % get unit-class for each spike
        spikeinfo = load(spikefile,'threshold');
        currThreshold = nanmedian(spikeinfo.threshold);
        currUnitID = unique(cluster_class(:,1));

        threshold = [threshold; zeros(size(cluster_class,1),1) + currThreshold];
        currUnitClasses = cell(size(cluster_class,1),1);
        for uc = 1:length(currUnitID)
            index_currUC = cluster_class(:,1) == uc;
            currUnitClasses(index_currUC) = {'MU'};
        end
        unitClass = [unitClass; currUnitClasses];

        % set unitClass for artifacts
        unclassified = cellfun(@isempty,unitClass,'Uniformoutput', false);
        index_unclassi = cell2mat(unclassified);
        unitClass(index_unclassi) = {'A'};

    end
end

detectionLabel = ones(size(timeStamps,1),1);
spikeInfos = table(region, bundleID, channelID, clusterID, unitClass, threshold, timeStamps, SpikeShapes, detectionLabel);
[~, idxsort] = sort(spikeInfos.timeStamps);
spikeInfos = spikeInfos(idxsort,:);

end

