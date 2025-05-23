### A Pluto.jl notebook ###
# v0.20.8

using Markdown
using InteractiveUtils

# ╔═╡ d3d24c69-f186-494e-bf7b-ad9ce73efaa4
begin
	using LinearAlgebra
	using StaticArrays
end

# ╔═╡ dbd593e8-377b-11f0-08d7-3d503e18c52e
struct so3 end

# ╔═╡ 244f2c53-8517-436c-b3ca-3e7dc440f26e
begin
	# 𝔰𝔬(3) の生成元
	G1 = @SMatrix [
		0 0 0
		0 0 -1
		0 1 0
	]
	
	G2 = @SMatrix [
		0 0 1
		0 0 0
		-1 0 0
	]
	
	G3 = @SMatrix [
		0 -1 0
		1 0 0 
		0 0 0
	]
end

# ╔═╡ 1e456efd-8bca-44b8-8b21-c2a727bf1211
function skew(::Type{so3}, ω)
	a, b, c = ω[1], ω[2], ω[3]
	@SMatrix [
		0 -c b
		c 0 -a
		-b a 0
	]
end

# ╔═╡ 972863c3-2130-4d12-a991-7e785880966a
skew(so3, rand(3))

# ╔═╡ d968260d-6aed-4db9-817d-fea5a839599e
let
	ω = [1, 0, 0]
	θ = norm(ω)
end

# ╔═╡ ba40a4af-4c83-459b-9fce-dd036ddf32a1
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

# ╔═╡ db5c72b8-fd70-4440-867f-fe591f600300
[
	exp(G1), exp(G2), exp(G3)
]

# ╔═╡ 5d8d7a3a-238d-49a2-8813-608537579df1
begin
	@assert exp(so3, @SVector [0., 0., 0.]) ≈ I(3)
	@assert exp(so3, @SVector [1., 0., 0.]) ≈ exp(G1)
	@assert exp(so3, @SVector [0., 1., 0.]) ≈ exp(G2)
	@assert exp(so3, @SVector [0., 0., 1.]) ≈ exp(G3)
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
# ╠═d3d24c69-f186-494e-bf7b-ad9ce73efaa4
# ╠═dbd593e8-377b-11f0-08d7-3d503e18c52e
# ╠═244f2c53-8517-436c-b3ca-3e7dc440f26e
# ╠═db5c72b8-fd70-4440-867f-fe591f600300
# ╠═1e456efd-8bca-44b8-8b21-c2a727bf1211
# ╠═972863c3-2130-4d12-a991-7e785880966a
# ╠═d968260d-6aed-4db9-817d-fea5a839599e
# ╠═ba40a4af-4c83-459b-9fce-dd036ddf32a1
# ╠═5d8d7a3a-238d-49a2-8813-608537579df1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
