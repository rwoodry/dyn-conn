theFiles=dir(fullfile(pwd(), 'array3d_15roiroi_100parcels_subsub033*'));
n_ROIs = 15;
array3dEx = zeros(n_ROIs, n_ROIs, 28);

theFiles = theFiles([15:28, 1:14]);

for i=1:length(theFiles)
  baseFileName = theFiles(i).name;
  fullFileName = fullfile(pwd(), baseFileName);
  array3dEx(:,:,i) = table2array(readtable(fullFileName));
end

cseq = arrayToContactSeq(array3dEx, false);

plotDNarc(cseq)