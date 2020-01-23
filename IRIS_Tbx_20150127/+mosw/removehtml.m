function Msg = removehtml(Msg)
% removehtml [Not a public function] Remove HTML tags from message before printing.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

Msg = regexprep(Msg,'<a[^<]*>','');
Msg = strrep(Msg,'</a>','');

end
