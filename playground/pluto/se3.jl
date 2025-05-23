### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ a1396782-31ad-4d97-b369-34f130a99445
begin
	using LinearAlgebra
	using StaticArrays
end

# ╔═╡ 2933c764-377e-11f0-127c-ff0723372567
begin
	struct so3 end
	struct se3 end
end

# ╔═╡ 32e17b02-bb4b-4844-95ab-8a5a38147ae9
function skew(::Type{so3}, ω)
	a, b, c = ω[1], ω[2], ω[3]
	@SMatrix [
		0 -c b
		c 0 -a
		-b a 0
	]
end

# ╔═╡ 8ba26216-f03a-4023-a75b-7dee2c6d20bd
begin
	G1 = @SMatrix Float64[
		0 0 0 1
		0 0 0 0
		0 0 0 0
		0 0 0 0
	]
	
	G2 = @SMatrix Float64[
		0 0 0 0
		0 0 0 1
		0 0 0 0
		0 0 0 0
	]
	
	G3 = @SMatrix Float64[
		0 0 0 0
		0 0 0 0
		0 0 0 1
		0 0 0 0
	]

	G4 = @SMatrix Float64[
		0 0  0 0
		0 0  -1 0
		0 1 0 0
		0 0 0  0
	]

	G5 = @SMatrix Float64[
		0 0 1 0
		0 0 0 0
		-1 0 0 0
		0 0 0 0
	]

	G6 = @SMatrix Float64[
		0 -1 0 0
		1 0 0 0
		0 0 0 0
		0 0 0 0
	]
end

# ╔═╡ cb0da492-dc86-4e98-aeaf-35ae95088505
function alg2group(se3, u_ω::SVector{6, Float64})
	u1, u2, u3, ω1, ω2, ω3 = u_ω
	ω = @SVector [ω1, ω2, ω3]
	u = @SVector [u1, u2, u3]
	θ = norm(ω)
	ω_sk = @SMatrix [
		0 -ω3 ω2
		ω3 0 -ω1
		-ω2 ω1 0
	]
	
	return SMatrix{4, 4, Float64}[
		ω_sk u
		0 0 0 0
	]
end

# ╔═╡ 725bbeb2-1483-447d-9fd4-ce547bf3fe86
function Base.exp(::Type{so3}, ω::SVector{3, Float64})
	θ = norm(ω)
	ω_sk = skew(so3, ω)
	sinθ_over_θ = if θ ≈ 0
		1 - (θ^2/6)*(1 - (θ^2/20) * (1 - θ^2/42))
	else
		sin(θ) / θ
	end

	one_minus_cosθ_over_θ² = if θ ≈ 0
		0.5*(1 - (θ^2/12) * (1 - (θ^2/30) * (1 - θ^2/56)))
	else
		(1 - cos(θ))/(θ^2)
	end
	return I(3) + sinθ_over_θ * ω_sk + one_minus_cosθ_over_θ² * ω_sk * ω_sk
end

# ╔═╡ 13060795-ad7a-4069-bde0-650a1d187416
function Base.exp(::Type{se3}, u_ω::SVector{6, Float64})
	u1, u2, u3, ω1, ω2, ω3 = u_ω
	ω = @SVector [ω1, ω2, ω3]
	u = @SVector [u1, u2, u3]
	θ = norm(ω)
	ω_sk = skew(so3, ω)
	exp_ω_sk = exp(so3, ω)
	one_minus_cosθ_over_θ² = if θ ≈ 0
		0.5*(1 - (θ^2/12) * (1 - (θ^2/30) * (1 - θ^2/56)))
	else
		(1 - cos(θ))/(θ^2)
	end

	θ_minus_sinθ_over_θ³ = if θ ≈ 0 
		1/6 * (1 - (θ^2/20) * (1 - (θ^2/42) * (1-(θ^2/72))))
	else
		(θ - sin(θ))/(θ^3)
	end
	
	V = I(3) + one_minus_cosθ_over_θ² * ω_sk + θ_minus_sinθ_over_θ³ * ω_sk * ω_sk
	Vu = V * u
	return [
		exp_ω_sk Vu
		0 0 0 1
	]
end

# ╔═╡ e6ecb58f-71ff-4fee-8d9d-9a1dcfe8ff4a
begin
	@assert exp(se3, @SVector[0,0,0,0,0,0.0]) ≈ I(4)
	@assert exp(se3, @SVector[1.0,0,0,0,0,0]) ≈ exp(G1)
	@assert exp(se3, @SVector[0,1.0,0,0,0,0]) ≈ exp(G2)
	@assert exp(se3, @SVector[0,0,1.0,0,0,0]) ≈ exp(G3)
	@assert exp(se3, @SVector[0,0,0,1.0,0,0]) ≈ exp(G4)
	@assert exp(se3, @SVector[0,0,0,0,1.0,0]) ≈ exp(G5)
	@assert exp(se3, @SVector[0,0,0,0,0,1.0]) ≈ exp(G6)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[compat]
StaticArrays = "~1.9.13"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.5"
manifest_format = "2.0"
project_hash = "261c2414089ece81d677bdce651e11ecbd4eb320"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"
"""

# ╔═╡ Cell order:
# ╠═a1396782-31ad-4d97-b369-34f130a99445
# ╠═2933c764-377e-11f0-127c-ff0723372567
# ╠═32e17b02-bb4b-4844-95ab-8a5a38147ae9
# ╠═8ba26216-f03a-4023-a75b-7dee2c6d20bd
# ╠═cb0da492-dc86-4e98-aeaf-35ae95088505
# ╠═725bbeb2-1483-447d-9fd4-ce547bf3fe86
# ╠═13060795-ad7a-4069-bde0-650a1d187416
# ╠═e6ecb58f-71ff-4fee-8d9d-9a1dcfe8ff4a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
