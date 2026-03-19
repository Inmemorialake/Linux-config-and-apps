(
 (plt:framework-pref:framework:exit-when-no-frames #t)
 (plt:framework-pref:framework:standard-style-list:font-size #2(#hash((((1920 1080)) . 12)) 12))
 (plt:framework-pref:framework:color-scheme classic)
 (|plt:DrRacket 9.0-splash-max-width| 1000)
 (plt:framework-pref:plt:debug-tool:stack/variable-area 9/10)
 (plt:framework-pref:drracket:window-position #hash((#f . (0 0 0)) (((0 0 1920 1080)) . (0 0 0))))
 (plt:framework-pref:drracket:window-size #hash((#f . (#t 600 650)) (((0 0 1920 1080)) . (#t 600 650))))
 (plt:framework-pref:drracket:recent-language-names (("Determine language from source" #6(#t print mixed-fraction-e #f #t debug) (default) #0() #f #t #t ((test) (main)) #t)))
 (plt:framework-pref:drracket:language-settings ((-32768) (#6(#t print mixed-fraction-e #f #t debug) (default) #0() #f #t #t ((test) (main)) #t)))
 (plt:framework-pref:drracket:unit-window-size-percentage 1/2)
 (plt:framework-pref:framework:recently-opened-files/pos ((#"/home/Inmemorialake/Downloads/Codigo de Prueba/Racket" 0 0)))
 (plt:framework-pref:drracket:most-recent-lang-line "#lang eopl\n")
 (plt:framework-pref:framework:verify-exit #t)
 (plt:framework-pref:framework:last-opened-files ())
 (plt:framework-pref:drracket:recently-closed-tabs ((#"/home/Inmemorialake/Downloads/Codigo de Prueba/Racket" 12 12)))
 (plt:framework-pref:drracket:console-previous-exprs (("+ 5 2") ("(+ 5 2)")))
 (readline-input-history
  (
   #"(EVALUARSAT '(FNC 4 ((1 or -2 or 3 or 4) and (-2 or 3) and (-1 or -2 or -3) and (3 or 4) and (2))))"
   #"(EVALUARSAT '(FNC 4 ((1 -2 3 4) (-2 3) (-1 -2 -3) (3 4) (2))))"
   #"; resultado asumido que pasaron las variables ordenadas\n(define EVALUARSAT (lambda (my-fnc)(\n  let*(\n    [parsed-fnc (PARSEBNF my-fnc)]\n    [lst-clausulas (fnc->clausulas parsed-fnc)]\n    [unique-vars (get-unique-vars lst-clausulas)]\n    [posibilities (n-posibilities (length unique-vars))]\n    [cartesian (multiproduct-cartesian posibilities)]\n    [mapped-values (make-map unique-vars cartesian)]\n  )\n  (EVALUARSAT-helper lst-clausulas mapped-values)\n)))"
   #"(define EVALUARSAT-helper (lambda (lst-clausulas mapped-values)(\n  cond\n  [(null? mapped-values) '(insatisfactible ())]\n  [(evaluate-clausulas lst-clausulas (car mapped-values)) (list 'satisfactible (my-map (lambda(x)(cadr x)) (car mapped-values)))]\n  [else (EVALUARSAT-helper lst-clausulas (cdr mapped-values))]\n)))"
   #"(define evaluate-clausulas (lambda (list-clausula mapped-values)(\n  cond  [(null? list-clausula) #t]\n  [else (and (evaluate-clausula (car list-clausula) mapped-values) (evaluate-clausulas (cdr list-clausula) mapped-values))]\n)))"
   #"(define evaluate-clausula (lambda (cls mapped-values)(\n  if(null? cls) #f (\n      let* (\n        [var (car cls)]\n        [actual-value (get-value var mapped-values)]\n      )\n      (cond\n      [(equal? actual-value #t) #t]\n      [else (evaluate-clausula (cdr cls) mapped-values)]\n  )\n)\n)))"
   #"; value = #f || #\340\270\245\340\270\207\n; ((key value))\n; (())\n(define get-value (lambda (get-key mapped-values)\n    (\n    if(null? mapped-values) empty ( \n    let*(\n    [actual-pair (car mapped-values)] ; (key value)\n    [key (car actual-pair)]\n    [actual-value (cadr actual-pair)]\n    )\n  (cond\n  [(equal? key get-key) actual-value]\n  [(equal? key (* get-key -1) ) (not actual-value)]\n  [else (get-value get-key (cdr mapped-values))]\n  )\n)\n)))"
   #"(define make-map (lambda (unique-values product-cartesian)(\n  my-map (make-map-lambda unique-values) product-cartesian\n)))"
   #"(define my-map (lambda (func lst)(\n  cond\n  [(null? lst) empty]\n  [else (cons (func (car lst)) (my-map func (cdr lst)))]\n)))"
   #"(define make-map-lambda (lambda (unique-values)(\n  lambda(product-cartesian)(\n        zip unique-values product-cartesian\n  )\n)))"
   #"(define make-map-helper(lambda (unique-values cartesian [res empty])(\n  cond\n  [(null? cartesian) empty]\n  [else (make-map-helper unique-values cartesian)]\n)))"
   #"; map\n; values = \n\n; list a, list list n\n; ((key1a value1n) (key2a value2n))\n;\n; same length\n(define zip (lambda (l1 l2)(\n  cond\n  [(null? l1) empty]\n  [else (cons (list (car l1) (car l2)) (zip (cdr l1) (cdr l2)))]\n)))"
   #"(define multiproduct-cartesian (lambda (lst [res empty])(\n  cond\n  [(null? lst) (map flat res)]\n  [(null? res) (multiproduct-cartesian (cddr lst) (product-cartesian (car lst) (cadr lst)))]\n  [else (multiproduct-cartesian (cdr lst) (product-cartesian  res (car lst)))]\n)))"
   #"(define flat (lambda (lst)(\n  cond\n  [(null? lst) empty]\n  [(not (list? lst)) (list lst)]\n  [else (append (flat (car lst)) (flat (cdr lst)))]\n)))"
   #"(define product-cartesian (lambda (l1 l2)(\n  cond\n  [(null? l1) empty]\n  [else (append (product-cartesian-helper (car l1) l2) (product-cartesian (cdr l1) l2))]\n)))"
   #"(define product-cartesian-helper (lambda (x lst)(\n  cond\n  [(null? lst) empty]\n  [(list? (car lst)) (cons (append (list x) lst) (product-cartesian-helper x (cdr lst)))]\n  [else (cons (list x (car lst)) (product-cartesian-helper x (cdr lst)))]\n)))"
   #"(define n-posibilities(lambda (n [lst '()])(\n  cond\n  [(<= n 0) lst]\n  [else (n-posibilities (- n 1)  (cons '(#t #f) lst))]\n)))"
   #"(define get-unique-vars (lambda (list-clausulas [lst empty])(\n  cond\n  [(null? list-clausulas) (get-unique-vars-helper lst)]\n  [else (get-unique-vars (cdr list-clausulas) (append lst (get-unique-vars-helper (car list-clausulas))))]\n)))"
   #"(define get-unique-vars-helper (lambda (cls [lst empty])(\n  cond\n  [(null? cls) lst]\n  [else (get-unique-vars-helper (cdr cls) (if (find-if-exist (convert-positive (car cls)) lst) lst (append lst (list (convert-positive (car cls))))))]\n)))"
   #"(define convert-positive (lambda (x)(\n  if (> x 0) x (* x -1)\n)))"
   #"(define find-if-exist (lambda (x cls)(\n  cond\n  [(null? cls) #f]\n  [(or (equal? x (car cls)) (equal? (* x -1) (car cls))) #t]\n  [else (find-if-exist x (cdr cls))]\n)))"
   #"(define count-vars (lambda (cls [ct 0])(\n  cond\n  [(null? cls) ct]\n  [else (count-vars (cdr cls) (+ ct (helper-count-vars (car cls) (cdr cls))))]\n)))"
   #";;EVALUARSAT\n\n(define helper-count-vars (lambda (x cls)(\n  cond\n  [(null? cls) 1]\n  [(equal? x (car cls)) 0]\n  [else (helper-count-vars x (cdr cls))]\n)))"
   #"(x 3)"
   #"(let (x 3))"
   #"(exit)"
   #"q"
   #"(funcion 2 3)"
   #"(define funcion\n  (lambda (a b)\n    (begin\n        (set! a (* a b))\n        (set! b (- a b))\n        (+ a b)\n    )\n  )\n)"
   #"(exit)"
   #"(balanced-parentheses? '(|(| |)| |)|))"
   #";; Pruebas\n(balanced-parentheses? '(|(| |(| |)| |(| |)| |)|))"
   #"(define balanced-parentheses?\n  (lambda (L)\n    (balanced-iter L 0)))"
   #"(define balanced-iter\n  (lambda (L contador)\n    (cond\n      [(< contador 0) #f]\n      [(null? L) (= contador 0)]\n      [(eqv? (car L) '|(|)\n       (balanced-iter (cdr L) (+ contador 1))]\n      [(eqv? (car L) '|)|)\n       (balanced-iter (cdr L) (- contador 1))]\n      [else (balanced-iter (cdr L) contador)])))"
   #"(inversions '(1 2 3 4))"
   #";; Pruebas\n(inversions '(2 3 8 6 1))"
   #"(define inversions\n  (lambda (L)\n    (if (null? L)\n        0\n        (+ (contar-menores (car L) (cdr L))\n           (inversions (cdr L))))))"
   #"(define contar-menores\n  (lambda (x L)\n    (if (null? L)\n        0\n        (if (> x (car L))\n            (+ 1 (contar-menores x (cdr L)))\n            (contar-menores x (cdr L))))))"
   #"(exit)"
   #"(mapping (lambda (d) (* d 4)) '(1 4 5) '(20 2 10))"
   #"(mapping (lambda (d) (* d 3)) '(1 2 2) '(2 4 6))"
   #";; Pruebas\n(mapping (lambda (d) (* d 2)) '(1 2 3) '(2 4 6))"
   #";; mapping : F L1 L2 -> L\n;; Prop\303\263sito: Recibe una funci\303\263n unaria F y dos listas de n\303\272meros\n;; L1 y L2 de igual tama\303\261o. Retorna los pares (a b) donde a \342\210\210 L1,\n;; b \342\210\210 L2 y se cumple F(a) = b.\n;;\n;; <lista-num> := ()\n;;             | (<n\303\272mero> <lista-num>)\n;;\n(define mapping\n  (lambda (F L1 L2)\n    (if (null? L1)\n        '()\n        (if (= (F (car L1)) (car L2))\n            (cons (list (car L1) (car L2))\n                  (mapping F (cdr L1) (cdr L2)))\n            (mapping F (cdr L1) (cdr L2))))))"
   #"(exit)"
   #"exit"
   #"(mi-append '(1 2 3 4) '(5 6 7 2))"
   #"(define mi-append\n  (lambda (L1 L2)\n    (if (null? L1)\n        L2\n        (cons (car L1)\n              (mi-append (cdr L1) L2)))))"
   #"(factorial 2000)"
   #"(factorial 400)"
   #"(factorial 4)"
   #"(factorial 5)"
   #"(factorial 3)"
   #"(define factorial\n  (lambda (n)\n    (if (= n 0)\n        1\n        (* n (factorial (- n 1))))))"
   #"(exit)"
   #"(multiplique 3 4             )"
   #"(exit\n )"
   #"(multiplique 3 4)"
   #"(exit)"
   #"exit"
   #":q"
   #"quit"
   #"q"
   #"(multiplique A 6)"
   #"(define multiplique (lambda (a b) (* a (* b b))))"
   #"A"
   #"(define A 2)"
   #"ls"
  ))
)
