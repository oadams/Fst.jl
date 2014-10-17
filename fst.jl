using Lumberjack

# The FST type that doesn't support weighted arcs.
type Fst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    transitions::Set
    initial_weights::Dict
    final_weights::Dict
end

# Empty constructor
Fst() = Fst(Set(), Set{String}(), Set{String}(), Set(), Set(), Set(),
            Dict(), Dict())

function fst2dot(fst::Fst)
    s = "digraph FST {\n"
    for node in fst.states
        nodetext = replace(string(node), r"\"", "\\\"")
        if node in fst.final_states
            s = "$s\t\"$nodetext\" [shape=doublecircle, color=purple
                label=\"$nodetext$(haskey(fst.final_weights, node) ?
                string("/", fst.final_weights[node]) : "")\"]\n"
        elseif node in fst.initial_states
            s = "$s\t\"$nodetext\" [shape=circle, color=green
                label=\"$nodetext$(haskey(fst.initial_weights, node) ?
                string("/", fst.initial_weights[node]) : "")\"]\n"
        else
            s = "$s\t\"$nodetext\" [shape=circle]\n"
        end
    end
    for rule in fst.transitions
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

function create_pdf(fst::Fst, filename::String)
    dotstring = fst2dot(fst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end

function add_arc(fst::Fst,
        from::String, to::String,
        input::String, output::String, weight::Float64)
    fst.states = union(fst.states, Set([[from], [to]]))
    fst.input_alphabet = union(fst.input_alphabet, Set([input]))
    fst.output_alphabet = union(fst.output_alphabet, Set([output]))
    fst.transitions =
            union(fst.transitions, Set([(from, to, input, output, weight)]))
end

function compose(a::Fst, b::Fst)
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
        # This is going to cause things to blow up (we don't enforce weights)
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
    return Fst(states, input_alphabet, output_alphabet, initial_states,
           final_states, transitions, initial_weights, final_weights)
end

# Add a compose operator in the same style as pyfst
(>>) = compose

# Add a state to the final states list
function add_final_state(fst::Fst, state::String)
    @assert state in fst.states
    fst.final_states = union(fst.final_states, Set([state]))
end

# Add a state to the initial states list
function add_initial_state(fst::Fst, state::String)
    @assert state in fst.states
    fst.initial_states = union(fst.initial_states, Set([state]))
end

a = Fst()
add_arc(a, "0", "1", "a", "b", 0.1)
add_arc(a, "1", "0", "a", "b", 0.2)
add_arc(a, "1", "2", "b", "b", 0.3)
add_arc(a, "1", "3", "b", "b", 0.4)
add_arc(a, "2", "3", "a", "b", 0.5)
add_arc(a, "3", "3", "a", "a", 0.6)
add_initial_state(a, "0")
add_final_state(a, "3")
a.final_weights["3"] = 0.7
create_pdf(a, "a.pdf")


b = Fst()
add_arc(b, "0", "1", "b", "b", 0.1)
add_arc(b, "1", "1", "b", "a", 0.2)
add_arc(b, "1", "2", "a", "b", 0.3)
add_arc(b, "1", "3", "a", "b", 0.4)
add_arc(b, "2", "3", "b", "a", 0.5)
add_initial_state(b, "0")
add_final_state(b, "3")
b.final_weights["3"] = 0.6
create_pdf(b, "b.pdf")

c = compose(a, b)
create_pdf(c, "c.pdf")
