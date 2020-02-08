%%%%% RAPIDA GUIDA DI PORROLOG %%%%%
% = non crea una sottolista ma fa solo un "puntatore". 
% =.. invece la crea e quindi ridivide X
% trace. per il debug
% "a" per uscire dal debug
% ["nomefile.pl"]. per caricare il file


/* Controllo input */

% Casi base 
is_regexp([]).
is_regexp(RE) :- atomic(RE).  
controllo_segno(['*', Y | []]).
controllo_segno(['+', Y | []]).
controllo_segno(['/', _ | _]).
crea_stati_segno(FA_ID, [A, []], _, _).

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


divisina(FA_ID, RE) :- RE =.. ['[|]' | Y],
               is_regexp(RE),
               nfa_crea_automa(FA_ID, RE).

divisina(FA_ID, RE) :- RE =.. [X | Y],
                Y = [A | B],
                controllo_segno([X, A | B]),
                is_regexp([X | Y]),
                nfa_crea_automa(FA_ID, [X | Y]).

                

nfa_regexp_comp(FA_ID, RE) :- divisina(FA_ID, RE).

                              %%Se la testa è * + e il secondo elemento della coda è compound allora errore


/* Creazione dell'Automa */

%StartID e EndID sono dell'OR locale

%OR con primo elemento ATOMICO BOOOOM
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- Y = [A | B],
                                                      atomic(A),
                                                      gensym(FA_ID, EpsilonMossaUno),
                                                      gensym(FA_ID, StatoA),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, EpsilonMossaUno)),
                                                      assert(delta(FA_ID, EpsilonMossaUno, A, StatoA)),
                                                      assert(delta(FA_ID, StatoA, epsilonMossa, EndID)),
                                                      crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).

%OR con primo elemento compound (com£)
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- Y = [A | B],
                                                      compound(A),
                                                      gensym(FA_ID, EpsilonMossaUno),
                                                      gensym(FA_ID, StatoA),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, EpsilonMossaUno)),
                                                      crea_stati_segno(FA_ID, A, EpsilonMossaUno, StatoA),
                                                      assert(delta(FA_ID, StatoA, epsilonMossa, EndID)),
                                                      crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).
                                                                                                            
%STAR atomico BOOOOM
crea_stati_segno(FA_ID, [A | Y], StartID, EndID) :- Y = [C | D],
                                                    atomic(C).

nfa_crea_automa(FA_ID, [X | Y]) :- gensym(FA_ID, StartID),
                                   gensym(FA_ID, EndID),
                                   crea_stati_segno(FA_ID, [X | Y], StartID, EndID).
                                   
