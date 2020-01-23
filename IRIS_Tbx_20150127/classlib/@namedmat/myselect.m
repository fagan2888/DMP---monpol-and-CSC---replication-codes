function [X,Pos] = myselect(X,RowNames,ColNames,varargin)
% myselect  [Not a public function] Implementation of namedmat selection.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

RowSel = varargin{1};
varargin(1) = [];

isColSelect = ~isempty(varargin);
if isColSelect
    ColSel = varargin{1};
    varargin(1) = []; %#ok<NASGU>
else
    ColSel = RowSel;
end

if ischar(RowSel)
    RowSel = regexp(RowSel,'[\w\{\}\(\)\+\-]+','match');
end

if ischar(ColSel)
    ColSel = regexp(ColSel,'[\w\{\}\(\)\+\-]+','match');
end

usrRowSelect = RowSel;
usrColSelect = ColSel;

%--------------------------------------------------------------------------

removeLogFunc = @(x) regexprep(strtrim(x),'log\((.*?)\)','$1','once');
RowSel = removeLogFunc(RowSel(:).');
ColSel = removeLogFunc(ColSel(:).');
RowNames = removeLogFunc(RowNames(:).');
ColNames = removeLogFunc(ColNames(:).');


rowPos = nan(size(RowSel));
colPos = nan(size(ColSel));

% Match row and columns selections against row and columns names.
for i = 1 : length(RowSel)
    pos = find(strcmp(RowNames,RowSel{i}),1);
    if ~isempty(pos)
        rowPos(i) = pos;
    end
end
for i = 1 : length(ColSel)
    pos = find(strcmp(ColNames,ColSel{i}),1);
    if ~isempty(pos)
        colPos(i) = pos;
    end
end

% Check for not-found positions.
ixNanRow = isnan(rowPos);
ixNanCol = isnan(colPos);
doChkNotFound();
rowPos(ixNanRow) = [];
colPos(ixNanCol) = [];
nRowSel = length(rowPos);
nColSel = length(colPos);

X = double(X);
s = size(X);
X = X(:,:,:);
X = X(rowPos,colPos,:);
if length(s) > 2
    X = reshape(X,[nRowSel,nColSel,s(3:end)]);
end
Pos = {rowPos,colPos};


% Nested functions...


%**************************************************************************

    
    function doChkNotFound()
        msg = {};
        if isColSelect
            % Row and column selections entered separately.
            if ~any(ixNanRow) && ~any(ixNanCol)
                return
            end
            for ii = find(ixNanRow)
                msg{end+1} = 'row'; %#ok<AGROW>
                msg{end+1} = usrRowSelect{ii}; %#ok<AGROW>
            end
            for ii = find(ixNanCol)
                msg{end+1} = 'column'; %#ok<AGROW>
                msg{end+1} = usrColSelect{ii}; %#ok<AGROW>
            end
        else
            % Row and column selections entered as one list.
            ixNan = ixNanRow & ixNanCol;
            if ~any(ixNan)
                return
            end
            for ii = find(ixNan)
                msg{end+1} = 'row or column'; %#ok<AGROW>
                msg{end+1} = usrRowSelect{ii}; %#ok<AGROW>
            end
        end
        utils.error('namedmat:myselect', ...
            'This is not a valid %s name: ''%s''.', ...
            msg{:});
    end % doChkNotFound()


end
