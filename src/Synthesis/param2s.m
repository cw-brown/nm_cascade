function s = param2s(n, freqs, order)
    % Turn a vector of parameters N into an s-parameter matrix using
    % impedance synthesis
    s = tf('s');
    % z11 = (n(1)*s^3 + n(2)*s) / (n(3)*s^2 + n(4));
    % z22 = (n(5)*s^3 + n(6)*s) / (n(7)*s^2 + n(8));
    % z12 = (n(9)*s^3 + n(10)*s) / (n(11)*s^2 + n(12));
    z11 = cauer1(n(1:order) * s);
    z22 = cauer1(n(order+1:order*2) * s);
    z12 = cauer1(n(order*2+1:order*3) * s);
    z(1, 1, :) = freqresp(z11, freqs);
    z(2, 2, :) = freqresp(z22, freqs);
    z(1, 2, :) = freqresp(z12, freqs);
    z(2, 1, :) = z(1, 2, :);
    s = z2s(z);
end