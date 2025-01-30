function f = gridobj(x, gridsize, n, sfreq, efreq, nfreq, sparam, match, xdata)
    t = getCurrentTask();
    if isempty(t)
        filename = 'grid';
    else
        filename = ['grid' num2str(t.ID)];
    end
    config = round(x);
    s = gridmake(gridsize, config, n, filename, 0, sfreq, efreq, nfreq);
    % switch match
    %     case 1
    %         f = zeros(1, n^2);
    % end
    for ii = 1:n^2
        [i, j] = ind2sub([n, n], ii);
        s1 = s.Parameters(i, j, :);
        s2 = sparam.Parameters(i, j, :);
        switch match
            case 1
                f(i, j, :) = db(s1);
        end
    end
    f = reshape(f, 1, []);
end