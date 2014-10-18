export topological_sort

# Returns a topolically sorted ordering of the states in the supplied wfst.
function topological_sort(wfst::Wfst)
    graph = deepcopy(wfst)
    l = Any[]
    s = states_with_no_in_arcs(wfst)
    while length(s) > 0
        n = pop!(s)
        push!(l, n)
        debug(string("s: ", s))
        debug(string("l: ", l))
        # Remove arcs that lead from n to other nodes
        for arc in graph.arcs
            if arc.from == n
                debug(string("arc to delete: ", arc))
                graph.arcs = setdiff(graph.arcs, Set([arc]))
                debug(string("graph.arcs ", graph.arcs))
                # Add to the queue those other states have other incoming arcs.
                if arc.to in states_with_no_in_arcs(graph)
                    s = union(s, Set([arc.to]))
                end
            end
        end
    end
    debug(string("graph.arcs: ", graph.arcs))
    if length(graph.arcs) > 0
        error("Graph is cyclic.")
    else
        return l
    end
end

# Returns a set of states that have no arcs coming in.
function states_with_no_in_arcs(wfst::Wfst)
    states_with_in_arcs = Set([arc.to for arc in wfst.arcs])
    return setdiff(wfst.states, states_with_in_arcs)
end
