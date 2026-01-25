

# response.( CAR_filter.( pole_freqs( 30, 0.85*0.5*22050 ), 22050) ) |> CollectArrays
# impulse |> CascadeScan( CAR_filter.( pole_freqs( 30, 0.85*0.5*22050 ), 22050) ) |> collect
impulse = zeros(16384); impulse[1] = 1
fs = 22050
fs = 48000
#fs = 96000
ERB_per_step = 0.5
ERB_per_step = 0.25
f_high = 0.85*0.5*22050
f_high = 15000
# ys = impulse |> CascadeScan( CAR_filter.( pole_freqs( 30, f_high, ERB_per_step ), fs, 2.0 ^ ERB_per_step ) ) |> CollectArrays
cfs = pole_freqs( 30, f_high, ERB_per_step )
car = CAR_filter.( cfs, fs, 2.0 ^ ERB_per_step )
extract_y = fill(  Processors.Mapb{x->x.y, Float64}(), length(cfs) )
ys = impulse |> CascadeScan( Constant_undamping.(1.0) .|> car .|> extract_y ) |> CollectArrays
complex_spectra = FFTW.fft( identity.(ys), 2 )
db_spectra = 20 * log10.(abs.(complex_spectra) .+ 1e-50)
plot(db_spectra')
plot!(legend=false)
plot!( xlim=(1,8192), xaxis=:log )
plot!( ylim=(-25,75) )


linear_resonators = [ LinearResonator( r, 1.0 ) for r in car ]
p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )


indxs = 1:findfirst( f->(f<1000), cfs )


unit_circle = exp.( 1im * pi * range(-1.0, 1.0; length = 1000 ) )
plot( size=(600,600), aspect_ratio=:equal )
plot!( unit_circle )

scatter!( z[indxs], markershape=:circle, markercolor=:white )
scatter!( p[indxs], markershape=:xcross  )


linear_resonators = [ LinearResonator( r, 0.0 ) for r in car ]
p = reshape( quadratic_poles.( linear_resonators ) |> CollectArrays , : )
z = reshape( quadratic_zeros.( linear_resonators ) |> CollectArrays , : )

scatter!( z[indxs], markershape=:circle, markercolor=:white )
scatter!( p[indxs], markershape=:xcross )


# plot!( xlim=(-1,0) )



import SNR


# DOHC response

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

f1.(ampdBs)


