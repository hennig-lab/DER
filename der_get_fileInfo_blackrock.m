function fileInfo = der_get_fileInfo_blackrock(directory)
% function fileInfo = der_get_fileInfo_blackrock(directory)
%  Get file information for Blackrock data in the specified directory.
%  The function looks for files named 'times_*.mat' and extracts
%  relevant information such as channel name, channel number, bundle number,
%  and threshold from associated spike files.
% 
%  Note that this function assumes times files are named in the format:
% 'times_<channel_name>_<channel_number>.mat'
%     where <channel_name> includes the bundle number as the last two digits
%     e.g. 'mRT2cHb01_2325' where '01' is the bundle number and '2325' is the channel number.
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
