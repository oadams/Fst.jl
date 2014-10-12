# The FST type that doesn't support weighted arcs.
type Fst
    states::Set
    input_alphabet::Set{String}
    output_alphabet::Set{String}
    initial_states::Set
    final_states::Set
    transitions::Set
end

# Empty constructor
Fst() = Fst(Set(), Set{String}(), Set{String}(), Set(), Set(), Set())

function fst2dot(fst::Fst)
    s = "digraph FST {\n"
    for rule in fst.transitions
        println(rule[1])
        println(string("hello", string(rule[1])))
        #s = string(s, "\t", rule[1], " -> ", rule[2], ";\n")
        s = "$s\t$(string(rule[1])) -> $(string(rule[2]))
                [label=\"$(string(rule[3]))/$(string(rule[4]))\"];\n"
    end
    s = "$s}"
    return s
end

function create_pdf(fst::Fst, filename::String)
    dotstring = fst2dot(fst)
    run(`echo '$dotstring'` |> `dot -Tpdf -o $filename`)
end

function add_arc(fst::Fst,
        from::String, to::String,
        input::String, output::String)
    fst.states = union(fst.states, Set([[from], [to]]))
    fst.input_alphabet = union(fst.input_alphabet, Set([input]))
    fst.output_alphabet = union(fst.output_alphabet, Set([output]))
    fst.transitions = union(fst.transitions, Set([(from, to, input, output)]))
end

function compose(a::Fst, b::Fst)
    # Check that the output alphabet of a matches the input alphabet of b

    # New states are the cross product of the states of the two FSTs
    states = Set([(x,y) for x in a.states, y in b.states])
    ##println(states)

    # New initial_states and final_states are created similarly
    initial_states =
            Set([(x,y) for x in a.initial_states, y in b.initial_states])
    ##println(initial_states)
    final_states =
            Set([(x,y) for x in a.final_states, y in b.final_states])
    #println(final_states)

    # Then combine the rules
    transitions = Set()
    for a_rule in a.transitions
        for b_rule in b.transitions
            if a_rule[4] == b_rule[3]
                transitions = union(transitions,
                        Set([((a_rule[1], b_rule[1]), (a_rule[2], b_rule[2]),
                        a_rule[3], b_rule[4])]))
            end
        end
    end
    #println(transitions)

    input_alphabet = a.input_alphabet
    output_alphabet = b.output_alphabet

    # Then consider removing unreachable states and transitions that cannot
    # occur

    # Then create the new fst and return it
    #println(typeof(states))
    #println(typeof(input_alphabet))
    #println(typeof(output_alphabet))
    #println(typeof(initial_states))
    ###println(typeof(final_states))
    #println(typeof(transitions))
    return Fst(states, input_alphabet, output_alphabet, initial_states,
           final_states, transitions)
end

a = Fst()
add_arc(a, "0", "1", "a", "b")
add_arc(a, "1", "0", "a", "b")
add_arc(a, "1", "2", "b", "b")
add_arc(a, "2", "3", "a", "b")
add_arc(a, "1", "3", "b", "b")
create_pdf(a, "a.pdf")


b = Fst()
add_arc(b, "0", "1", "b", "b")
add_arc(b, "1", "1", "b", "a")
add_arc(b, "1", "2", "a", "b")
add_arc(b, "1", "3", "a", "b")
add_arc(b, "2", "3", "b", "a")
#println(fst2dot(b))
create_pdf(b, "b.pdf")

c = compose(a, b)
println(fst2dot(c))
create_pdf(c, "c.pdf")
#println("here")
