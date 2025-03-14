%% Plot the cost function at different variables
%% Circuit 1 in S-parameters
clear; clc;
s = tf('s');
stx = [6.67e-6, 16658];
o = sqrt(1/stx(1)/stx(2));
freqs = linspace(0.1, 2*o, 200);
% Circuit 1 - Inductor
Z = 1/(s*stx(1));
g(1,1) = Z/(100+Z); g(2,2) = g(1,1);
g(1,2) = 100/(100+Z); g(2,1) = g(1,2);
s1 = sparameters(freqresp(g, freqs), freqs);

%% Circuit 2 in S-parameters
% Circuit 1 - Capacitor
Z = s*stx(2);
h(1,1) = Z/(100+Z); h(2,2) = h(1,1);
h(1,2) = 100/(100+Z); h(2,1) = h(1,2);
s2 = sparameters(freqresp(h, freqs), freqs);

%% Cascaded
sc = cascadesparams(s1, s2);

%% Error and setup
err = [abs(squeeze(sc.Parameters(1,1,:)))'...
       abs(squeeze(sc.Parameters(1,2,:)))'...
       angle(squeeze(sc.Parameters(1,1,:)))'...
       angle(squeeze(sc.Parameters(1,2,:)))'];
% err = [db(squeeze(sc.Parameters(1,1,:)))'...
%        db(squeeze(sc.Parameters(1,2,:)))'...
%        unwrap(rad2deg(angle(squeeze(sc.Parameters(1,1,:)))))'...
%        unwrap(rad2deg(angle(squeeze(sc.Parameters(1,2,:)))))'];
% err = [34*real(squeeze(sc.Parameters(1,1,:)))'...
%        34*real(squeeze(sc.Parameters(1,2,:)))'...
%        34*imag(squeeze(sc.Parameters(1,1,:)))'...
%        34*imag(squeeze(sc.Parameters(1,2,:)))'...
%        db(squeeze(sc.Parameters(1,1,:)))'...
%        db(squeeze(sc.Parameters(1,2,:)))'...
%        unwrap(rad2deg(angle(squeeze(sc.Parameters(1,1,:)))))'...
%        unwrap(rad2deg(angle(squeeze(sc.Parameters(1,2,:)))))'];

nvar = 16;
x = ones(1, nvar);
sweep = linspace(-100,100,200);

pt = zeros(size(x));
eval = zeros(size(sweep));
figure;
for ii = 1:nvar
    parfor jj = 1:length(sweep)
        pt = x;
        pt(ii) = sweep(jj);
        eval(jj) = mlobj(pt, freqs, err);
    end
    subplot(4,4,ii);
    plot(sweep, eval); grid on;
    % title(['Cost Function of Variable ' num2str(ii)]); grid on;
    xlabel('Variable Value'); ylabel('Function Evaluation');
end

function f = mlobj(x, freqs, err)
    Y = mt(x, freqs);
    U = [abs(squeeze(Y.Parameters(1,1,:)))'...
         abs(squeeze(Y.Parameters(1,2,:)))'...
         angle(squeeze(Y.Parameters(1,1,:)))'...
         angle(squeeze(Y.Parameters(1,2,:)))'];
    % U = [db(squeeze(Y.Parameters(1,1,:)))'...
    %      db(squeeze(Y.Parameters(1,2,:)))'...
    %      unwrap(rad2deg(angle(squeeze(Y.Parameters(1,1,:)))))'...
    %      unwrap(rad2deg(angle(squeeze(Y.Parameters(1,2,:)))))'];
    % U = [34*squeeze(real(Y.Parameters(1, 1, :)))'...
    %      34*squeeze(real(Y.Parameters(1, 2, :)))'...
    %      34*squeeze(imag(Y.Parameters(1, 1, :)))'...
    %      34*squeeze(imag(Y.Parameters(1, 2, :)))'...
    %      db(squeeze(Y.Parameters(1,1,:)))'...
    %      db(squeeze(Y.Parameters(1,2,:)))'...
    %      unwrap(rad2deg(angle(squeeze(Y.Parameters(1,1,:)))))'...
    %      unwrap(rad2deg(angle(squeeze(Y.Parameters(1,2,:)))))'];
    f = rmse(U,err);
end

function y = mt(x, freqs)
    s = tf('s');
    g(1,1) = x(1) + x(2)/(abs(x(3))+s*x(4)); g(2,2) = g(1,1);
    g(1,2) = x(5) + x(6)/(abs(x(7))+s*x(8)); g(2,1) = g(1,2);
    F1 = sparameters(freqresp(g, freqs), freqs);

    h(1,1) = x(9) + x(10)/(abs(x(11))+s*x(12)); h(2,2) = h(1,1);
    h(1,2) = x(13) + x(14)/(abs(x(15))+s*x(16)); h(2,1) = h(1,2);
    F2 = sparameters(freqresp(h, freqs), freqs);
    y = cascadesparams(F1, F2);
end