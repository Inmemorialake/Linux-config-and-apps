(
 (plt:framework-pref:framework:color-scheme classic)
 (|plt:DrRacket 9.0-splash-max-width| 1000)
 (plt:framework-pref:drracket:language-settings ((-32768) (#6(#t print mixed-fraction-e #f #t debug) (default) #0() #f #t #t ((test) (main)) #t)))
 (|plt:DrRacket 9.2-splash-max-width| 987)
 (readline-input-history
  (
   #"(interprete \"@a\")"
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
 (plt:framework-pref:framework:spell-check-strings? #f)
 (plt:framework-pref:framework:white-on-black? #f)
 (plt:framework-pref:framework:exit-when-no-frames #t)
 (plt:framework-pref:framework:standard-style-list:font-size #2(#hash((((1920 1080)) . 12)) 12))
 (plt:framework-pref:framework:color-scheme-light classic)
 (plt:framework-pref:framework:delegatee-overview-color (173 216 230 1.0))
 (plt:framework-pref:drracket:recent-language-names (("Determine language from source" #6(#t print mixed-fraction-e #f #t debug) (default) #0() #f #t #t ((test) (main)) #t)))
 (plt:framework-pref:plt:debug-tool:stack/variable-area 9/10)
 (plt:framework-pref:drracket:unit-window-size-percentage 637/954)
 (plt:framework-pref:drracket:window-size #hash((#f . (#t 600 650)) (((0 0 1920 1080)) . (#t 600 650))))
 (plt:framework-pref:drracket:window-position #hash((#f . (0 0 0)) (((0 0 1920 1080)) . (0 0 0))))
 (plt:framework-pref:framework:recently-opened-files/pos
  (
   (#"/home/Inmemorialake/Downloads/Sustentaci\303\263n 2.rkt" 0 0)
   (#"/home/Inmemorialake/Downloads/Proyecto-Mathflow/mathflow.rkt" 0 0)
   (#"/home/Inmemorialake/Downloads/Proyecto-Mathflow/pruebas-for.rkt" 0 0)
   (#"/home/Inmemorialake/Documents/Taller3-FLP-/interpretador.rkt" 0 0)
   (#"/home/Inmemorialake/Downloads/Codigo de Prueba/Racket" 0 0)
  ))
 (plt:framework-pref:drracket:most-recent-lang-line "#lang eopl\n")
 (plt:framework-pref:framework:verify-exit #t)
 (plt:framework-pref:framework:last-opened-files ())
 (plt:framework-pref:drracket:recently-closed-tabs
  (
   (#"/home/Inmemorialake/Downloads/Proyecto-Mathflow/mathflow.rkt" 0 0)
   (#"/home/Inmemorialake/Downloads/Sustentaci\303\263n 2.rkt" 36 36)
   (#"/home/Inmemorialake/Downloads/Proyecto-Mathflow/pruebas-for.rkt" 2372 2468)
   (#"/home/Inmemorialake/Documents/Taller3-FLP-/interpretador.rkt" 14912 14912)
   (#"/home/Inmemorialake/Downloads/Codigo de Prueba/Racket" 12 12)
  ))
 (plt:framework-pref:drracket:console-previous-exprs
  (
   (";***********************************************************************************************************************\n;**********************************  Pruebas — Punto 6 (Control y recursión)  ******************************************\n;***********************************************************************************************************************\n\n;; 1. if / else con anidamiento\n(eval-program (scan&parse\n               \"begin\n     func categoria (edad) {\n       if <(edad, 13) then return \\\"nino\\\"\n       else if <(edad, 18) then return \\\"adolescente\\\"\n       else return \\\"adulto\\\" end end\n     };\n     print((categoria 10));\n     print((categoria 15));\n     print((categoria 30))\n   end\"))\n;; Esperado: \"nino\" / \"adolescente\" / \"adulto\"\n\n;; 2. switch con default\n(eval-program (scan&parse\n               \"begin\n     var { color = (\\\"azul\\\") };\n     switch color {\n       case \\\"rojo\\\" : print(\\\"Detente\\\")\n       case \\\"verde\\\" : print(\\\"Sigue\\\")\n       default : print(\\\"Color desconocido\\\")\n     }\n   end\"))\n;; Esperado: \"Color desconocido\"\n\n;; 3. while: la mutación se ve DESPUÉS del ciclo\n(eval-program (scan&parse\n               \"begin\n     var { contador = (0) };\n     while <(contador, 5) do\n       contador = +(contador, 1)\n     done;\n     print(contador)\n   end\"))\n;; Esperado: 5\n\n;; 4. for sobre lista vacía\n(eval-program (scan&parse\n               \"begin\n     var { total = (0) };\n     for n in vacio do\n       total = +(total, n)\n     done;\n     print(total)\n   end\"))\n;; Esperado: 0\n\n;; 5. for acumulando sobre una lista no vacía\n(eval-program (scan&parse\n               \"begin\n     var { suma = (0) };\n     for n in crear-lista(1, crear-lista(2, crear-lista(3, vacio))) do\n       suma = +(suma, n)\n     done;\n     print(suma)\n   end\"))\n;; Esperado: 6\n\n;; 6. Recursión: factorial y fibonacci\n(eval-program (scan&parse\n               \"begin\n     func factorial (n) {\n       if <=(n, 1) then return 1 else return *(n, (factorial -(n, 1))) end\n     };\n     func fib (n) {\n       if <=(n, 1) then return n else return +((fib -(n, 1)), (fib -(n, 2))) end\n     };\n     print((factorial 5));\n     print((fib 6))\n   end\"))\n;; Esperado: 120 / 8\n\n;; 7. Función sin return -> debe devolver null\n(eval-program (scan&parse\n               \"begin\n     func saludar (nombre) {\n       print(concatenar(\\\"Hola, \\\", nombre))\n     };\n     print((saludar \\\"Gerardo\\\"))\n   end\"))\n;; Esperado: imprime \"Hola, Gerardo\" y luego \"null\"\n\n;; 8. begin anidado dentro de una función\n(eval-program (scan&parse\n               \"begin\n     func calcular (a, b) {\n       return begin\n         var { suma = (+(a, b)) };\n         var { doble = (*(suma, 2)) };\n         doble\n       end\n     };\n     print((calcular 3 4))\n   end\"))\n;; Esperado: 14")
   ("(eval-program (scan&parse\n                 \"begin\n     func sinReturn (x) {\n       +(x, 1)\n     };\n     print((sinReturn 5))\n   end\"))\n  ;; Según el README debería dar: null\n  ;; Con el código actual probablemente da: 6")
   ("(eval-program (scan&parse\n  \"begin\n     symbol b;\n     symbol h;\n     symbol r;\n     var { area_triangulo = ( /(*(b, h), 2) ) };\n     var { area_circulo = ( *(3.1416, *(r, r)) ) };\n\n     print(area_triangulo);\n     print(area_circulo);\n\n     print(evaluar(area_triangulo, b=6));\n     print(evaluar(area_triangulo, h=4));\n\n     print(evaluar(area_triangulo, b=6, h=4));\n     print(evaluar(area_circulo, r=3))\n   end\"))")
   ("(eval-program (scan&parse\n                 \"begin\n     symbol b;\n     symbol h;\n     symbol r;\n     var { areaTriangulo = ( /(*(b, h), 2) ) };\n     var { areaCirculo = ( *(3.1416, *(r, r)) ) };\n\n     print(areaTriangulo);\n     print(areaCirculo);\n\n     print(evaluar(areaTriangulo, b=6));\n     print(evaluar(areaTriangulo, h=4));\n\n     print(evaluar(areaTriangulo, b=6, h=4));\n     print(evaluar(areaCirculo, r=3))\n   end\"))")
   ("(eval-program (scan&parse\n                 \"begin\n     symbol x;\n     print(simplificar(+(x, 0)));\n     print(simplificar(+(*(x, 1), 0)));\n     var { y = ( +(+(x, 2), 3) ) };\n     print(simplificar(y));\n     print(simplificar(+(*(x, 0), 10)));\n     print(simplificar(*(*(x, 5), 6)));\n     print(simplificar(+(*(+(x, 0), 1), +(2, 3))))\n   end\"))")
   ("(eval-program (scan&parse\n                 \"begin\n     func crearVehiculo(marca, modelo) {\n       return crear-diccionario(\\\"marca\\\", marca, \\\"modelo\\\", modelo)\n     };\n\n     func despacharVehiculo(v, msg, valor) {\n       return switch msg {\n         case \\\"getMarca\\\" : ref-diccionario(v, \\\"marca\\\")\n         case \\\"setMarca\\\" : set-diccionario(v, \\\"marca\\\", valor)\n         case \\\"getModelo\\\" : ref-diccionario(v, \\\"modelo\\\")\n         case \\\"setModelo\\\" : set-diccionario(v, \\\"modelo\\\", valor)\n         default : null\n       }\n     };\n\n     func crearMoto(marca, modelo, cilindrada) {\n       return crear-diccionario(\\\"vehiculo\\\", (crearVehiculo marca modelo), \\\"cilindrada\\\", cilindrada)\n     };\n\n     func despacharMoto(m, msg, valor) {\n       return switch msg {\n         case \\\"getCilindrada\\\" : ref-diccionario(m, \\\"cilindrada\\\")\n         case \\\"setCilindrada\\\" : set-diccionario(m, \\\"cilindrada\\\", valor)\n         case \\\"getMarca\\\" : (despacharVehiculo ref-diccionario(m, \\\"vehiculo\\\") \\\"getMarca\\\" null)\n         case \\\"setMarca\\\" : (despacharVehiculo ref-diccionario(m, \\\"vehiculo\\\") \\\"setMarca\\\" valor)\n         case \\\"getModelo\\\" : (despacharVehiculo ref-diccionario(m, \\\"vehiculo\\\") \\\"getModelo\\\" null)\n         case \\\"setModelo\\\" : (despacharVehiculo ref-diccionario(m, \\\"vehiculo\\\") \\\"setModelo\\\" valor)\n         default : null\n       }\n     };\n\n     var { moto1 = ( (crearMoto \\\"Yamaha\\\" \\\"FZ\\\" 150) ) };\n     var { moto2 = ( (crearMoto \\\"Honda\\\" \\\"CB1\\\" 190) ) };\n     var { moto3 = ( (crearMoto \\\"Suzuki\\\" \\\"GN\\\" 125) ) };\n\n     print((despacharMoto moto1 \\\"getMarca\\\" null));\n     print((despacharMoto moto1 \\\"getModelo\\\" null));\n     print((despacharMoto moto1 \\\"getCilindrada\\\" null));\n\n     (despacharMoto moto1 \\\"setMarca\\\" \\\"Yamaha-Editada\\\");\n     (despacharMoto moto1 \\\"setModelo\\\" \\\"FZ25\\\");\n     (despacharMoto moto1 \\\"setCilindrada\\\" 160);\n\n     print((despacharMoto moto1 \\\"getMarca\\\" null));\n     print((despacharMoto moto1 \\\"getModelo\\\" null));\n     print((despacharMoto moto1 \\\"getCilindrada\\\" null));\n\n     print((despacharMoto moto2 \\\"getMarca\\\" null));\n     print((despacharMoto moto2 \\\"getCilindrada\\\" null));\n\n     print((despacharMoto moto3 \\\"getMarca\\\" null));\n     print((despacharMoto moto3 \\\"getCilindrada\\\" null))\n   end\"))")
   ("(eval-program (scan&parse\n  \"begin\n     var { original = ( crear-lista(1, crear-lista(2, crear-lista(3, crear-lista(4, crear-lista(5, vacio))))) ) };\n     var { reciprocos = ( vacio ) };\n\n     for x in original do\n       begin\n         var { r = ( /(1.0, x) ) };\n         print(x);\n         print(r);\n         reciprocos = append(reciprocos, crear-lista(r, vacio))\n       end\n     done;\n\n     print(reciprocos)\n   end\"))")
   ("(eval-program (scan&parse\n  \"begin\n     func esPar(n) {\n       return ==(%(n, 2), 0)\n     };\n\n     var { i = (1) };\n     while <=(i, 5) do\n       begin\n         print((esPar i));\n         i = +(i, 1)\n       end\n     done\n   end\"))")
   (";; ver el árbol de sintaxis abstracta\n(scan&parse\n \"func map(L, F) {\n    if vacio?(L) then\n      return vacio\n    else\n      return crear-lista((F cabeza(L)), (map cola(L) F))\n    end\n  }\")\n\n;; ejecutarlo con un ejemplo completo\n(eval-program (scan&parse\n  \"begin\n     func map(L, F) {\n       if vacio?(L) then\n         return vacio\n       else\n         return crear-lista((F cabeza(L)), (map cola(L) F))\n       end\n     };\n     func doble(x) {\n       return *(x, 2)\n     };\n     var { numeros = (crear-lista(1, crear-lista(2, crear-lista(3, vacio)))) };\n     print((map numeros doble))\n   end\"))")
   ("(eval-program (scan&parse\n  \"begin\n     func map(L, F) {\n       if vacio?(L) then\n         return vacio\n       else\n         return crear-lista((F cabeza(L)), (map cola(L) F))\n       end\n     };\n     func factorial(n) {\n       if <=(n, 1) then\n         return 1\n       else\n         return *(n, (factorial -(n, 1)))\n       end\n     };\n     func registroFactorial(L) {\n       return crear-diccionario(\\\"valores\\\", L, \\\"factoriales\\\", (map L factorial))\n     };\n     var { lista = (crear-lista(1, crear-lista(2, crear-lista(3, crear-lista(4, crear-lista(7, crear-lista(9, vacio))))))) };\n     print((registroFactorial lista))\n   end\"))")
  ))
)
