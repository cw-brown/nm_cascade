function [s, p] = gridmake(pgridsize, config, n, name, openfile, sfreq, efreq, nfreq)
%   pgridsize := The side length of the square pixelated area
%   configuration := a binary number of length 2^(pgridsize^2) that is
%                    the unique pixelated configuration
    arguments
        pgridsize (1, 1) {mustBeNonnegative, mustBeInteger}
        config %{mustBeNumericOrLogical}
        n (1, 1) {mustBeNonnegative, mustBeInteger}
        name {mustBeText}
        openfile {mustBeNumericOrLogical}
        sfreq (1, 1) {mustBeFloat}
        efreq (1, 1) {mustBeFloat}
        nfreq
    end

    lambda = 299792458*1e-6/efreq/36;

    offset = 12*lambda;
    g = pgridsize*lambda;
    
    p = SonnetProject();
    p.changeLengthUnit('MM');
    p.replaceDielectricLayer(1, 'Air', 100);
    p.replaceDielectricLayer(2, 'FR-4', 1.6);
    p.enableCurrentCalculations();
    p.defineNewMetalType('Copper', 0.02);
    p.changeFrequencyUnit('GHz');
    p.addLsweepFrequencySweep(sfreq, efreq, nfreq);
    p.VariableSweepBlock.ArrayOfSweepSets{1}.ArrayOfSweeps{1}.AdaptiveEnabled = 'Y';
    wcm = [1, 0; ...
           1, 1; ...
           2, 1; ...
           2, 2];
    
    p.changeBoxSize(g+2*lambda+wcm(n, 1)*offset, g+2*lambda+wcm(n, 2)*offset);
    p.changeCellSizeUsingNumberOfCells(lambda, lambda);

    %% Only god knows whats happening here, dont change
    % i dont understand this at all, literal black magic to make it work
    hg = round(pgridsize/2)*lambda;
    p1 = [0, 0, 0, 1];
    p2 = [0, 1, 1, 1];
    p3 = [0, 1, 1, 2];
    pxo = [0, hg+p2(n)*offset, g+lambda+2*offset, hg+offset];
    pyo = [hg+p1(n)*offset, g+lambda+p3(n)*offset, hg+p1(n)*offset, 0];
    flx = [offset, lambda, -offset, lambda];
    fly = [lambda, -offset, lambda, offset];
    flxo = [lambda, hg+p2(n)*offset, g+lambda+2*offset, hg+offset];
    flyo = [hg+p1(n)*offset, g+lambda+p3(n)*offset, hg+p1(n)*offset, lambda];

    for ii = 1:n
        [x, y] = createSquare(lambda, lambda, pxo(ii), pyo(ii));
        polygon = p.addMetalPolygonEasy(0, x, y, 'Copper');
        p.addPortToPolygon(polygon, ii);
        [x, y] = createSquare(flx(ii), fly(ii), flxo(ii), flyo(ii));
        p.addMetalPolygonEasy(0, x, y, 'Copper');
    end

    gcm = [1, 0; ...
           1, 0; ...
           1, 0; ...
           1, 1];
    grid = reshape(config, pgridsize, pgridsize);
    for ii = 1:pgridsize^2
        [row, col] = ind2sub([pgridsize, pgridsize], ii);
        if grid(ii) == '1' || grid(ii) == 1
            [x, y] = createSquare(lambda, lambda, row*lambda+gcm(n,1)*offset, col*lambda+gcm(n,2)*offset);
            p.addMetalPolygonEasy(0, x, y, 'Copper');
        end
    end

    spname = [name '.s' num2str(n) 'p'];
    sonname = [name '.son'];
    p.addFileOutput('TS', 'D', 'Y', spname, 'NC', 'N', 'S', 'MA', 'R', 50);
    p.saveAs(sonname);
    [success, message] = p.simulate('-t -c');
    if success ~= 0
        error(message);
    else
        s = sparameters(spname);
    end

    if openfile
        p.openInSonnet();
    end
end