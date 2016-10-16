function scrollcandle(p)
% Created by 

% Generate and plot data
figure('menubar', 'none',...
    'name', 'slider_plot_scroll',...
    'numbertitle', 'off');

x = p.DateTime(1:end);
y = p.Price(1:end);
dx = 3;
%% dx is the width of the axis 'window'
%a=gca;
plot(x, y, 'r');

% Set appropriate axis limits and settings
set(gcf, 'doublebuffer','on');
%% This avoids flickering when updating the axis
%a = datenum(min(x));
%b = datenum(min(x)+hours(dx));
a = min(x);
b = min(x)+hours(dx);
set(gca, 'xlim', [a b]);
set(gca, 'ylim', [min(y) max(y)]);

% Generate constants for use in uicontrol initialization
pos=get(gca,'position');
Newpos=[pos(1) pos(2)-0.1 pos(3) 0.05];
%% This will create a slider which is just underneath the axis
%% but still leaves room for the axis labels above the slider
%xmax=max(x);
%S=['set(gca,''xlim'',get(gcbo,''value'')+[0 ' num2str(dx) '])'];
%% Setting up callback string to modify XLim of axis (gca)
%% based on the position of the slider (gcbo)

% Creating Uicontrol
uicontrol('style','slider',...
    'units','normalized',...
    'position',Newpos,...
    'callback',@slide_call,...
    'min', 0,...
    'max', 13);

    function slide_call(hObject, ~)
        t = get(hObject, 'value');
        set(gca, 'xlim', datenum(hours(t)) + [a b]);
    end
end
