function der_save_spikeTimes_blackrock(spikeInfos, fileInfo)
    for ii = 1:numel(fileInfo)
        d = load(fileInfo(ii).timesfile);
        sps = spikeInfos(fileInfo(ii).channel == spikeInfos.channelID,:);
        if size(sps,1) ~= size(d.spikes,1)
            error(['Internal error: timesfile "' fileInfo(ii).timesfile ...
                '" does not have same number of spikes as spikeInfos']);
        end
        if ~isequal(sps.timeStamps, d.cluster_class(:,2))
            error(['Internal error: timesfile "' fileInfo(ii).timesfile ...
                '" does not have same spike times as spikeInfos']);
        end
        d.detectionLabel = sps.detectionLabel;
        save(fileInfo(ii).timesfile, '-struct', 'd');
    end
end