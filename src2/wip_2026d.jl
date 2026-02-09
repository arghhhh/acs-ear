
# measure the IHC response - AC level in to dc level out


xs = Sequences.Sinusoid( 997.0, 48e3 ) |> IHC1( :one_cap, 48e3 ) |> ExtractField( :ihc_out ) |> Processors.Take( 1000 ) |> collect


import SNR
import Sequences

to_dB(x) = 20.0 * log10(x)
from_dB(x) = 10.0^(x/20) 


fs = 48e3
f_sig = 997.123456
ampdBs = range(-100, 50.0; length = 1000 )

dohc = DOHC( 0.6, 0.3, fs )
# for dB in ampdBs

n_drop = 10000
N      = 10000

f1(dB) = begin
         x = from_dB(dB) * Sequences.Sinusoid( f_sig, fs ) 
  #      y = x|> dohc |> Processors.Take(N+100) |> Processors.Drop(100) |> ExtractField( :relative_undamping ) |> collect

        y1 = x |> IHC1( :one_cap, 48e3 ) |> ExtractField( :ihc_out ) |>Processors.Take(N+n_drop) |> Processors.Drop(n_drop) |> collect
        y2 = x |> IHC1( :two_cap, 48e3 ) |> ExtractField( :ihc_out ) |>Processors.Take(N+n_drop) |> Processors.Drop(n_drop) |> collect


        dc1 = SNR.estimate_dc_ac(y1)[1]
        dc2 = SNR.estimate_dc_ac(y2)[1]
        return [ dc1,dc2 ]
end

y = f1.(ampdBs)
y = f1.(ampdBs) |> CollectArrays 

y1 = 1.0 .- y

#plot( ampdBs, [ to_dB.(y), to_dB.(y1) ] )
plot( ampdBs, [ y, y1 ] )

plot( ampdBs, to_dB.(y') )
