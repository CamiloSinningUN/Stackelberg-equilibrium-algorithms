#  --- SETS, PARAMETERS, AND VARIABLES ---
# Time
param time integer;
set TIME := 0..time;
set TIME_WITHOUT_ZERO := 1..time;

# Environment
param rows integer;
param cols integer;
param cells integer := rows*cols;
set CELLS := 0..(cells-1);
set CELLS_WITH_I := -1..(cells-1);
param V {CELLS}; # Encoding: 0 = blocked, 1 = empty, 2 = target

# States
set STATES; # Covered(0), Uncovered(1)
set ROLES; # Defender(0), Attacker(1)

# Utility
set TARGETS := {v in CELLS: V[v] = 2};
param U {TARGETS, ROLES, STATES};

# Constant
param Z;

# Strategy
var alpha {CELLS_WITH_I, CELLS, TIME} binary >= 0; # Defender
var x {TARGETS, TIME_WITHOUT_ZERO} binary >= 0; # Attacker

# Expected utilities
var d; # Defender
var k; # Attacker

# --- OBJECTIVE ---
maximize obj:
    d
;

# --- CONSTRAINTS ---
# Movement
subject to GetOutFromIAtZero {t in TIME}:
    sum{v_p in CELLS} alpha[-1, v_p, t] = if (t = 0) then 1 else 0
;

subject to FollowASequence {v in CELLS, t in TIME_WITHOUT_ZERO}:
    sum{v_p in CELLS} alpha[v, v_p, t] <= sum{v_pp in CELLS_WITH_I} alpha[v_pp, v, t-1]
;

subject to MovementRestrictions {v in CELLS_WITH_I, v_p in CELLS, t in TIME}:
    alpha[v, v_p, t] <= if (V[v_p] = 1 or V[v_p] = 2) then 1 else 0
;

subject to MovementToAdjacentCells {v in CELLS, v_p in CELLS, t in TIME_WITHOUT_ZERO}:
    alpha[v, v_p, t] <= if (v = v_p) or (v = v_p + 1 and v_p != -1 and v mod cols != 0) or (v = v_p - 1 and v_p mod cols != 0) or (v = v_p + cols) or (v = v_p - cols) then 1 else 0 
;

# Probability constraints
subject to SumToOneDefender {t in TIME}:
    sum{v in CELLS_WITH_I, v_p in CELLS} alpha[v, v_p, t] = 1
;

subject to SumToOneAttacker {t in TIME_WITHOUT_ZERO}:
    sum{v in TARGETS} x[v, t] = 1 # Attack by force every time
;

# ERASER constraints

subject to defenderExpectedPayoff {v in TARGETS, t in TIME_WITHOUT_ZERO}:
    d - ((sum{v_p in CELLS} alpha[v, v_p, t])*U[v, 0, 0] + (1-(sum{v_p in CELLS} alpha[v, v_p, t]))*U[v, 0, 1]) <= (1-x[v, t])*Z
;

subject to attackerStrategy1 {v in TARGETS, t in TIME_WITHOUT_ZERO}:
    k - ((sum{v_p in CELLS} alpha[v, v_p, t])*U[v, 1, 0] + (1-(sum{v_p in CELLS} alpha[v, v_p, t]))*U[v, 1, 1]) >= 0
;

subject to attackerStrategy2 {v in TARGETS, t in TIME_WITHOUT_ZERO}:
    k - ((sum{v_p in CELLS} alpha[v, v_p, t])*U[v, 1, 0] + (1-(sum{v_p in CELLS} alpha[v, v_p, t]))*U[v, 1, 1]) <= (1-x[v,t])*Z
;






