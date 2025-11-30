
include( "env.jl" )

import Processors


fs = 22050
fs = 48e3

sig = [ [1.0], [1.0], [1.0] ]

import Sequences
s = Sequences.Sinusoid( 1000, fs ) |> Processors.Take(10000)

sig = map( x->[x], ones(500) ) 
sig = map( x->[x], s ) 

CF = CARFACjl.CARFAC_Design(1, fs)
CF = CARFACjl.CARFAC_Design_version( :do_syn, 1, fs )

t = sig |> CARFACjl.CF_Runner( CF ) |> Processors.Drop(9000) |> collect

include("dmh_collect.jl" )

a = CollectNamedTuples(t)
bm = a.BM[:,1,:]
nr,nc = size(bm)

mi,ma = extrema(bm)

using Plots

anim = @animate for i ∈ 1:nc
    plot( bm[:,i], ylim=(mi,ma) )
end
gif(anim, "anim.gif", fps = 15)



naps = a.naps[:,1,:]
nr,nc = size(naps)

mi,ma = extrema(naps)

using Plots

anim = @animate for i ∈ 1:nc
    plot( naps[:,i], ylim=(mi,ma) )
end
gif(anim, "anim-naps.gif", fps = 15)

plot( naps[50,:] )



i = Processors.Stateful( Processors.Delay(2) )

@show (1:10) |> i |> collect

