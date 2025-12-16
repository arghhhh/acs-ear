
include( "env.jl" )

import Processors
import Sequences
using Plots

include("dmh_collect.jl" )

fs = 22050
fs = 48e3

sig = [ [1.0], [1.0], [1.0] ]


function do_animation( f_sig, fs, filename )

   # f_sig = 1000
    period_samples = round( Int64, fs / f_sig )

    s = Sequences.Sinusoid( f_sig, fs ) |> Processors.Take(9000+period_samples)

    sig = map( x->[x], ones(500) ) 
    sig = map( x->[x], s ) 

    sig = s

    CF = CARFACjl.CARFAC_Design(1, fs)
    CF = CARFACjl.CARFAC_Design_version( :do_syn, 1, fs )

    t = sig |> CARFACjl.CF_Runner( CF ) |> Processors.Drop(9000) |> Processors.Take(period_samples) |> collect


    a = CollectNamedTuples(t)
    bm = a.BM[:,1,:]
    nr,nc = size(bm)

    mi1,ma1 = extrema(bm)

    mi = minimum( bm ; dims = 2 )
    ma = maximum( bm ; dims = 2 )


    anim = @animate for i ∈ 1:nc
        plot( bm[:,i], ylim=(-8,8), linewidth=2, framestyle=:box, legend=nothing )
        plot!( mi , linestyle=:dash )
        plot!( ma , linestyle=:dash )
        plot!( xlabel="channel number", ylabel="basilar membrane motion (arbitrary scaling)" )
    end
    gif(anim, filename, fps = 15)

end


do_animation( 500.0, fs, "bm_0500.gif" )
do_animation( 1000.0, fs, "bm_1000.gif" )
do_animation( 2000.0, fs, "bm_2000.gif" )
do_animation( 4000.0, fs, "bm_4000.gif" )
do_animation( 8000.0, fs, "bm_8000.gif" )

#=
naps = a.naps[:,1,:]
nr,nc = size(naps)

mi,ma = extrema(naps)

using Plots

anim = @animate for i ∈ 1:nc
    plot( naps[:,i], ylim=(mi,ma) )
end
gif(anim, "anim-naps.gif", fps = 15)

plot( naps[50,:] )
=#


i = Processors.Stateful( Processors.Delay(2) )

@show (1:10) |> i |> collect

