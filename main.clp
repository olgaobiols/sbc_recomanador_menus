
;; COMENTARIS GENERALS ---------------------------------------------------
; definir usa-ingredient ??
; DEFINIR QUANTITAT INGREDIENT ??
; CORREGIR ALCOHOL NO --> MILLOR FALSE PER PODER FER NOT??
; MODIFICAR LÍMIT MÀXIM i MÍNIM  MENU??? --> VEURE ENUNCIAT -> NO PREU APROXIMAT PER CAP
; AFEGIR ID MENU A ONTOLOGIA EN COMPTES DE NOM I GENERAR NOM EN FUNCIO ATRIBUTS ???
; AFEGIR POSSIBILITAT PER PART DE L USUARI  DE DIR QUE LI ES IGUAL EL FILTRE
;; ------------------------------------------------------------------

(defmodule MAIN (export ?ALL))

(deftemplate MAIN::peticio
    (slot tipus-esdeveniment)               ; SYMBOL (nil al principi)
    (slot data)                             ; SYMBOL
    (slot torn)                             ; SYMBOL
    (slot espai)                            ; SYMBOL
    (slot num-comensals (type INTEGER SYMBOL)) ; permet nil al principi
    ; (slot infantil-senior (type SYMBOL)) ; "si"/"no" en minúscules
    (slot pressupost-min (type NUMBER SYMBOL))  ; permet nil al principi
    (slot pressupost-max (type NUMBER SYMBOL))  ; permet nil al principi
    ;   (slot servei)                           ; SYMBOL: emplatat/buffet/pica-pica/mixt/indiferent
    (slot formalitat)                       ; SYMBOL: informal/formal
    (slot beguda-mode)                      ; SYMBOL: general/per-plat
    (slot alcohol)                          ; SYMBOL: si/no
    (slot menu-mode)                        ; SYMBOL: unic/alternatiu
    

    ;SLOTS EN FASE DE PROVA
    (slot requereix-pastis (type SYMBOL))   ; si/no/indiferent
    ; (slot public-aniversari)                ; adults/nens/mixt
    (slot necessita-pica-pica (type SYMBOL)) ; si/no/indiferent
    (slot diferenciar-edats (type SYMBOL))   ; si/no
    (slot num-nens (type INTEGER SYMBOL))
    (slot num-adults (type INTEGER SYMBOL))  
    (slot num-vegans (type INTEGER SYMBOL))
    (slot num-vegetarians (type INTEGER SYMBOL))
    (slot num-celiacs (type INTEGER SYMBOL))
    (slot num-halal (type INTEGER SYMBOL))
    (slot estrategia-dietes (type SYMBOL)) ; adaptar/alternatiu/mixt/nil
    (slot alergies-si (type SYMBOL)) ; si/no
    (slot alergens)                  ; TEXT/SYMBOL
)

; HELPERS
(deffunction round2 (?x) "Arrodoneix un float a 2 decimals"
  (/ (float (round (* ?x 100))) 100.0))

(deffunction factor-complexitat (?c) "Factor de complexitat segons la classificació baixa/mitjana/alta"
  (if (eq ?c baixa) then 1.10
   else (if (eq ?c mitjana) then 1.25
   else (if (eq ?c alta) then 1.50 else 1.20))))

(deffunction factor-formalitat (?f)  "Factor de formalitat segons la classificació informal/formal"
  (if (eq ?f formal) then 1.15 else 1.00))

; POSAR DIRECTAMENT A LA BASE DE DADES COM 1/2/3???
; (deffunction nivell-complexitat (?nivell) "Retorna un valor numèric per comparar nivells de complexitat"
;   (if (eq ?nivell baixa) then 1
;    else (if (eq ?nivell mitjana) then 2
;    else (if (eq ?nivell alta) then 3 else 2))))

; (deffunction servei-compatible (?preferit $?serveis-menu) "Comprova si el tipus de servei preferit és present"
;   (or (eq ?preferit indiferent)
;       (member$ ?preferit $?serveis-menu)
;       (and (eq ?preferit mixt)
;            (or (member$ buffet $?serveis-menu)
;                (member$ emplatat $?serveis-menu)
;                (member$ pica-pica $?serveis-menu)))))

; (deffunction disponibilitat-compatible (?temporada $?dispon)
;   (or (member$ sempre $?dispon)
;       (member$ ?temporada $?dispon)))

; (deffunction suporta-dieta (?dieta $?suportades)
;   (member$ ?dieta $?suportades))



;; VALIDADORS DE RESPOSTES -------------------------------------------------
(deffunction valida-boolea "Valida una resposta booleana (sí/no)"
  (?prompt)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)

  (while (not ?resp_valida)
    (printout t ?prompt " (sí/no): " crlf)
    (bind ?x (lowcase (readline)))
    (if (or (eq ?x "sí") (eq ?x "si") (eq ?x "s") (eq ?x "y") (eq ?x "yes")) then
        (bind ?resp_valida TRUE) (bind ?resp si)
    else
    (if (or (eq ?x "no") (eq ?x "n")) then
        (bind ?resp_valida TRUE) (bind ?resp no)
    else
        (printout t "Si us plau, respon 'sí' o 'no'." crlf))))
  ?resp
)


(deffunction valida-num "Valida una resposta numèrica dins d'un rang"
  (?prompt ?min ?max)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)

  (while (not ?resp_valida)
    (printout t ?prompt " (" ?min "-" ?max "): " crlf)
    (bind ?resp (read))
    (if (numberp ?resp) then
        (if (and (>= ?resp ?min) (<= ?resp ?max)) then ; resposta dins del rang 
            (bind ?resp_valida TRUE)
        else
            (printout t "Si us plau introdueix un valor dins del rang ("?min " - "?max ")."  crlf)
        )
    else
        (printout t "Si us plau introdueix un valor numèric." crlf)
    )
  )
  ?resp ; retorna la resposta validada  
)

(deffunction valida-opcio (?pregunta $?opcions)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)

  (while (not ?resp_valida)
    (printout t ?pregunta crlf)
    (bind ?input (string-to-field (lowcase (readline)))) 

    ; comprova si l’entrada és una de les opcions vàlides
    (if (member$ ?input ?opcions) then
        (bind ?resp_valida TRUE)
        (bind ?resp ?input)
     else
        (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))
  )
  ?resp
)

(deffunction separa-paraules (?txt) "Separa un text en paraules individuals"
  (if (or (eq ?txt nil) (eq ?txt "")) then (create$) else (explode$ ?txt)))

;; MÒDULS DE CONTROL I CLASSIFICACIÓ HEURÍSTICA-------------------------------
(defmodule ControlFlux (import MAIN ?ALL))
(defrule ControlFlux::arrencada
  (declare (auto-focus TRUE))
  (initial-fact)
  =>
  (focus RefinamentHeuristica)
  (focus AssociacioHeuristica)
  (focus AbstraccioHeuristica)
  (focus PreferenciesMenu))

;; PAS 1: RECOLLIR PREFERÈNCIES -------------------------------
(defmodule PreferenciesMenu (import MAIN ?ALL) (export ?ALL))

(defrule PreferenciesMenu::iniciar-peticio
  (declare (auto-focus TRUE))
  (not (peticio))
;   (not (iniciat))
  =>
  (printout t "Benvingut/da al recomanador de menús RicoRico!" crlf)
  (printout t "Si us plau respon a les preguntes següents per personalitzar les propostes." crlf)
  (assert (peticio))
;   (assert (iniciat))
  (focus PreferenciesMenu)
)

; PREGUNTES DE CONTEXT GENERAL DE L'ESDEVENIMENT
(defrule PreferenciesMenu::preguntar-tipus-esdeveniment
  (declare (auto-focus TRUE))
  ?p <- (peticio (tipus-esdeveniment ?te&nil))
  (not (preguntat-tipus))
=>
  (bind ?res (valida-opcio 
              "Quin tipus d’esdeveniment estàs organitzant? (casament/ aniversari/ comunió/ congrés/ empresa/ altres)"
              casament aniversari comunio congres empresa altres)
  
  )
  (modify ?p (tipus-esdeveniment ?res))
  (assert (preguntat-tipus))
)

; AFEGIR OPCIÓ DE NO SABUT
(defrule PreferenciesMenu::preguntar-data
  ?p <- (peticio (data ?e&nil))
  (preguntat-tipus)
  (not (preguntat-data))
=>
  (bind ?r (valida-opcio
              "Quina època de l’any? (primavera/ estiu/ tardor/ hivern)"
              primavera estiu tardor hivern))
  (modify ?p (data ?r))
  (assert (preguntat-data))
)

(defrule PreferenciesMenu::preguntar-dinar-sopar 
  ?p <- (peticio (torn ?t&nil))
  (preguntat-data)
  (not (preguntat-dinar-sopar))
=>
  (bind ?r (valida-opcio "Serà dinar o sopar?" dinar sopar))
  (modify ?p (torn ?r))
  (assert (preguntat-dinar-sopar))
)

(defrule PreferenciesMenu::preguntar-interior-exterior
  ?p <- (peticio (espai ?s&nil))
  (preguntat-dinar-sopar)
  (not (preguntat-interior-exterior))
=>
  (bind ?r (valida-opcio "Es farà en interior o exterior?" interior exterior))
  (modify ?p (espai ?r))
  (assert (preguntat-interior-exterior))
)

; MODIFICAR LÍMIT MÀXIM
(defrule PreferenciesMenu::preguntar-num-comensals
  ?p <- (peticio (num-comensals ?n&nil))
  (preguntat-interior-exterior)
  (not (preguntat-num-comensals))
=>
  (bind ?r (valida-num "Quants comensals assistiran aproximadament?" 1 5000))
  (modify ?p (num-comensals ?r))
  (assert (preguntat-num-comensals))
)

(defrule PreferenciesMenu::preguntar-pressupost-min
  ?p <- (peticio (pressupost-min ?ppmin&nil))
  (preguntat-infantil-senior)
  (not (preguntat-pressupost))
=>
  (bind ?min (valida-num "Quin és el pressupost mínim per persona?" 1 1000))
  (modify ?p (pressupost-min ?min))
  (assert (preguntat-pressupost-min)))

(defrule PreferenciesMenu::preguntar-pressupost-max
  ?p <- (peticio (pressupost-min ?min&~nil) (pressupost-max ?ppmax&nil))
  (preguntat-pressupost-min)
  (not (preguntat-pressupost-max))
=>
  (bind ?max (valida-num "I quin és el pressupost màxim per persona?" ?min 2000))
  (modify ?p (pressupost-max ?max))
  (assert (preguntat-pressupost-max))
  (assert (preguntat-pressupost))
)

(defrule PreferenciesMenu::preguntar-formalitat
  ?p <- (peticio (formalitat ?f&nil))
  (preguntat-pressupost)
  (not (preguntat-formalitat))
=>
  (bind ?r (valida-opcio "Quin grau de formalitat vols? (formal/ informal)" 
            informal formal))
  (modify ?p (formalitat ?r))
  (assert (preguntat-formalitat))
)

(defrule PreferenciesMenu::preguntar-beguda-general
  ?p <- (peticio (beguda-mode ?bm&nil))
  (preguntat-formalitat)
  (not (preguntat-beguda-general))
=>
  (bind ?r (valida-opcio "Beguda per a tot el menú o per a cada plat? (general/per-plat)" general per-plat))
  (modify ?p (beguda-mode ?r))
  (assert (preguntat-beguda-general))
)

(defrule PreferenciesMenu::preguntar-alcohol
  ?p <- (peticio (alcohol ?a&nil))
  (preguntat-beguda-general)
  (not (preguntat-alcohol))
=>
  (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques? (sí/no)"))
  (modify ?p (alcohol ?r))
  (assert (preguntat-alcohol))
)

(defrule PreferenciesMenu::preguntar-menu-unic
  ?p <- (peticio (menu-mode ?mm&nil))
  (preguntat-alcohol)
  (not (preguntat-menu-unic))
=>
  (bind ?r (valida-opcio "Vols un menú únic per a tothom o opcions alternatives? (unic/alternatiu)" unic alternatiu))
  (modify ?p (menu-mode ?r))
  (assert (preguntat-menu-unic))
)

(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
  (preguntat-menu-unic)
  (not (preguntat-alergens-prohibits))
=>
  (bind ?r (valida-boolea "Hi ha al·lèrgies o ingredients prohibits? (sí/no)"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits))
)
(defrule PreferenciesMenu::detallar-alergens
  ?p <- (peticio (alergies-si ?r&:(or (eq ?r "si") (eq ?r "sí"))) (alergens ?al&nil))
  (preguntat-alergens-prohibits)
  (not (alergens-detalats))
=>
  (printout t "Indica'ls separats per espais (ex: gluten marisc lactosa): " crlf)
  (bind ?txt (lowcase (readline)))
  (modify ?p (alergens ?txt))
  (assert (alergens-detalats))
)

; (defrule PreferenciesMenu::preguntar-dietes-vegans
;   ?p <- (peticio (menu-mode alternatiu) (num-vegans ?v&nil) (num-comensals ?n&~nil))
;   (preguntat-menu-unic)
;   (not (preguntat-vegans))
; =>
;   (bind ?resp (valida-num "Quants comensals necessiten opció vegana?" 0 ?n))
;   (modify ?p (num-vegans ?resp))
;   (assert (preguntat-vegans)))

; (defrule PreferenciesMenu::preguntar-dietes-vegetarians
;   ?p <- (peticio (menu-mode alternatiu) (num-vegans ?v&~nil) (num-vegetarians ?vv&nil) (num-comensals ?n&~nil))
;   (preguntat-vegans)
;   (not (preguntat-vegetarians))
; =>
;   (bind ?resp (valida-num "Quants comensals necessiten opció vegetariana?" 0 ?n))
;   (modify ?p (num-vegetarians ?resp))
;   (assert (preguntat-vegetarians)))

; (defrule PreferenciesMenu::preguntar-dietes-celiacs
;   ?p <- (peticio (menu-mode alternatiu) (num-vegetarians ?vv&~nil) (num-celiacs ?vc&nil) (num-comensals ?n&~nil))
;   (preguntat-vegetarians)
;   (not (preguntat-celiacs))
; =>
;   (bind ?resp (valida-num "Quants comensals requereixen opció sense gluten?" 0 ?n))
;   (modify ?p (num-celiacs ?resp))
;   (assert (preguntat-celiacs)))

; (defrule PreferenciesMenu::preguntar-dietes-halal
;   ?p <- (peticio (menu-mode alternatiu) (num-celiacs ?vc&~nil) (num-halal ?vh&nil) (num-comensals ?n&~nil))
;   (preguntat-celiacs)
;   (not (preguntat-halal))
; =>
;   (bind ?resp (valida-num "Quants comensals necessiten opció sense porc/halal?" 0 ?n))
;   (modify ?p (num-halal ?resp))
;   (assert (preguntat-halal)))


; ; POSSIBLES PREGUNTES PER A LA FASE REFINAMENT?? O ORDENAR PREGUNTES: 
; (defrule PreferenciesMenu::preguntar-detall-casament
;   ?p <- (peticio (tipus-esdeveniment casament) (requereix-pastis ?rp&nil))
;   (preguntat-formalitat) ; AJUSTAR SEGONS ORDRE
;   (not (preguntat-pastis-casament))
; =>
;   (bind ?r (valida-opcio "Vols assegurar un pastís cerimonial per al casament? (si/no/indiferent)"
;             si no indiferent))
;   (modify ?p (requereix-pastis ?r))
;   (assert (preguntat-pastis-casament))
;   )
; (defrule PreferenciesMenu::preguntar-detall-aniversari
;   ?p <- (peticio (tipus-esdeveniment aniversari) (public-aniversari ?pa&nil))
;   (preguntat-formalitat)
;   (not (preguntat-public-aniversari))
; =>
;   (bind ?r (valida-opcio "Per a qui és l'aniversari? (adults/ nens/ mixt)" adults nens mixt))
;   (modify ?p (public-aniversari ?r))
;   (assert (preguntat-public-aniversari)))

; (defrule PreferenciesMenu::preguntar-detall-congres
;   ?p <- (peticio (tipus-esdeveniment congres) (necessita-pica-pica ?pic&nil))
;   (preguntat-formalitat)
;   (not (preguntat-pica-pica))
; =>
;   (bind ?r (valida-opcio "Prefereixes un format ràpid tipus pica-pica? (si/no/indiferent)"
;             si no indiferent))
;   (modify ?p (necessita-pica-pica ?r))
;   (assert (preguntat-pica-pica)))

; (defrule PreferenciesMenu::preguntar-estrategia-dietes
;   ?p <- (peticio (menu-mode alternatiu) (estrategia-dietes ?ed&nil))
;   (preguntat-halal)
;   (not (preguntat-estrategia-dietes))
; =>
;   (bind ?r (valida-opcio "Prefereixes adaptar els plats base o oferir opcions separades? (adaptar/alternatiu/mixt/indiferent)"
;             adaptar alternatiu mixt indiferent))
;   (modify ?p (estrategia-dietes ?r))
;   (assert (preguntat-estrategia-dietes)))

; (defrule PreferenciesMenu::preguntar-diferenciar-edats
;   ?p <- (peticio (diferenciar-edats ?de&nil) (infantil-senior ?inf) (public-aniversari ?pa) (num-comensals ?n&~nil))
;   (preguntat-menu-unic)
;   (not (preguntat-diferenciar-edats))
;   (test (or (eq ?inf si) (eq ?pa nens) (eq ?pa mixt)))
; =>
;   (bind ?r (valida-boolea "Vols un menú diferenciat per edats (nens/adults/avis)? (sí/no)"))
;   (modify ?p (diferenciar-edats ?r))
;   (assert (preguntat-diferenciar-edats)))

; (defrule PreferenciesMenu::preguntar-num-nens
;   ?p <- (peticio (diferenciar-edats si) (num-nens ?nn&nil) (num-comensals ?n&~nil))
;   (preguntat-diferenciar-edats)
;   (not (preguntat-num-nens))
; =>
;   (bind ?resp (valida-num "Quants nens assistiran aproximadament?" 0 ?n))
;   (modify ?p (num-nens ?resp))
;   (assert (preguntat-num-nens)))

; ; realment no cal: si fem 2 separacions (nens/adults) el num-adults es pot calcular com num-comensals - num-nens
; (defrule PreferenciesMenu::preguntar-num-adults
;   ?p <- (peticio (diferenciar-edats si) (num-nens ?nn&~nil) (num-adults ?ns&nil) (num-comensals ?n&~nil))
;   (preguntat-num-nens)
;   (not (preguntat-num-adults))
; =>
;   (bind ?resp (valida-num "Quants adults o persones grans hi haurà?" 0 ?n))
;   (modify ?p (num-adults ?resp))
;   (assert (preguntat-num-adults)))


;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

(deftemplate AbstraccioHeuristica::perfil-usuari
  (slot temporada)        ; primavera/estiu/tardor/hivern
  (slot torn)             ; dinar/sopar
  (slot espai)            ; interior/exterior
  (slot tipus-esdeveniment)
  (slot formalitat)       ; informal/formal
  (slot alcohol)          ; si/no
;   (slot infantil-senior)  ; si/no
  (slot num-comensals (type INTEGER))
  (slot beguda-mode)
  (slot menu-mode)
  (slot pressupost-min (type NUMBER))
  (slot pressupost-max (type NUMBER))
;   (slot servei)
;   (slot requereix-pastis)
;   (slot public-aniversari)
;   (slot necessita-pica-pica)
;   (slot diferenciar-edats)
;   (slot num-nens (type INTEGER) (default 0))
;   (slot num-adults (type INTEGER) (default 0))
;   (slot num-vegans (type INTEGER) (default 0))
;   (slot num-vegetarians (type INTEGER) (default 0))
;   (slot num-celiacs (type INTEGER) (default 0))
;   (slot num-halal (type INTEGER) (default 0))
;   (slot estrategia-dietes)
  (multislot alergens-prohibits)
)
(defrule AbstraccioHeuristica::construir-perfil
  ?p <- (peticio (tipus-esdeveniment ?te&~nil) (data ?temp&~nil) (torn ?t&~nil)
                (espai ?esp&~nil) (num-comensals ?n&~nil) (pressupost-min ?min&~nil)
                (pressupost-max ?max&~nil) (formalitat ?form&~nil) (beguda-mode ?bm&~nil)
                (alcohol ?alc&~nil) (menu-mode ?mm&~nil) (alergies-si ?asi&~nil) (alergens ?als))
  (not (perfil-usuari))
  =>
  (bind ?alergies (if (eq ?asi si) then (separa-paraules ?als) else (create$)))
  (assert (perfil-usuari (temporada ?temp) (torn ?t) (espai ?esp) (tipus-esdeveniment ?te)
                         (formalitat ?form) (alcohol ?alc) (num-comensals ?n)
                         (beguda-mode ?bm) (menu-mode ?mm) (pressupost-min ?min)
                         (pressupost-max ?max) (alergens-prohibits ?alergies))))


;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))
(deftemplate AssociacioHeuristica::menu-base
  (slot id (type SYMBOL))
  (slot nom (type STRING))
  (slot categoria (type SYMBOL))      ; barat/mitja/car
  (slot preu-pp (type FLOAT))
  (slot formalitat)
  (multislot temporades)
  (multislot torns)
  (multislot espais)
  (multislot esdeveniments)
  (slot alcohol)
  (slot beguda-mode)
;   (slot infantil-friendly)
;   (multislot serveis)
;   (slot temperatura-dominant)
;   (multislot disponibilitat)
;   (slot complexitat-max)
;   (multislot dietes-suportades)
;   (multislot public-objectiu)
;   (slot postres-cerimonial)
;   (slot format-picapica)
;   (multislot etiquetes)
  (slot menu-mode (default unic)) 
  (multislot plats)
  (multislot begudes)
  (multislot alergens)
  (slot descripcio (type STRING)))

(deftemplate AssociacioHeuristica::candidat-menu
  (slot id-menu)
  (slot nom (type STRING))
  (slot franja-preu) ; barat/mitjà/car
  (slot preu-pp (type FLOAT))
  (slot formalitat)
  (multislot temporades)
  (multislot torns)
  (multislot espais)
  (multislot esdeveniments)
  (slot alcohol)
  (slot beguda-mode)
;   (slot infantil-friendly)
;   (multislot serveis)
;   (slot temperatura-dominant)
;   (multislot disponibilitat)
;   (slot complexitat-max)
;   (multislot dietes-suportades)
;   (multislot public-objectiu)
;   (slot postres-cerimonial)
;   (slot format-picapica)
;   (multislot etiquetes)
  (slot menu-mode)
  (multislot plats)
  (multislot begudes)
  (multislot alergens)
  (slot descripcio (type STRING))
  (slot puntuacio (type FLOAT))
;   (multislot motius)
)

(defrule AssociacioHeuristica::genera-candidat-menu
  (perfil-usuari (temporada ?usu-temp) (torn ?usu-torn) (espai ?usu-esp)
                 (tipus-esdeveniment ?usu-event) (formalitat ?usu-form) (alcohol ?usu-alc)
                 (beguda-mode ?usu-beguda) (menu-mode ?usu-menu)
                 (pressupost-min ?min) (pressupost-max ?max)
                 (alergens-prohibits $?prohibits))
  (menu-base (id ?id) (nom ?nom) (categoria ?cat) (preu-pp ?pp)
             (formalitat ?form) (temporades $?temps) (torns $?torns)
             (espais $?espais) (esdeveniments $?events) (alcohol ?alc)
             (beguda-mode ?beguda) (menu-mode ?menu-mode)
             (plats $?plats) (begudes $?begudes) (alergens $?menu-alergens)
             (descripcio ?desc))
  (not (candidat-menu (id-menu ?id)))
  =>
  (if (or (< ?pp ?min) (> ?pp ?max)) then (return))
  (if (> (length$ $?menu-alergens) 0) then
    (loop-for-count (?i 1 (length$ $?menu-alergens))
      (bind ?al (nth$ ?i $?menu-alergens))
      (if (member$ ?al $?prohibits) then (return))))
  (bind ?score 0)
  (if (eq ?form ?usu-form) then (bind ?score (+ ?score 3)))
  (if (member$ ?usu-temp $?temps) then (bind ?score (+ ?score 2)))
  (if (member$ ?usu-torn $?torns) then (bind ?score (+ ?score 2)))
  (if (member$ ?usu-esp $?espais) then (bind ?score (+ ?score 1)))
  (if (member$ ?usu-event $?events) then (bind ?score (+ ?score 1)))
  (if (eq ?alc ?usu-alc) then (bind ?score (+ ?score 1)))
  (if (eq ?beguda ?usu-beguda) then (bind ?score (+ ?score 1)))
  (if (eq ?menu-mode ?usu-menu) then (bind ?score (+ ?score 1)))
  (assert (candidat-menu (id-menu ?id) (nom ?nom) (franja-preu ?cat) (preu-pp ?pp)
                         (formalitat ?form) (temporades $?temps) (torns $?torns)
                         (espais $?espais) (esdeveniments $?events) (alcohol ?alc)
                         (beguda-mode ?beguda) (menu-mode ?menu-mode)
                         (plats $?plats) (begudes $?begudes) (alergens $?menu-alergens)
                         (descripcio ?desc) (puntuacio (float ?score)))))


; logica de puntuacions --> si s'allarga massa codi borrar motius



;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))

(defrule RefinamentHeuristica::sense-opcions
  (declare (salience -15))
  (perfil-usuari)
  (not (candidat-menu))
  (not (capcalera-impresa))
  =>
  (printout t crlf "No s'han trobat menús que encaixin amb els criteris indicats." crlf))

(defrule RefinamentHeuristica::mostrar-capcalera
  (declare (salience -10))
  (candidat-menu)
  (not (capcalera-impresa))
  =>
  (printout t crlf "MENÚS SUGGERITS" crlf)
  (assert (capcalera-impresa)))

(defrule RefinamentHeuristica::mostrar-candidat
  (declare (salience -11))
  ?c <- (candidat-menu (nom ?nom) (franja-preu ?cat) (preu-pp ?pp)
                       (plats $?plats) (begudes $?begudes) (descripcio ?desc)
                       (puntuacio ?score))
  =>
  (bind ?pp-str (format nil "%.2f" ?pp))
  (bind ?score-str (format nil "%.0f" ?score))
  (printout t "   • [" ?cat "] " ?nom " (" ?pp-str " €/pp, puntuació " ?score-str ")" crlf)
  (if (neq ?desc "") then (printout t "     " ?desc crlf))
  (if (> (length$ $?plats) 0) then (printout t "     Plats: " $?plats crlf))
  (if (> (length$ $?begudes) 0) then (printout t "     Begudes: " $?begudes crlf))
  (retract ?c))

; (defrule RefinamentHeuristica::filtra-disponibilitat
;   (perfil-usuari (temporada ?temp))
;   ?c <- (candidat-menu (id-menu ?id) (disponibilitat $?disp))
;   (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
;   (test (not (disponibilitat-compatible ?temp $?disp)))
;   =>
;   (retract ?c))

(deftemplate millor-menu (slot franja) (slot id) (slot puntuacio))
(defrule RefinamentHeuristica::seleccionar-millor-per-franja
  ?c <- (candidat-menu (id-menu ?id) (franja-preu ?fr) (puntuacio ?s))
  (not (candidat-menu (franja-preu ?fr) (puntuacio ?s2&:(> ?s2 ?s))))
  =>
  (assert (millor-menu (franja ?fr) (id ?id) (puntuacio ?s))))


; VEURE A QUIN MODUL IMPORTAR-HO
(defmodule ComposicioMenus (import MAIN ?ALL)(export ?ALL))

; (defrule ComposicioMenus::calcula-preu-venta-plat "Calcula el preu de venda d'un plat segons els ingredients que el componen i altres factors rellevants"
;   (plat (nom ?np)(complexitat ?cx)(racio ?r)(formalitat ?ff)) ; AJUSTAR FORMULA SEGONS NOSTRE CRITERI / EXPERT
;   (not (plat-preu (plat ?np)))
;   =>
;   (bind ?cost-base
;     (accumulate 
;       (bind ?sum 0.0)
;       (and (usa-ingredient (plat ?np)(ingredient ?ni)(quantitat ?q))
;            (ingredient (nom ?ni)(cost-unitari ?cu)))
;       (+ ?sum (* ?q ?cu))))

;   (bind ?fcomp (factor-complexitat ?cx))
;   (bind ?frac  (if (> ?r 1.0) then ?r else 1.0)) ; AJUSTAR SEGONS MIDES RACIONS BASE DE DADES
;   (bind ?fform (factor-formalitat ?ff))
;   (bind ?marge 1.35) ; marge global de venda --> AJUSTAR SEGONS BENEFICI DESITJAT

;   (bind ?preu-venta (round2 (* ?cost-base ?fcomp ?frac ?fform ?marge))) 
;   (assert (plat-preu (plat ?np)(preu-venta ?preu-venta)))
; )

; (defrule ComposicioMenus::calcula-preu-venta-beguda
; ; atributs beguda que es poden tenir en compte: alcohol, formalitat, preu_cost, ?
; ; tenir en compte si beguda per plat o general del menu
;   ?b <- ()
; )

; (defrule ComposicioMenus::calcula-preu-venta-menu

; )