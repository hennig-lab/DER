function filenames = der_get_filenames_neuralynx(directory, nr_chBundle)
    if nargin < 1
        directory = pwd;
    end
    if nargin < 2
        nr_chBundle = 8;
    end

    % get list of bundle per channel
    NCSFiles = struct2table(dir(fullfile(directory, '*.ncs')));
    no_channels = size(NCSFiles,1);
    if no_channels == 0
        error('No .ncs files found in current directory.');
    end

    chnname = cell(no_channels,1);
    channels = nan(no_channels,1);

    channel_info = [];
    for chan = 1:no_channels
        % get header infos of current channel
        currFile = NCSFiles.name{chan};
        channels(chan) = str2double(currFile(isstrprop(currFile,'digit')));

        fileID = fopen(currFile);
        header = textscan(fileID,'%s',55);
        header = header{1};
        fclose(fileID);
        channel_name = header{find(strcmp('-AcqEntName',header))+1};

        bundle_no = str2double(channel_name(end));
        cur_channel = struct('channel', channels(chan), 'chnname', channel_name, 'bundle', bundle_no);
        channel_info = [channel_info; cur_channel];
    end

    % sort channel info by channel number
    [~, idx] = sort([channel_info.channel]);
    channel_info = channel_info(idx);

    % get bundle identity
    chnno = [channel_info.bundle];
    index_lastChPBd = find(chnno == nr_chBundle);

    index_bundle = ones(no_channels,1);
    currBundle = 1;
    index_firstCh = 1;
    for bndl = 1:length(index_lastChPBd)

        index_lastCh = index_lastChPBd(bndl);
        index_bundle(index_firstCh:index_lastCh) = currBundle;
        currBundle = currBundle + 1;
        index_firstCh = index_lastCh + 1;

    end   

end
