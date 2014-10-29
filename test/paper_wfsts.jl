using Fst

lexicon = read_wfst(readall("fsts/paper_wfsts/lexicon.txt"))
create_pdf(lexicon, "fsts/paper_wfsts/lexicon.pdf")

lm = read_wfst(readall("fsts/paper_wfsts/lm.txt"))
create_pdf(lm, "fsts/paper_wfsts/lm.pdf")

lexicon_lm = compose_epsilon(lexicon, lm)
create_pdf(lexicon_lm, "fsts/paper_wfsts/lexicon_lm.pdf")

tm = read_wfst(readall("fsts/paper_wfsts/tm.txt"))
create_pdf(tm, "fsts/paper_wfsts/tm.pdf")

lexicon_tm = compose_epsilon(lexicon, tm)
lexicon_tm = trim(lexicon_tm)
create_pdf(lexicon_tm, "fsts/paper_wfsts/lexicon_tm_trim.pdf")
