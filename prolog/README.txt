MATRICOLA NOME COGNOME

Il programma nfa.pl serve per gestire automi creati da delle Regular Expression(RE). 
Questo avviene usando quattro funzioni.

    is_regexp(RE) => E' la funzione di controllo input. Restituisce vero solo se l'input RE è un Regular Expression valida.
                     Questo controllo avviene chiamando is_regexp ricorsivamente, differenziando solo se la lista in input è atomica o meno.
                     Questa funzione accetta un qualsiasi numero di simboli; mentre gli unici operandi accettati sono:
                            Operatore di sequenza (SEQ) => []
                            Operatore di unione (OR) => /
                            Chiusura di Kleene (STAR) => *
                            Operatore Plus (PLUS) => +
    
    
