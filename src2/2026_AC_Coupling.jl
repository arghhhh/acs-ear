

# extracted from function CARFAC_CAR_Step() and CARFAC_DesignFilters()

struct AC_Couple <: Processors.SampleProcessor
        ac_coeff

        AC_Couple( fs, ac_corner_Hz = 20.0 ) = new( 2 * pi * ac_corner_Hz / fs )
end

function Processors.process( f::AC_Couple, zY, state = 0.0 )
        # % AC couple the filters_out, with 20 Hz corner (previously part of IHC)
        ac_diff = zY - state
        state = state + f.ac_coeff * ac_diff

        car_out = ac_diff

        return car_out, state
end
