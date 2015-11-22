clear all
clc
close all hidden                      %Close all windows if opened
a=zeros(1024,5);
t = cputime;
parfor (i=1:1024)
    myTemp = zeros(1,5);
    for jx = 1:5
        myTemp(jx) = i+jx;
    end
    a(i,:) = myTemp;
end
e = cputime-t