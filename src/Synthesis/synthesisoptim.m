function f = synthesisoptim(x, sz, freqs, errfunc, terms)
    s = param2s(x, sz, freqs, terms); s = s(1, 2, :);
    f = sqrt(mean((db(s(:)') - db(errfunc(:)')).^2));
end