function varargout = irisconfigmaster(varargin)
% irisconfigmaster  [Not a public function ] The IRIS Toolbox master configuration file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

persistent CONFIG;

if isempty(varargin) || isempty(CONFIG)
    CONFIG = irisconfig();
    mlock();
end

try
    Req = varargin{1};
    varargin(1) = [];
catch
    return
end

%--------------------------------------------------------------------------

switch Req
    
    case 'get'
        if nargin == 1
            varargout{1} = CONFIG;
        else
            notFound = {};
            n = length(varargin);
            varargout = cell(1,n);
            for i = 1 : n
                try
                    name = lower(varargin{i});
                    varargout{i} = CONFIG.(name);
                catch %#ok<CTCH>
                    notFound{end+1} = varargin{i}; %#ok<AGROW>
                    varargout{i} = NaN;
                end
            end
            if ~isempty(notFound)
                utils.warning('config:irisconfigmaster',...
                    'This is not a valid IRIS config option: ''%s''.',...
                    notFound{:});
            end
        end
        
    case 'set'
        invalid = {};
        unable = {};
        for i = 1 : 2 : nargin-1
            name = lower(varargin{i});
            if any(strcmp(name,CONFIG.protected))
                unable{end+1} = varargin{i}; %#ok<AGROW>
            elseif isfield(CONFIG,name)
                value = varargin{i+1};
                if isfield(CONFIG.validate,name) ...
                        && ~CONFIG.validate.(name)(CONFIG.(name))
                    invalid{end+1} = name; %#ok<AGROW>
                else
                    CONFIG.(name) = value;
                end
            end
        end
        if ~isempty(unable)
            utils.warning('config:irisconfigmaster', ...
                ['This IRIS config option is not customisable ', ...
                'and its value has not been changed: ''%s''.'], ...
                unable{:});
        end
        if ~isempty(invalid)
            utils.warning('config:irisconfigmaster', ...
                ['The value supplied for this IRIS config option is invalid ', ...
                'and has not been assigned: ''%s''.'], ...
                invalid{:});
        end
        
    case 'reset'
        CONFIG = irisconfig();
    
    otherwise
        utils.error('config:irisconfigmaster',...
            'Incorrect type or number of input or output arguments.');

end

end
