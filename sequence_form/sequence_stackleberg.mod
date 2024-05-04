set Ql;
set Qf;

set Hl;
set Hf;

param Ff{Hf, Qf};
param Fl{Hl, Ql};

param fl{Hl};
param ff{Hf};

param Ml;
param Mf;

param Ul{Ql, Qf};
param Uf{Ql, Qf};

var rl{Ql} >= 0;
var rf{Qf} integer >= 0, <= 1;

var z{Ql, Qf};
var vf{Hf};

maximize obj:
    sum{ql in Ql, qf in Qf} z[ql, qf]
;

subject to cons_1 {qf in Qf}:
    sum{hf in Hf}(Ff[hf, qf] * vf[hf]) - sum{ql in Ql}(Uf[ql, qf] * rl[ql]) - Mf*(1 - rf[qf]) <= 0
;

subject to cons_2 {qf in Qf}:
    sum{hf in Hf}(Ff[hf, qf] * vf[hf]) - sum{ql in Ql}(Uf[ql, qf] * rl[ql]) >= 0
;

subject to cons_3 {hf in Hf}:
    sum{qf in Qf}(Ff[hf, qf] * rf[qf]) = ff[hf]
;

subject to cons_4 {hl in Hl}:
    sum{ql in Ql}(Fl[hl, ql] * rl[ql]) = fl[hl]
;


subject to cons_5 {ql in Ql, qf in Qf}: 
    z[ql, qf] - rf[qf]*Ml <= 0
;

subject to cons_6 {ql in Ql, qf in Qf}:
    z[ql, qf] <= Ul[ql, qf]*rl[ql]
;

