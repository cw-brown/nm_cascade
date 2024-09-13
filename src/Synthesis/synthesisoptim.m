function f = synthesisoptim(x, freqs, errfunc, order)
    s = param2s(x, freqs, order); s = s(1, 2, :);
    f = sqrt(mean((db(s(:)') - db(errfunc(:)')).^2));
end