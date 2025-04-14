clear; clc; close all;
s = tf('s');
nfreq = 200;
lims = [0.01,2];
freqs = linspace(lims(1), lims(2), nfreq);
stx = [1, 0.5, 0.35, 0.025, 0.025, 0.025];

s1 = makecircuit(stx(1:3), freqs);
s2 = makecircuit(stx(4:6), freqs);
sc = cascadesparams(s1, s2);

%% Error and setup
err = [real(squeeze(sc.Parameters(1,1,:)))'...
       real(squeeze(sc.Parameters(1,2,:)))'...
       real(squeeze(sc.Parameters(2,2,:)))'...
       imag(squeeze(sc.Parameters(1,1,:)))'...
       imag(squeeze(sc.Parameters(1,2,:)))'...
       imag(squeeze(sc.Parameters(2,2,:)))'];

sz = [2, 2, 1, 2];
networks = fpg(sz);
nvar = 3*sum(networks.^2+networks)/2;

x = ones(1,nvar);
sweep = linspace(-1,1,100);
%%
pt = zeros(size(x));
eval = zeros(size(sweep));
figure;
for ii = 1:nvar/2
    parfor jj = 1:length(sweep)
        pt = x;
        pt(ii) = sweep(jj);
        eval(jj) = synthobj(pt,sz,freqs,err);
    end
    subplot(3,9,ii);
    plot(sweep, eval); grid on; 
    title(['Variable ' num2str(ii)]); grid on;
    xlabel('Variable Value'); ylabel('Function Evaluation');
    drawnow;
end

figure;
for ii = nvar/2+1:nvar
    parfor jj = 1:length(sweep)
        pt = x;
        pt(ii) = sweep(jj);
        eval(jj) = synthobj(pt,sz,freqs,err);
    end
    subplot(3,9,ii-27);
    plot(sweep, eval); grid on; 
    title(['Variable ' num2str(ii)]); grid on;
    xlabel('Variable Value'); ylabel('Function Evaluation');
    drawnow;
end

%% Functions
function gsys = tranmake(x, sz)
    % Return a cell array of MIMO systems formed from x values
    networks = fpg(sz);
    gsys = cell(1, length(networks));
    st = 1;
    for ii = 1:length(networks)
        nvar = 3*(networks(ii)^2+networks(ii))/2;
        gsys{ii} = mimotm(x(st:st+nvar-1), networks(ii));
        st = st + nvar;
    end

    function g = mimotm(x, sz)
        s = tf('s');
        nt = (sz^2 + sz)/2;
        g = tf(1, 1);
        i = meshgrid(1:sz, 1:sz);
        ip = triu(i); ig = triu(i');
        ip = nonzeros(ip); ig = nonzeros(ig);
        nf = 3;
        for jj = 1:nt
            g(ip(jj), ig(jj)) = x((jj-1)*nf+1) + ...
                x((jj-1)*nf+2)/(s+abs(x((jj-1)*nf+3)));
            g(ig(jj), ip(jj)) = g(ip(jj), ig(jj));
        end
    end
end

function f = synthobj(x, sz, freqs, err)
    G = tranmake(x, sz);
    H = tsc(G, sz);
    F = sparameters(freqresp(H,freqs),freqs);
    U = [real(squeeze(F.Parameters(1,1,:)))'...
         real(squeeze(F.Parameters(1,2,:)))'...
         real(squeeze(F.Parameters(2,2,:)))'...
         imag(squeeze(F.Parameters(1,1,:)))'...
         imag(squeeze(F.Parameters(1,2,:)))'...
         imag(squeeze(F.Parameters(2,2,:)))'];
    f = rmse(U,err);
end

function s = makecircuit(x, freqs)
    s = tf('s');
    Z1 = x(1)*s;
    Z2 = 1/(x(2)*s);
    Z3 = 1/(x(3)*s);
    A = 1+Z1/Z3;
    B = Z1+Z2+Z1*Z2/Z3;
    C = 1/Z3;
    D = 1+Z2/Z3;
    O = [freqresp(A,freqs), freqresp(B,freqs); freqresp(C,freqs), freqresp(D,freqs)];
    s = sparameters(abcd2s(O, 50),freqs);
end