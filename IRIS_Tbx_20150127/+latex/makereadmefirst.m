function makereadmefirst()
% makereadmefirst  Populate the read_me_first.m file based on tutorial files.

br = sprintf('\n');

% A read_me_first.m must exist, with exactly one tutorial file included in
% each section code. The first, second, and last sections are special.
c = file2char('read_me_first.m');
c = strfun.converteols(c);

% Split the read_me_first.m file into code sections.
start = regexp(c,'^%%(?!%)','start','lineanchors');
nSect = length(start);
sect = cell(1,nSect);
start = [start,length(c)+1];
for i = 1 : nSect
    sect{i} = c(start(i):start(i+1)-1);
end

% First section does not change...

% Second section is How to Run...
sect{2} = file2char(fullfile(irisroot(),'+latex','howtorun.m'));

fileList = {};
for i = 3 : nSect-1
    s = sect{i};
    
    % Keep everything after the first % ... unchanged.
    [keep,pos] = regexp(s,'% \.\.\..*','match','start','once');
    s(pos:end) = '';
    
    s = preparser.removecomments(s,'%',{'%{','%}'});
    
    file = regexp(s,'edit (\w+)\.model','once','tokens');
    if ~isempty(file)
        % Model file.
        ext = '.model';
        file = file{1};
        % Do not comment out the `edit filename;` line for model files.
        cmtout = '';
    else
        % M-file.
        s = regexprep(s,'edit [^\n]+','');
        file = regexp(s,'\w+','match');
        ci = sprintf('%g',i);
        if isempty(file)
            utils.error('latex:makereadmefirst', ...
                'No m-file names in section #%s.',ci);
        elseif length(file) > 1
            utils.error('latex:makereadmefirst', ...
                ['Multiple m-file names in section #',ci,': ''%s''.'], ...
                file{:});
        end
        ext = '.m';
        file = file{1};
        % Comment out the `edit filename;` line for m-files.
        cmtout = '% ';
    end
    
    intro = latex.mfile2intro([file,ext]);
    intro = regexprep(intro,'^%[ ]*[Bb]y.*?\n','','once','lineanchors');
    sect{i} = [intro,br,br,cmtout,'edit ',file,ext,';'];
    if isequal(ext,'.m')
        sect{i} = [sect{i},br,file,';'];
    end
    if ~isempty(keep)
        sect{i} = [sect{i},br,br,keep];
    end
    fileList{end+1} = [file,ext]; %#ok<AGROW>
end

% Last section is Publish M-Files to PDFs...
pub = file2char(fullfile(irisroot(),'+latex','howtopublish.m'));
for i = 1 : length(fileList)
    pub = [pub,br,'    latex.publish(''',fileList{i},''');']; %#ok<AGROW>
end
pub = [pub,br,'%}',br];
sect{end} = pub;

% Make sure there are exactly two line breaks at the end of each section,
% and one line break at the end of the file.
for i = 1 : nSect
    sect{i} = regexprep(sect{i},'\n+$','');
    sect{i} = [sect{i},br];
    if i < nSect
        sect{i} = [sect{i},br]; 
    end
end

c = [sect{:}];
char2file(c,'read_me_first.m');

end
