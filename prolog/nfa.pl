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
crea_stati_segno(FA_ID, ['*'], _, _).
crea_stati_segno(FA_ID, ['+'], _, _).
crea_stati_segno(FA_ID, ['/'], _, _).
crea_stati_segno(FA_ID, [], _, _).

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

                

nfa_regexp_comp(FA_ID, RE) :- nonvar(FA_ID),
                              divisina(FA_ID, RE).

/* Creazione dell'Automa 
        FUNZIONA - NON TOCCARE 

*/

%StartID e EndID sono dell'OR locale 

divisina_automa(FA_ID, [X | Y], StartID, EndID) :- X =.. ['[|]' | A],
                                                    crea_stati_segno(FA_ID, X, StartID, EndID),
                                                    crea_stati_segno(FA_ID, Y, StartID, EndID).

divisina_automa(FA_ID, [X | Y], StartID, EndID) :- X =.. [A | B],
                                                    crea_stati_segno(FA_ID, [A | B], StartID, EndID).

%OR con primo elemento ATOMICO BOOOOM
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- Y = [A | B],
                                                      atomic(A),
                                                      print("or at"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, StatoUno)),
                                                      assert(delta(FA_ID, StatoUno, A, StatoDue)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).

%OR con primo elemento compound (com£) 
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- Y = [A | B],
                                                      compound(A),
                                                      print("or comp"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, StatoUno)),
                                                      divisina_automa(FA_ID, [A], StatoUno, StatoDue),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).
                                                                                                            
%STAR atomico BOOOOM
crea_stati_segno(FA_ID, ['*' | Y], StartID, EndID) :- Y = [A | B],
                                                      atomic(A),
                                                      print("star at"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
                                                      assert(delta(FA_ID, StatoUno, A, StatoDue)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, EndID)).

%STAR compound (com£)
crea_stati_segno(FA_ID, ['*' | Y], StartID, EndID) :- Y = [A | B],
                                                      compound(A),
                                                      print("star comp"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
                                                      assert(delta(FA_ID, StartID, epsilonMossa, EndID)),
                                                      Y = [J | K],
                                                      divisina_automa(FA_ID, [J | K], StatoUno, StatoDue).

%PLUS atomico BOOOOM
crea_stati_segno(FA_ID, ['+' | Y], StartID, EndID) :- Y = [A | B],
                                                      atomic(A),
                                                      print("plus at"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
                                                      assert(delta(FA_ID, StatoUno, A, StatoDue)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)).

%PLUS compound (com£)
crea_stati_segno(FA_ID, ['+' | Y], StartID, EndID) :- Y = [A | B],
                                                      compound(A),
                                                      print("plus comp"),
                                                      gensym(FA_ID, StatoUno),
                                                      gensym(FA_ID, StatoDue),
                                                      assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
                                                      assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
                                                      Y = [J | K],
                                                      divisina_automa(FA_ID, [J | K], StatoUno, StatoDue).

%SEQ 
crea_stati_segno(FA_ID, [X | []], StartID, EndID) :- atomic(X),
                                                     print("seq atom vuoto"),
                                                     gensym(FA_ID, StatoUno),
                                                     assert(delta(FA_ID, StartID, X, StatoUno)),
                                                     assert(delta(FA_ID, StatoUno, epsilonMossa, EndID)).

crea_stati_segno(FA_ID, [X | []], StartID, EndID) :- compound(X),
                                                      print("seq comp vuoto"),
                                                      gensym(FA_ID, StatoUno),
                                                      divisina_automa(FA_ID, [X], StartID, StatoUno),
                                                      assert(delta(FA_ID, StatoUno, epsilonMossa, EndID)).

crea_stati_segno(FA_ID, [X | Y], StartID, EndID) :- atomic(X),
                                                    print("seq at"),
                                                    gensym(FA_ID, StatoUno),
                                                    gensym(FA_ID, StatoDue),
                                                    assert(delta(FA_ID, StartID, X, StatoUno)),
                                                    assert(delta(FA_ID, StatoUno, epsilonMossa, StatoDue)),
                                                    crea_stati_segno(FA_ID, Y, StatoDue, EndID).

crea_stati_segno(FA_ID, [X | Y], StartID, EndID) :- compound(X),
                                                    print("seq comp"),
                                                    gensym(FA_ID, StatoUno),
                                                    gensym(FA_ID, StatoDue),
                                                    divisina_automa(FA_ID, [X], StartID, StatoUno),
                                                    assert(delta(FA_ID, StatoUno, epsilonMossa, StatoDue)),
                                                    crea_stati_segno(FA_ID, Y, StatoDue, EndID).


nfa_crea_automa(FA_ID, [X | Y]) :- gensym(FA_ID, StartID),
                                   gensym(FA_ID, EndID),
                                   crea_stati_segno(FA_ID, [X | Y], StartID, EndID).
    