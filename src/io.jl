export wfst2dot, create_pdf, read_wfst

# Returns a string representation of the supplied WFST in the DOT language for
# use with Graphviz.
function wfst2dot(wfst::Wfst)
    s = "digraph FST {\n"
    for node in wfst.states
        nodetext = replace(string(node), r"\"", "\\\"")
        if node in wfst.final_states
            s = string("$s\t\"$nodetext\" [shape=doublecircle, color=purple, ",
                "label=\"$nodetext$(haskey(wfst.final_weights, node) ?
                string("/", wfst.final_weights[node]) : "")\"];\n")
        elseif node in wfst.initial_states
            s = string("$s\t\"$nodetext\" [shape=circle, color=green, ",
                "label=\"$nodetext$(haskey(wfst.initial_weights, node) ?
                string("/", wfst.initial_weights[node]) : "")\"];\n")
        else
            s = "$s\t\"$nodetext\" [shape=circle];\n"
        end
    end
    for arc in wfst.arcs
        # fromtext and totext used to allow us to prepend quotes in the
        # actual nodes names with backslashes so that bash pipes the desired
        # text to graphviz.
        fromtext = replace(string(arc.from), r"\"", "\\\"")
        totext = replace(string(arc.to), r"\"", "\\\"")
        s = string("$s\t\"$fromtext\" -> \"$totext\" ",
             "[label=\"$(string(arc.input)):$(string(arc.output))",
             "/$(arc.weight)\"];\n")
    end
    s = "$s}"
    return s
end

function create_pdf(wfst::Wfst, filename::String)
    dotstring = wfst2dot(wfst)
    run(`echo $dotstring` |> `dot -Tpdf -o $filename`)
end

# Reads a text representation of a WFST in AT&T format and returns the WFST.
function read_wfst(text)
    wfst = Wfst()
    lines = split(text, "\n")
    for line in lines
        line_items = split(line)
        if length(line_items) == 5
            # Then it's an arc
            from = int(line_items[1])
            to = int(line_items[2])
            input = string(line_items[3])
            output = string(line_items[4])
            weight = float64(line_items[5])
            add_arc!(wfst, from, to, input, output, weight)
        elseif length(line_items) == 2
            # Then it specifies a final weight.
            final = int(line_items[1])
            weight = float64(line_items[2])
            add_final_state!(wfst, final, weight)
        else
            error("Invalid line length")
        end
    end
    # This is going to break when we introduce other semirings because of the
    # weight.
    add_initial_state!(wfst, int(split(lines[1])[1]), 1.0)
    return wfst
end
