844963 - Di Nuovo Gabriele
845012 - Piccoli Matteo

Il programma nfa.lisp serve per gestire automi creati da
Regular Expression(RE).
Questo avviene usando quattro funzioni.

(is_regexp RE)
	Controllo dell'input. Restituisce vero solo se l'input RE è un  
	Regular Expression valida.
	Questo controllo avviene chiamando (is_regexp RE) ricorsivamente.
	Questa funzione accetta un qualsiasi numero di simboli, mentre  
	accetta solo gli operandi di:
		Operatore di sequenza (SEQ) => []
		Operatore di unione (OR) => /
		Chiusura di Kleene (STAR) => *
		Operatore Plus (PLUS) => +
	Inoltre controlla che ogni operatore abbia il giusto numero di parametri.
	
	esempio:
		(is_regexp '([] a (+b) c)

(nfa_regexp_comp FA_ID RE)
	Dato l'input RE crea il suo automa corrispondente FA_ID.
	Ogni nodo dell'automa è generato automaticamente, e gli archi avranno 
	un tag nullo (epsilon) o il tag relativo all'espressione,
	in base alla costruzione necessaria dell'operatore.

	nfa_regexp_comp utilizza una funzione di supporto chiamata crea_automa,
	che in base all'operatore da utilizzare creerà ricorsivamente il
	pezzo di automa relativo all'operatore stesso.   

	esempio:
		(nfa_regexp_comp automa1 '(/ a b ([] c (*d)))
	
(nfa_rec FA_ID INPUT) ;	
	Controlla che INPUT venga consumato completamente dall'automa 
	contenuto da FA_ID, e che l'automa termini nel suo stato finale.

	nfa_rec FA_ID INPUT è un wrapper per la funzione elabora. 
	La funzione elabora, usando un automa di supporto, verificherà  
	che l'input INPUT sia accettato da FA_ID e che l'automa sia nello
	stato finale.
	
	esempio:
		(nfa_rec automa1 (c d d d)
	


		