# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.5.2
#   kernelspec:
#     display_name: Julia 1.5.0-rc2
#     language: julia
#     name: julia-1.5
# ---

"""
    SOneTo(n)

Return a statically-sized `AbstractUnitRange` starting at `1`, functioning as the `axes` of a `StaticArray`
"""
struct SOneTo{n} <: AbstractUnitRange{Int} end

Base.first(::SOneTo) = 1
Base.last(::SOneTo{n}) where {n} = n::Int

# +
SOneTo(n::Int) = SOneTo{n}()

function SOneTo{n}(r::AbstractUnitRange) where {n}
    ((first(r) == 1) & (last(r) == n)) && return SOneTo{n}()
    
    errmsg(r) = throw(DimensionMismatch("$r is inconsistent with SOneTo{$n}"))
    errmsg(r)
end
# -

Base.Tuple(::SOneTo{n}) where {n} = ntuple(identity, Val(n))

Base.axes(s::SOneTo) = (s,)
Base.size(s::SOneTo) = (length(s),)
Base.length(s::SOneTo{n}) where {n} = n

Base.@propagate_inbounds function Base.getindex(s::SOneTo, i::Int)
    @boundscheck checkbounds(s, i)
    return i
end
Base.@propagate_inbounds function Base.getindex(s::SOneTo, s2::SOneTo)
    @boundscheck checkbounds(s, s2)
    return s2
end


Base.@pure Base.iterate(::SOneTo{n}) where {n} = ifelse(n::Int<1,nothing,(1,1))
Base.iterate(::SOneTo{n}, s::Int) where {n} = ifelse(s<n::Int, (s+1,s+1),nothing)

function Base.getproperty(::SOneTo{n}, s::Symbol) where {n}
    if s === :start
        return 1
    elseif s === :stop
        return n::Int
    else
        error("type SOneTo has no property $s")
    end
end

Base.show(io::IO, ::SOneTo{n}) where {n} = print(io, "SOneTo(", n::Int, ")")

# +
Base.@pure function Base.checkindex(::Type{Bool}, ::SOneTo{n1}, ::SOneTo{n2}) where {n1, n2}
    return n1::Int >= n2::Int
end

function Base.promote_rule(a::Type{Base.OneTo{T}}, ::Type{SOneTo{n}}) where {T,n} 
    Base.OneTo{promote_type(T, Int)}
end
