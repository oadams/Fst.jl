export compose_basic, compose_epsilon

function compose_basic(a::Wfst, b::Wfst)
    # Assert that the WFSTs are using the same semiring.
    @assert a.semiring == b.semiring

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
            initial_weights[state] = a.semiring.multiplication(
                    a.initial_weights[state[1]], b.initial_weights[state[2]])
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
            final_weights[state] = a.semiring.multiplication(
                    a.final_weights[state[1]], b.final_weights[state[2]])
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
                    product = a.semiring.multiplication(
                            arc_combo[1].weight, arc_combo[2].weight)
                    new_arc = Arc(state,next_state,
                            arc_combo[1].input, arc_combo[2].output,
                            product)
                    debug(string("new_arc: ", new_arc))
                    arcs = union(arcs, Set{Arc}([new_arc]))
                end
            end
        end
    end

    return Wfst(states, input_alphabet, output_alphabet, initial_states,
           final_states, arcs, initial_weights, final_weights, a.semiring)
end

function compose_epsilon(a::Wfst, b::Wfst)
    @assert a.output_alphabet == b.input_alphabet

    for arc in a.arcs
        if arc.output == "<eps>"
            arc.output = "<eps2>"
        end
    end
    for arc in b.arcs
        if arc.input == "<eps>"
            arc.input = "<eps1>"
        end
    end
    for state in a.states
        add_arc!(a, state, state, "<eps>", "<eps1>", 1.0)
    end
    for state in b.states
        add_arc!(b, state, state, "<eps2>", "<eps>", 1.0)
    end
    f = create_filter(a.output_alphabet)
    c = compose_basic(compose_basic(a,f), b)
    return c
end

# Creates a filter that is used to filter out redundant paths when composing
# WFSTs with epsilon transitions.
function create_filter(alphabet::Set{String})
    f = Wfst()
    for symbol in alphabet
        add_arc!(f, 0, 0, symbol, symbol, 1.0)
    end
    add_arc!(f, 0, 0, "<eps2>", "<eps1>", 1.0)
    add_arc!(f, 0, 1, "<eps1>", "<eps1>", 1.0)
    add_arc!(f, 1, 1, "<eps1>", "<eps1>", 1.0)
    for symbol in alphabet
        add_arc!(f, 1, 0, symbol, symbol, 1.0)
    end
    add_arc!(f, 0, 2, "<eps2>", "<eps2>", 1.0)
    add_arc!(f, 2, 2, "<eps2>", "<eps2>", 1.0)
    for symbol in alphabet
        add_arc!(f, 2, 0, symbol, symbol, 1.0)
    end
    add_initial_state!(f, 0, 1.0)
    add_final_state!(f, 0, 1.0)
    add_final_state!(f, 1, 1.0)
    add_final_state!(f, 2, 1.0)
    return f
end
