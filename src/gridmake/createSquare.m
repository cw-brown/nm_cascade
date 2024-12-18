function [x, y] = createSquare(length, width, xOffset, yOffset)
    x = [xOffset xOffset length+xOffset length+xOffset];
    y = [yOffset width+yOffset width+yOffset +yOffset];
end