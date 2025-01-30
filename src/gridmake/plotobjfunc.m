clear; clc;
gridsize = 2;
% stx = randi([0, 1], 1, gridsize^2);
stx = zeros(1, gridsize^2);
n = 2;
sfreq = 1;
efreq = 4;
nfreq = 100;

s = gridmake(gridsize, stx, n, 'grid', 0, sfreq, efreq, nfreq);

solutionspace = 2^(gridsize^2);
eval = zeros(1, solutionspace);


% for ii = 1:solutionspace
%     config = pad(dec2bin(ii-1), gridsize^2, 'left', '0');
%     eval(ii) = obj(config, gridsize, n, sfreq, efreq, nfreq, s);
% end
for ii = 0:solutionspace-1
    config = pad(dec2bin(ii), gridsize^2, 'left', '0');
    eval(ii+1) = sum(obj(config, gridsize, n, sfreq, efreq, nfreq, s));
    disp(['Config ' num2str(ii) ' done.']);
end

figure
plot(0:solutionspace-1, eval);

function f = obj(x, gridsize, n, sfreq, efreq, nfreq, desired)
    t = getCurrentTask();
    filename = ['gridobj'];
    s = gridmake(gridsize, x, n, filename, 0, sfreq, efreq, nfreq);
    st = 1;
    for ii = 1:n^2
        [row, col] = ind2sub([n, n], ii);
        f(st) = sum(abs((db(s.Parameters(row, col, :)) - db(desired.Parameters(row, col, :))).^2));
        st = st + 1;
    end
end