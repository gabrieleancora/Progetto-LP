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
                            NIL )
                            (is-regexp (cdr RE)))
                    ((equal (list (car RE)) '(/)) 
                        (is-regexp (cdr RE)))
                    ((equal (list (car RE)) '(+)) 
                        (if (equal (list-length (cdr RE)) 1) 
                            NIL)
                            (is-regexp (cdr RE)))
                    (T (is-regexp (cdr RE)))
                )   
            )   
        )
    )
)



; TODO bestemmiare
(defun nfa-regexp-comp (RE)
    (if (is-regexp RE)
        (if (listp RE)
            (let ((PAPA (gensym "q")) (END (gensym "q"))) ; PAPA stato iniziale  END stato finale
                (list (crea-automa RE PAPA END))  ; la lista funge da wrapper per l'automa
            )
            (let ((PAPA (gensym "q")) (END (gensym "q"))) ; PAPA stato iniziale  END stato finale
                (list (crea-automa (list RE) PAPA END)))
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
                ; unione sottoliste
            )
            (cond 
                ((equal (list (car RE)) '(*))
                    (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
                        (list (list PAPA 'epsilon END) 
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
                        (list (list PAPA 'epsilon stato1)
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
                            (progn (print stato1)
                            (list (list stato1 'epsilon END)
                                (if (listp (car (cdr RE)))
                                    (crea-automa (car (cdr RE)) PAPA stato1)
                                    (list PAPA (car (cdr RE)) stato1)
                                )
                                ; se il cdr non è null allora crea stato2, automa cdr da stato1 a end, la epsilon mossa va da stato 1 a stato 2 
                            ))
                        )
                        (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
                            (list (list stato1 'epsilon stato2)
                                (if (listp (car (cdr RE)))
                                        (crea-automa PAPA (car (cdr RE)) stato1)
                                        (list PAPA (car (cdr RE)) stato1)
                                )
                                (crea-automa (list '[] (cdr (cdr RE))) stato2 END)
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




