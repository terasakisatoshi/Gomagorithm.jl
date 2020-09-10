# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.5.2
#   kernelspec:
#     display_name: Julia 1.5.0
#     language: julia
#     name: julia-1.5
# ---

# # fixed_arrays.jl

using StaticArrays

function unit(::Type{T}, i::Integer) where T<:StaticVector
    T(ntuple(Val(length(T))) do j
        ifelse(i==j, 1,0)
    end)
end

macro fixed_vector(name, parent)
    esc(quote
        """
            S: Size
            T: Type
        """
        struct $(name){S, T} <: $(parent){S, T}
                data::NTuples{S, T}
                function $(name){S, T}(x::NTuple{S, T}) where {S, T}
                   new{S, T}(x)
                end
                
                function $(name){S, T}(x::NTuple{S, Any}) where {S, T}
                   new{S, T}(StaticArrays.convert_ntuple(T, x))
                end
            end
        end
    )
end

@macroexpand @fixed_vector goma kyu
