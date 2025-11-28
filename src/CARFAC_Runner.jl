


# keeping this separate from CARFAC struct for now
# so this is a wrapper over CARFAC that adds the julia-signal-processing interface:

import Processors

mutable struct CF_Runner <: Processors.SampleProcessor
        CF::CARFAC
end

Base.eltype( ::Type{ Processors.Apply{I,CF_Runner} } ) where {I,P<:Processors.SampleProcessor} = Any

function Processors.process( cf::CF_Runner, x )
        state = CARFAC_Init( cf.CF )
        return Processors.process( cf, x, state )
end

function Processors.process( cf::CF_Runner, x::Vector{Float64}, state )

        # make inputs look like those of CARFAC_Run_Segment
        CF = cf.CF
        CF_state_ears = state
        input_waves = x
        do_BM = true

        n_ears = length(input_waves)
        
        if n_ears != length( CF.ears )
                error("bad number of input_waves channels passed to CARFAC_Run")
        end

        # TODO: ideally CF should be properly set up before getting here
        # ie these fields contain data, or a value indicating not being used
# if ~isfield(CF, 'open_loop') # % Find open_loop in CF or default it.
#   CF.open_loop = 0;
# end
# 
# if ~isfield(CF, 'linear_car') # % Find linear in CF or default it.
#   CF.linear_car = 0;
# end
# 
# if ~isfield(CF, 'use_delay_buffer') # % To let CAR be fully parallel.
#   CF.use_delay_buffer = 0;
# end

        n_ch = CF.n_ch;
#        naps = zeros(n_samp, n_ch, n_ears); # % allocate space for result
        naps = zeros( n_ch, n_ears); # % allocate space for result
        if do_BM
#                BM = zeros(n_samp, n_ch, n_ears);
                BM = zeros( n_ch, n_ears);
#                seg_ohc = zeros(n_samp, n_ch, n_ears);
                seg_ohc = zeros( n_ch, n_ears);
#                seg_agc = zeros(n_samp, n_ch, n_ears);
                seg_agc = zeros( n_ch, n_ears);
                if CF.do_syn
#                        firings_all = zeros(n_samp, n_ch, CF.SYN_params.n_classes, n_ears);
                        firings_all = zeros( n_ch, CF.SYN_params.n_classes, n_ears);
                else
                        firings_all = []; # % In case someone asked for it when it's not used.
                end
        end

        # % A 2022 addition to make open-loop running behave.  In open_loop mode, these
        # % coefficients are set, per AGC filter outputs, when we CARFAC_Close_AGC_Loop
        # % on AGC filter output updates.  They drive the zB and g coefficients to the
        # % intended value by the next update, but if open_loop they would just keep
        # % going, extrapolating.  The point of open_loop mode is to stop them moving,
        # % so we need to make sure these deltas are zeroed in case the mode is switched
        # % from closed to open, as in some tests to evaluate the transfer functions
        # % before and after adapting to a signal.
        if CF.open_loop
                # % The interpolators may be running if it was previously run closed loop.
              #  for ear = 1:CF.n_ears
                for ear = 1:n_ears
                        CF_state_ears[ear].CAR_state.dzB_memory .= 0; # % To stop intepolating zB.
                        CF_state_ears[ear].CAR_state.dg_memory .= 0; # % To stop intepolating g.
                end
        end

        # % Apply control coeffs to where they are needed.
      #  for ear = 1:CF.n_ears
        for ear = 1:n_ears
                # TODO: this looks icky - changing the coeffs
                CF.ears[ear].CAR_coeffs.linear = CF.linear_car; # % Skip OHC nonlinearity.
                CF.ears[ear].CAR_coeffs.use_delay_buffer = CF.use_delay_buffer;
        end

        detects = zeros(n_ch, n_ears);


#        # DMH: this is the main loop over input samples
#        for k = 1:n_samp


                # % at each time step, possibly handle multiple channels
                AGC_updated = false  # DMH declare this here, so can access it after loop  TODO: icky?
                for ear = 1:n_ears

                        # % This would be cleaner if we could just get and use a reference to
                        # % CF.ears(ear), but Matlab doesn't work that way...

                #        car_out, CF_state_ears[ear].CAR_state = CARFAC_CAR_Step( input_waves[k, ear], CF.ears[ear].CAR_coeffs, CF_state_ears[ear].CAR_state);
                        car_out, CF_state_ears[ear].CAR_state = CARFAC_CAR_Step( input_waves[ear], CF.ears[ear].CAR_coeffs, CF_state_ears[ear].CAR_state);

                        # % update IHC state & output on every time step, too
                        ihc_out, CF_state_ears[ear].IHC_state, v_recep = CARFAC_IHC_Step( car_out, CF.ears[ear].IHC_coeffs, CF_state_ears[ear].IHC_state);

                        if CF.do_syn
                                # % Use v_recep from IHC_Step to
                                # % update the SYNapse state and get firings and new nap.
                                syn_out, firings, CF_state_ears[ear].SYN_state = CARFAC_SYN_Step( v_recep, CF.ears[ear].SYN_coeffs, CF_state_ears[ear].SYN_state);
                                # % Use sum over syn_outs classes, appropriately scaled, as nap to agc.
                                # % firings always positive, unless v2 ihc_out.
                                # % syn_out can go a little negative; should be zero at rest.
                                nap = syn_out;
                                # % Maybe still should add a way to return firings (of the classes).
                        #        firings_all[k, :, :, ear] = firings;
                                firings_all[    :, :, ear] = firings;
                        else
                                # % v2, ihc_out already has rest_output subtracted.
                                nap = ihc_out; # % If no SYN, ihc_out goes to nap and agc as in v2.
                        end

                        # % Use nap to run the AGC update step, maybe decimating internally.
                        CF_state_ears[ear].AGC_state, AGC_updated = CARFAC_AGC_Step( nap, CF.ears[ear].AGC_coeffs, CF_state_ears[ear].AGC_state);

                        # % save some output data:
                #       naps[k, :, ear] = nap; # % output to neural activity pattern
                        naps[   :, ear] = nap; # % output to neural activity pattern
                        if do_BM
                        #       BM[k, :, ear] = car_out;
                                BM[   :, ear] = car_out;
                                state = CF_state_ears[ear].CAR_state;
                        #        seg_ohc[k, :, ear] = state.zA_memory;
                                seg_ohc[ :, ear] = state.zA_memory;
                                # %  seg_agc(k, :, ear) = state.zB_memory;
                                # % Better thing to return, easier to interpret AGC net (stage 1) state:
                                # % seg_agc(k, :, ear) = CF.ears(ear).AGC_state(1).AGC_memory;
                        #       seg_agc[k, :, ear] = CF_state_ears[ear].AGC_state.AGC_memory[:, 1];
                                seg_agc[   :, ear] = CF_state_ears[ear].AGC_state.AGC_memory[:, 1];
                        end
                end

                # % connect the feedback from AGC_state to CAR_state when it updates;
                # % all ears together here due to mixing across them:
                if AGC_updated
                        if n_ears > 1
                                # % do multi-aural cross-coupling:
                                CF_state_ears = CARFAC_Cross_Couple(CF, CF_state_ears);
                        end
                        if ~CF.open_loop
                             #   error("here")
                                CF = CARFAC_Close_AGC_Loop(CF, CF_state_ears); # % Starts the interpolation of zB and g.
                        end
                end
#        end


#        if !do_BM
#                BM = nothing
#                seg_ohc = nothing
#                seg_agc = nothing
#                if !CF.do_syn
#                        firings_all = nothing
#                end
#        end
#   #     @show naps
   #     return (; naps, CF, CF_state_ears, BM, seg_ohc, seg_agc, firings_all ), CF_state_ears
        return (; naps, BM, seg_ohc, seg_agc, firings_all ), CF_state_ears
end