function varargout = file_list(varargin)
% FILE_LIST MATLAB code for file_list.fig
%      FILE_LIST, by itself, creates a new FILE_LIST or raises the existing
%      singleton*.
%
%      H = FILE_LIST returns the handle to a new FILE_LIST or the handle to
%      the existing singleton*.
%
%      FILE_LIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILE_LIST.M with the given input arguments.
%
%      FILE_LIST('Property','Value',...) creates a new FILE_LIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before file_list_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to file_list_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help file_list

% Last Modified by GUIDE v2.5 08-Dec-2014 18:04:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @file_list_OpeningFcn, ...
                   'gui_OutputFcn',  @file_list_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function file_list_OpeningFcn(hObject, eventdata, handles, varargin)
moviefiles = varargin{1};
currentf = varargin{2};

set(handles.listbox_files,'String',moviefiles,'Value',currentf)

% Choose default command line output for file_list
handles.output = hObject;

uiwait(handles.figure1)
% Update handles structure
guidata(hObject, handles);


function varargout = file_list_OutputFcn(hObject, eventdata, handles) 
varargout{1} = get(handles.listbox_files,'Value');
varargout{2} = get(handles.pushbutton_accept,'UserData');
if ishandle(handles.figure1)
    delete(handles.figure1)
end


function listbox_files_Callback(hObject, eventdata, handles)


function listbox_files_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton_accept_Callback(hObject, eventdata, handles)
set(handles.pushbutton_accept,'UserData',true)
uiresume(handles.figure1)


function pushbutton_cancel_Callback(hObject, eventdata, handles)
set(handles.pushbutton_accept,'UserData',false)
uiresume(handles.figure1)