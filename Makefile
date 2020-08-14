.phony : all, pull, build, atom, web, clean

OS:=$(shell uname -s)
DOCKERIMAGE=gomagorithm

ifeq ($(OS), Linux)
TAG=latest
REMOTE_DOCKER_REPOSITORY:=terasakisatoshi/${DOCKERIMAGE}:${TAG}
endif
ifeq ($(OS), Darwin)
TAG=mac
REMOTE_DOCKER_REPOSITORY:=terasakisatoshi/${DOCKERIMAGE}:${TAG}
endif

all: build

pull:
	rm -f Manifest.toml
	docker pull ${REMOTE_DOCKER_REPOSITORY}
	docker build --cache-from ${REMOTE_DOCKER_REPOSITORY} -t ${DOCKERIMAGE} .
	docker-compose run --rm julia julia --project=/work -e 'using Pkg; Pkg.instantiate()'

build:
	rm -f Manifest.toml
	docker build -t ${DOCKERIMAGE} .
	docker-compose build
	docker-compose run --rm julia julia --project=/work -e 'using Pkg; Pkg.instantiate()'

atom:
ifeq ($(OS), Linux)
	docker run --rm -it --network=host -v ${PWD}:/work -w /work ${DOCKERIMAGE} julia -J/sysimages/atom.so --project=@. -L .atom/init_linux.jl
endif
ifeq ($(OS), Darwin) # i.e. macOS
	docker run --rm -it --network=host -v ${PWD}:/work -w /work ${DOCKERIMAGE} julia -J/sysimages/atom.so --project=@. -L .atom/init_mac.jl
endif
# Excecute in docker container
web: docs
	julia --project=docs -e '\
		using Pkg;\
		Pkg.develop(PackageSpec(path=pwd()));\
		Pkg.instantiate();\
		include("docs/make.jl");\
		'
	python3 -m http.server --bind 0.0.0.0 --directory docs/build

clean:
	docker-compose down
	rm -f docs/src/weavesample.md
	rm -f experiments/notebook/*.ipynb
	rm -rf experiments/notebook/*.gif
	rm -f  Manifest.toml
	rm -rf docs/build

