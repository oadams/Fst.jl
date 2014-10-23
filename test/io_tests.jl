using Fst

text = "0 1 a b 1.0\n1 2 d c 1.0\n2 1.0"

create_pdf(read_wfst(text), "ioread.pdf")
