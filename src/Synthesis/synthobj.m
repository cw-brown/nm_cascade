function f = synthobj(x, sz, freqs)
    h = mimotm(x, sz);
    h = frd(h, freqs); s = h.ResponseData(1, 2, :);
    f = db(s(:)');
end