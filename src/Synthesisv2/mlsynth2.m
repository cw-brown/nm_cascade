%% Test file to compose one curve from many
clear; clc; close all;

% Parameters of the discrete system
sz = [2, 2, 1, 4];
networks = fpg(sz);
nvar = 7*sum(networks.^2+networks)/2;


