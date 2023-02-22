# GDX.jl
 Load a GDX file into the GamsStucture package 

https://github.com/mitchphillipson/GamsStructure.jl


Since GAMS is case insensitive this package will make all sets lower case and all parameters uppercase. 

All aliases in parameter domains are replaced by their non-aliased twin. For example, if $i$ is a set and $j$ is an alias of $i$ then all instances of $j$ in a parameter definition are replaced with $j$.

If a parameter has a * domain, then a new set is created based on the entries of the column. This set will be called :__[parm_name]_[column_index].

To Do:
1. Add options to load_universe_gdx to do the following:
    1. Only load some sets/parameters
    2. Don't load aliases
2. 