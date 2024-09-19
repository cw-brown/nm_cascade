n = 1e-3*rand(1, 3*8);
sz = 2;
freqs = logspace(1, 6, 50);
ntran = (sz^2+sz)/2;
[a, b] = meshgrid(1:sz, 1:sz);
a = triu(a); b = triu(b);
a = a(a ~= 0); b = b(b ~= 0);
z = zeros(sz, sz, length(freqs));
st = 1;
for ii = 1:ntran
    denominator = [n(st), 0, n(st+1), 0, n(st+2), 0, n(st+3)];
    numerator = [n(st+4), 0, n(st+5), 0, n(st+6), 0, n(st+7), 0];
    g(a(ii), b(ii)) = tf(numerator, denominator);
    g(b(ii), a(ii)) = g(a(ii), b(ii));
    st = st + 8;
end
y = 1/sqrt(50) * eye(sz);
S = (y*g*y+eye(sz))\(y*g*y-eye(sz));
S = freqresp(S, freqs);
S = sparameters(S, freqs);
rfplot(S);
xscale("log");