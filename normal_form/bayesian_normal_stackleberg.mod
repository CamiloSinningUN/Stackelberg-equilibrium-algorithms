set Al;
set Af;
set T;

param Ul{Al, Af};
param Uf{T, Al, Af};
param P{T};
param Af_bar{T};

var sl{Al} >= 0;

maximize obj:
    sum{t in T, al in Al} P[t] * Ul[al, Af_bar[t]] * sl[al]
;

subject to cons{af in Af, t in T}:
    sum{al in Al} Uf[t, al, Af_bar[t]]* sl[al] - sum{al in Al} Uf[t, al, af] * sl[al] >= 0
;

subject to SumToOneLeader: 
    sum{al in Al} sl[al] = 1
;