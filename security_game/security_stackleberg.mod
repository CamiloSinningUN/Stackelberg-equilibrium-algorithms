# Time
set T; # start with 1
set T_minus_1:= 1..card(T)-1;

# Environment
set ROWS; 
set COLUMNS;

# States
set STATE; # Covered(0), Uncovered(1)
set ROLE; # Defender(0), Attacker(1)

# Targets
set TARGET_ROWS ordered;
set TARGET_COLUMNS ordered;

# Grid
param V{ROWS, COLUMNS}; # Encoding: 0 = blocked, 1 = empty, 2 = target

# Utility
param U{TARGET_COLUMNS, TARGET_ROWS, ROLE, STATE};

# Constant
param Z;


# Movement
var alpha{ROWS, COLUMNS, ROWS, COLUMNS, T} binary >= 0; # Deterministic movement (Could be stochastic)
var alpha0{ROWS, COLUMNS} binary >= 0; # Initial movement

# Attack
var x{ROWS, COLUMNS, T} binary >= 0; # Attack

# Expected utility of the defender
var d;

# Expected utility of the attacker
var k;

# Objective
maximize obj:
    d
;

# --- Constraints ---
# Movement
subject to MoveOnlyToCellsWithValueOneOrTwo{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= if (V[r_p, c_p] = 1 or V[r_p, c_p] = 2) then 1 else 0
;

subject to ConsistencyConstraint{r in ROWS, c in COLUMNS, t in T_minus_1}:
    sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t] = sum{r_pp in ROWS, c_pp in COLUMNS} alpha[r_pp, c_pp, r, c, t+1]
;

subject to MovementToAdjacentCells{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= if (r = r_p and c = c_p) or (r = r_p and c = c_p + 1) or (r = r_p and c = c_p - 1) or (r = r_p + 1 and c = c_p) or (r = r_p - 1 and c = c_p) then 1 else 0 
;

subject to MovementInsideGrid{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= if ((r_p >= 0) and (r_p < card(ROWS)) and (c_p >= 0) and (c_p < card(COLUMNS) - 1)) then 1 else 0   
;

# Attack
subject to CanOnlyAttackInCellsThatAreTargets{r in ROWS, c in COLUMNS, t in T}:
    x[r, c, t] <= if (V[r, c] = 2) then 1 else 0
;

# Ficticious cell
subject to atTZeroYouAreInFictitiousCell:
    sum{r in ROWS, c in COLUMNS} alpha0[r, c] = 1
;

# Probability constraints
subject to SumToOneDefender{r in ROWS, c in COLUMNS, t in T}:
    sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t] = 1
;

subject to SumToOneAttacker{t in T}:
    sum{r in ROWS, c in COLUMNS} x[r, c, t] = 1
;

# ERASER constraints

# This ones go over all combinations of r and c, does not work

# subject to defenderExpectedPayoff{i in 1..card(TARGET_ROWS), t in T}:
#     d - ((sum{r_p in ROWS, c_p in COLUMNS} alpha[TARGET_ROWS[i], TARGET_COLUMNS[i], r_p, c_p, t])*U[TARGET_COLUMNS[i], TARGET_ROWS[i], 0, 0] + (1-(sum{r_p in ROWS, c_p in COLUMNS} alpha[TARGET_ROWS[i], TARGET_COLUMNS[i], r_p, c_p, t]))*U[TARGET_COLUMNS[i], TARGET_ROWS[i], 0, 1]) <= (1-x[TARGET_ROWS[i],TARGET_COLUMNS[i],t])*Z
# ;

subject to defenderExpectedPayoff{r in TARGET_ROWS, c in TARGET_COLUMNS, t in T}:
    d - ((sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t])*U[c, r, 0, 0] + (1-(sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t]))*U[c, r, 0, 1]) <= (1-x[r,c,t])*Z
;

subject to attackerStrategy1{r in TARGET_ROWS, c in TARGET_COLUMNS, t in T}:
    k - ((sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t])*U[c ,r, 1, 0] + (1-(sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t]))*U[c, r, 1, 1]) >= 0
;

subject to attackerStrategy2{r in TARGET_ROWS, c in TARGET_COLUMNS, t in T}:
    k - ((sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t])*U[c, r, 1, 0] + (1-(sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t]))*U[c, r, 1, 1]) <= (1-x[r,c,t])*Z
;