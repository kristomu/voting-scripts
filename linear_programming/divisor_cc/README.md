divisor\_cc
===========

Two attempts to combine Chamberlin-Courant and divisor methods by using the
"floating/variable quota" formulation of the latter. Unfortunately, whether
the method favors large or small parties depend nonlinearly on the quota. I
seem to get results consistent with the ordinary divisor methods with all-
plump ballots when the quota is the minimum possible that gives the right
number of seats.

Furthermore, the methods are not cloneproof in their current state, which 
somewhat voids the reason for combining CC and party list in this way.

Files ending in .mod are linear-integer programs in GNU MathProg format, and
.dat are data files to be used by these. Usage is like this:

`glpsol -m some_model.mod -d some_data.dat`

using the GLPK solver.

`dhondt_cc_party_list.mod` is the D'Hondt version, and `sl_cc_party_list.mod` 
is the Sainte-Laguë version. See these files for further comments.
