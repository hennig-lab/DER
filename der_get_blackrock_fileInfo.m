function fileInfo = der_get_blackrock_fileInfo(directory)
    
    fldrs = dir(fullfile(directory, 'times_*.mat'));
    fileInfo = [];
    for chan = 1:numel(fldrs)
        fileName = fldrs(chan).name; % e.g. 'times_mRT2cHb01_2325.mat'
        channel_name = strrep(strrep(fileName, '.mat', ''), ...
            'times_', ''); % e.g. 'mRT2cHb01_2325'

        % get threshold
        spikesfile = fullfile(fldrs(chan).folder, ...
            [channel_name '_spikes.mat']);
        if exist(spikesfile, 'file')
            spikeinfo = load(spikesfile, 'threshold');
            threshold = nanmedian(spikeinfo.threshold);
        else
            threshold = nan;
        end

        fileNameParts = strsplit(channel_name, '_');
        curFileInfo = struct('timesfile', '', 'threshold', threshold, ...
            'channel_name', '', 'channel', 0, 'bundle', 0);
        curFileInfo.timesfile = fullfile(fldrs(chan).folder, fileName);
        curFileInfo.threshold = threshold;
        curFileInfo.channel_name = channel_name; % e.g. mRT2cHb01_2325
        curFileInfo.channel = str2double(fileNameParts{2}); % e.g. 2325
        curFileInfo.bundle = str2double(fileNameParts{1}(end-1:end)); % e.g. 1
        fileInfo = [fileInfo curFileInfo];
    end

end
