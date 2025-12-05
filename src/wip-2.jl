

# this is derived from test_spike_rates

include( "include.jl" )
using Plots

function wip_test_spike_rates()
	# % Test: Assure the 3 class rates versus level look good.

        figures = Plots.Plot[] 


#	status = false # 0;
	fs = 22050;
	fp = 1000; # % Probe tone frequency
	duration = 0.25;
	dbstep = 10;  # % 10 is good


	#dbfs = -104:dbstep:6; # % 0 to 110 dB SPL
    #    dbfs = dB_SPL - 104

        N = round( Int64, fs * 0.25 * 12 )

        db = range( -110.0, 6.0; length = N )

        sinusoid = Sequences.Sinusoid( fp, fs ) |> Processors.Take(N) |> collect
        amplitude = sqrt(2) * 10.0 .^ ( db ./ 20)
        signal = amplitude .* sinusoid

        #=
	t = (0:(1/fs):(duration - 1/fs)) # '; # % Sample times for short duration
	sinusoid = sin.(2 * pi * t * fp);
	signal = Float64[];
	time = Float64[];
	t_start = 0;
	for (i,db) = enumerate(dbfs)  # % Levels spanning a huge range
		amplitude = sqrt(2) * 10.0^(db/20);
		# signal = [signal; amplitude*sinusoid];
		append!( signal, amplitude*sinusoid )
		# time = [time; t + t_start];
		append!( time, t .+ t_start )
		t_start = t_start + duration
	end

	signal = reshape( signal, length(signal), 1 )
=#
	CF = CARFAC_Design_version( :do_syn, 1, fs ); # % v3 3-class synapse model
        #=
	CF_state_ears = CARFAC_Init(CF);
	r = CARFAC_Run_Segment(CF, CF_state_ears, signal) #  % nap has 3 columns of firings

	# MATLAB version returns [naps, CF, BM, seg_ohc, seg_agc, firings_all]

	nap = r.naps
	CF = r.CF
	CF_state_ears = r.CF_state_ears
	bm = r.BM
	ohc = r.seg_ohc
	agc = r.seg_agc
	firings = r.firings_all
=#
	# the above is a straight forward single simulation of CARFAC
	# - should be easy to replicate with the julia-signals-systems version:

	cf = CF_Runner( CF )
	r1 = signal |> cf |> CollectNamedTuples


	nap = permutedims( r1.naps, (3, 1, 2) )
	bm = permutedims( r1.BM, (3, 1, 2) ) 
        ohc = permutedims( r1.seg_ohc, (3, 1, 2) )
        agc = permutedims( r1.seg_agc, (3, 1, 2) )
        firings =  permutedims( r1.firings_all, (4, 1, 2, 3) ) 


        #=
	# julia-signals-systems version should match EXACTLY:
	@assert r1.naps == r.naps
	@assert r1.firings == r.firings
	@assert r1.BM == r.BM
=#

#	global global_firings = firings

	#if do_plots
	# %%
#		@show  CF.pole_freqs fp

	#	chan = find(CF.pole_freqs * 1.06 < fp, 1) # % probably best channel
		chan = findfirst( CF.pole_freqs * 1.06 .< fp )
	#	chan_firings = squeeze(firings[:, chan, :, 1]) #  % Just one channel, 3 class columns.
		chan_firings = firings[:, chan, :, 1] #  % Just one channel, 3 class columns.
		healthy_n_fibers = CF.SYN_params.healthy_n_fibers;

#@show size(chan_firings) size(healthy_n_fibers)

		rates = chan_firings ./ reshape( healthy_n_fibers, 1, : )

		# figure();
		p = plot()
                push!( figures, p )   # Fig 33

		plot!(db, chan_firings);
		plot!( title  = "Instantaneous rates of 3 fiber-group classes")
		plot!( xlabel = "time in seconds, with 10 dB steps from -100 to 0 dB FS")
		plot!( ylabel = "firings per sample")
#		for db = dbfs .+ 104
		#	text(duration * (db/dbstep + 0.4), 12, num2str(db))
#		end

		# figure();
		p = plot()
                push!( figures, p )   # Fig 34
		plot!(db, fs*smooth1d(rates, fs*0.005)) # % Per fiber
		plot!( title  = "Mean rates of 3 fiber classes")
		plot!( xlabel = "time in seconds, with 10 dB steps from 0 to 110 dB SPL rms")
		plot!( ylabel = "firings per second per fiber")
	#	for db = dbfs .+ 104
		#	text(duration * (db/dbstep + 0.4), 100, num2str(db))
	#	end
	#	octave_basal_chan = find(CF.pole_freqs * 1.06 < fp*2, 1);
		octave_basal_chan = findfirst(CF.pole_freqs * 1.06 .< fp*2);
	#	half_octave_basal_chan = find(CF.pole_freqs * 1.06 < fp*sqrt(2), 1);
		half_octave_basal_chan = findfirst(CF.pole_freqs * 1.06 .< fp*sqrt(2));
	#	best_chan = find(CF.pole_freqs * 1.06 < fp, 1);
		best_chan = findfirst(CF.pole_freqs * 1.06 .< fp);
	#	half_octave_apical_chan = find(CF.pole_freqs * 1.06 < fp/sqrt(2), 1);
		half_octave_apical_chan = findfirst(CF.pole_freqs * 1.06 .< fp/sqrt(2));

		@show octave_basal_chan half_octave_basal_chan best_chan half_octave_apical_chan

		channels = [octave_basal_chan, half_octave_basal_chan, best_chan, half_octave_apical_chan];
	#	figure()
		p = plot()
                push!( figures, p )    # Fig 35

		plot!(db[1:8:end], agc[1:8:end, channels])
		# text(2.55, 0.15, [num2str(channels(4)), ": apical 0.5"])
		# text(2.55, 0.5, [num2str(channels(3)), ": best"])
		# text(2.58, 0.74, [num2str(channels(2)), ": basal 0.5"])
		# text(2.45, 0.93, [num2str(channels(1)), ": basal 1"])
	#	for db = dbfs .+ 104
			# text(duration * (db/dbstep + 0.4), 0.4, num2str(db))
	#	end
	#end

	#report_status(status, "test_spike_rates")
	return figures
end

