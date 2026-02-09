


# DOHC response


# measure the "relative undamping" output of the DOHC as a result of input signal level

# the DOHC 

import SNR

to_dB(x) = 20.0 * log10(x)
from_dB(x) = 10.0^(x/20) 


fs = 48e3
f_sig = 997.123456
ampdBs = range(0, 100.0; length = 1000 )
N = 1000

dohc = DOHC( 0.6, 0.3, fs )
# for dB in ampdBs

f1(dB) = begin
         x = from_dB(dB) * Sequences.Sinusoid( f_sig, fs ) 
        y = x|> dohc |> Processors.Take(N+100) |> Processors.Drop(100) |> ExtractField( :relative_undamping ) |> collect

        dc = SNR.estimate_dc_ac(y)[1]
        return dc
end

y = f1.(ampdBs)

plot( ampdBs, y )

