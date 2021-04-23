%Name: Sham Maatouk
%ID: 20105652

%%%%This section is for the GUI controls, skip to line 156 for extracting
%%%%and analysing code

function varargout = PlantNucleiExtractor(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlantNucleiExtractor_OpeningFcn, ...
                   'gui_OutputFcn',  @PlantNucleiExtractor_OutputFcn, ...
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


% --- Executes just before PlantNucleiExtractor is made visible.
function PlantNucleiExtractor_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Set up images in the buttons
im1 =imread('StackNinja1.bmp');
im1 = imresize(im1,0.45);
set(handles.view1,'CData',im1);

im2 =imread('StackNinja2.bmp');
im2 = imresize(im2,0.45);
set(handles.view2,'CData',im2);

im3 =imread('StackNinja3.bmp');
im3 = imresize(im3,0.5);
set(handles.view3,'CData',im3);

global im;
% Update handles structure
guidata(hObject, handles);
%Initialize counter for next button
set(handles.next, 'UserData', 1);

% --- Outputs from this function are returned to the command line.
function varargout = PlantNucleiExtractor_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%If any of these three buttons is pressed im will be set to the
%corresponding image and showprogram function will be executed

% --- Executes on button press in view2.
function view1_Callback(hObject, eventdata, handles)
global im;
im1 = imread('StackNinja1.bmp');
im = im1;
showprogram(1,hObject, eventdata, handles);

% --- Executes on button press in view2.
function view2_Callback(hObject, eventdata, handles)
global im;
im2 = imread('StackNinja2.bmp');
im = im2;
showprogram(1,hObject, eventdata, handles);

% --- Executes on button press in view3.
function view3_Callback(hObject, eventdata, handles)
global im;
im3 = imread('StackNinja3.bmp');
im = im3;
showprogram(1,hObject, eventdata, handles);



%getting the filepath of chosen image by user
% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
handles.output = hObject;
[rawname rawpath] = uigetfile({'*.jpg;*.png;*.bmp'},'select image file');
fullname = [rawpath rawname];
set(handles.image_path,'String',fullname);

%when ok is pressed image path will be assigned to im and showprogram
%function will be executrd
% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
global im;
im4 = imread(handles.image_path.String);
im = im4;
showprogram(1,hObject, eventdata, handles);


%callback for Next button
function next_Callback(hObject, eventdata, handles)
global im;
global image;
%create an array of headings
handles.strings = {'Isolating The Green Parts Using Colour-Space Segmentation';'Producing a Binary Image by Adaptive Thresholding';'Applying Median Filter to Remove Salt-And-Pepper Noise';'Applying Morphology to Define Nuclei And Eliminate Redundant Pixels';'Segmenting And Seperating Nuclei Using Watershed Technique';'Total Count of Detected Nuclei Using Boundary Detection';'Size Analysis And Distribution';'Shape Analysis And Distribution';'Brightness Analysis And Distribution';''};
%get the value of the index
val = get(hObject, 'UserData');
%set the heading to array element corresponding to index
set(handles.heading2,'String',handles.strings{val});
%check the index and call functions accordingly to display different steps
%of the program
switch val
case 1
    image = getnuclei(im);
    assignin('base','nuclei_segmented_in_green',image);%this is to save variables in the worplace to be viewed after prgram is terminated
    axes(handles.plane)
    imshow(image);
case 2
    image = threshold(im);
    axes(handles.plane)
    imshow(image);
case 3
    image = filter(image);
    axes(handles.plane)
    imshow(image);
case 4
    image = morphology(image);
    axes(handles.plane)
    imshow(image);
case 5
    image = watershedding(image);
    assignin('base','segmented_binary_image',image);
    axes(handles.plane)
    imshow(image);
case 6
    count(image, handles.plane, handles.text);
case 7
    area(image,handles.plane,handles.plane1,handles.plane2,handles.text);  
    set(hObject, 'UserData', val+1);
case 8
    circularity(handles.plane1,handles.plane2,handles.text);  
case 9
    intensity(segmentgreen(im),handles.plane1,handles.plane2,handles.text);  
    set(handles.next,'String','Finish');
case 10
    showprogram(2,hObject, eventdata, handles);
otherwise
end
%Increment the index by one
set(hObject, 'UserData', val+1);

%Function to get intensities
function intensity(im,plane1,plane2,text)
global label;
global boundaries;
global num;
%get the mean intensities labelled images against original gray scale image
stats = regionprops(label,im,'MeanIntensity');
intensities = [stats.MeanIntensity];
max_intensity = round(max(intensities),2);
min_intensity = round(min(intensities),2);
avg_intensity = round(mean(intensities),2);
assignin('base','max_intensity',max_intensity);
assignin('base','min_intensity',min_intensity);
assignin('base','avg_intensity',avg_intensity);

axes(plane1);
imshow(im);
hold on;
%loop to check the mean intensity against threshold and draw border
%accordingly
for k = 1:num
    boundary = boundaries{k};
    intensity = intensities(k);
    if intensity>= avg_intensity
       plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2);
    elseif intensity < avg_intensity
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 0.2);
    end
end
%plot a histogram for intensity distribution
axes(plane2);
intensity_hist = histogram(intensities);
intensity_hist;
assignin('base','Histogram_of_Intensities_of_Nuclei',intensity_hist);
title('Histogram of Intensity');
xlabel('Intensity');
ylabel('Number of nuclei');
%set the text 
s1 = sprintf('The brightness of every nucleus is determined by considering the Mean Intensity of its region. Regions corresbonding to high intensity values are ones with higher brightness, others with low intensity values have lower brightness.');
s2 = sprintf('\nProminent nuclei having intensity higher than average are marked with green borders, others having less than average are marked with yellow.');
s3 = sprintf('\nMaximum intensity value: ');
s4 = sprintf(', Minimum intensity value: ');
s5 = sprintf(', Mean intensity value: ');
set(text,'String',strcat(s1,s2,s3,num2str(max_intensity),s4,num2str(min_intensity),s5,num2str(avg_intensity)));

%function to determine roundness and shapes of objects
function circularity(plane1,plane2,text)
global boundaries;
global label;
%get the Eccentricity of each labeled segment
stats = regionprops(label,'Area','Centroid','Eccentricity');
eccentricities = [stats.Eccentricity];
max_eccentricity = round(max(eccentricities),2);
min_eccentricity = round(min(eccentricities),2);
avg_eccentricity = round(mean(eccentricities),2);
assignin('base','max_eccentricity',max_eccentricity);
assignin('base','min_eccentricity',min_eccentricity);
assignin('base','avg_eccentricity',avg_eccentricity);
axes(plane1);
imshow(label);
hold on
%loop through all segments and check their Eccentricity valuse against a
%threshold abd draw borders accordingly
for k = 1:length(stats)
    boundary = boundaries{k};
    e = eccentricities(k);
    if e >= avg_eccentricity
        plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 0.5)
    end
    if e < avg_eccentricity
       plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 0.5)   
    end
end
axes(plane2);
%plot distribuition histogram of eccentricities
roundness_hist = histogram(eccentricities);
roundness_hist;
assignin('base','Histogram_of_Roundness_of_Nuclei',roundness_hist);
title('Histogram of Eccentricity');
xlabel('Eccentricity');
ylabel('Number of nuclei');
s1 = sprintf('The roundness of each nucleus is determined by its eccentricity, which is the ratio of the distance between the foci of the ellipse and its major axis length. Eccentricity values range from 0 to 1 and can be obtained from regionprops() function. An eccentricity value that is approximately close to 0 belongs to a circular object');
s2 =sprintf('Outlined in red lines are nuclei that have high circularity, while those with low circularity are outlined in yellow');
s3 = sprintf('\nMaximum eccentricity value: ');
s4 = sprintf(', Minimum eccentricity value: ');
s5 = sprintf(', Mean eccentricity value: ');
set(text,'String',strcat(s1,s2,s3,num2str(max_eccentricity),s4,num2str(min_eccentricity),s5,num2str(avg_eccentricity)));

%function to obtain areas of labelled segments
function area(im,plane,plane1,plane2,text)
global label;
%get the areas in pixels from regionprops
stats = regionprops(label, 'Area', 'boundingbox');
areas = [stats.Area];
%compute mean, min, and max values
area_avg = ceil(mean(areas));
area_max = ceil(max(areas));
area_min = ceil(min(areas));
s1 = sprintf('\nMaximum nuclei area in pixels: ');
s2 = sprintf('\nMinimum nuclei area in pixels: ');
s3 = sprintf('\nThe distribution of nuclei bigger than average is shown by red rectangles');
s4 = sprintf('\nThe distribution of nuclei smaller than average is shown by yellow rectangles');

set(text,'String',strcat('Average nuclei area in pixels: ',num2str(area_avg),s1,num2str(area_max),s2,num2str(area_min),s3,s4));
distributions = cat(1,  stats.BoundingBox);
%get areas more than average
max_areas = areas >= area_avg & areas<= area_max;  
[max_rect] = distributions(max_areas, :);  
%get areas less than average
min_areas = areas <= area_avg & areas>= area_min;  
[min_rect] = distributions(min_areas, :);  
cla(plane);
axes(plane1);
imshow(im);  
%draw border according to its group
for i = 1:size(max_rect,1)  
    rectangle('position', max_rect(i,:), 'EdgeColor', 'r');   
end
for i = 1:size(min_rect,1)  
    rectangle('position', min_rect(i,:), 'EdgeColor', 'y');   
end
axes(plane2);
%plot a histogram of area distribution
areas_hist = histogram(areas);
areas_hist;
assignin('base','Histogram_of_Equivalent_Areas_in_Pixels',areas_hist);
title('Histogram of Equivalent Areas in Pixels');
xlabel('Equivalent Area in Pixels');
ylabel('Number of nuclei');

%function to count detected nuclei
function count(im,plane,text)
global boundaries;
global label;
global num;
%get boundaries and number of elements
[boundaries,label,num]  = bwboundaries(im, 'noholes');
assignin('base','number_of_detected_nuclei',num);
axes(plane);
imshow(im);
set(text,'String',strcat('Number of detected nuclei: ',num2str(num)));
hold on
%dear borders over detected nuclei
for k = 1:num
boundary = boundaries{k};
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 0.2)
end

%watershedding technique to segment attached nuclei
function w = watershedding(im)
%Calculate the distance transform of the complement of the binary image.
D = bwdist(~im);
%Take the complement of the distance transformed image so that light pixels represent high elevations and dark pixels represent low elevations
D = -D;
L = watershed(D);
% Set pixels that are outside the ROI to 0.
L(~im) = 0;

%convert to binary
L = double(L);
w = imbinarize(L);


function m = morphology(im)
%open blobs that are less than 9 pixels
b = bwareaopen(im,9);
%dialate if distance is less than 2
dilate = imdilate(b,true(2));
%open with structuring element
se = strel('disk',1);
open = imopen(dilate,se);
m = open;

function f = filter(im)
f=medfilt2(im);

%convert gray image to binary
function bw = threshold(im)
%get the green parts first
s = segmentgreen(im);
%adapt histogram equalisation
a = adapthisteq(s);
bw = imbinarize(a,'adaptive');
    
function nuclei = getnuclei(im)
greenness = segmentgreen(im)
%convert to logical
green_binary = imbinarize(greenness);
%invert
green_binary_invert = imcomplement(green_binary);
%copy the image
segmented_green = im;
%only show surpressed parts
segmented_green(green_binary_invert) = 0;
nuclei = segmented_green;

function greenness = segmentgreen(im)
%get rgb channels
red= im(:,:,1);
green= im(:,:,2);
blue= im(:,:,3);

%get average green intensity
greenness= green -(red+blue)/2;
assignin('base','nuclei_segmented_grayimage',greenness);

%this function hides and displays gui according to program stage
function showprogram(c,hObject, eventdata, handles)
if c == 1
    set(handles.Heading,'visible','off') 
    set(handles.OK,'visible','off') 
    set(handles.view1,'visible','off') 
    set(handles.view2,'visible','off') 
    set(handles.view3,'visible','off') 
    set(handles.text1,'visible','off') 
    set(handles.text2,'visible','off')
    set(handles.image_path,'visible','off') 
    set(handles.browse,'visible','off') 
    set(handles.heading2,'visible','on') 
    set(handles.text,'visible','on') 
    set(handles.plane,'visible','on') 
    set(handles.next,'visible','on') 
    set(handles.heading2,'String','The Initial Laser Microscopic Image Of The Plant Root');
    axes(handles.plane);
    global im;
    imshow(im);
    set(handles.plane,'Units','normalized');
    guidata(hObject, handles);
elseif c==2
    set(handles.Heading,'visible','on') 
    set(handles.OK,'visible','off') 
    set(handles.view1,'visible','off') 
    set(handles.view2,'visible','off') 
    set(handles.view3,'visible','off') 
    set(handles.text1,'visible','off') 
    set(handles.text2,'visible','on')
    set(handles.image_path,'visible','off') 
    set(handles.browse,'visible','off') 
    set(handles.heading2,'visible','off') 
    set(handles.text,'visible','off') 
    cla(handles.plane);
    cla(handles.plane1);
    cla(handles.plane2);
    set(handles.plane,'visible','off') 
    set(handles.plane1,'visible','off') 
    set(handles.plane2,'visible','off') 
    set(handles.next,'visible','off') 
    set(handles.Heading,'String','Thank You!');
    set(handles.text2,'String','All important data and graphs are stored in the workplace');
    guidata(hObject, handles);
end
    
