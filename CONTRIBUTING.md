# How to contribute to Overpass.jl

## Did you find a bug or you intend to add a new feature?
- Ensure the bug or feature request was not already reported by searching on GitHub under [Issues](https://github.com/gwehrle/Overpass.jl/issues).

- If you're unable to find an open issue addressing your topic, open a [new one](https://github.com/gwehrle/Overpass.jl/issues). Be sure to include a **title** and **clear description**, as much relevant information as possible. If you report a bug please add a **code sample** or an **executable test case** demonstrating the expected behavior that is not occurring.

## Did you write a patch that solves an issue?

- Open a new GitHub pull request with the patch.
- Ensure the PR description clearly describes what you did. Include the relevant issue number if applicable.
- Please make **granular commits** by ensuring that each commit addresses a single, specific change. Unrelated changes should be committed separately. For example, **renaming files** or **reformatting code** should be done in separate commits from logic changes to maintain clarity and ease of review.

## Project Setup

It's highly recommended to use [Revise.jl](https://timholy.github.io/Revise.jl/) for developement.\
Please follow their documentation for project setup.

### Run all tests

```julia-repl
julia> ]
pkg> test
```

### Enforce coding style

```julia-repl
julia> using JuliaFormatter
julia> format(".")
```

### Locally build and serve documentation

```julia-repl
julia> ]
pkg>   activate docs
julia> using LiveServer
julia> LiveServer.servedocs()
```

Thanks! ❤️ 🚂
