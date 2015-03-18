function varargout = Labeler_fix(varargin)
% LABELER_FIX MATLAB code for Labeler_fix.fig
%      LABELER_FIX, by itself, creates a new LABELER_FIX or raises the existinglabeledpos
%      singleton*.
%
%      H = LABELER_FIX returns the handle to a new LABELER_FIX or the handle to
%      the existing singleton*.
%
%      LABELER_FIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELER_FIX.M with the given input arguments.
%
%      LABELER_FIX('Property','Value',...) creates a new LABELER_FIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Labeler_fix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Labeler_fix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Labeler_fix

% Last Modified by GUIDE v2.5 15-Dec-2014 19:11:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Labeler_fix_OpeningFcn, ...
                   'gui_OutputFcn',  @Labeler_fix_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && exist(varargin{1}),
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function Labeler_fix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Labeler_fix (see VARARGIN)

% Choose default command line output for Labeler_fix
handles.output = hObject;

if numel(varargin)==0
  handles.frames = [];
  [filep,folderp] = uigetfile('*.mat');
  if filep==0
      return
  end
  s_p = load(fullfile(folderp,filep));
  handles.p_all = s_p.p_all;
  if isfield(s_p,'moviefiles_all')
    handles.moviefiles_all = s_p.moviefiles_all;
  else
    filetypes={  '*.ufmf','MicroFlyMovieFormat (*.ufmf)'; ...
      '*.fmf','FlyMovieFormat (*.fmf)'; ...
      '*.sbfmf','StaticBackgroundFMF (*.sbfmf)'; ...
      '*.avi','AVI (*.avi)'
      '*.mp4','MP4 (*.mp4)'
      '*.mov','MOV (*.mov)'
      '*.mmf','MMF (*.mmf)'
      '*.tif','TIF (*.tif)'
      '*.*','*.*'};
    [file,folder]=uigetfile(filetypes);
    handles.moviefile=fullfile(folder,file);
  end
  if isfield(s_p,'curr_vid')
    handles.curr_vid = s_p.curr_vid;
  else
    handles.curr_vid = 1;
  end
elseif numel(varargin)==2 || numel(varargin)==3 
  handles.p_all = varargin{1};
  handles.moviefiles_all = varargin{2};
  if numel(varargin)==3
    handles.curr_vid = varargin{3};
  else
    handles.curr_vid = 1;
  end
else
  fprintf('Invalid number of input arguments')  
  return
end

if ~isunix
    old_drive = '/tier2/hantman/';
    new_drive = 'Y:\';
    for i=1:numel(handles.moviefiles_all)
        if strcmp(handles.moviefiles_all{i}(1),'/')
            handles.moviefiles_all{i}=strrep(handles.moviefiles_all{i},old_drive,new_drive);
            handles.moviefiles_all{i}=strrep(handles.moviefiles_all{i},'/','\');
        end
    end
end

handles.keypressmode = '';
handles.motionobj = [];

handles.binfo.first=nan(numel(handles.moviefiles_all,1));
handles.binfo.last=nan(numel(handles.moviefiles_all,1));

handles = InitializeGUI(handles);

% Update handles structure
guidata(hObject, handles);
uiwait(handles.figure)


function PointButtonDownCallback(hObject,eventdata,handles,i)
if get(handles.uipanel_method,'SelectedObject')==handles.radiobutton_dragg
    handles = guidata(handles.figure);
    handles.motionobj = i;
    handles.didmovepoint = false;
    guidata(hObject,handles);
end


function handles = Updatep(pos,hfig,i,handles)

if nargin < 4,
  handles = guidata(hfig);
end
handles.p(handles.f,[i i+handles.npoints]) = pos;


function handles = InitializeVideo(handles)

% open video
handles.f_im = handles.f;
handles.imprev = handles.imcurr;
handles.fprev = handles.f;

handles.minv = max(handles.minv,0);
if isfield(handles.headerinfo,'bitdepth'),
  handles.maxv = min(handles.maxv,2^handles.headerinfo.bitdepth-1);
elseif strcmp(handles.isa,'tif') || strcmp(handles.isa,'mat') % Temp. remove
    handles.minv=400;
   handles.maxv = 4000;
elseif isa(handles.imcurr,'uint16'),
  handles.maxv = min(2^16 - 1,handles.maxv);
elseif isa(handles.imcurr,'uint8'),
  handles.maxv = min(handles.maxv,2^8 - 1);
else
  handles.maxv = min(handles.maxv,2^(ceil(log2(max(handles.imcurr(:)))/8)*8));
end

set(handles.axes_curr,'CLim',[handles.minv,handles.maxv],...
  'XLim',[.5,size(handles.imcurr,2)+.5],...
  'YLim',[.5,size(handles.imcurr,1)+.5]);
set(handles.axes_prev,'CLim',[handles.minv,handles.maxv],...
  'XLim',[.5,size(handles.imcurr,2)+.5],...
  'YLim',[.5,size(handles.imcurr,1)+.5]);

hold(handles.axes_curr,'on')
hold(handles.axes_prev,'on')
handles.hpoly = nan(handles.npoints,1);
handles.htext = nan(handles.npoints,1);
handles.posprev = nan(handles.npoints,1);
handles.textprev = nan(handles.npoints,1);
for i=1:handles.npoints
    x = handles.p(handles.f,i);
    y = handles.p(handles.f,i+handles.npoints);
    handles.hpoly(i) = plot(handles.axes_curr,x,y,'r+','MarkerSize',12,'Linewidth',2,...
        'ButtonDownFcn',@(hObject,eventdata) PointButtonDownCallback(hObject,eventdata,handles,i));%,...
      %'KeyPressFcn',handles.keypressfcn);
    handles.htext(i) = text(x+10,y-10,num2str(i),'Color',[0 0.8 0.8],'Parent',handles.axes_curr);
    handles.posprev(i) = plot(handles.axes_prev,nan,nan,'r+','MarkerSize',12);%,...
      %'KeyPressFcn',handles.keypressfcn);
    handles.textprev(i) = text(nan,nan,num2str(i),'Color',[0 0.8 0.8],'Parent',handles.axes_prev);
end

sliderstep = [1/(handles.nframes-1),min(1,10/(handles.nframes-1))];
set(handles.slider_frame,'Min',1,'Max',handles.nframes,'Value',1,'SliderStep',sliderstep);


function handles = InitializeGUI(handles)

set(handles.figure,'ToolBar','figure');

handles = UpdateData(handles);

handles.image_curr = image(0,'Parent',handles.axes_curr);
axis(handles.axes_curr,'image','off','equal');
hold(handles.axes_curr,'on');
%colormap(handles.figure,fire_colormap(2^8));
colormap(handles.figure,gray(255));

handles.image_prev = image(0,'Parent',handles.axes_prev);
axis(handles.axes_prev,'image','off');
hold(handles.axes_prev,'on');
handles.posprev = [];
handles.textprev = [];

linkaxes([handles.axes_prev,handles.axes_curr]);

fcn = get(handles.slider_frame,'Callback');
handles.hslider_listener = handle.listener(handles.slider_frame,...
  'ActionEvent',fcn);
set(handles.slider_frame,'Callback','');

handles.hpoly = [];
handles.pointselected = false(1,handles.npoints);

handles.maxv = inf;
handles.minv = 0;

handles = InitializeVideo(handles);

handles = UpdateFrame(handles);

hchil = findall(handles.figure,'-property','KeyPressFcn');
handles.keypressfcn = get(handles.figure,'KeyPressFcn');
set(hchil,'KeyPressFcn',handles.keypressfcn);


function handles = UpdateFrame(handles,hObject)

if nargin < 2,
  hObject = nan;
end

handles.pclicked = 0;

if get(handles.togglebutton_lock,'Value') && ~get(handles.togglebutton_play,'Value') && ~isempty(handles.pointselected)
    x = cell2mat(get(handles.hpoly,'Xdata'))';
    y = cell2mat(get(handles.hpoly,'Ydata'))';
    pointselected = find(handles.pointselected);
    handles.p(handles.f,pointselected) = x(pointselected);
    handles.p(handles.f,pointselected+handles.npoints) = y(pointselected);
end

if handles.f > 1,
  if handles.fprev ~= handles.f-1,
    handles.fprev = handles.f-1;
    switch handles.isa
      case 'tif'
        handles.imprev=imread(handles.moviefile,handles.fprev);
      case 'mat'
        handles.imprev=handles.Is{handles.fprev};
      otherwise
        [handles.imprev,~] = handles.readframe(handles.fprev);
    end
  end
end

switch handles.isa
case 'tif'
  handles.imcurr=imread(handles.moviefile,handles.f);
case 'mat'
  handles.imcurr=handles.Is{handles.f};
otherwise
  [handles.imcurr,~] = handles.readframe(handles.f);
end
handles.f_im = handles.f;

if handles.f > 1 && isfield(handles,'imprev'),
  set(handles.image_prev,'CData',handles.imprev);
else
  set(handles.image_prev,'CData',0);
end
if isfield(handles,'imcurr'),
  set(handles.image_curr,'CData',handles.imcurr);
end
if hObject ~= handles.slider_frame,
  set(handles.slider_frame,'Value',handles.f);
end
if hObject ~= handles.edit_frame,
  set(handles.edit_frame,'String',num2str(handles.f));
end


for i = 1:handles.npoints,
  x = handles.p(handles.f,i);
  y = handles.p(handles.f,i+handles.npoints);
  set(handles.hpoly(i),'XData',x,'YData',y);
  set(handles.htext(i),'Position',[x+10,y-10]);
  if handles.f > 1,
    x_prev = handles.p(handles.fprev,i);
    y_prev = handles.p(handles.fprev,i+handles.npoints);
    set(handles.posprev(i),'XData',x_prev,'YData',y_prev);
    set(handles.textprev(i),'Position',[x_prev+10, y_prev-10])
  else
    set(handles.posprev,'XData',nan,'YData',nan);
    set(handles.textprev,'Position',[nan nan]);
  end
end
drawnow


function varargout = Labeler_fix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
delete(handles.figure)



function slider_frame_Callback(hObject, eventdata, handles)
v = get(hObject,'Value');
handles.f = round(v);
handles = UpdateFrame(handles,hObject);
guidata(hObject,handles);


function slider_frame_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function menu_file_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_file_quit_Callback(hObject, eventdata, handles)
res = questdlg('Save before closing?');
if isempty(res) || strcmpi(res,'Cancel'),
  return;
elseif strcmpi(res,'Yes'),
  SaveProgress(handles)
end
uiresume(handles.figure);


% --------------------------------------------------------------------
function menu_setup_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function CloseImContrast(hObject)

handles = guidata(hObject);
clim = get(handles.axes_curr,'CLim');
handles.minv = clim(1);
handles.maxv = clim(2);
set(handles.axes_prev,'CLim',[handles.minv,handles.maxv]);
set(handles.axes_curr,'CLim',[handles.minv,handles.maxv]);
delete(handles.adjustbrightness_listener);
guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_setup_adjustbrightness_Callback(hObject, eventdata, handles)
hcontrast = imcontrast_kb(handles.axes_curr);
handles.adjustbrightness_listener = addlistener(hcontrast,'ObjectBeingDestroyed',@(x,y) CloseImContrast(hObject));
guidata(hObject,handles);


function figure_CloseRequestFcn(hObject, eventdata, handles)
res = questdlg('Save before closing?');
if isempty(res) || strcmpi(res,'Cancel'),
  return;
elseif strcmpi(res,'Yes'),
  SaveProgress(handles)
end
uiresume(handles.figure);
  
  
function edit_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function figure_KeyPressFcn(hObject, eventdata, handles)
switch eventdata.Key,
  case 'rightarrow',
    if any(handles.pointselected),
      xlim = get(handles.axes_curr,'XLim');
      dx = diff(xlim);
      if ismember('control',eventdata.Modifier),
        dx = dx / 50;
      else
        dx = dx / 500;
      end
      for i = find(handles.pointselected),
        x = get(handles.hpoly(i),'XData');
        handles.p(handles.f,i) = x + dx;
        set(handles.hpoly(i),'XData',handles.p(handles.f,i));
        textpos = get(handles.htext(i),'Position');
        textpos(1) = textpos(1) + dx;
        set(handles.htext(i),'Position',textpos)
        guidata(hObject,handles);
      end
    else
      if ismember('control',eventdata.Modifier),
        df = 10;
      else
        df = 1;
      end
      f = min(handles.f+df,handles.lf);
      if f ~= handles.f,
        handles.f = f;
        handles = UpdateFrame(handles,hObject);
        guidata(hObject,handles);
      end
    end
  case 'equal',
    if ismember('control',eventdata.Modifier),
      df = 10;
    else
      df = 1;
    end
    f = min(handles.f+df,handles.lf);
    if f ~= handles.f,
      handles.f = f;
      handles = UpdateFrame(handles,hObject);
      guidata(hObject,handles);
    end
  case 'hyphen',
    if ismember('control',eventdata.Modifier),
      df = 10;
    else
      df = 1;
    end
    f = max(handles.f-df,1);
    if f ~= handles.f,
      handles.f = f;
      handles = UpdateFrame(handles,hObject);
      guidata(hObject,handles);
    end
  case 'leftarrow',
    if any(handles.pointselected),
      xlim = get(handles.axes_curr,'XLim');
      dx = diff(xlim);
      if ismember('control',eventdata.Modifier),
        dx = dx / 50;
      else
        dx = dx / 500;
      end
      for i = find(handles.pointselected),
        x = get(handles.hpoly(i),'XData');
        handles.p(handles.f,i) = x - dx;
        set(handles.hpoly(i),'XData',handles.p(handles.f,i));
        guidata(hObject,handles);
        textpos = get(handles.htext(i),'Position');
        textpos(1) = textpos(1) - dx;
        set(handles.htext(i),'Position',textpos)
      end
    else
      if ismember('control',eventdata.Modifier),
        df = 10;
      else
        df = 1;
      end
      f = max(handles.f-df,1);
      if f ~= handles.f,
        handles.f = f;
        handles = UpdateFrame(handles,hObject);
        guidata(hObject,handles);
      end
    end
  case 'uparrow',
    if any(handles.pointselected),
      ylim = get(handles.axes_curr,'YLim');
      dy = diff(ylim);
      if ismember('control',eventdata.Modifier),
        dy = dy / 50;
      else
        dy = dy / 500;
      end
      for i = find(handles.pointselected),
        y = get(handles.hpoly(i),'YData');
        handles.p(handles.f,i+handles.npoints) = y - dy;
        set(handles.hpoly(i),'YData',handles.p(handles.f,i+handles.npoints));
        guidata(hObject,handles);
        textpos = get(handles.htext(i),'Position');
        textpos(2) = textpos(2) - dy;
        set(handles.htext(i),'Position',textpos)
      end
    end
  case 'downarrow',
    if any(handles.pointselected),
      ylim = get(handles.axes_curr,'YLim');
      dy = diff(ylim);
      if ismember('control',eventdata.Modifier),
        dy = dy / 50;
      else
        dy = dy / 500;
      end
      for i = find(handles.pointselected),
        y = get(handles.hpoly(i),'YData');
        handles.p(handles.f,i+handles.npoints) = y + dy;
        set(handles.hpoly(i),'YData',handles.p(handles.f,i+handles.npoints));
        guidata(hObject,handles);
        textpos = get(handles.htext(i),'Position');
        textpos(2) = textpos(2) + dy;
        set(handles.htext(i),'Position',textpos)
      end
    end
  case 'q'
    v = max(1,get(handles.popupmenu_frame,'Value')-1);
    set(handles.popupmenu_frame,'Value',v)
    handles.f=handles.frames(v);
    handles = UpdateFrame(handles,hObject);
    guidata(hObject,handles);
  case 'w'
    v = min(numel(handles.frames),get(handles.popupmenu_frame,'Value')+1);
    set(handles.popupmenu_frame,'Value',v)
    handles.f=handles.frames(v);
    handles = UpdateFrame(handles,hObject);
    guidata(hObject,handles);
  otherwise
    key = str2double(eventdata.Key);  
    all_p = 1:size(handles.p,2)/2;
    if any(key == all_p)
      handles.pointselected(key) = true;
      handles.pointselected(all_p~=key) = false;
      for i = 1:numel(all_p)
        UpdatePointSelected(handles,i);
      end
      handles.pclicked=0;
      guidata(hObject, handles);
    end
end


function figure_WindowButtonMotionFcn(hObject, eventdata, handles)
if ~isfield(handles,'motionobj') || isempty(handles.motionobj), return; end

if isnumeric(handles.motionobj),
  handles.didmovepoint = true;
  tmp = get(handles.axes_curr,'CurrentPoint');
  pos = tmp(1,1:2);
  set(handles.hpoly(handles.motionobj),'XData',pos(1),'YData',pos(2));
  set(handles.htext(handles.motionobj),'Position',[pos(1)+10,pos(2)-10])
  handles = Updatep(pos,hObject,handles.motionobj,handles);
  guidata(hObject, handles);
end


function figure_WindowButtonUpFcn(hObject, eventdata, handles)
tmp = get(handles.axes_curr,'CurrentPoint');
pos = tmp(1,1:2);
Xlim = get(handles.axes_curr,'Xlim');
Ylim = get(handles.axes_curr,'Ylim');
isin=pos(1)>Xlim(1)&&pos(1)<Xlim(2)&&pos(2)>Ylim(1)&&pos(2)<Ylim(2);
if isin
    if ~isempty(handles.motionobj) && isnumeric(handles.motionobj) && get(handles.uipanel_method,'SelectedObject')==handles.radiobutton_dragg,
      if ~handles.didmovepoint,
        handles.pointselected(handles.motionobj) = ~handles.pointselected(handles.motionobj);
        UpdatePointSelected(handles,handles.motionobj);    
      end
      handles.motionobj = [];
      guidata(hObject,handles);
    elseif get(handles.uipanel_method,'SelectedObject')==handles.radiobutton_click && sum(handles.pointselected)~=0, 
      handles.pclicked = handles.pclicked+1;
      pidx = find(handles.pointselected);
      pcurr = pidx(handles.pclicked);
      set(handles.hpoly(pcurr),'XData',pos(1),'YData',pos(2));
      set(handles.htext(pcurr),'Position',[pos(1)+10,pos(2)-10])
      handles = Updatep(pos,hObject,pcurr,handles);
      pause(.1)
      if handles.pclicked==sum(handles.pointselected)
          handles.f = min(handles.f+1,handles.lf);
          handles = UpdateFrame(handles,hObject);
      end
      guidata(hObject, handles);
    end
end

function UpdatePointSelected(handles,i)

if handles.pointselected(i),
  set(handles.hpoly(i),'LineWidth',2,'Color',[0 1 0],'Marker','o');
else
  set(handles.hpoly(i),'LineWidth',2,'Color',[1 0 0],'Marker','+');
end


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function menu_help_keyboardshortcuts_Callback(hObject, eventdata, handles)
s = {};
s{end+1} = '* When template point is selected, LEFT, RIGHT, UP, and DOWN move the selected point a small amount.';
s{end+1} = '* When template point is selected, CTRL+LEFT, RIGHT, UP, and DOWN move the selected point a large amount.';
s{end+1} = '* When no template point is selected, LEFT and RIGHT decrement and increment the frame shown.';
s{end+1} = '* MINUS (-) and EQUAL (=) always decrement and increment the frame shown.';
s{end+1} = '* When no template point is selected, CTRL+LEFT and CTRL+RIGHT decrease and increase the frame shown by 10.';
s{end+1} = '* CTRL+MINUS and CTRL+EQUAL decrease and increase the frame shown by 10.';

msgbox(s,'Keyboard shortcuts','help','modal');


function pushbutton_next_Callback(hObject, eventdata, handles)
handles.p_all{handles.curr_vid}=handles.p;
if handles.curr_vid < numel(handles.p_all)
  handles.curr_vid = handles.curr_vid+1;
  handles = UpdateData(handles);
  handles = UpdateFrame(handles);
else
  handles.curr_vid=1;
  SaveProgress(handles)
  return
end
guidata(hObject,handles)


function pushbutton_cancel_Callback(hObject, eventdata, handles)
uiresume(handles.figure)


function popupmenu_frame_Callback(hObject, eventdata, handles)
v=get(hObject,'Value');
handles.f=handles.frames(v);
handles = UpdateFrame(handles,hObject);
uicontrol(handles.text_frames)
guidata(hObject,handles);


function popupmenu_frame_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_frame_Callback(hObject, eventdata, handles)
f = str2double(get(hObject,'String'));
if isnan(f),
  set(hObject,'String',num2str(handles.f));
  return;
end
f = min(max(1,round(f)),handles.lf);
set(hObject,'String',num2str(f));
if f ~= handles.f,
  handles.f = f;
  handles = UpdateFrame(handles,hObject);
end
guidata(hObject,handles);


function togglebutton_lock_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(hObject,'String','Locked')
else
    set(hObject,'String','Unlocked')
end


function togglebutton_play_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(hObject,'String','Stop','BackgroundColor',[1 0 0])
else
    set(hObject,'String','Play','BackgroundColor',[0 1 0])
end
while get(hObject,'Value') && handles.f<handles.lf
    handles.f=handles.f+1;
    handles = UpdateFrame(handles,hObject);
end
guidata(hObject,handles);

function SaveProgress(handles)
[file_s,folder_s] = uiputfile('*.mat','Save labels to file');
if ~ischar(file_s),
  return;
end

s_p = struct;
s_p.curr_vid = handles.curr_vid;
s_p.moviefiles_all = handles.moviefiles_all;
s_p.p_all = handles.p_all; %#ok<STRNU>

savefile = fullfile(folder_s,file_s);
save(savefile,'-struct','s_p');


function handles = UpdateData(handles)
curr_vid = handles.curr_vid;
handles.moviefile = handles.moviefiles_all{curr_vid};
handles.p = handles.p_all{curr_vid};
handles.npoints = size(handles.p,2)/2;
handles.nframes = size(handles.p,1);

set(handles.togglebutton_lock,'String','Unlocked','Value',0)

set(handles.text_vid,'String',handles.moviefile)

usebinfo=strcmp(get(handles.menu_setup_binfo,'Checked'),'on');
if usebinfo && ~isnan(handles.binfo.first(curr_vid)) && ~isnan(handles.binfo.last(curr_vid))
    ff=handles.binfo.first(curr_vid);
    lf=handles.binfo.last(curr_vid);
else
    ff=1;
    lf=handles.nframes;
end
handles.ff=ff;
handles.lf=lf;
handles.nframes=lf-ff+1;

d=sqrt(diff(handles.p(ff:lf,1:handles.npoints)).^2)+sqrt(diff(handles.p(ff:lf,handles.npoints+1:end)).^2);
handles.frames=find(any(d>20,2))'+ff-1;

if ~isempty(handles.frames)
    handles.f = handles.frames(1);
    s_pop = cell(numel(handles.frames),1);
    for i=1:numel(handles.frames)
        which_p = find(d(handles.frames(i)-ff+1,:)>20);
        which_str = sprintf('%i, ',which_p);
        which_str = ['(',which_str(1:end-2),')'];
        s_pop{i} = sprintf('%i: frame %i %s\n',i,handles.frames(i),which_str);
    end
    set(handles.popupmenu_frame,'String',s_pop,'Enable','on','Value',min(numel(s_pop),1))
else 
    handles.f = ff;
    set(handles.popupmenu_frame,'String','No "sucpicious" frames','Value',1,'Enable','off')
end

sliderstep = [1/(handles.nframes-1),min(1,10/(handles.nframes-1))];
set(handles.slider_frame,'Min',ff,'Max',lf,'Value',handles.f,'SliderStep',sliderstep);

handles.isa=handles.moviefile(end-2:end);
switch handles.isa
    case 'tif'
      handles.imcurr=imread(handles.moviefile,ff);
      handles.fid=0;
      handles.headerinfo=[];
    case 'mat'
      load(handles.moviefile)
      handles.Is=IsT;
      handles.imcurr=handles.Is{ff};
      handles.fid=0;
      handles.headerinfo=[];
    otherwise
      [handles.readframe,~,handles.fid,handles.headerinfo] = ...
        get_readframe_fcn(handles.moviefile);
      setappdata(0,'grayscale',true)
      [handles.imcurr,~] = handles.readframe(handles.f);
end




%%% TO DO: 
% 2) Replace include tif and mat reader in get_readframe_fcn.
% 4) Read Tif faster.


function pushbutton_prev_Callback(hObject, eventdata, handles)
handles.p_all{handles.curr_vid}=handles.p;
if handles.curr_vid > 1
  handles.curr_vid = handles.curr_vid-1;
  handles = UpdateData(handles);
  handles = UpdateFrame(handles);
end
guidata(hObject,handles)


function pushbutton_video_Callback(hObject, eventdata, handles)
[handles.curr_vid,accept] = file_list(handles.moviefiles_all,handles.curr_vid);
if accept
    handles = UpdateData(handles);
    handles = UpdateFrame(handles);
    guidata(hObject,handles);
end


% --------------------------------------------------------------------
function menu_file_save_Callback(hObject, eventdata, handles)
SaveProgress(handles)


function menu_setup_binfo_Callback(hObject, eventdata, handles)
switch get(handles.menu_setup_binfo,'Checked')
    case 'on'
        set(handles.menu_setup_binfo,'Checked','off');
    case 'off'
        set(handles.menu_setup_binfo,'Checked','on');
        handles=getinfo(handles);
end
handles = UpdateData(handles);
handles = UpdateFrame(handles);
guidata(hObject,handles);


function uipanel_method_SelectionChangeFcn(hObject, eventdata, handles)
if eventdata.NewValue==handles.radiobutton_click
    set(handles.togglebutton_lock,'String','Unlocked','Value',0,'Enable','off')
else
    set(handles.togglebutton_lock,'Enable','on')
end
handles.pclicked=0;
guidata(hObject,handles);


function handles=getinfo(handles)
[file,folder]=uigetfile('*.mat');
load(fullfile(folder,file));
nvids = numel(handles.moviefiles_all);
ninfo = numel(importantframes);
first = nan(nvids,1);
last = nan(nvids,1);

for i=1:ninfo
    info_file = [importantframes(i).expdir,'/movie_comb.avi'];
    if ~isunix
        old_drive = '/tier2/hantman/';
        new_drive = 'Y:\';
        info_file=strrep(info_file,old_drive,new_drive);
        info_file=strrep(info_file,'/','\');
    end
    isfile = find(strcmp(handles.moviefiles_all,info_file));
    if ~isempty(isfile)
        nframes = size(handles.p_all{isfile},1);
        first(isfile) = max(1,importantframes(i).firstbehavior-10);
        last(isfile) = min(nframes,importantframes(i).lastbehavior+10);
    end
end

handles.binfo = struct('first',first,'last',last);
