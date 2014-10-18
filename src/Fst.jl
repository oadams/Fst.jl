module Fst

using Lumberjack

export Wfst, Arc, wfst2dot, create_pdf, add_arc!, add_initial_state!,
        add_final_state!, compose, states_with_no_in_arcs, topological_sort

# The arc type that specify "arcs", "edges" or "transition rules".
type Arc
    from
    to
    input::String
    output::String
    weight::Float64
end

# The weighted FST type.
type Wfst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    # Arcs of the form: (from, to, input, output, weight)
    arcs::Set{Arc}
    # Maps from initial and final states to their weights.
    initial_weights::Dict
    final_weights::Dict
end

# Empty constructor
Wfst() = Wfst(Set(), Set{String}(), Set{String}(), Set(), Set(),
        Set{Arc}(), Dict(), Dict())

# Returns a string representation of the supplied WFST in the DOT language for
# use with Graphviz.
function wfst2dot(wfst::Wfst)
    s = "digraph FST {\n"
    for node in wfst.states
        nodetext = replace(string(node), r"\"", "\\\"")
        if node in wfst.final_states
            s = "$s\t\"$nodetext\" [shape=doublecircle, color=purple
                label=\"$nodetext$(haskey(wfst.final_weights, node) ?
                string("/", wfst.final_weights[node]) : "")\"]\n"
        elseif node in wfst.initial_states
            s = "$s\t\"$nodetext\" [shape=circle, color=green
                label=\"$nodetext$(haskey(wfst.initial_weights, node) ?
                string("/", wfst.initial_weights[node]) : "")\"]\n"
        else
            s = "$s\t\"$nodetext\" [shape=circle]\n"
        end
    end
    for arc in wfst.arcs
        # fromtext and totext used to allow us to prepend quotes in the
        # actual nodes names with backslashes so that bash pipes the desired
        # text to graphviz.
        fromtext = replace(string(arc.from), r"\"", "\\\"")
        totext = replace(string(arc.to), r"\"", "\\\"")
        s = "$s\t\"$fromtext\" -> \"$totext\"
             [label=\"$(string(arc.input)):$(string(arc.output))
             /$(arc.weight)\"];\n"
    end
    s = "$s}"
    return s
end

function create_pdf(wfst::Wfst, filename::String)
    dotstring = wfst2dot(wfst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end

function add_arc!(wfst::Wfst,
        from::String, to::String,
        input::String, output::String, weight::Float64)
    wfst.states = union(wfst.states, Set([[from], [to]]))
    wfst.input_alphabet = union(wfst.input_alphabet, Set([input]))
    wfst.output_alphabet = union(wfst.output_alphabet, Set([output]))
    wfst.arcs =
            union(wfst.arcs, Set([Arc(from, to, input, output, weight)]))
end

function compose(a::Wfst, b::Wfst)
    # Note that we're going with the probability semiring right now.

    # The input and output alphabets are those of a and b respectively
    @assert a.output_alphabet == b.input_alphabet
    input_alphabet = a.input_alphabet
    output_alphabet = b.output_alphabet
    debug("a.output_alphabet == b.input_alphabet")

    # Initial states are the cross product of the states of the two FSTs
    initial_states =
            Set([(x,y) for x in a.initial_states, y in b.initial_states])
    debug(string("initial_states: ", initial_states))

    # Initialize the weights for the initial states
    initial_weights = Dict()
    for state in initial_states
        if haskey(a.initial_weights, state[1]) &&
                haskey(b.initial_weights, state[2])
            initial_weights[state] =
                    a.initial_weights[state[1]] * b.initial_weights[state[2]]
        end
    end
    debug(string("initial_weights: ", initial_weights))
    # States start with the initial states
    states = Set([(x,y) for x in a.initial_states, y in b.initial_states])
    # Our queue also starts with the initial states
    queue = [(x,y) for x in a.initial_states, y in b.initial_states]
    queue = reshape(queue, length(queue))
    # Let the final states start empty
    final_states = Set()
    final_weights = Dict()
    arcs::Set{Arc} = Set{Arc}()

    # From the starting states, propagate through the Fst along possible
    # composed paths adding states and weights as we go.
    while queue != []
        debug(string("queue: ", queue))
        state = shift!(queue)
        if state in [(x,y) for x in a.final_states, y in b.final_states]
            debug(string("state ", state, " in final state cross product."))
            final_states = union(final_states, Set([state]))
            final_weights[state] = a.final_weights[state[1]] *
                    b.final_weights[state[2]]
        end
        # For each arc combination that travels from the states of 'a' and 'b'
        for arc_combo in [(x,y) for x in a.arcs, y in b.arcs]
            if arc_combo[1].from == state[1] && arc_combo[2].from == state[2]
                # If the output of the 'a' arc == the input of the 'b' arc
                if arc_combo[1].output == arc_combo[2].input
                    next_state = (arc_combo[1].to, arc_combo[2].to)
                    if !(next_state in states)
                        states = union(states, Set([next_state]))
                        push!(queue, next_state)
                    end
                    new_arc = Arc(state,next_state,
                            arc_combo[1].input, arc_combo[2].output,
                            arc_combo[1].weight * arc_combo[2].weight)
                    debug(string("new_arc: ", new_arc))
                    arcs = union(arcs, Set{Arc}([new_arc]))
                end
            end
        end
    end

    return Wfst(states, input_alphabet, output_alphabet, initial_states,
           final_states, arcs, initial_weights, final_weights)
end

# Add a state to the final states list
function add_final_state!(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.final_states = union(wfst.final_states, Set([state]))
end

# Add a state to the initial states list
function add_initial_state!(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.initial_states = union(wfst.initial_states, Set([state]))
end

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
end
