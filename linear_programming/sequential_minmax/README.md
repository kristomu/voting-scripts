These are linear programs based on Minmax(margins).

- minmax.mod : LP implementation of Minmax(margins)
- multiwinner\_minmax.mod : LP implementation of the inner loop of a virtual constituency/clustering Minmax multiwinner method. See comments.
- multiwinner\_minmax\_maximize.mod : Same as multiwinner\_minmax, but using the "maximize minimum victory" formulation of minmax (as in rbvote) rather than the "minimize maximum defeat" formulation as in Wikipedia.
- multiwinner\_minmax\_lcr.dat : Data file for the LCR ballot set (center squeeze), which ideally should elect C with one seat and L and R with two.
