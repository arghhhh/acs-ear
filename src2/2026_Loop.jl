

# This combines CARFAC_Close_AGC_Loop, with part of the DOHC stuff originally in CAR part 
# Removed the stuff to do with the gain - this is calculated in the CAR part - without the approximation


struct AGC_Loop <: Processors.SampleProcessor
        decim1
        OHC_health
        zr_coeffs
end
 
function Processors.process( agc::AGC_Loop, x1, state = ( zB_memory = 0.0, dzB_memory = 0.0 ) )
        # % function CF = CARFAC_Close_AGC_Loop(CF)

        x = x1.x
        updated = x1.updated

        zB = state.zB_memory + state.dzB_memory

        dzB = state.dzB_memory

        if updated
                # % fastest decimated rate determines interp needed:
                # decim1

                # % Set the deltas to be applied to g and zB on next CAR_Step.
                # % If decim1 = 1 (non-decimating), the delta goes all the way;
                # % if decim1 > 1, it ramps 1/decim1 of the way on each step.
                undamping = 1 - x # % stage 1 result
                # % degrade the OHC active undamping if the ear is less than healthy:
                undamping = undamping * agc.OHC_health;


                # % set the deltas needed to get to the new damping:
                dzB = ( agc.zr_coeffs * undamping - state.zB_memory ) / agc.decim1
        end

        next_state = ( zB_memory = zB, dzB_memory = dzB )
                
        return zB, next_state
end
