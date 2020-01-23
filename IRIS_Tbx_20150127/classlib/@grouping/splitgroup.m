function This = splitgroup(This,varargin)
% splitgroup  Split group into its components in grouping object.
%
% Syntax
% =======
%
%     G = splitgroup(G,GroupName1,GroupName2,...)
%
% Input arguments
% ================
%
% * `G` [ grouping ] - Grouping object.
%
% * `GroupName1`,`GroupName2`,... [ char ] - Group names.
%
% Output arguments
% =================
%
% * `G` [ grouping ] - Grouping object.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

GroupName = varargin;

pp = inputParser();
pp.addRequired('G',@(x) isa(x,'grouping'));
pp.addRequired('GroupName',@iscellstr);
pp.parse(This,GroupName);

%--------------------------------------------------------------------------

for iGroup = 1:numel(GroupName)
    ind = strcmpi(This.groupNames,GroupName{iGroup}) ;
    if any(ind)
        % Group exists, split
        split = This.groupContents{ind} ;
        This = rmgroup(This,GroupName{iGroup}) ;
    elseif strcmpi(This.otherName,GroupName{iGroup})
        % Split apart 'Other' group
        split = This.otherContents ;
    else
        % Group does not exist, cannot remove
        utils.error('grouping', ...
            'Group does not exist and cannot be split: %s', ...
            GroupName{iGroup}) ;
    end
    
    for iSplit = find(split(:).')
        This = addgroup(This,This.descript{iSplit},This.list{iSplit}) ;
    end
end

end


