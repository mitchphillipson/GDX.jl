# GDX.jl
 Load a GDX file into the GamsStucture package 

https://github.com/mitchphillipson/GamsStructure.jl


Since GAMS is case insensitive this package will make all sets and parameters names be lower case. 

All aliases in parameter domains are replaced by their non-aliased twin. For example, if $i$ is a set and $j$ is an alias of $i$ then all instances of $j$ in a parameter definition are replaced with $i$. If it's an explicit alias.

If a parameter has a * domain, then a new set is created based on the entries of the column. This set will be called :__[parm_name]_[column_index].

This package requires you to install [gams.transfer](https://www.gams.com/latest/docs/API_PY_GAMSTRANSFER.html) into Julia's Python package. This will be loaded with PyCall.jl. I've found this to be finicky since gams.transfer is not available via pip (yet). Gams.transfer also requires a Gams installation. 

To Do:
1. Add options to load_universe_gdx to do the following:
    1. Only load some sets/parameters
2. ~~Add option to create aliases~~
