
# inner hair cell detection non-linearity

# see Figure 18.2

# CARFAC uses the "rational function"

xs = range( -1.0, 4.0 ; length=1000)
ys = CARFAC_Detect1.( xs )
plot( xs, ys )


# Figure 18.7:
#  NLF is obviously non-linear, but so is the next stage
# The AGC loop is non-linear - contains a multiplier, and the v = (1-q) operation are non-linear

# ignoring the dynamics - should be able to determine an input AC level to output DC level function:




