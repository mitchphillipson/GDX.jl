module GDX

using PyCall
using DataFrames
using GamsStructure

#@pyimport gams.transfer as gt

const gt = PyNULL()

function __init__()
    copy!(gt, pyimport("gams.transfer"))
end

export load_universe_gdx,load_universe_gdx!


function pd_to_df(df_pd)
    df= DataFrame()
    for col in df_pd.columns
        df[!, col] = [e for e in df_pd.get(col)]
    end
    df
end

function GamsSet_from_python(py_set)
    X = py_set.records
    description =py_set.description
    df = pd_to_df(X)
    elms = [GamsElement(Symbol(e),desc) for (e,desc) in zip(df[:,1],df[:,2])]
    return GamsSet(elms,description)
end


function GamsSet_from_python!(GU,py_set)
    name = Symbol(lowercase(py_set.name))
    s = GamsSet_from_python(py_set)
    add_set(GU,name,s)
end


function convert_domain(domain::Tuple{Int64,PyObject},X,GU)
    _,s = domain
    @assert py"type"(s)∈[gt.Set,gt.Alias] "Parameter $(X.name) domain entry $(s.name) has type $(py"type"(s)), should be Set or Alias"
    if py"type"(s) == gt.Set
        name = Symbol(lowercase(s.name))
    end
    if py"type"(s) == gt.Alias
        name = Symbol(lowercase(s.alias_with.name))
    end
    return name
end

function convert_domain(domain::Tuple{Int64,String},X,GU)
    ind,s = domain
    #@assert s=="*" "Parameter $(X.name) has string domain \"$s\", only expect \"*\""
    df = pd_to_df(X.records)
    if s == "*"
        elms = [GamsElement(e,"") for e in unique(df[!,ind])]
        description  = "Generated domain for column $ind of parameter $(X.name)"
        S = GamsSet(elms,description)
        name = Symbol("__$(lowercase(X.name))_2")
        add_set(GU,name,S)
    else
        name = Symbol(s)
        @assert name in keys(sets(GU)) """Parameter $(X.name) has string domain $s that is not a set. Odds are 
        when the GDX file unloaded an alias wasn't unloaded at the same time. Once you figure out what that alias
        is add the keyword aliases = Dict(:base_set => [:$(X.name)]) to this function call. If you find more aliases,
        add more sets to this."""
    end
    return name
end

function GamsParameter_from_python(GU,py_parm)
    description = py_parm.description
    set_names = Tuple(map(x-> convert_domain(x,py_parm,GU),enumerate(py_parm.domain)))
    P = GamsParameter(GU,set_names,description)

    if !(isnothing(py_parm.records))
        df = pd_to_df(py_parm.records)
        for row in eachrow(df)
            index = [[Symbol(e)] for e in row[begin:end-1]]
            P[index...] = row[:value]
        end
    end

    return P
end

function GamsParameter_from_python!(GU,py_parm)
    name = Symbol(uppercase(py_parm.name))
    P = GamsParameter_from_python(GU,py_parm)
    add_parameter(GU,name,P)
end


function load_universe_gdx!(GU,path_to_gdx;aliases = Dict{Symbol,Vector{Symbol}}())
    w = gt.Container(path_to_gdx)
    #Sets
    for key in w.data
        X = w.data.get(key)
        if !(isnothing(X)) && py"type"(X) == gt.Set
            GamsSet_from_python!(GU,X)
        end
    end
    #Alaises
    for (parent,child) in aliases
        map(c->alias(GU,parent,c),child)
    end
    for key in w.data
        X = w.data.get(key)
        if !(isnothing(X)) && py"type"(X) == gt.Alias
            parent = Symbol(lowercase(X.alias_with.name))
            alias(GU,parent,Symbol(lowercase(key)))
        end
    end
    #Parameters
    for key in w.data
        X = w.data.get(key)
        if !(isnothing(X)) && py"type"(X) == gt.Parameter
            GamsParameter_from_python!(GU,X)
        end
    end
    return GU
end


function load_universe_gdx(path_to_gdx;aliases = Dict{Symbol,Vector{Symbol}}())
    GU = GamsUniverse()
    return load_universe_gdx!(GU,path_to_gdx, aliases = aliases)
end



end # module GDX
