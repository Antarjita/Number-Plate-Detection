
function numberPlateExtraction
%NUMBERPLATEEXTRACTION extracts the characters from the input number plate image.
clc;clear all;close all;
f=imread('carplate2.jpg'); % Reading the number plate image.
%imshow(f);
f=imresize(f,[400 NaN]); % Resizing the image keeping aspect ratio same.
g=rgb2gray(f); % Converting the RGB (color) image to gray (intensity).
%imshow(g);
g=medfilt2(g,[3 3]);% Median filtering to remove noise.
%imshow(g);
se=strel('disk',1); % Structural element (disk of radius 1) for morphological processing.
gi=imdilate(g,se); % Dilating the gray image with the structural element.
%imshow(gi);
ge=imerode(g,se); % Eroding the gray image with structural element.
gdiff1=imsubtract(gi,ge); % Morphological Gradient for edges enhancement.
%imshow(gdiff1);
gdiff=mat2gray(gdiff1); % Converting the class to double.
gdiff=conv2(gdiff,[1 1;1 1]); % Convolution of the double image for brightening the edges.
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],0.1); % Intensity scaling between the range 0 to 1.
%subplot(1,2,1);
%imshow(gdiff1);
%subplot(1,2,2);
%imshow(gdiff);
B=logical(gdiff); % Conversion of the class from double to binary. 
% Eliminating the possible horizontal lines from the output image of regiongrow
% that could be edges of license plate.

%subplot(1,2,1);
%imshow(gdiff);
%subplot(1,2,1);
%imshow(B);
er=imerode(B,strel('line',50,0));% 50 is the length from the center and 0 is the degree from horizontal
out1=imsubtract(B,er);
%subplot(1,2,1);
%imshow(out1);
F=imfill(out1,'holes'); %filling out all the holes
%subplot(1,2,1);
%imshow(F);
%title('filling out the holes');
H=bwmorph(F,'thin',1); % fills the charecters to make it more distinct
%subplot(1,2,2);
%imshow(H);
%H=imerode(H,strel('line',3,90));
%subplot(1,2,1);
%imshow(H);
%title('Thinning the image to ensure character isolation.');
final=bwareaopen(H,100);%Remove objects containing fewer than 100 pixels ie.. suppresses noise further
subplot(1,2,1);
imshow(f);title('original image');
subplot(1,2,2);
imshow(final);title('final image');

%title('after using bwareaopen()');
%label=bwlabel(final); %tells the number of connected components
%disp('connected components');
%disp(label);
Iprops=regionprops(final,'BoundingBox','Image');
%Two properties 'BoundingBox' and binary 'Image' corresponding to these
% Bounding boxes are acquired.
delete '/Users/antarjita/PES/sem-4/image_processing/project/build/bounding_box.txt';
diary ('/Users/antarjita/PES/sem-4/image_processing/project/build/bounding_box.txt')

% Selecting all the bounding boxes in matrix of order numberofboxesX4;
%[left, top, width, height].
fprintf('left   top  width  height\n');
NR=cat(1,Iprops.BoundingBox);
disp(NR);

diary off

hold on
for k=1:size(NR,1)
    rectangle('Position',[NR(k,1),NR(k,2),NR(k,3),NR(k,4)],'EdgeColor','r','LineWidth',2);
end
hold off;


% Calling of controlling function.
r=controlling(NR); % Function 'controlling' outputs the array of indices of boxes required for extraction of characters.
if ~isempty(r) % If succesfully indices of desired boxes are achieved.
    I={Iprops.Image}; % Cell array of 'Image' (one of the properties of regionprops)
    noPlate=[]; % Initializing the variable of number plate string.
    for v=1:length(r)
        N=I{1,r(v)}; % Extracting the binary image corresponding to the indices in 'r'.
        letter=readLetter(N); % Reading the letter corresponding the binary image 'N'.
        while letter=='O' || letter=='0' 
            if v<=3                     
                letter='O';              
            else                         
                letter='0';              
            end                          
            break;                       
        end
         noPlate=[noPlate letter]; % Appending every subsequent character in noPlate variable.
    end
    fid = fopen('number_plate.txt', 'w'); 
    fprintf(fid,'%s\n',noPlate);      
    fclose(fid);                      
    system(('open number_Plate.txt'))
else 
    fprintf('Unable to extract the characters from the number plate.\n');
    fprintf('The characters on the number plate might not be clear or touching with each other or boundries.\n');
end
end
