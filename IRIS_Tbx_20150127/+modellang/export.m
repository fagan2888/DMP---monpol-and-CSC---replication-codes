% !export  Create a carry-around file to be saved on the disk.
%
% Syntax
% =======
%
%     !export(FileName)
%         FileContents
%     !end
%
% Description
% ============
%
% You can include in the model file the contents of files you need or want
% to carry around together with the model; a typical example is your own
% m-file functions used in the model equations.
%
% The file or files are created and save under the name specified in the
% `!export` keyword at the time you load the model using the function
% [`model`](model/model). The contents of the export files is are also
% stored in the model objects. You can manually re-create and re-save the
% files by running the function [`export`](model/export).
%
% If no filename is provided or `FileName` is empty, the corresponding
% `!export` block is discarded with no error or warning.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.
