function filtered = depthImageInterpolation(orig, seg)
% This function tries to fill out the missing depth values (0s) in a depth
% image from the Kinect.
% The missing zeros are filled out by using an iterative process where each
% missing pixel is given the mean of the 5X5 pixel window around the
% pixel
filtered = double(orig);
seg = double(seg);
tolerance = 0.01;
[missX missY] = find(orig == 0);
distBound = zeros(size(missX));
for i = 1:length(missX);
    distBound(i) = min(min(missX(i),size(orig,1)-missX(i)),min(missY(i),size(orig,2) - missY(i)));
end
sorted = sortrows([missX missY distBound],3);
missX = sorted(:,1);
missY = sorted(:,2);
iter = 0;
diffSum = Inf;

while (diffSum > tolerance && iter < 10)
    diffSum = 0;
    for i = 1:length(missX)
        curX = missX(i);
        curY = missY(i);
        window = filtered(max(1,curX-2):min(size(orig,1),curX+2),max(1,curY-2):min(size(orig,2),curY+2));
        segWindow = seg(max(1,curX-2):min(size(orig,1),curX+2),max(1,curY-2):min(size(orig,2),curY+2));
        nonZwindow = window(window~=0 & segWindow==seg(curX,curY));
        if ~isempty(nonZwindow)
            avgVal = median(nonZwindow(:));
            diffSum = diffSum + (abs(filtered(curX,curY) - avgVal)./avgVal);
            filtered(curX,curY) = avgVal;
        end
    end
    iter = iter + 1;
end
filtered = uint16(filtered);
end