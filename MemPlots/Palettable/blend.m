%BLEND Takes two RGB values and returns one that's an HSV blend of the two
function c = blend(color1, color2)
    color1HSV = rgb2hsv(color1);
    color2HSV = rgb2hsv(color2);
    c = hsv2rgb(mean([color1HSV;color2HSV]));
    c(c<0) = 0;
    c(c>1) = 1;
end
