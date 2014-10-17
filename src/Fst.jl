module Fst

using Lumberjack

export Wfst, wfst2dot, create_pdf, add_arc, add_initial_state, add_final_state,
        compose, states_with_no_in_edges, topological_sort

# The weighted FST type.
type Wfst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    # Transition rules of the form: (fromstate, tostate, input, output, weight)
    transitions::Set
    # Maps from initial and final states to their weights.
    initial_weights::Dict
    final_weights::Dict
end

# Empty constructor
Wfst() = Wfst(Set(), Set{String}(), Set{String}(), Set(), Set(), Set(),
            Dict(), Dict())

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
    for rule in wfst.transitions
        # fromtext and totext used to allow us to prepend quotes in the
        # actual nodes names with backslashes so that bash pipes the desired
        # text to graphviz.
        fromtext = replace(string(rule[1]), r"\"", "\\\"")
        totext = replace(string(rule[2]), r"\"", "\\\"")
        s = "$s\t\"$fromtext\" -> \"$totext\"
             [label=\"$(string(rule[3])):$(string(rule[4]))/$(rule[5])\"];\n"
    end
    s = "$s}"
    return s
end

function create_pdf(wfst::Wfst, filename::String)
    dotstring = wfst2dot(wfst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end

function add_arc(wfst::Wfst,
        from::String, to::String,
        input::String, output::String, weight::Float64)
    wfst.states = union(wfst.states, Set([[from], [to]]))
    wfst.input_alphabet = union(wfst.input_alphabet, Set([input]))
    wfst.output_alphabet = union(wfst.output_alphabet, Set([output]))
    wfst.transitions =
            union(wfst.transitions, Set([(from, to, input, output, weight)]))
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
    transitions = Set()


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
        # For each rule combination that travels from the states of 'a' and 'b'
        for rule_combo in [(x,y) for x in a.transitions, y in b.transitions]
            if rule_combo[1][1] == state[1] && rule_combo[2][1] == state[2]
                # If the output of the 'a' rule == the input of the 'b' rule
                if rule_combo[1][4] == rule_combo[2][3]
                    next_state = (rule_combo[1][2], rule_combo[2][2])
                    if !(next_state in states)
                        states = union(states, Set([next_state]))
                        push!(queue, next_state)
                    end
                    new_rule = (state,next_state,
                            rule_combo[1][3],rule_combo[2][4],
                            rule_combo[1][5]*rule_combo[2][5])
                    debug(string("new_rule: ", new_rule))
                    transitions = union(transitions, Set([new_rule]))
                end
            end
        end
    end

    # Then consider removing unreachable states and transitions that cannot
    # occur
    return Wfst(states, input_alphabet, output_alphabet, initial_states,
           final_states, transitions, initial_weights, final_weights)
end

# Add a state to the final states list
function add_final_state(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.final_states = union(wfst.final_states, Set([state]))
end

# Add a state to the initial states list
function add_initial_state(wfst::Wfst, state::String)
    @assert state in wfst.states
    wfst.initial_states = union(wfst.initial_states, Set([state]))
end

# Returns a topolically sorted ordering of the states in the supplied wfst.
function topological_sort(wfst::Wfst)
    graph = deepcopy(wfst)
    l = Any[]
    s = states_with_no_in_edges(wfst)
    while length(s) > 0
        n = pop!(s)
        push!(l, n)
        debug(string("s: ", s))
        debug(string("l: ", l))
        # Remove edges that lead from n to other nodes
        for rule in graph.transitions
            if rule[1] == n
                debug(string("rule to delete: ", rule))
                graph.transitions = setdiff(graph.transitions, Set([rule]))
                debug(string("graph.transitions: ", graph.transitions))
                # Add to the queue those other nodes have other incoming edges.
                if rule[2] in states_with_no_in_edges(graph)
                    s = union(s, Set([rule[2]]))
                end
            end
        end
    end
    debug(string("graph.transitions: ", graph.transitions))
    if length(graph.transitions) > 0
        error("Graph is cyclic.")
    else
        return l
    end
end

# Returns a set of states that have no edges coming in.
function states_with_no_in_edges(wfst::Wfst)
    states_with_in_edges = Set([rule[2] for rule in wfst.transitions])
    return setdiff(wfst.states, states_with_in_edges)
end
end
