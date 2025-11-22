# % // clang-format off
# % Copyright 2012 The CARFAC Authors. All Rights Reserved.
# % Author: Richard F. Lyon
# %
# % This file is part of an implementation of Lyon's cochlear model:
# % "Cascade of Asymmetric Resonators with Fast-Acting Compression"
# %
# % Licensed under the Apache License, Version 2.0 (the "License");
# % you may not use this file except in compliance with the License.
# % You may obtain a copy of the License at
# %
# %     http://www.apache.org/licenses/LICENSE-2.0
# %
# % Unless required by applicable law or agreed to in writing, software
# % distributed under the License is distributed on an "AS IS" BASIS,
# % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# % See the License for the specific language governing permissions and
# % limitations under the License.

mutable struct CAR_state
        z1_memory::Vector{Float64}  # length n_ch
        z2_memory::Vector{Float64}  # length n_ch
        zA_memory::Vector{Float64}  # length n_ch
        zB_memory::Vector{Float64}  # length ??
        dzB_memory::Vector{Float64} # length n_ch
        zY_memory::Vector{Float64}  # length n_ch
        g_memory::Vector{Float64}   # length ??
        dg_memory::Vector{Float64}  # length n_ch
        ac_coupler::Vector{Float64} # length n_ch
        CAR_state() = new()
end    

mutable struct IHC_state
        # should probably different state structs for each of just_hwr, one_cap, else cases
        ihc_accum::Vector{Float64}  # length n_ch

        cap_voltage::Vector{Float64}  # length n_ch
        lpf1_state::Vector{Float64}  # length n_ch
        lpf2_state::Vector{Float64}  # length n_ch

        cap1_voltage::Vector{Float64}  # length n_ch
        cap2_voltage::Vector{Float64}  # length n_ch

        IHC_state() = new()
end

mutable struct AGC_state
        AGC_memory::Matrix{Float64}   # n_ch   x     n_AGC_stages
        decim_phase::Matrix{Float64}  #   1    x     n_AGC_stages    (row vector)
        input_accum::Matrix{Float64}  # n_ch   x     n_AGC_stages
        AGC_state() = new()
end

mutable struct SYN_state
        reservoirs::Matrix{Float64}  # n_ch   x     ??
        lpf_state::Matrix{Float64}  # n_ch   x     ??
        SYN_state() = new()
end

mutable struct Ear_state
        CAR_state::CAR_state
        IHC_state::IHC_state
        AGC_state::AGC_state
        SYN_state::SYN_state

        Ear_state() = new()
end

function CARFAC_Init(CF::CARFAC)::Vector{Ear_state}
# % function CF = CARFAC_Init(CF)
# %
# % Initialize state for one or more ears of CF.
# % This allocates and zeros all the state vector storage in the CF struct.

      #  n_ears = CF.n_ears;
        n_ears = length(CF.ears);

        states = [ Ear_state() for _ in 1:n_ears ]

        for ear = 1:n_ears
                # % for now there's only one coeffs, not one per ear
                states[ear].CAR_state = CAR_Init_State(CF.ears[ear].CAR_coeffs)
                states[ear].IHC_state = IHC_Init_State(CF.ears[ear].IHC_coeffs)
                states[ear].AGC_state = AGC_Init_State(CF.ears[ear].AGC_coeffs)
                if CF.do_syn
                        states[ear].SYN_state = SYN_Init_State(CF.ears[ear].SYN_coeffs)
                end
        end
        return states
end

    

function CAR_Init_State(coeffs::CAR_coeffs_struct)::CAR_state
        n_ch = coeffs.n_ch
        state = CAR_state()
        state.z1_memory            = zeros(n_ch)
        state.z2_memory            = zeros(n_ch)
        state.zA_memory            = zeros(n_ch)
        state.zB_memory            = coeffs.zr_coeffs
        state.dzB_memory           = zeros(n_ch)
        state.zY_memory            = zeros(n_ch)
        state.g_memory             = coeffs.g0_coeffs
        state.dg_memory            = zeros(n_ch)
        state.ac_coupler           = zeros(n_ch)
        return state
end



function AGC_Init_State(coeffs::AGC_coeffs_struct)::AGC_state
        # % 2025 new way, one struct instead of array of them.
        state = AGC_state()

        state.AGC_memory  = zeros(coeffs.n_ch, coeffs.n_AGC_stages)
        state.decim_phase = zeros(1, coeffs.n_AGC_stages) #  % small ints

        if coeffs.simpler_decimating  # % One decimation factor vs per stage.
                state.input_accum = zeros(coeffs.n_ch, 1);
        else
                state.input_accum = zeros(coeffs.n_ch, coeffs.n_AGC_stages);
        end
        return state
end



function IHC_Init_State(coeffs::IHC_coeffs_struct)::IHC_state
        n_ch = coeffs.n_ch;

        state = IHC_state()

        if coeffs.just_hwr
                state.ihc_accum = zeros(n_ch);
        elseif coeffs.one_cap
                state.ihc_accum     = zeros(n_ch)
                state.cap_voltage   = coeffs.rest_cap * ones(n_ch)
                state.lpf1_state    = coeffs.rest_output * ones(n_ch)
                state.lpf2_state    = coeffs.rest_output * ones(n_ch)
        else
                state.ihc_accum     = zeros(n_ch)
                state.cap1_voltage  = coeffs.rest_cap1 * ones(n_ch)
                state.cap2_voltage  = coeffs.rest_cap2 * ones(n_ch)
                state.lpf1_state    = coeffs.rest_output * ones(n_ch)
        end
        return state
end

 

function SYN_Init_State(coeffs::SYN_coeffs)::SYN_state
        n_ch = coeffs.n_ch;
        n_cl = coeffs.n_classes;
        state = SYN_state()
        state.reservoirs    = ones(n_ch) * transpose( coeffs.res_lpf_inits )  # % 0 full, 1 empty.
        state.lpf_state     = ones(n_ch) * transpose( coeffs.spont_p       )

        return state
end
