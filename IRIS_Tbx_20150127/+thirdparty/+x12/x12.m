function [Y,varargout] = x12(X,StartDate,Dummy,Opt)
% x12  [Not a public function] Matlab interface for X13-ARIMA-Seats.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2015 IRIS Solutions Team.

switch lower(Opt.mode)
    case {0,'mult','m'}
        Opt.mode = 'mult';
    case {1,'add','a'}
        Opt.mode = 'add';
    case {2,'pseudo','pseudoadd','p'}
        Opt.mode = 'pseudoadd';
    case {3,'log','logadd','l'}
        Opt.mode = 'logadd';
    otherwise
        Opt.mode = 'auto';
end

if ischar(Opt.output)
    Opt.output = {Opt.output};
elseif ~iscellstr(Opt.output)
    Opt.output = {'d11'};
end
nOutp = length(Opt.output);

% Get the entire path to this file.
thisDir = fileparts(mfilename('fullpath'));

if strcmpi(Opt.specfile,'default')
    Opt.specfile = fullfile(thisDir,'default.spc');
end

%--------------------------------------------------------------------------

kb = Opt.backcast;
kf = Opt.forecast;
nPer = size(X,1);
nx = size(X,2);

% Output data.
[varargout{1:nOutp}] = deal(nan(nPer,nx));
% Output file(s).
varargout{nOutp+1}(1:nx) = {''};
% Error file(s).
varargout{nOutp+2}(1:nx) = {''};

freq = datfreq(StartDate);
if isnan(freq)
    utils.warning('x12', ...
        'Input tseries is empty, cannot run X12.');    
    return
elseif freq ~= 4 && freq ~= 12
    utils.warning('x12', ...
        'X12 runs only on quarterly or monthly data.');
    return
end

tempDir = Opt.tempdir;
isNewTempDir = false;
doTempDir();

is3YearsWarn = false;
is70YearsWarn = false;
is15YearsBcastWarn = false;
isNanWarn = false;
Mdl = struct('mode',NaN,'spec',[],'ar',[],'ma',[]);
Mdl = Mdl(ones(1,nx));
Outp = cell(1,nx);
Err = cell(1,nx);
Y = nan(nPer+kb+kf,nx);
for i = 1 : nx
    tmpTitle = tempname(tempDir);
    first = find(~isnan(X(:,i)),1);
    last = find(~isnan(X(:,i)),1,'last');
    data = X(first:last,i);
    iErrMsg = '';
    if length(data) < 3*freq
        is3YearsWarn = true;
    elseif length(data) > 70*freq
        is70YearsWarn = true;
    elseif ~Opt.missing && any(isnan(data))
        isNanWarn = true;
    else
        if length(data) > 15*freq && kb > 0
            is15YearsBcastWarn = true;
        end
        offset = first - 1;
        [aux,fcast,bcast,ok] = ...
            xxRunX12(thisDir,tmpTitle,data,StartDate+offset,Dummy,Opt);
        for j = 1 : nOutp
            varargout{j}(first:last,i) = aux(:,j);
        end
        % Append forecasts and backcasts to original data.
        Y(first:last+kb+kf,i) = [bcast;data;fcast];
        % Catch output file.
        if exist([tmpTitle,'.out'],'file')
            Outp{i} = xxReadOutpFile([tmpTitle,'.out']);
        end
        % Catch error file.
        if exist([tmpTitle,'.err'],'file')
            Err{i} = xxReadOutpFile([tmpTitle,'.err']);
            iErrMsg = regexp(Err{i},'(?<=ERROR:).*','match','once');
            iErrMsg = regexprep(iErrMsg,'[\r\n]+','\n');
            iErrMsg = regexprep(iErrMsg,'[ \t]+',' ');
            iErrMsg = regexprep(iErrMsg,'\n[ \t\n]+','\n');
        end
        % Catch ARIMA model specification.
        if exist([tmpTitle,'.mdl'],'file')
            Mdl(i) = xxReadModel([tmpTitle,'.mdl'],Outp{i});
        end
        % Delete all X12 files.
        if ~isempty(Opt.saveas)
            doSaveAs();
        end
        if Opt.cleanup
            delete([tmpTitle,'.*']);
            if ismac() && exist('fort.6','file')
                delete('fort.6');
            end
        end
        if ~ok
            utils.warning('x12:x12', ...
                ['Unable to read at least on the X13 output file(s). ', ...
                'The most likely cause is ', ...
                'that X13 failed to estimate an appropriate ', ...
                'seasonal model or failed to ', ...
                'converge. Run X13 with three output arguments ', ...
                'to capture the X13 output and error messages.\n\n', ...
                'X13 says:%s'], ...
                iErrMsg);
        end
    end
end

doWarn();

varargout{nOutp+1} = Outp;
varargout{nOutp+2} = Err;
varargout{nOutp+3} = Mdl;

% Clean up newly created directory.
if isNewTempDir && Opt.cleanup
    rmdir(tempDir,'s');
end


% Nested functions...


%**************************************************************************


    function doWarn()
        if is3YearsWarn
            utils.warning('x12:x12', ...
                'X12 requires three or more years of observations.');
        end
        if is70YearsWarn
            utils.warning('x12:x12', ...
                'X12 cannot handle more than 70 years of observations.');
        end
        if is15YearsBcastWarn
            utils.warning('x12:x12', ...
                'X12 does not produce backcasts for time seris longer than 15 years.');
        end
        if isNanWarn
            utils.warning('x12:x12', ...
                ['Input data contain in-sample NaNs. ', ...
                'To allow for in-sample NaNs, ', ...
                'use the option ''missing='' true.']);
        end
    end % doWarnings()


%**************************************************************************


    function doSaveAs()
        [fPath,fTitle] = fileparts(Opt.saveas);
        list = dir([tmpTitle,'.*']);
        for ii = 1 : length(list)
            [~,~,fExt] = fileparts(list(ii).name);
            copyfile(list(ii).name,fullfile(fPath,[fTitle,fExt]));
        end
    end % doSaveAs()


%**************************************************************************


    function doTempDir()
        if isfunc(tempDir)
            tempDir = tempDir();
        end
        isNewTempDir = exist(tempDir,'dir') == 0;
        if isNewTempDir
            mkdir(tempDir);
        end
        returnDir = pwd();
        cd(tempDir);
        tempDir = pwd();
        cd(returnDir);
    end % doTempDir()


end


% Subfunctions...


%**************************************************************************


function [Data,Fcast,Bcast,Ok] = ...
    xxRunX12(ThisDir,TempTitle,Data,StartDate,Dummy,Opt)

Fcast = zeros(0,1);
Bcast = zeros(0,1);

% Flip sign if all values are negative
% so that multiplicative mode is possible.
flipSign = false;
if all(Data < 0)
    Data = -Data;
    flipSign = true;
end

nonPositive = any(Data <= 0);
if strcmp(Opt.mode,'auto')
    if nonPositive
        Opt.mode = 'add';
    else
        Opt.mode = 'mult';
    end
elseif strcmp(Opt.mode,'mult') && nonPositive
    utils.warning('x12:x12', ...
        ['Unable to use multiplicative mode because of ', ...
        'input data combine positive and non-positive numbers; ', ...
        'switching to additive mode.']);
    Opt.mode = 'add';
end

% Write a spec file.
xxSpecFile(TempTitle,Data,StartDate,Dummy,Opt);

% Set up a system command to run X12a.exe, enclosing the command in
% double quotes.
if ispc()
    cmd = ['"',fullfile(ThisDir,'x13aswin.exe'),'"'];
elseif ismac()
    originalDL = getenv('DYLD_LIBRARY_PATH');
    setenv('DYLD_LIBRARY_PATH','');
    cmd = ['"',fullfile(ThisDir,'x13asmac'),'"'];
elseif isunix()
    cmd = ['"',fullfile(ThisDir,'x13asunix'),'"'];
else
    utils.error('x12:x12', ...
        ['Cannot determine your operating system ', ...
        'and choose the appropriate X13 executable.']);
end
cmd = [cmd,' "',TempTitle,'"'];

[status,result] = system(cmd);

if ismac()
    setenv('DYLD_LIBRARY_PATH',originalDL);
end

if Opt.display
    disp(result);
end

% Return NaNs if X12 fails.
if status ~= 0
    Data(:) = NaN;
    utils.error('x12:x12', ...
        ['Unable to run the X13 executable.\n', ...
        '\tThe operating system says: %s'], ...
        result);
end

% Read in-sample results.
nPer = length(Data);
[Data,dataOk] = xxGetOutpData(TempTitle,nPer,Opt.output,2);

% Try to read forecasts.
fcastOk = true;
kf = Opt.forecast;
if kf > 0
    [Fcast,fcastOk] = xxGetOutpData(TempTitle,kf,{'fct'},4);
end

% Try to read backcasts.
bcastOk = true;
kb = Opt.backcast;
if kb > 0
    [Bcast,bcastOk] = xxGetOutpData(TempTitle,kb,{'bct'},4);
end

Ok = dataOk && fcastOk && bcastOk;

if flipSign
    Data = -Data;
    Fcast = -Fcast;
    Bcast = -Bcast;
end

end % xxRunX12()


%**************************************************************************


function xxSpecFile(TempTitle,Data,StartDate,Dummy,Opt)
% xxSpecFile  Create and save SPC file based on a template.

[dataYear,dataPer] = dat2ypf(StartDate);
[dummyYear,dummyPer] = dat2ypf(StartDate-Opt.backcast);

spec = file2char(Opt.specfile);

% Time series specs.

% Check for the required placeholders $series_data$ and $x11_save$:
if length(strfind(spec,'$series_data$')) ~= 1 ...
        || length(strfind(spec,'$x11_save$')) ~= 1
    utils.error('x12:x12', ...
        ['Invalid X12 spec file. Some of the required placeholders, ', ...
        '$series_data$ and $x11_save$, are missing or used more than once.']);
end

br = '\n';

% Data.
format = '%.8f';
cData = sprintf(['    ',format,br],Data);
cData = strrep(cData,sprintf(format,-99999),sprintf(format,-99999.01));
cData = strrep(cData,'NaN','-99999');
spec = strrep(spec,'$series_data$',cData);

% Seasonal period.
spec = strrep(spec,'$series_freq$',sprintf('%g',datfreq(StartDate)));
% Start date.
spec = strrep(spec,'$series_startyear$',sprintf('%g',round(dataYear)));
spec = strrep(spec,'$series_startper$',sprintf('%g',round(dataPer)));
if any(strcmp(Opt.output,'mv'))
    % Save missing value adjusted series.
    spec = strrep(spec,'$series_missingvaladj$','save = (mv)');
    Opt.output = setdiff(Opt.output,{'mv'});
else
    spec = strrep(spec,'$series_missingvaladj$','');
end    

% Transform specs.
if any(strcmp(Opt.mode,{'mult','pseudoadd','logadd'}))
    replace = 'log';
else
    replace = 'none';
end
spec = strrep(spec,'$transform_function$',replace);

% AUTOMDL specs.
spec = strrep(spec,'$maxorder$',sprintf('%g %g',round(Opt.maxorder)));

% FORECAST specs.
spec = strrep(spec,'$forecast_maxback$',sprintf('%g',Opt.backcast));
spec = strrep(spec,'$forecast_maxlead$',sprintf('%g',Opt.forecast));

% REGRESSION specs. If there's no REGRESSSION variable, we cannot include
% the spec in the spec file because X12 would complain. In that case, we
% keep the entire spec commented out. If tdays is requested but no user
% dummies are specified, we need to keep the dummy section commented out,
% and vice versa.
if Opt.tdays || ~isempty(Dummy)
    Dummy = real(Dummy);
    spec = strrep(spec,'#regression ','');
    if Opt.tdays
        spec = strrep(spec,'#tdays ','');
        spec = strrep(spec,'$tdays$','td');
    end
    if ~isempty(Dummy)
        spec = strrep(spec,'#dummy ','');
        nDummy = size(Dummy,2);
        dummyFmt = [ repmat(' %.8f',1,nDummy), br ];
        name = sprintf(' dummy%g',1:nDummy);
        spec = strrep(spec,'$dummy_type$',lower(Opt.dummytype));
        spec = strrep(spec,'$dummy_name$',name);
        spec = strrep(spec,'$dummy_data$',sprintf(dummyFmt,Dummy.'));
        spec = strrep(spec,'$dummy_startyear$', ...
            sprintf('%g',round(dummyYear)));
        spec = strrep(spec,'$dummy_startper$', ...
            sprintf('%g',round(dummyPer)));
    end
end

% ESTIMATION specs.
spec = strrep(spec,'$maxiter$',sprintf('%g',round(Opt.maxiter)));
spec = strrep(spec,'$tolerance$',sprintf('%e',Opt.tolerance));

% X11 specs.
spec = strrep(spec,'$x11_mode$',Opt.mode);
spec = strrep(spec,'$x11_save$',sprintf('%s ',Opt.output{:}));

char2file(spec,[TempTitle,'.spc']);

end % xxSpecFile()


%**************************************************************************


function [Data,Flag] = xxGetOutpData(TempTitle,NPer,Outp,NCol)

if ischar(Outp)
    Outp = {Outp};
end
Flag = true;
Data = zeros(NPer,0);
format = repmat(' %f',1,NCol);
nOutp = length(Outp);
for i = 1 : nOutp
    file = sprintf('%s.%s',TempTitle,Outp{i});
    fId = fopen(file,'r');
    if fId > -1
        fgetl(fId); % skip first 2 lines
        fgetl(fId);
        read = fscanf(fId,format);
        fclose(fId);
    else
        read = [];
    end
    if length(read) == NCol*NPer
        read = reshape(read,[NCol,NPer]).';
        Data(:,end+1) = read(:,2); %#ok<AGROW>
    else
        Data(:,end+1) = NaN; %#ok<AGROW>
        Flag = false;
    end
end
end % xxGetOutputData()


%**************************************************************************


function C = xxReadOutpFile(FName)
C = file2char(FName);
C = strfun.removeltel(C);
C = regexprep(C,'\n\n+','\n\n');
end % xxReadOutpFile()


%**************************************************************************


function Mdl = xxReadModel(FName,OuputFile)

C = file2char(FName);

Mdl = struct('mode',NaN,'spec',[],'ar',[],'ma',[]);

% ARIMA spec block.
arima = regexp(C,'arima\s*\{\s*model\s*=([^\}]+)\}','once','tokens');
if isempty(arima) || isempty(arima{1})
    return
end
arima = arima{1};

% Non-seasonal and seasonal ARIMA model specification
spec = regexp(arima,'\((.*?)\)\s*\((.*?)\)','once','tokens');
if isempty(spec) || length(spec) ~= 2 ...
        || isempty(spec{1}) || isempty(spec{2})
    return
end
specAr = sscanf(spec{1},'%g').';
specMa = sscanf(spec{2},'%g').';
if isempty(specAr) || isempty(specMa)
    return
end

% Estimated AR and MA coefficients.
estAr = regexp(arima,'ar\s*=\s*\((.*?)\)','once','tokens');
estMa = regexp(arima,'ma\s*=\s*\((.*?)\)','once','tokens');
if isempty(estAr) && isempty(estMa)
    return
end
try
    estAr = sscanf(estAr{1},'%g').';
catch %#ok<CTCH>
    estAr = [];
end
try
    estMa = sscanf(estMa{1},'%g').';
catch %#ok<CTCH>
    estMa = [];
end
if isempty(estAr) && isempty(estMa)
    return
end

mode = NaN;
if ~isempty(OuputFile) && ischar(OuputFile)
    tok = regexp(OuputFile,'Type of run\s*-\s*([\w\-]+)','tokens','once');
    if ~isempty(tok) && ~isempty(tok{1})
        mode = tok{1};
    end
end

% Create output struct only after we make sure all pieces have been read in
% all right.
Mdl.mode = mode;
Mdl.spec = {specAr,specMa};
Mdl.ar = estAr;
Mdl.ma = estMa;

end % xxReadModel()
