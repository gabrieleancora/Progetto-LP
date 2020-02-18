;; Di Nuovo Gabriele - 844963
;; Piccoli Matteo - 845012

;; (load "C:\\Users\\gabri\\Desktop\\Progetto\\Progetto LP\\lisp\\nfa.lisp") 

;;-------------- IS-REGEXP --------------
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
          (T (is-regexp (cdr RE))))))))

;;-------------- NFA-REGEXP-COMP -------------- 
(defun nfa-regexp-comp (RE)
  (if (is-regexp RE)
    (if (listp RE)
      (let ((PAPA (gensym "q")) (END (gensym "q")))
        (append (list PAPA) (list END) (crea-automa RE PAPA END)))
      (let ((PAPA (gensym "q")) (END (gensym "q")))
        (append (list PAPA) (list END) (crea-automa (list RE) PAPA END))))
    NIL))

;;-------------- CREA-AUTOMA --------------
(defun crea-automa (RE PAPA END)
  (if (null (car RE))
    NIL
    (if (listp (car RE))
      (progn (crea-automa (car RE) PAPA END)
        (crea-automa (cdr RE) PAPA END))
      (cond 
        ((equal (list (car RE)) '(*))
          (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
            (append (list PAPA 'epsilon END) 
            (list PAPA 'epsilon stato1)
            (list stato2 'epsilon END)
            (list stato2 'epsilon stato1)
            (if (listp (car (cdr RE)))
              (crea-automa (car (cdr RE)) stato1 stato2)
              (list stato1 (car (cdr RE)) stato2)))))
        ((equal (list (car RE)) '(+))
          (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
            (append (list PAPA 'epsilon stato1)
            (list stato2 'epsilon END)
            (list stato2 'epsilon stato1)
            (if (listp (car (cdr RE)))
              (crea-automa (car (cdr RE)) stato1 stato2)
              (list stato1 (car (cdr RE)) stato2)))))
        ((equal (list (car RE)) '([]))
          (if (null (car (cdr (cdr RE))))
            (let ((stato1 (gensym "q")))
               (append 
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) PAPA stato1))
                  (list PAPA (car (cdr RE)) stato1))
                (list stato1 'epsilon END)))
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) PAPA stato1))
                  (list PAPA (car (cdr RE)) stato1))
                (append (crea-automa (append '([]) 
                                      (cdr (cdr RE))) stato2 END))
                (list stato1 'epsilon stato2)))))
        ((equal (list (car RE)) '(/) )
          (if (null (car (cdr (cdr RE))))
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append (list PAPA 'epsilon stato1)
                (list stato2 'epsilon END)
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) stato1 stato2))
                  (list stato1 (car (cdr RE)) stato2))))
            (let ((stato1 (gensym "q")) (stato2 (gensym "q")))
              (append (list PAPA 'epsilon stato1)
                (list stato2 'epsilon END)
                (if (listp (car (cdr RE)))
                  (append (crea-automa (car (cdr RE)) stato1 stato2))
                  (list stato1 (car (cdr RE)) stato2))
                (append (crea-automa (append '(/)
                                        (cdr (cdr RE))) PAPA END))))))
        (T 
          (list PAPA (car RE) END))))))

;;-------------- NFA-REC -------------- 
(defun nfa-rec (FA_ID Input)
    (if (listp FA_ID)
      (progn
        (setq VarLoc (car FA_ID))
        (let ((StatoIn (car FA_ID)) (StatoFin (car (cdr FA_ID))))
          (elabora (cdr (cdr FA_ID)) Input StatoIn StatoFin 
            (cddr FA_ID) (cddr FA_ID))))
    (print "Automa inesistente")))

;;-------------- ELABORA -------------- 
(defun elabora (FA_ID Input StatoIn StatoFin SupportList Contatore)
  (if (equal StatoIn StatoFin)
    (if (null Input)
      T
      (if (null Contatore)
        NIL
        (if (null FA_ID)
          (if (null SupportList)
            (elabora SupportList Input VarLoc StatoFin 
                      SupportList (cdddr Contatore))
            (elabora SupportList Input VarLoc StatoFin 
                      (cdddr SupportList) Contatore))
          (if (equal (car FA_ID) StatoIn)
            (cond
              ((equal (car Input) (car (cdr FA_ID)))
                (elabora (cdr (cdr (cdr FA_ID))) (cdr Input)
                    (car (cdr (cdr FA_ID))) StatoFin SupportList Contatore))
              ((equal 'EPSILON (car (cdr FA_ID)))
                (elabora (cdr (cdr (cdr FA_ID))) Input
                    (car (cdr (cdr FA_ID))) StatoFin SupportList Contatore)))
            (elabora (cdr (cdr (cdr FA_ID))) Input StatoIn StatoFin 
                                                  SupportList Contatore)))))
    (if (null Contatore)
      NIL
      (if (null FA_ID)
        (elabora SupportList Input StatoIn StatoFin 
            SupportList (cdddr Contatore))
        (if (equal (car FA_ID) StatoIn)
          (cond
            ((equal (car Input) (car (cdr FA_ID)))
              (elabora (cdr (cdr (cdr FA_ID))) (cdr Input) 
              (car (cdr (cdr FA_ID))) StatoFin SupportList Contatore))
            ((equal 'EPSILON (car (cdr FA_ID)))
              (elabora (cdr (cdr (cdr FA_ID))) Input
                   (car (cdr (cdr FA_ID))) StatoFin SupportList Contatore)))
          (elabora (cdr (cdr (cdr FA_ID))) Input StatoIn StatoFin
                    SupportList Contatore))))))