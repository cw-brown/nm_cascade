npoles = 2;
s = tf('s');
g = tf([1,1;1,1]);
nvar = 3*(1+npoles*2);
x = rand(1,nvar);

st = 1;
for ii = 1:4
    if ii == 2; continue; end
    [row,col] = ind2sub([2,2],ii);
    g(row,col) = x(st);
    for jj = 1:npoles
        g(row,col) = g(row,col) + x(st+1)/(abs(x(st+2))+s);
        st = st + 3;
    end
    st = st - 1;
    g(col,row) = g(row,col);
end