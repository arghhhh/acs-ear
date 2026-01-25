

# Not doing this the normal Julia way.
# This is my "simpler" way to make Modules accessible:

# Directly add path to the Julia LOAD_PATH if not already present
function add_to_Julia_path( p )
	if p ∉ LOAD_PATH
		push!( LOAD_PATH, p )
	end
end

add_to_Julia_path( "." )
DSP_lib_path = "../git-submodules/julia-signals-systems/src"
add_to_Julia_path( "$(DSP_lib_path)/Sequences" )
add_to_Julia_path( "$(DSP_lib_path)/Processors" )
add_to_Julia_path( "$(DSP_lib_path)/ProcSeqs" )
add_to_Julia_path( "$(DSP_lib_path)/SNR" )
add_to_Julia_path( "$(DSP_lib_path)/DSPfns" )


import Processors
import Sequences
import ProcSeqs
import CARFACjl
