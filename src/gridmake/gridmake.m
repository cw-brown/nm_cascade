function [s, p] = gridmake(pgridsize, config, n, name, openfile, sfreq, efreq)
%   pgridsize := The side length of the square pixelated area
%   configuration := a binary number of length 2^(pgridsize^2) that is
%                    the unique pixelated configuration
    arguments
        pgridsize (1, 1) {mustBeNonnegative, mustBeInteger}
        config {mustBeNumericOrLogical}
        n (1, 1) {mustBeNonnegative, mustBeInteger}
        name {mustBeText}
        openfile {mustBeNumericOrLogical}
        sfreq (1, 1) {mustBeFloat}
        efreq (1, 1) {mustBeFloat}
    end

    offset = 2;
    
    p = SonnetProject();
    p.changeLengthUnit('MM');
    p.replaceDielectricLayer(1, 'Air', 100);
    p.replaceDielectricLayer(2, 'FR-4', 300);
    p.defineNewMetalType('Copper', 1);
    p.addAbsFrequencySweep(sfreq, efreq);
    p.changeFrequencyUnit('GHz');

    wcm = [1, 0; ...
           1, 1; ...
           2, 1; ...
           2, 2];
    
    p.changeBoxSize(pgridsize+2+wcm(n, 1)*offset, pgridsize+2+wcm(n, 2)*offset);
    p.changeCellSizeUsingNumberOfCells(1, 1);
   
    %% Only god knows whats happening here, dont change
    % i dont understand this at all, literal black magic to make it work
    p1 = [0, 0, 0, 1];
    p2 = [0, 1, 1, 1];
    p3 = [0, 1, 1, 2];
    hg = round(pgridsize/2);
    pxo = [0, hg+p2(n)*offset, pgridsize+1+2*offset, hg+offset];
    pyo = [hg+p1(n)*offset, pgridsize+1+p3(n)*offset, hg+p1(n)*offset, 0];
    flx = [offset, 1, -offset, 1];
    fly = [1, -offset, 1, offset];
    flxo = [1, hg+p2(n)*offset, pgridsize+1+2*offset, hg+offset];
    flyo = [hg+p1(n)*offset, pgridsize+1+p3(n)*offset, hg+p1(n)*offset, 1];

    for ii = 1:n
        [x, y] = createSquare(1, 1, pxo(ii), pyo(ii));
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
        if grid(ii) == 1
            [x, y] = createSquare(1, 1, row+gcm(n,1)*offset, col+gcm(n,2)*offset);
            p.addMetalPolygonEasy(0, x, y, 'Copper');
        end
    end
    
    %%
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