
;; DINS del mòdul AssociacioHeuristica

;; (Exemple) coneixement base dels menús (substitueix-ho per la teva ontologia/objectes)
(deftemplate menu
  (slot id)                        ; identificador
  (slot preu-pp (type NUMBER))     ; preu per persona
  (slot formalitat)                ; informal/formal
  (slot torn)                      ; dinar/sopar
  (slot espai)                     ; interior/exterior
  (slot temporada)                 ; primavera/estiu/tardor/hivern
  (slot alcohol)                   ; si/no
  (slot infantil-friendly))        ; si/no


;; helpers de puntuació
(deffunction append-motius ($?old) ($?more)
  (create$ $?old $?more))

;; 3.1) Generar candidats per franja de preu

(defrule AssociacioHeuristica::puntua-formalitat
  (perfil-usuari (formalitat ?f) (pes-formalitat ?w))
  (menu (id ?id) (formalitat ?f))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s ?w))
            (motius (append-motius $?m (str-cat "+ " ?w " per formalitat")))))

(defrule AssociacioHeuristica::puntua-torn
  (perfil-usuari (torn ?t) (pes-torn ?w))
  (menu (id ?id) (torn ?t))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s ?w))
            (motius (append-motius $?m (str-cat "+ " ?w " per torn")))))

(defrule AssociacioHeuristica::puntua-espai
  (perfil-usuari (espai ?e) (pes-espai ?w))
  (menu (id ?id) (espai ?e))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s ?w))
            (motius (append-motius $?m (str-cat "+ " ?w " per espai")))))

(defrule AssociacioHeuristica::puntua-temporada
  (perfil-usuari (temporada ?temp) (pes-temporada ?w))
  (menu (id ?id) (temporada ?temp))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s ?w))
            (motius (append-motius $?m (str-cat "+ " ?w " per temporada")))))

(defrule AssociacioHeuristica::puntua-alcohol
  (perfil-usuari (alcohol ?a) (pes-beguda ?w))
  (menu (id ?id) (alcohol ?a))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s ?w))
            (motius (append-motius $?m (str-cat "+ " ?w " per preferència de beguda")))))

(defrule AssociacioHeuristica::puntua-infantil
  (perfil-usuari (infantil-senior si))
  (menu (id ?id) (infantil-friendly si))
  ?c <- (candidat-menu (id-menu ?id) (puntuacio ?s) (motius $?m))
  =>
  (modify ?c (puntuacio (+ ?s 0.5))
            (motius (append-motius $?m "+ 0.5 apte infantil/sènior"))))


;; coneixement de (menu-te-alergen id, alergen)
; (deftemplate menu-te-alergen (slot id) (slot alergen))

; ;; 4.1) Filtre dur d’al·lèrgens
; (defrule RefinamentHeuristica::filtra-alergens
;   (perfil-usuari (alergens-prohibits $?ban))
;   ?c <- (candidat-menu (id-menu ?id))
;   (menu-te-alergen (id ?id) (alergen ?a))
;   (test (member$ ?a $?ban))
;   =>
;   (retract ?c))


