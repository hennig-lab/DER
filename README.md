# DER algorithm
Duplicate Event Removal algorithm - Artifact detection in human single unit recordings 

Version 1.1, released October 2025 by Jay Hennig.

This version extends the original codepack to support Blackrock input data.
This project continues to be licensed under the terms of the Mozilla Public License Version 2.0 (MPL 2.0). See the LICENSE for details.

Original code (Version 1.0, released February 2021): Copyright © 2021.
Gert Dehnen, Marcel S. Kehl, Florian Mormann, and the University of Bonn Medical Center
This software was tested with MATLAB (R2018a–R2024b) on Linux, Windows, and macOS.

------------------------------------------------------------------------------------------
The DER algorithm was written in MATLAB2018a. 
To run the code the following MATLAB packages are required:  

* *Statistics and Machine Learning Toolbox*
* *Wavelet Toolbox*  


## How to use the code 

Download the source code from this repository and add it to your MATLAB path. 
To run the automated artefact detection you need to execute `DER.m` in MATLAB.  
For Neuralynx data, please provide the data path and define the spike-sorting algorithm used (*'Wave_clus'* or *'Combinato'*) as:  

```
DER(data_path,'Combinato')
```  
Note that this will remove identified artifactual spikes from the original data.

Or if using Blackrock data:
```
fileInfo = der_get_blackrock_fileInfo(data_path);
DER(data_path, 'Wave_clus', false, 'blackrock', fileInfo);
```
Note that this will add a `detectionLabel` field to the original `*times*.mat` files, but will not remove any artifactual spikes from the original data.

## Structure of the code

The detection pipeline is structured in three parts: 

* Part I - Detection of artifacts within different wire bundles  
The detection of artifacts across different bundles is done by `der_detectArtifacts.m`.  

* Part II - Detection of spikes within channels of same wire bundle  
The detection of artifacts within bundles is done by `der_detectDuplicateSpikes.m`.  

* Part III - Detection of suspicious cross-correlations  
Calculation of all cross-correlations is performed by `der_cal_spike_cross_corr_mat.m`.
Spike events in suspicious central bins of the cross-correlograms are identified by `der_detect_cross_corr_spikes.m`.

### Data structures

Within this pipeline the data structure needed for detection is created by `der_get_spikeInfos.m`.
This script generates a MATLAB table containing all required information on the recorded spike events.
These structure includes the timestamp and the waveform of the spike event (64 data points). 
Additionally, information on the recorded clusters (cluster ID, unit class, channel number, detection threshold, wire bundle ID, anatomical region) as well as a detection label is stored. 

The DER alogorithm is currently compatible with the output structures of *Combinato Spike Sorting* and *Wave_clus*.
In order to apply the algorithm to other spike sorting algorithms you can easily adjust `der_get_spikeInfos.m` 
and `der_save_spikeinfos.m` to your data structure. 

Detected spike events are labeled individually for each part of the detection pipeline using prime factor labels.
The detection label is given by the procuct of the following prime factors:

Factor | Part detected
:---|:---
2   | across bundles (Part I)
3   | within the same channel (Part II)  
5   | within the same bundle (but different channel) (Part II)  
7   | based on the cross-correlograms (Part III)

## References

Cite as: 

Dehnen, G.; Kehl, M.S.; Darcher, A.; Müller, T.T.; Macke, J.H.; Borger, V.; Surges, R.; Mormann, F. Duplicate Detection of Spike Events: A Relevant Problem in Human Single-Unit Recordings. Brain Sci. 2021, 11, 761. https://doi.org/10.3390/brainsci11060761

