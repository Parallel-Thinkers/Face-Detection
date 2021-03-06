clear all
clc
close all hidden                      %Close all windows if opened
 % vid = videoinput('winvideo', 1);
% preview(vid);
 %pause(3);
 %img=getsnapshot(vid);
 %img=ycbcr2rgb(img);
t = cputime;
 img=imread('family.jpg');          %Reading an image file
[x y z]=size(img);                 %image size
per=500/x;
img=imresize(img,per);              %resizing image for better noise removal function
[x y z]=size(img) ;                %x y z get oerwrite
subplot(2,2,1)
imshow(img);
title('Original Image');

img=double(img);                    %Converting image in double format
                                %Calculating width,height and RGB components of the image

%RGB cimponent of image
R=img(:,:,1);                     
G=img(:,:,2);
B=img(:,:,3);



%%%%%%%%%%%%%%%%%%%%LIGHTING COMPENSATION ALGO

%converting image to YCbCr fort
YCbCr=rgb2ycbcr(img);
subplot(2,2,2)
imshow(YCbCr);
title('YCbCr');
Y=YCbCr(:,:,1);                 

%normalize Y compponent
minY=min(min(Y));
maxY=max(max(Y));
YEye=Y;
Yavg=sum(sum(Y))/(x*y);

if (Yavg<64)
    T=1.4;
elseif (Yavg>192)
    T=0.6;
else
    T=1;
end

RI=R.^T;
GI=G.^T;


img=zeros(x,y,3);
img(:,:,1)=RI;
img(:,:,2)=GI;
img(:,:,3)=B;


subplot(2,2,3)
imshow(img/255);
title('Lighting compensation');

%%%%%%%%%%%%%%%%%%%%%%%%%SKIN EXTRACTION ALGO

Cr=YCbCr(:,:,3);

aw=zeros(x,y);
parfor i=1:x
    myTemp = zeros(1,y);
    for j=1:y
        if(Cr(i,j)>8 && Cr(i,j)<40)
            myTemp(j)=1;
        end
        end
    aw(i,:)=myTemp;
end

subplot(2,2,4)
imshow(aw);
title('skin');

pause
%%%%%%%%%%%%NOISE REMOVAL
figure, subplot(2,2,1)
imshow(aw)
title('figure with noise');


se=strel('disk',5);
awn=imerode(aw,se);
subplot(2,2,2)
imshow(awn)
title('imerode');

awn=~awn;
awn=bwareaopen(awn, 1000);             %removing black areas of area<1000
awn=~awn;
subplot(2,2,3)
imshow(awn)
title('bwareaopen(<1000)');


awn = bwareaopen(awn, 1000);          %removing white areas of area<3000
subplot(2,2,4)
imshow(awn)
title('bwareaopen(<1000)');

pause


%%%%%%%%%%%%%%%%%%%%%FINDING SKIN COLOR(Faces) WHITE AREAS
label = bwlabel(awn,8);                    %give number to all the white areas
figure, subplot(1,2,1);
imshow(label)
impixelinfo;
title('bwlabel');

rgb=label2rgb(label);                    %give diffrent colour th diffren area
subplot(1,2,2);
imshow(rgb)
title('colour');

BB  = regionprops(label, 'BoundingBox');  %corners of the box
bboxes= cat(1, BB.BoundingBox);
lenRegions=size(bboxes,1);            %total ROI

BA=regionprops(label,'Area');
area=cat(1,BA.Area);
   
pause
for i=1:lenRegions
   
   areacurr=area(i);
   
   % get current region's bounding box
    bwcurrent=zeros(x,y);
    parfor l=1:x
        myTemp = zeros(1,y);
        for m=1:y
            if (label(l,m)==i)
                myTemp(m)=1;
            end
        end
        bwcurrent(l,:)=myTemp;
    end
    se=strel('disk',15);
    bwcurrent=imdilate(bwcurrent,se);
   
    
    BB  = regionprops(bwcurrent, 'BoundingBox');  %corners of the box
    bboxes= cat(1, BB.BoundingBox);
    lenRegions=size(bboxes,1);            %total ROI

    CurBox=bboxes;
    XStart=CurBox(1);
    YStart=CurBox(2);
    XEnd=CurBox(3);
    YEnd=CurBox(4);
    X=XEnd-XStart;
    Y=YEnd-YStart;
    % crop current region
    rangeY=int32(YStart):int32(YStart+YEnd-1);
    rangeX= int32(XStart):int32(XStart+XEnd-1);
    RIC=R(rangeY, rangeX);
    GIC=G(rangeY, rangeX);
    BC=B(rangeY, rangeX);
    RIC=cat(3,RIC,GIC,BC);
    foundFaces(i)=1;
    
    sizx=size(rangeX);
    sizy=size(rangeY);
    ratio2=sizy(2)/sizx(2);
    
        
    if ratio2>0.8 && ratio2<1.9
        [a b c]=size(RIC);
        if(a*b)>550 && a*b<55000
            ratio=b/a;
            if ratio>0.5 && ratio<1.4
                figure, imshow(RIC/255);
                title('Possible face');
    
            end
        end
    end
end
e = cputime-t
pause
clc

%%%%%%%%%%%%%%%%%%%%%%%END%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
