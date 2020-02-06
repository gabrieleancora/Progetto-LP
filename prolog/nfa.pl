%%%%% RAPIDA GUIDA DI PORROLOG %%%%%
% = non crea una sottolista ma fa solo un "puntatore". 
% =.. invece la crea e quindi ridivide X
% trace. per il debug
% "a" per uscire dal debug
% ["nomefile.pl"]. per caricare il file

is_regexp([]).
is_regexp(RE) :- atomic(RE).  
controllo_segno(['*', Y | []]).
controllo_segno(['+', Y | []]).
controllo_segno(['/', _ | _]).

is_regexp([X | Y]) :- compound(X),
                      divisina_comp([X | Y]),
                      is_regexp(Y).

is_regexp([X | Y]) :- atomic(X),
                      is_regexp(X),
                      is_regexp(Y).  

divisina_comp([X | Y]) :- X =.. ['[|]' | B],
                          is_regexp(X).

divisina_comp([X | Y]) :- X =.. [A | B],
                          B = [R | T],
                          controllo_segno([A, R | T]),
                          is_regexp(A),
                          is_regexp(B).


divisina(RE) :- RE =.. ['[|]' | Y],
               is_regexp(RE).

divisina(RE) :- RE =.. [X | Y],
                Y = [A | B],
                controllo_segno([X, A | B]),
                is_regexp([X | Y]).
                



nfa_regexp_comp(FA_ID, RE) :- divisina(RE).
                              %%nfa_crea_automa(ID, [X | Y]).

                              %%Se la testa è * + e il secondo elemento della coda è compound allora errore