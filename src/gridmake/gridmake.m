function [s, p] = gridmake(pgridsize, config)
%   pgridsize := The side length of the square pixelated area
%   configuration := a binary number of length 2^(pgridsize^2) that is
%                    the unique pixelated configuration
    arguments
        pgridsize (1, 1) {mustBeNonnegative, mustBeInteger}
        config (1, 1) {mustBeNonnegative, mustBeInteger}
    end

    binsize = pgridsize^2;
    
    p = SonnetProject();
    p.changeLengthUnit('MM');
    p.replaceDielectricLayer(1, 'Air', 100);
    p.replaceDielectricLayer(2, 'FR-4', 300);
    p.defineNewMetalType('Copper', 1);
    p.addAbsFrequencySweep(1, 25);
    
    p.changeBoxSize(pgridsize+2, pgridsize+2);
    p.changeCellSizeUsingNumberOfCells(1, 1);
    
    % Create each port square on the edges
    n = 2;
    halfx = round(pgridsize/2);
    halfy = round(pgridsize/2);
    xoff = [0, halfx, pgridsize+1, halfx];
    yoff = [halfy, pgridsize+1, halfy, 0];
    for ii = 1:n
        [x, y] = createSquare(1, 1, xoff(ii), yoff(ii));
        polygon = p.addMetalPolygonEasy(0, x, y, 'Copper');
        p.addPortToPolygon(polygon, ii);
    end
    
    grid = reshape(pad(dec2bin(config), binsize, 'left', '0'), pgridsize, pgridsize);
    for ii = 1:binsize
        [row, col] = ind2sub([pgridsize, pgridsize], ii);
        if grid(ii) == '1'
            [x, y] = createSquare(1, 1, row, col);
            p.addMetalPolygonEasy(0, x, y, 'Copper');
        end
    end
    
    p.addFileOutput('TS', 'D', 'Y', ['grid.s' num2str(n) 'p'], 'NC', 'N', 'S', 'MA', 'R', 50);
    p.saveAs('grid.son');
    [success, message] = p.simulate('-t -c');
    if success ~= 0
        disp(message);
    else
        s = sparameters(['grid.s' num2str(n) 'p']);
    end
end