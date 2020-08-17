using JuliaFormatter
function postprocess()

  if get(ENV, "GITHUB_ACTIONS", "false") == "true"

    # TODO rewrite using Julia functions

    # Move the content of the directory to the root
    artifact_path = joinpath(pwd(), "artifact")
    run(`rsync -a $artifact_path/ ./`)
    run(`rm -d -r $artifact_path`)

    # Discard unrelated changes
    git_checkout_all(["precompile_includer.jl", r"precompile/.*precompile_.*\.jl"], pwd())

    # Format precompile_includer.jl
    format_file(joinpath(pwd(), "src/precompile_includer.jl"))

    # TODO
    # - name: Create Pull Request
    #   # https://github.com/marketplace/actions/create-pull-request
    #   uses: peter-evans/create-pull-request@v2
    #   with:
    #     token: ${{ secrets.GITHUB_TOKEN }}
    #     commit-message: Update precompile_*.jl file
    #     committer: YOUR NAME <yourEmail@something.com> # NOTE: change `committer` to your name and your email.
    #     title: "[AUTO] Update precompiles"
    #     labels: SnoopCompile
    #     branch: "SnoopCompile_AutoPR"

  end

end

using FilePathsBase
"""
  git_checkout_all( ignore_list::Vector, rootpath::AbstractString = pwd()) # <UString

Discard unrelated changes

# Examples
```julia
git_checkout_all(["precompile_includer.jl", r"precompile/.*precompile_.*\\.jl"], pwd())
```
"""
function git_checkout_all( ignore_list::Vector, rootpath::AbstractString = pwd()) # <UString
  push!(ignore_list, ".git/")
  for file in walkpath(Path(rootpath))
    filepath = GoodPath(string(file))
    if !any(occursin.( ignore_list,  Ref(filepath) ))
      if !isempty(readchomp(`git ls-files $filepath`))
        run(`git checkout -- $filepath`)
      end
    end
  end
end
