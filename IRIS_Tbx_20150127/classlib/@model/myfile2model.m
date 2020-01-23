function [This,Asgn] = myfile2model(This,FName,Opt)
% myfile2model  [Not a public function] Translate model file to model object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Preparse the model file.
p = preparser(FName,[],Opt);

% Get and save carry-on files. They must be available before we run `parse`
% because we check for syntax error by evaluating the equations.
This.FName = p.FName;
This.Export = p.Export;
export(This);

% Parse the model code proper.
[This,Asgn] = myparse(This,p,Opt);
This.Comment = p.Comment;

% Mark the build.
This.Build = irisversion();

end
