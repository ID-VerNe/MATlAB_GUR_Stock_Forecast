function varargout = candle(varargin)

%--------------------------- Parsing/Validation --------------------------%
try
    narginchk(1,Inf);
    [ax,args] = internal.finance.axesparser(varargin{:});
    if ~isempty(ax) && ~isscalar(ax)
        error(message('finance:internal:finance:axesparser:ScalarAxes'))
    end
    
    output = internal.finance.ftseriesInputParser(args, ...
        4,{'open','high','low','close'},{},{},{'Color'},{''},{@(x)1,@ischar},1);
catch ME
    throwAsCaller(ME)
end

[data,optional,dates,~] = output{:};
op = data(:,1);
hi = data(:,2);
lo = data(:,3);
cl = data(:,4);

% Validation work will be left to child functions.
color = optional.Color;

%------------------------------ Data Preparation -------------------------%

% Need to pad all inputs with NaN's to leave spaces between day data
% Vertical High/Low lines data preparation.
numObs = length(hi(:));

hiloVertical = [hi lo NaN(numObs, 1)]';
indexVertical = repmat(dates',3,1);

% Boxes data preparation
if isdatetime(dates) && length(dates) > 1
    %If using datetimes, make the box width one half of the smallest
    %distance between dates
    inc = 1/4 * min(diff(dates));
else
    inc = 0.25;
end
indexLeft = dates - inc;
indexRight = dates + inc;

%------------------------------- Plot ------------------------------------%

if isempty(ax)
    ax = gca;
end

% Store NextPlot flag (and restore on cleanup):
next = get(ax,'NextPlot');
cleanupObj = onCleanup(@()set(ax,'NextPlot',next));

backgroundColor = get(ax,'color');
if isempty(color)
    cls = get(ax, 'colororder');
    color = cls(1, :);
end

h = gobjects(numObs+1,1); % Preallocate

% Plot vertical lines
h(1) = plot(ax,indexVertical(:),hiloVertical(:),'Color',color,'AlignVertexCenters','on');

set(ax,'NextPlot','add')

% Plot filled boxes
colorSet = {backgroundColor,color};

% Filled the boxes when opening price is greater than the closing price.
filledIndex = ones(numObs, 1);
filledIndex(op > cl) = 2;

try
    for i = 1 : numObs
        h(i+1) = fill(ax, ...
                [indexLeft(i); indexLeft(i); indexRight(i); indexRight(i)], ...
                [op(i); cl(i); cl(i); op(i)],colorSet{filledIndex(i)},'Edgecolor',color, ...
                'AlignVertexCenters', 'on');
    end
catch ME
    throwAsCaller(ME)
end

switch next
    case {'replace','replaceall'}
        grid(ax, 'on')
    case {'replacechildren','add'}  
        % Do not modify axes properties
end

if nargout % Not equal to 0
    varargout = {h};
end

