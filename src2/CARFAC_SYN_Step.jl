# % // clang-format off
function CARFAC_SYN_Step(v_recep::Vector{Float64}, coeffs::SYN_coeffs, state::SYN_state)

#@show v_recep coeffs state

        # % Drive multiple synapse classes with receptor potential from IHC,
        # % returning instantaneous spike rates per class, for a group of neurons
        # % associated with the CF channel, including reductions due to synaptopathy.

        # % Normalized offset position into neurotransmitter release sigmoid.
#@show size(v_recep) size( coeffs.v_halfs ) size( coeffs.v_widths )
#@show size(v_recep) size( transpose(coeffs.v_halfs) ) size( coeffs.v_widths )
#@show (v_recep .- transpose(coeffs.v_halfs))
        x = (v_recep .- transpose(coeffs.v_halfs)) ./ transpose( coeffs.v_widths )
#@show size(x)
        s = 1 ./ (1 .+ exp.(-x))  # % Between 0 and 1; positive at rest.
        q = state.reservoirs  # % aka 1 - w, between 0 and 1; positive at rest.
        r = (1 .- q) .* s  # % aka w*s, between 0 and 1, proportional to release rate.

        # % Smooth once with LPF (receptor potential was already smooth), after
        # % applying the gain coeff a2 to convert to firing prob per sample.
        state.lpf_state = state.lpf_state + coeffs.lpf_coeff * (coeffs.a2 .* r - state.lpf_state)  # % this is firing probs.
        firing_probs = state.lpf_state  # % Poisson rate per neuron per sample.
        # % Include number of effective neurons per channel here, and interval T;
        # % so the rates (instantaneous action potentials per second) can be huge.
        firings = coeffs.n_fibers .* firing_probs

        # % Feedback, to update reservoir state q for next time.
        state.reservoirs = q + coeffs.res_coeff .* (coeffs.a1 .* r - q)

        # % Make an output that resembles ihc_out, to go to agc_in (collapse over classes).
        # % Includes synaptopathy's presumed effect of reducing feedback via n_fibers.
        # % But it's relative to the healthy nominal spont, so could potentially go
        # % a bit negative in quiet is there was loss of high-spont or medium-spont units.
        # % The weight multiplication is an inner product, reducing n_classes
        # % columns to 1 column (first transpose the agc_weights row to a column).

#@show size( (coeffs.n_fibers .* firing_probs) )
#@show size( coeffs.agc_weights' )
#@show size( coeffs.spont_sub )

        syn_out = (coeffs.n_fibers .* firing_probs) * coeffs.agc_weights .- coeffs.spont_sub

        return syn_out, firings, state 
end
