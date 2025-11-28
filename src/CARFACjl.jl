

module CARFACjl


# pretty much everything, except the tests:
include( "ERB_Hz.jl"                )
include( "CARFAC_Design_Stage_g.jl" )
include( "CARFAC_Detect.jl"         )
include( "CAR_params_default.jl"    )
include( "AGC_params_default.jl"    )
include( "IHC_params_default.jl"    )
include( "SYN_params_default.jl"    )
include( "CARFAC_Design.jl"         )
include( "CARFAC_Init.jl"           )
include( "CARFAC_CAR_Step.jl"       )
# include( "CARFAC_Detect.jl"         )
include( "CARFAC_IHC_Step.jl"       )
include( "CARFAC_SYN_Step.jl"       )
include( "CARFAC_AGC_Step.jl"       )
include( "CARFAC_Stage_g.jl"        )
include( "CARFAC_OHC_NLF.jl"        )
include( "CARFAC_Run_Segment.jl"    )
include( "CARFAC_Close_AGC_Loop.jl" )
include( "CARFAC_Cross_Couple.jl"   )
include( "smooth1d.jl"              )


include( "CARFAC_Runner.jl" )

end # module CARFACjl