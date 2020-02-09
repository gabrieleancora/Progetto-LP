%%% 844963 - Di Nuovo Gabriele
%%% 845012 - Piccoli Matteo

% -------------------- Casi base 
is_regexp([]).
is_regexp(RE) :- atomic(RE). 
controllo_segno(['*', Y | []]).
controllo_segno(['+', Y | []]).
controllo_segno(['/', _ | _]).
crea_stati_segno(FA_ID, ['*'], _, _).
crea_stati_segno(FA_ID, ['+'], _, _).
crea_stati_segno(FA_ID, ['/'], _, _).
crea_stati_segno(FA_ID, [], _, _).

% -------------------- Controllo REGEXP  

is_regexp([X | Y]) :- 
        compound(X),
        divisina_comp([X | Y]),
        is_regexp(Y).

is_regexp([X | Y]) :- 
        atomic(X),
        is_regexp(X),
        is_regexp(Y).  

% -------------------- Divisione lista
divisina_comp([X | Y]) :- 
        X =.. ['[|]' | B],
        is_regexp(X).

divisina_comp([X | Y]) :- 
        X =.. [A | B],
        B = [R | T],
        controllo_segno([A, R | T]),
        is_regexp(A),
        is_regexp(B).

divisina(FA_ID, RE) :- 
        RE =.. ['[|]' | Y],
        is_regexp(RE),
        nfa_crea_automa(FA_ID, RE).

divisina(FA_ID, RE) :- 
        RE =.. [X | Y],
        Y = [A | B],
        controllo_segno([X, A | B]),
        is_regexp([X | Y]),
        nfa_crea_automa(FA_ID, [X | Y]).

divisina(FA_ID, RE) :-
        RE =.. [X],
        is_regexp([X]),
        nfa_crea_automa(FA_ID, [X]).

% -------------------- Funzione di inizio                

nfa_regexp_comp(FA_ID, RE) :- 
        nonvar(FA_ID),
        divisina(FA_ID, RE).

% -------------------- Creazione dell'Automa

divisina_automa(FA_ID, [X | Y], StartID, EndID) :- 
        X =.. ['[|]' | A],
        crea_stati_segno(FA_ID, X, StartID, EndID),
        crea_stati_segno(FA_ID, Y, StartID, EndID).

divisina_automa(FA_ID, [X | Y], StartID, EndID) :-
        X =.. [A | B],
        crea_stati_segno(FA_ID, [A | B], StartID, EndID).

% -------------------- OR Atomico 
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- 
        Y = [A | B],
        atomic(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa, StatoUno)),
        assert(delta(FA_ID, StatoUno, A, StatoDue)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).

% -------------------- OR Compound 
crea_stati_segno(FA_ID, ['/' | Y], StartID, EndID) :- 
        Y = [A | B],
        compound(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa, StatoUno)),
        divisina_automa(FA_ID, [A], StatoUno, StatoDue),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        crea_stati_segno(FA_ID, ['/' | B], StartID, EndID).
                                                            
% -------------------- STAR Atomico 
crea_stati_segno(FA_ID, ['*' | Y], StartID, EndID) :- 
        Y = [A | B],
        atomic(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
        assert(delta(FA_ID, StatoUno, A, StatoDue)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
        assert(delta(FA_ID, StartID, epsilonMossa, EndID)).

% -------------------- STAR Compound
crea_stati_segno(FA_ID, ['*' | Y], StartID, EndID) :- 
        Y = [A | B],
        compound(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
        assert(delta(FA_ID, StartID, epsilonMossa, EndID)),
        Y = [J | K],
        divisina_automa(FA_ID, [J | K], StatoUno, StatoDue).

% -------------------- PLUS Atomico
crea_stati_segno(FA_ID, ['+' | Y], StartID, EndID) :- 
        Y = [A | B],
        atomic(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
        assert(delta(FA_ID, StatoUno, A, StatoDue)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)).

% -------------------- PLUS Compound 
crea_stati_segno(FA_ID, ['+' | Y], StartID, EndID) :- 
        Y = [A | B],
        compound(A),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, epsilonMossa , StatoUno)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, EndID)),
        assert(delta(FA_ID, StatoDue, epsilonMossa, StatoUno)),
        Y = [J | K],
        divisina_automa(FA_ID, [J | K], StatoUno, StatoDue).

% -------------------- SEQ Vuoto  
crea_stati_segno(FA_ID, [X | []], StartID, EndID) :- 
        atomic(X),
        gensym(FA_ID, StatoUno),
        assert(delta(FA_ID, StartID, X, StatoUno)),
        assert(delta(FA_ID, StatoUno, epsilonMossa, EndID)).

crea_stati_segno(FA_ID, [X | []], StartID, EndID) :-  
        compound(X),
        gensym(FA_ID, StatoUno),
        divisina_automa(FA_ID, [X], StartID, StatoUno),
        assert(delta(FA_ID, StatoUno, epsilonMossa, EndID)).

% -------------------- SEQ non Vuoto 
crea_stati_segno(FA_ID, [X | Y], StartID, EndID) :- 
        atomic(X),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        assert(delta(FA_ID, StartID, X, StatoUno)),
        assert(delta(FA_ID, StatoUno, epsilonMossa, StatoDue)),
        crea_stati_segno(FA_ID, Y, StatoDue, EndID).

crea_stati_segno(FA_ID, [X | Y], StartID, EndID) :- 
        compound(X),
        gensym(FA_ID, StatoUno),
        gensym(FA_ID, StatoDue),
        divisina_automa(FA_ID, [X], StartID, StatoUno),
        assert(delta(FA_ID, StatoUno, epsilonMossa, StatoDue)),
        crea_stati_segno(FA_ID, Y, StatoDue, EndID).


% -------------------- Inizio Creazione Automa 
nfa_crea_automa(FA_ID, [X | Y]) :- 
        gensym(FA_ID, StartID),
        gensym(FA_ID, EndID),
        assert(startAutoma(FA_ID, StartID)),
        assert(endAutoma(FA_ID, EndID)),
        crea_stati_segno(FA_ID, [X | Y], StartID, EndID).


% -------------------- Controllo Input  
nfa_controllo(FA_ID, StartID, [A | B]) :- 
        atomic(A),
        delta(FA_ID, StartID, A, StatoFinale),
        nfa_controllo(FA_ID, StatoFinale, B).

nfa_controllo(FA_ID, StartID, [A | B]) :- 
        atomic(A),
        delta(FA_ID, StartID, epsilonMossa, StatoFinale),
        nfa_controllo(FA_ID, StatoFinale, [A | B]).

%Se la lista è vuota quando il controllo arriva al nodo finale 
% allora l'input è stato "mangiato" correttamente dall'automa
nfa_controllo(FA_ID, StartID, []) :- 
        endAutoma(FA_ID, StartID).

nfa_controllo(FA_ID, StartID, []) :- 
        delta(FA_ID, StartID, epsilonMossa, StatoFinale),
        nfa_controllo(FA_ID, StatoFinale, []).


% -------------------- NFA REC
nfa_rec(FA_ID, INPUT) :- 
        nonvar(FA_ID),
        is_list(INPUT),
        startAutoma(FA_ID, StartID),
        nfa_controllo(FA_ID, StartID, INPUT).
                         

% -------------------- NFA CLEAR  
nfa_clear() :- 
        retractall(delta(_,_,_,_)),
        reset_gensym().

nfa_clear(FA_ID) :- 
        retractall(delta(FA_ID,_,_,_)),
        reset_gensym(FA_ID).