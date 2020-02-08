/*
Funzioni da implementare obbligatoriamente
    is_regexp(RE) - wrapper
    nfa_regexp_comp(FA_Id, RE) - RE è regexp e FAid è il suo id generato
    nfa_rec(FA_Id, Input) - l'automa FAid mangia l'input ed è nello stato finale
    nfa_clear(FA_Id) - cancella l'automa

Tutte le altre funzioni sono a discrezione
*/

/*
Funtori
    atomic(a). => Mi dice se a è atomico (asd Vero - a-b falso)
    compound(asd). => Contrario di atomic

*/


/*
    Base di Dati
*/

is_regexp(epsilon).     % Insieme vuoto
equal(A, A).

isOp(X, '+').
isOp(X, '/').
isOp(X, '*').
isOp(X, '[').
isOp(X, ']').


/*
    Codice di controllo input
*/

is_regexp(RE) :- atomic(RE).  % Un elemento atomico è una regexp 

is_regexp(RE) :- RE = [X | Y],  % Una lista di elementi atomici è regexp
                 is_regexp(X),
                 is_regexp(Y).

is_regexp(RE) :- split_string("RE", "(", ")", X),  % Se togliendo le parentesi è una regexp, RE è regexp
                is_regexp(X).

%is_op(X) :- X è un cazzo di operatore


/*
    Creazione Branch NFA
*/

nfa_regexp_comp(FA_Id, Input) :- gensym(ciao, FA_Id),
                                is_regexp(Input).

    /* SEQ */
