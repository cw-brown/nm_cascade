clear; clc; close all;
gridsize = 9;
stx = randi([0, 1], 1, gridsize^2);
s = gridmake(gridsize, stx, 2, 'grid', 1, 2, 5.5);
rfplot(s);
