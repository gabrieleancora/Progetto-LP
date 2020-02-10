;; SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA SCIVOLA 

;; (load "C:\\Users\\gabri\\Desktop\\Progetto\\Progetto LP\\lisp\\nfa.lisp")

(defun is-regexp (RE)
  (if (not (listp RE))
    T
    (if (null (car RE))
        T
      (if (listp (car RE)) 
          (progn (is-regexp (car RE))
          (is-regexp (cdr RE)))
        (cond 
          ((equal (list (car RE)) '([]))
            (is-regexp (cdr RE)))
          ((equal (list (car RE)) '(*)) 
            (if (equal (list-length (cdr RE)) 1) 
              (is-regexp (cdr RE))
              NIL))
          ((equal (list (car RE)) '(/)) 
            (is-regexp (cdr RE)))
          ((equal (list (car RE)) '(+)) 
            (if (equal (list-length (cdr RE)) 1) 
              (is-regexp (cdr RE))
              NIL))
          (T (is-regexp (cdr RE)))
        )   
      )   
    )
  )
)


(defun nfa-regexp-comp (RE)
  (if (is-regexp RE)
    (if (listp RE)
      (let ((PAPA (gensym "q")) (END (gensym "q"))) ; PAPA stato iniziale  END stato finale
        (append (list PAPA) (list END) (crea-automa RE PAPA END))  ; la lista funge da wrapper per l'automa
      )
      (let ((PAPA (gensym "q")) (END (gensym "q"))) ; PAPA stato iniziale  END stato finale
        (append (list PAPA) (list END) (crea-automa (list RE) PAPA END)))
    )
    NIL
  )
)

(defun crea-automa (RE PAPA END)
  (if (null (car RE))
    NIL
    (if (listp (car RE))
      (progn (crea-automa (car RE) PAPA END)
        (crea-automa (cdr RE) PAPA END)
      )
      (cond 
        ((equal (list (car RE)) '(*))
          (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
            (append (list PAPA 'epsilon END) 
            (list PAPA 'epsilon stato1)
            (list stato2 'epsilon END)
            (list stato2 'epsilon stato1)
            (if (listp (car (cdr RE)))
              (crea-automa (car (cdr RE)) stato1 stato2)
              (list stato1 (car (cdr RE)) stato2)
            ))
          )
        )
        ((equal (list (car RE)) '(+))
          (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
            (append (list PAPA 'epsilon stato1)
            (list stato2 'epsilon END)
            (list stato2 'epsilon stato1)
            (if (listp (car (cdr RE)))
              (crea-automa (car (cdr RE)) stato1 stato2)
              (list stato1 (car (cdr RE)) stato2)
            ))
          )
        )
        ((equal (list (car RE)) '([]))
          (if (null (car (cdr (cdr RE)))) ; se siamo in fondo
            (let ((stato1 (gensym "q")))
               (append ;append invece che lista?
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) PAPA stato1))
                  (list PAPA (car (cdr RE)) stato1)
                )
                (list stato1 'epsilon END)
               )
                ; se il cdr non è null allora crea stato2, automa cdr da stato1 a end, la epsilon mossa va da stato 1 a stato 2 
            )
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) PAPA stato1)) ;prima il car e PAPA erano invertiti
                  (list PAPA (car (cdr RE)) stato1)
                )
                (append (crea-automa (append '([]) (cdr (cdr RE))) stato2 END))
                (list stato1 'epsilon stato2)
              )
            )
          )
        )
        ((equal (list (car RE)) '(/) )
          (if (null (car (cdr (cdr RE))))
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append (list PAPA 'epsilon stato1)
                (list stato2 'epsilon END)
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) stato1 stato2))
                  (list stato1 (car (cdr RE)) stato2)
                )
              )
            )
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append (list PAPA 'epsilon stato1)
                (list stato2 'epsilon END)
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) stato1 stato2))
                  (list stato1 (car (cdr RE)) stato2)
                )
                (append (crea-automa (append '(/) (cdr (cdr RE))) PAPA END))
              )
            )
          )
        )
        (T 
          (list PAPA (car RE) END)
        )
      )
    )
  )
)

(defun nfa-rec (FA_ID Input)
    (if (listp FA_ID)
      (let ((StatoIn (car FA_ID)) (StatoFin (car (cdr FA_ID))))
        (elabora (cdr (cdr FA_ID)) Input StatoIn StatoFin (cddr FA_ID))
    )
    (print "Automa inesistente")
  )
)

(defun elabora (FA_ID Input StatoIn StatoFin SupportList)
  (print Input)
  (print FA_ID)
  (print StatoIn)
  (print StatoFin)
  (if (and (null SupportList) (null FA_ID))
    (if (equal StatoIn StatoFin) 
      T
      NIL
    )
    (if (and (null Input) (not (null SupportList)))
      (if (equal StatoIn StatoFin)
        T
        (elabora SupportList NIL StatoIn StatoFin NIL)
        ;(print "fallito") ; Oppure qualcosa che torna indietro
      )
      (if (null FA_ID)
        (elabora SupportList Input StatoIn StatoFin SupportList) ; oppure qualcosa che torna indietro
        (if (equal (car FA_ID) StatoIn)
          (cond
            ((equal (car Input) (car (cdr FA_ID)))
              (elabora (cdr (cdr (cdr FA_ID))) (cdr Input) (car (cdr (cdr FA_ID))) StatoFin SupportList)
              ;;(if ((elabora (cdr (cdr (cdr FA_ID))) (cdr Input) (car (cdr (cdr FA_ID))) StatoFin)) ; questa riga va rivista
                ; in caso fallisce ^ ramo bisogna ri-elaborare partendo da qualche passaggio prima
              ;;  T  
              ;;  (elabora (cdddr (cdddr FA_ID) (cdr Input) (cdddr FA_ID) StatoFin ))
              ) ;se fallisce deve passare al faid dopo a cazzum
            ((equal 'EPSILON (car (cdr FA_ID)))
              (elabora (cdr (cdr (cdr FA_ID))) Input (car (cdr (cdr FA_ID))) StatoFin SupportList)
            )
          )
          (elabora (cdr (cdr (cdr FA_ID))) Input StatoIn StatoFin SupportList)
        )
      )
    )
  )
)
  ;; (if (null FA_ID)
  ;;   (if (null Input)
  ;;     (if (equal StatoIn StatoFin)
  ;;           T
  ;;           (print "NON FINALE VUOTO")
  ;;     )
  ;;     (print "NO FAID SI INPUT")
  ;;   )
  ;;   (if (null Input)
  ;;     (if (equal StatoIn StatoFin)
  ;;           T
  ;;           (print "NO FAID NO INPUT NO FINALE" )
  ;;     )
  ;;     (if (equal (car FA_ID) StatoIn)
  ;;       (cond
  ;;         ((equal (car Input) (car (cdr FA_ID)))
  ;;           (elabora (cdr (cdr (cdr FA_ID))) (cdr Input) (car (cdr (cdr FA_ID))) StatoFin)) ;cadddr
  ;;         ((equal 'EPSILON (car (cdr FA_ID)))
  ;;           (elabora (cdr (cdr (cdr FA_ID))) Input (car (cdr (cdr FA_ID))) StatoFin )
  ;;         )
  ;;       )
  ;;       (elabora (cdr (cdr (cdr FA_ID))) Input StatoIn StatoFin )
  ;;     )
  ;;   )
  ;; )


;;(#:|q3166| #:|q3167| 

;; #:|q3166| A #:|q3168| #:|q3169| B #:|q3170| #:|q3170| EPSILON #:|q3167| #:|q3168| EPSILON #:|q3169|)