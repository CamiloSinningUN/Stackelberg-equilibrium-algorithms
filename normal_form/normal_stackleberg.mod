set Al;
set Af;

param Ul{Al, Af};
param Uf{Al, Af};
param Af_bar;

var sl{Al} >= 0;

maximize obj:
    sum{al in Al} Ul[al, Af_bar] * sl[al]
;

subject to cons{af in Af}:
    sum{al in Al} Uf[al, Af_bar]* sl[al] - sum{al in Al} Uf[al, af]* sl[al] >= 0
;

subject to SumToOneLeader: 
    sum{al in Al} sl[al] = 1
;
