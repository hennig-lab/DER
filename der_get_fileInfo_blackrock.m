function fileInfo = der_get_fileInfo_blackrock(directory)
% function fileInfo = der_get_fileInfo_blackrock(directory)
%  Get file information for Blackrock data in the specified directory.
%  The function looks for files named 'times_*.mat' and extracts
%  relevant information such as channel name, channel number, bundle number,
%  and threshold from associated spike files.
% 
%  Note that this function assumes times files are named in the format:
% 'times_<channel_name>_<channel_number>.mat'
%     where <channel_name> = <bundle_name><2-digit microwire_number>
%     e.g. 'mRT2cHb01_2325' where '01' is the microwire number
%       and 'mRT2cHb' is the bundle name
%
%  Input:
%    directory - path to the directory containing the Blackrock data files
%  Output:
%    fileInfo - struct array with fields:
%       timesfile - full path to the times file
%       threshold - threshold value from the associated spikes file
%       channel_name - name of the channel
%       channel - channel number
%       bundle - bundle number

    fldrs = dir(fullfile(directory, 'times_*.mat'));
    fileInfo = [];
    bundleNames = {};
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
            'channel_name', '', 'channel', 0, 'bundle', 0, ...
            'bundle_name', '');
        curFileInfo.timesfile = fullfile(fldrs(chan).folder, fileName);
        curFileInfo.threshold = threshold;
        curFileInfo.channel_name = channel_name; % e.g. mRT2cHb01_2325
        curFileInfo.bundle_name = fileNameParts{1}(1:end-2);
        curFileInfo.channel = str2double(fileNameParts{2}); % e.g. 2325

        % set bundle number as index of name in bundleNames
        if ~ismember(curFileInfo.bundle_name, bundleNames)
            bundleNames = [bundleNames curFileInfo.bundle_name];
        end
        curFileInfo.bundle = find(ismember(bundleNames, curFileInfo.bundle_name));

        fileInfo = [fileInfo curFileInfo];
    end
end
