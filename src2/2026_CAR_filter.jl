



# this a single channel, with no DOHC behaviour, other than a second input for undamping
mutable struct CAR_filter <: Processors.SampleProcessor
        a0 :: Float64
        c0 :: Float64
        r1 :: Float64
        zr :: Float64
        h  :: Float64
        fs :: Float64
end




function CAR_filter( f_ch, fs, zero_ratio = sqrt(2) )

        high_f_damping_compression = 0.5
        min_zeta = 0.1
        max_zeta = 0.35

        # % zero_ratio comes in via h.  In book's circuit D, zero_ratio is 1/sqrt(a),
        # % and that a is here 1 / (1+f) where h = f*c.
        # % solve for f:  1/zero_ratio^2 = 1 / (1+f)
        # % zero_ratio^2 = 1+f => f = zero_ratio^2 - 1
        f = zero_ratio^2 - 1 # % nominally 1 for half-octave

        # % Make pole positions, s and c coeffs, h and g coeffs, etc.,
        # % which mostly depend on the pole angle theta:
        theta = f_ch * (2 * pi / fs)
        c0 = sin(theta)
        a0 = cos(theta)

        # % different possible interpretations for min-damping r:
        # % r = exp(-theta * CF_CAR_params.min_zeta).
        # % Compress theta to give somewhat higher Q at highest thetas:
        ff = high_f_damping_compression # % 0 to 1; typ. 0.5
        x = theta/pi
        theta = pi * (x - ff * x.^3) # % when ff is 0, this is just theta,
        # %                          and when ff is 1 it goes to zero at theta = pi.
        r1 = (1 - theta * max_zeta) # % "r1" for the max-damping condition

#        ERB_break_freq = 165.3    # DMH shouldn't be here
#        ERB_Q = 1000/(24.7*4.37)  # DMH shouldn't be here


        # % Increase the min damping where channels are spaced out more, by pulling
        # % toward ERB_Hz/pole_freqs (close to 0.1 at high f)
        min_zetas = min_zeta + 0.25*(ERB_Hz(f_ch ) / f_ch - min_zeta)
        r1 = (1 - theta * max_zeta) # % "r1" for the max-damping condition
        zr = theta * (max_zeta - min_zetas) # % how r relates to undamping
        

        h = c0 * f

        return CAR_filter( a0 ,c0 ,r1 ,zr ,h  ,fs )
end

function CAR_filter_min_max_zeta( f_ch, fs, zero_ratio = sqrt(2) )

        high_f_damping_compression = 0.5
        min_zeta = 0.1
        max_zeta = 0.35

        # % zero_ratio comes in via h.  In book's circuit D, zero_ratio is 1/sqrt(a),
        # % and that a is here 1 / (1+f) where h = f*c.
        # % solve for f:  1/zero_ratio^2 = 1 / (1+f)
        # % zero_ratio^2 = 1+f => f = zero_ratio^2 - 1
        f = zero_ratio^2 - 1 # % nominally 1 for half-octave

        # % Make pole positions, s and c coeffs, h and g coeffs, etc.,
        # % which mostly depend on the pole angle theta:
        theta = f_ch * (2 * pi / fs)
        c0 = sin(theta)
        a0 = cos(theta)

        # % different possible interpretations for min-damping r:
        # % r = exp(-theta * CF_CAR_params.min_zeta).
        # % Compress theta to give somewhat higher Q at highest thetas:
        ff = high_f_damping_compression # % 0 to 1; typ. 0.5
        x = theta/pi
        theta = pi * (x - ff * x.^3) # % when ff is 0, this is just theta,
        # %                          and when ff is 1 it goes to zero at theta = pi.
        r1 = (1 - theta * max_zeta) # % "r1" for the max-damping condition

#        ERB_break_freq = 165.3    # DMH shouldn't be here
#        ERB_Q = 1000/(24.7*4.37)  # DMH shouldn't be here


        # % Increase the min damping where channels are spaced out more, by pulling
        # % toward ERB_Hz/pole_freqs (close to 0.1 at high f)
        min_zetas = min_zeta + 0.25*(ERB_Hz(f_ch ) / f_ch - min_zeta)
        r1 = (1 - theta * max_zeta) # % "r1" for the max-damping condition
        zr = theta * (max_zeta - min_zetas) # % how r relates to undamping
        

        h = c0 * f

        return theta * min_zetas, theta * max_zeta
end





function CAR_filter2( f_ch, fs, ERB_per_step, zero_ratio = sqrt(2) )

        high_f_damping_compression = 0.5
        min_zeta = 0.1
        max_zeta = 0.35

        # % zero_ratio comes in via h.  In book's circuit D, zero_ratio is 1/sqrt(a),
        # % and that a is here 1 / (1+f) where h = f*c.
        # % solve for f:  1/zero_ratio^2 = 1 / (1+f)
        # % zero_ratio^2 = 1+f => f = zero_ratio^2 - 1
        f = zero_ratio^2 - 1 # % nominally 1 for half-octave

        # % Make pole positions, s and c coeffs, h and g coeffs, etc.,
        # % which mostly depend on the pole angle theta:
        theta = f_ch * (2 * pi / fs)
        c0 = sin(theta)
        a0 = cos(theta)

        # % different possible interpretations for min-damping r:
        # % r = exp(-theta * CF_CAR_params.min_zeta).
        # % Compress theta to give somewhat higher Q at highest thetas:
        ff = high_f_damping_compression # % 0 to 1; typ. 0.5
        x = theta/pi
        theta1 = pi * (x - ff * x.^3) # % when ff is 0, this is just theta,
        # %                          and when ff is 1 it goes to zero at theta = pi.

        zeta_compression = 1.0 - high_f_damping_compression * (theta/pi)^2 

        @show abs( theta1 -  zeta_compression*theta )
        @assert abs( theta1 -  zeta_compression*theta ) < 1e-12

   #     r1 = (1 - theta * max_zeta) # % "r1" for the max-damping condition

#        ERB_break_freq = 165.3    # DMH shouldn't be here
#        ERB_Q = 1000/(24.7*4.37)  # DMH shouldn't be here

                ### local_low_level_q = pole_freqs ./ ERB_Hz( pole_freqs, CAR_params.ERB_break_freq, CAR_params.ERB_Q)
                ### # % Number of overlapping channels is about ERB_per_step^-1, so this:
                ### min_zetas = CAR_params.ERB_per_step^-0.5 ./ (2*local_low_level_q)
                ### min_zetas = min(min_zetas, 0.75*max_zeta) # % Keep some low CF action.
                ### # % "r1" for the max-damping condition
                ### CAR_coeffs.r1_coeffs = exp(-theta .* max_zeta)
                ### r0_coeffs = exp(-theta .* min_zetas) #  % min_damping condition.
                ### CAR_coeffs.zr_coeffs = r0_coeffs - CAR_coeffs.r1_coeffs

                local_low_level_q = f_ch / ERB_Hz( f_ch )
                ### # % Number of overlapping channels is about ERB_per_step^-1, so this:
                min_zetas = ERB_per_step ^ -0.5 / (2*local_low_level_q)
                min_zetas = min(min_zetas, 0.75*max_zeta) # % Keep some low CF action.
                ### # % "r1" for the max-damping condition
                r1 = exp(-theta1 * max_zeta)
                r0 = exp(-theta1 * min_zetas) #  % min_damping condition.
                zr = r0 - r1

        h = c0 * f

        return CAR_filter( a0 ,c0 ,r1 ,zr ,h  ,fs )
end



function stage_gain(f::CAR_filter, undamping)
# % function ideal_g = CARFAC_Stage_g(CAR_coeffs, undamping)
# % Return the stage gain g needed to get unity gain at DC
# % See also CARFAC_Stage_g, simplified approximation used at run time,
# % based on quadratic coefficient computed at Design time.

        r1 = f.r1    # % at max damping
        a0 = f.a0                       
        c0 = f.c0                       
        h  = f.h                     
        zr = f.zr                       
        r  = r1 .+ zr .* undamping    # % r at specified damping
        n  = 1 .- 2*r.*a0 .+ r.^2                       
        d  = 1 .- 2*r.*a0 .+ h.*r.*c0 .+ r.^2                       
        ideal_g = n ./ d                       

        return ideal_g
end

function tfn( f::CAR_filter, undamping = 1.0 ) 
        # Lyon book p301 - equation two thirds down, in z, but create poly in z^-1
        # 
        r1 = f.r1    # % at max damping
        a0 = f.a0                       
        c0 = f.c0                       
        h  = f.h                     
        zr = f.zr                       
        r  = r1 .+ zr .* undamping    # % r at specified damping
        n  = 1 .- 2*r.*a0 .+ r.^2                       
        d  = 1 .- 2*r.*a0 .+ h.*r.*c0 .+ r.^2                       
        g = n ./ d                       

     #   return TFNs.TFN( [ Polys.Poly( g, g*(-2a0+h*c0)*r, g*r*r ) ], [ Polys.Poly( 1.0, -2*a0*r, r*r ) ] )

        # move constant factor, do denominator, highest power coefficient is one:
        mag = r*r
        return TFNs.TFN( [ Polys.Poly( g/mag, g*(-2a0+h*c0)*r/mag, g #= *r*r/mag =# ) ], [ Polys.Poly( 1.0/mag, -2*a0*r/mag, 1.0 ) ] )
end

function tfn( f::Vector{CAR_filter}, undamping = ones(length(f)) ) 
        n = Polys.Poly{Float64}[]
        d = Polys.Poly{Float64}[]
        for (r,b) in zip(f, undamping)
                tf = tfn( r, b )
                append!( n, tf.numerator   )
                append!( d, tf.denominator )
        end
        return TFNs.TFN( n, d )
end

function poly_from_root( z::Complex )
	re = real(z)
	im = imag(z)
        # setting the highest power coefficient to one
        # this is what is usually wanted:   s^2 + wo/Q s + wo^2
        #                                   z^-2 + a z^-1 + b z^-1
	return Polys.Poly( re*re + im*im , -2.0 * re, 1.0 )
end

function poly_from_root_inv( z::Complex )
	re = real(z)
	im = imag(z)
        # setting the highest power coefficient to one
        # this is what is usually wanted:   s^2 + wo/Q s + wo^2
        #                                   z^-2 + a z^-1 + b z^-1
#	return Polys.Poly( re*re + im*im , -2.0 * re, 1.0 )
        mag = re*re + im*im
	return Polys.Poly( 1.0/mag, -2.0 * re / mag, 1.0 )
end

function roots_from_poly( poly::Polys.Poly )

        p = poly.p

        z,z2 = solve_quadratic( p[3], p[2], p[1] )

        return z, z2
end


# this is for getting the roots of a z-domain poly, when then poly is in z^-1
function roots_from_poly_inv( poly::Polys.Poly )

        p = poly.p

        z,z2 = solve_quadratic( p[1], p[2], p[3] )

        return z, z2
end


# originally taken from TFNtransform.jl
function z_from_s_poly( s_poly::Polys.Poly, fs )

        p = s_poly.p

	n = length(p)



	# @show p fs
	
	#	if n == 1
	#		# constant factor
	#		# do nothing
	#		f[1] = p[1]
	#	elseif n == 2
	#		# first order factor ( p[2].s + p[1] ) has
	#		# root location: ( s - si )
	#		si = -p[1] / p[2]
	#		# and maps to:
	#		f[2] = 1
	#		f[1] = -exp( si/fs )
	#
	#		println( "matched_z ", si, " -> ", -f[1] )
	#	elseif n == 3
			# second order factor

		#	z,z2 = roots_of_factor( p );
                #        z,z2 = solve_quadratic( p[3], p[2], p[1] )
#
	#
		#	f3 = p[3]
		#	f2 = p[3] * -2.0 * exp( z.re /  fs ) * cos( z.im /  fs )
		#	f1 = p[3] * exp( 2.0 * z.re /  fs )

                        s_pole,_ = roots_from_poly( s_poly )
                        z_pole   = exp( s_pole / fs )

                        z_poly = poly_from_root_inv( z_pole )

                return z_poly


	#	else
	#		error(" matched z transform poly must be factored")
	#	end

	return f
end

# inverse of matched_z_factor function - go from a z^-1-domain factor to a s-domain factor:
function s_from_z_poly( z_poly::Polys.Poly, fs )

        p = z_poly.p

	# n = length(p)
	# f = zeros(n)

	# @show p fs
	
	#	if n == 1
	#		# constant factor
	#		# do nothing
	#		f[1] = p[1]
	#	elseif n == 2
	#		# first order factor ( p[2].s + p[1] ) has
	#		# root location: ( s - si )
	#		si = -p[1] / p[2]
	#		# and maps to:
	#		f[2] = 1
	#		f[1] = -exp( si/fs )
	#
	#		println( "matched_z ", si, " -> ", -f[1] )
	#	elseif n == 3
			# second order factor

		#	z,z2 = roots_of_factor( p );
                #        z,z2 = solve_quadratic( p[3], p[2], p[1] )
                        z_pole,_ = roots_from_poly_inv( z_poly )

                        s = fs * log( z_pole )

                        s_poly = poly_from_root(s)
	
	#	else
	#		error(" matched z transform poly must be factored")
	#	end

	return s_poly
end

# Lyon book, Figure 8.4, p150:
get_w_N_from_s_poly( s_poly ) = abs( roots_from_poly( s_poly )[1] )
get_w_R_from_s_poly( s_poly ) = imag( roots_from_poly( s_poly )[1] )
get_gamma_from_s_poly( s_poly ) = -real( roots_from_poly( s_poly )[1] )
get_zeta_from_s_poly( s_poly ) = get_gamma_from_s_poly( s_poly ) / get_w_N_from_s_poly( s_poly )
get_Q_from_s_poly( s_poly ) = 1.0 / ( 2.0 * get_zeta_from_s_poly( s_poly ) )

# who uses radians/s?  get them in Hertz
get_f_N_from_s_poly( s_poly ) = get_w_N_from_s_poly( s_poly ) / (2pi)
get_f_R_from_s_poly( s_poly ) = get_w_R_from_s_poly( s_poly ) / 2(pi)




function Processors.process( f::CAR_filter, x1, state = (; z1_memory=0.0, z2_memory=0.0 ) )

        # deal with input.  there are three components of the input, 
        x_in          = x1.x               # main audio signal input
        undamping     = x1.undamping       # undamping which will be scaled by zr and applied to r
        agc_undamping = x1.agc_undamping   # undamping due to only the AGC - this is used to correct the gain

        r = f.r1 + f.zr * undamping
        zA = state.z2_memory   # DMH: not used?

        # % now reduce state by r and rotate with the fixed cos/sin coeffs:
        # % z1 = z1 + inputs;
        z1 = r * (f.a0 * state.z1_memory - f.c0 * state.z2_memory) + x_in
        z2 = r * (f.c0 * state.z1_memory + f.a0 * state.z2_memory)

        # DMH: book p301 H(z) eqn 3/4 down page
        # n and d are swapped, because calculating gain that needs to be applied to get unity at DC (z=1)
        n  = 1 - 2*r * f.a0 + r.^2                       
        d  = 1 - 2*r * f.a0 + f.h * r * f.c0 + r.^2                       
        ideal_g = n / d 

        ideal_g = stage_gain( f, agc_undamping )
        
        # Book p 303 for approximation

        g0    = stage_gain( f, 0.0)
        g1    = stage_gain( f, 1.0)
        ghalf = stage_gain( f, 0.5)
        # % Store fixed coefficients for A*undamping.^2 + B^undamping + C
        ga = 2*(g0 + g1 - 2*ghalf)
        gb = 4*ghalf - 3*g0 - g1
        gc = g0

        stage_g = ga * agc_undamping^2 + gb * agc_undamping + gc;

        gain = ideal_g  # ideal

        # @assert abs( 20.0 * log10( ideal_g / stage_g ) ) < 0.1 # dB error

        y = gain * (f.h * z2 + x_in) # % Outputs from z2

        mag = sqrt( z1^2 + z2^2 )

        return (; y, r, z1, z2, ideal_g, mag ),( z1_memory=z1, z2_memory=z2 )
end
 
function response( f::CAR_filter, N = 16384, amp = 1.0 )
        impulse = zeros(N)
        impulse[1] = amp
        y = impulse |> f |> collect

        complex_spectra = FFTW.fft( y )
        db_spectra = 20 * log10.(abs.(complex_spectra) .+ 1e-50)

        return db_spectra
end







mutable struct LinearResonator <: Processors.SampleProcessor
        a0 :: Float64
        c0 :: Float64
        r  :: Float64
        h  :: Float64
        g  :: Float64
end

function Processors.process( f::LinearResonator, x_in, state = (; z1_memory=0.0, z2_memory=0.0 ) )

        # % now reduce state by r and rotate with the fixed cos/sin coeffs:
        # % z1 = z1 + inputs;
        z1 = f.r * (f.a0 * state.z1_memory - f.c0 * state.z2_memory) + x_in
        z2 = f.r * (f.c0 * state.z1_memory + f.a0 * state.z2_memory)
                  
        y = f.g * (f.h * z2 + x_in) # % Outputs from z2

        return y,( z1_memory=z1, z2_memory=z2 )
end

function LinearResonator( f::CAR_filter, undamping = 1.0 ) 
        a0 = f.a0
        c0 = f.c0
        r  = f.r1 + f.zr * undamping
        h = f.h

        n  = 1 - 2*r * f.a0 + r.^2                       
        d  = 1 - 2*r * f.a0 + f.h * r * f.c0 + r.^2                       
        ideal_g = n / d  

        return LinearResonator( a0, c0, r, h, ideal_g )
end

function solve_quadratic(a, b, c)
    discr = b^2 - 4*a*c
    sq = sqrt(Complex(discr)) 
    [(-b + sq)/(2a), (-b - sq)/(2a)]    # return upper half plane root first
end

function quadratic_poles( res::LinearResonator )
        r  = res.r
        a0 = res.a0
        solve_quadratic( 1.0, -2*a0*r, r*r )
end
function quadratic_zeros( res::LinearResonator )
        r  = res.r
        h  = res.h
        a0 = res.a0
        solve_quadratic( 1.0, (-2*a0 + h)*r, r*r )
end










struct Constant_undamping <: Processors.SampleProcessor
        undamping::Float64
end
function Processors.process( f::Constant_undamping, x, state=nothing )
        return (;x=x,undamping=f.undamping,agc_undamping=f.undamping), nothing
end
Base.eltype( ::Type{ Processors.Apply{X,Constant_undamping} } ) where{X} = @NamedTuple{in::Float64, undamping::Float64}




struct CascadeScan <: Processors.SampleProcessor
        f::Vector
end

function Processors.process( f::CascadeScan, x::T ) where {T}
        state = Vector( undef, length(f.f) )
        y = Vector{T}( undef, length(f.f) )
        for i in eachindex(f.f)
                x,state[i] = Processors.process( f.f[i], x )
                y[i] = x
        end
        # calling identity below to try to narrow the type used for the state
        return y, identity.(state)
end

function Processors.process( f::CascadeScan, x::T, state ) where {T}
        state1 = similar(state)
        y = Vector{T}( undef, length(f.f) )
        for i in eachindex(f.f)
                x,state1[i] = Processors.process( f.f[i], x, state[i] )
                y[i] = x
        end
        return y,state1
end
Base.IteratorEltype( ::Type{ Processors.Apply{X,CascadeScan} } ) where{X} = Base.HasEltype() 
Base.eltype( ::Type{ Processors.Apply{X,CascadeScan} } ) where{X} = Vector{ Base.eltype(X) } 



##############################################################################################

struct CascadeScanAdapt <: Processors.SampleProcessor
        f::Vector
        adapt  # function called on the output of each Processor to a form suitable for the input of the next
        keep   # function called on the output of each Processor used to convert/limit saved output
end

function Processors.process( f::CascadeScanAdapt, x )
        state = Vector( undef, length(f.f) )

        # TODO: could do a better job here - call the first iteration
        # and build a vector of correct length and type, and then loop trough the rest of the iterations
        y = Vector( undef, length(f.f) )

        println("start of CascadeScanAdapt" )
        x_in = x
        @show x_in

        for i in eachindex(f.f)
                x1,state[i] = Processors.process( f.f[i], x_in )
                @show x_in x1
                @show f.keep( x1 )
                @show f.adapt( x1 )
                y[i] = f.keep( x1 )
                x_in = f.adapt( x1 )
        end
        # calling identity below to try to narrow the type used for the state
        return identity(y), identity.(state)
end

function Processors.process( f::CascadeScanAdapt, x, state )
        state1 = similar(state)

        # TODO: could do a better job here - call the first iteration
        # and build a vector of correct length and type, and then loop trough the rest of the iterations
        # TODO: particularly the "keep" data, which could be a vector or NamedTuple
        #       want to do the same thing as CollectArrays amd CollectTuples here
        #       - so need to build a "collect" abstraction that does the "first", "general", "finalize" stuff.
        y = Vector( undef, length(f.f) )
        for i in eachindex(f.f)
                x1,state1[i] = Processors.process( f.f[i], x, state[i] )
                y[i] = f.keep( x1 )
                x    = f.adapt( x1 )
        end
        return identity(y), identity.(state1)
end
# Base.IteratorEltype( ::Type{ Processors.Apply{X,CascadeScanAdapt} } ) where{X} = Base.HasEltype() 
# Base.eltype( ::Type{ Processors.Apply{X,CascadeScanAdapt} } ) where{X} = Vector{ Base.eltype(X) } 


##############################################################################################






struct Parallel <: Processors.SampleProcessor
        v::Vector
end
function Processors.process( f::Parallel, x )
        state = Vector( undef, length(f.f) )
        y = Vector( undef, length(f.f) )
        for i in eachindex(f.f)
                y[i],state[i] = Processors.process( f.f[i], x[i] )
        end
        return y,state
end

function Processors.process( f::Parallel, x, state )
        state1 = similar(state)
        y = Vector( undef, length(f.f) )
        for i in eachindex(f.f)
                y[i],state1[i] = Processors.process( f.f[i], x[i], state[i] )
        end
        return y,state1
end

