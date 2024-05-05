# Time
set T; # start with 1

# Environment
set ROWS; 
set COLUMNS;

# States
set STATE; # Covered(0), Uncovered(1)
set ROLE; # Defender(0), Attacker(1)

# Grid
param V{ROWS, COLUMNS} binary; # Encoding: 0 = blocked, 1 = empty, 2 = target

# Targets
# set TARGETS; # Position in grid, starting with 0,0 = 0, 0,1 = 1, etc.
# set TARGET_ROWS; # Calculate this from V
# set TARGET_COLUMNS; # Calculate this from V
set TARGET_ROWS := {i in ROWS: exists{j in COLUMNS} V[i,j] = 2};
set TARGET_COLUMNS := {j in COLUMNS: exists{i in ROWS} V[i,j] = 2};

# Utility
param U{ROLE, STATE, TARGET_ROWS, TARGET_COLUMNS};

# Constant
param Z;


# Movement
var alpha{ROWS, COLUMNS, ROWS, COLUMNS, T} binary >= 0; # Deterministic movement (Could be stochastic)
var alpha_0{ROWS, COLUMNS} binary >= 0; # Initial movement

# Attack
var x{ROWS, COLUMNS, T} binary >= 0; # Attack

# Expected utility of the defender
var d;

# Expected utility of the attacker
var k;

# Auxiliary variable
var c{r in ROWS, c in COLUMNS, t in R} := sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t];

# Objective
maximize obj:
    d
;

# --- Constraints ---
# Movement
subject to MoveOnlyToCellsWithValueOneOrTwo{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= 1 if V[r_p, c_p] = 1 or V[r_p, c_p] = 2 else 0;
;

subject to ConsistencyConstraint{r in ROWS, c in COLUMNS, t in T}:
    sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t] = sum{r_pp in ROWS, c_pp in COLUMNS} alpha[r_pp, c_pp, r, c, t+1] if t < max{T} else 0
;

subject to MovementToAdjacentCells{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= 1 if (r = r_p and c = c_p) or (r = r_p and c = c_p + 1) or (r = r_p and c = c_p - 1) or (r = r_p + 1 and c = c_p) or (r = r_p - 1 and c = c_p) else 0 
;

subject to MovementInsideGrid{r in ROWS, c in COLUMNS, r_p in ROWS, c_p in COLUMNS, t in T}:
    alpha[r, c, r_p, c_p, t] <= 1 if r_p >= 0 and r_p < CARDINALITY(ROWS) and c_p >= 0 and c_p < CARDINALITY(COLUMNS) - 1 else 0   
;

# Attack
subject to CanOnlyAttackInCellsThatAreTargets{r in ROWS, c in COLUMNS, t in T}:
    x[r, c, t] <= 1 if V[r, c] = 2 else 0
;

# Ficticious cell
subject to atTZeroYouAreInFictitiousCell:
    sum{r in ROWS, c in COLUMNS} alpha_0[r, c] = 1
;

# Probability constraints
subject to SumToOneDefender{r in ROWS, c in COLUMNS, t in T}:
    sum{r_p in ROWS, c_p in COLUMNS} alpha[r, c, r_p, c_p, t] = 1
;

subject to SumToOneAttacker{t in T}:
    sum{r in ROWS, c in COLUMNS} x[r, c, t] = 1
;

# ERASER constraints

subject to defenderExpectedPayoff{r in TARGET_ROWS, c in TARGET_COLUMNS, t in T}: # All targets
    d - (c[r, c, t]*U[0, 0, r, c] + (1-c[r, c, t])*U[0, 1, r, c]) <= (1-x[r,c,t])*Z
;

subject to attackerStrategy{r in TARGET_ROWS, c in TARGET_COLUMNS, t in T}: # All targets
    0 <= k - (c[r, c, t]*U[1, 0, r, c] + (1-c[r, c, t])*U[1, 1, r, c]) <= (1-x[r,c,t])*Z
;