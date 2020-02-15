Di Nuovo Gabriele - 844963
Piccoli Matteo - 845012
Riva Riccardo - 844936

Il programma nfa.pl serve per gestire automi creati da Regular Expression(RE).
Questo avviene usando quattro funzioni.

is_regexp/1
    is_regexp(RE) => Controllo dell'input. Restituisce vero solo se 
	        l'input RE è un Regular Expression valida.
            Questo controllo avviene chiamando is_regexp/1 ricorsivamente,
			differenziando solo se la lista in input è atomica o meno.
            Questa funzione accetta un qualsiasi numero di simboli, 
			mentre accetta solo gli operandi di :
                Operatore di sequenza (SEQ) => []
                Operatore di unione (OR) => /
                Chiusura di Kleene (STAR) => *
                Operatore Plus (PLUS) => +
            Inoltre controlla che ogni operatore abbia il giusto    
			numero di parametri.

        esempio:
            is_regexp([a, b, c]).


nfa_regexp_comp/2
    nfa_regexp_comp(FA_ID, RE) => Dall'input RE crea il suo automa  
	        corrispondente, e lo denomina FA_ID.
            Ogni nodo dell'automa è generato automaticamente, e gli 
			archi avranno un tag nullo (epsilon) o il tag relativo  
			all'espressione,
            in base alla costruzione necessaria dell'operatore.
        
            nfa_regexp_comp utilizza una funzione di supporto chiamata 
			crea_stati_segno,
            che in base all'operatore da utilizzare creerà ricorsivamente
			il pezzo di automa relativo all'operatore stesso.         

        esempio: 
            nfa_regexp_comp(nfa_uno, [a, b, c]).

nfa_rec/2
    nfa_rec(FA_ID, INPUT) => Controlla che INPUT venga consumato    
	        completamente dall'automa identificato da FA_ID, e che l'automa 
            termini nel suo stato finale.
            nfa_rec stabilisce il punto dell'automa in cui inizierà il  
            controllo di INPUT.

            Una volta stabilito il punto di inizio, nfa_rec si appoggia 
            alla funzione nfa_controllo/4. Questa seconda funzione percorre
            ricorsivamente l'automa FA_ID, e consuma una parte di INPUT 
            quando necessario.
            Quando nfa_controllo consuma tutto l'input controlla se si  
            trova nello stato finale, o se esso è raggiungibile attraverso 
            delle epsilon mosse.
            Se è nello stato finale, INPUT è accettato dall'automa, e la
            funzione restituirà true.

        esempio:
            nfa_rec(nfa_uno, [a]).

nfa_clear/0
    nfa_clear() => Cancella dalla base di dati tutti gli 
                   automi creati fino ad ora.
        
        esempio:
            nfa_clear().

nfa_clear/1
    nfa_clear(FA_ID) => Cancella dalla base di dati l'automa identificato
                        da FA_ID.

        esempio: 
            nfa_clear(nfa_uno).