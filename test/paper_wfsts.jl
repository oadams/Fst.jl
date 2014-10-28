using Fst

lexicon = read_wfst(readall("fsts/paper_wfsts/lexicon.txt"))
create_pdf(lexicon, "fsts/paper_wfsts/lexicon.pdf")

lm = read_wfst(readall("fsts/paper_wfsts/lm.txt"))
create_pdf(lm, "fsts/paper_wfsts/lm.pdf")

lexicon_lm = compose(lexicon, lm)
create_pdf(lexicon_lm, "fsts/paper_wfsts/lexicon_lm.pdf")
