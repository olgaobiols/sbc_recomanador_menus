(defmodule MAIN (export ?ALL))

(deftemplate MAIN::peticio
  (slot tipus-esdeveniment)               ; SYMBOL (nil al principi)
  (slot data)                             ; SYMBOL
  (slot torn)                             ; SYMBOL
  (slot espai)                            ; SYMBOL
  (slot num-comensals (type INTEGER SYMBOL)) ; permet nil al principi
  (slot infantil-senior (type SYMBOL)) ; "si"/"no" en minúscules
  (slot pressupost (type NUMBER SYMBOL))  ; permet nil al principi
  (slot formalitat)                       ; SYMBOL: informal/formal
  (slot beguda-mode )                      ; SYMBOL: general/per-plat
  (slot alcohol )                          ; SYMBOL: si/no
  (slot menu-mode )                        ; SYMBOL: unic/alternatiu
  (slot alergies-si (type SYMBOL)) ; si/no
  (slot alergens)                         ; TEXT/SYMBOL
)

(defrule MAIN::boot
  (declare (salience 10000) (auto-focus TRUE)) 
  (initial-fact)
  =>
  (printout t "Benvingut! Iniciant flux de preguntes..." crlf)
  (assert (peticio))
  (focus PreferenciesMenu))


;; COMENTARIS GENERALS ---------------------------------------------------
; definir usa-ingredient ??
; DEFINIR QUANTITAT INGREDIENT ??
; CORREGIR ALCOHOL NO --> MILLOR FALSE PER PODER FER NOT??

;; ------------------------------------------------------------------

; HELPERS
(deffunction round2 (?x) "Arrodoneix un float a 2 decimals"
  (/ (float (round (* ?x 100))) 100.0))

(deffunction factor-complexitat (?c) "Factor de complexitat segons la classificació baixa/mitjana/alta"
  (if (eq ?c baixa) then 1.10
   else (if (eq ?c mitjana) then 1.25
   else (if (eq ?c alta) then 1.50 else 1.20))))

(deffunction factor-formalitat (?f)  "Factor de formalitat segons la classificació informal/formal"
  (if (eq ?f formal) then 1.15 else 1.00))


;; VALIDADORS DE RESPOSTES -------------------------------------------------
(deffunction valida-boolea "Valida una resposta booleana (sí/no)"
  (?prompt)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)

  (while (not ?resp_valida)
    (printout t ?prompt " (sí/no): " crlf)
    (bind ?resp_usuari (readline))
    (bind ?resp (lowcase ?resp_usuari))  
    (if (or (eq ?resp "sí") (eq ?resp "si") (eq ?resp "s") (eq ?resp "n") (eq ?resp "no")) then
        (bind ?resp_valida TRUE)
    else
        (printout t "Si us plau respon amb 'sí' o 'no'." crlf)
    )
  )
  ?resp ; retorna la resposta validada
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
    (bind ?input (lowcase (readline)))

    ; comprova si l’entrada és una de les opcions vàlides
    (if (member$ ?input ?opcions) then
        (bind ?resp_valida TRUE)
        (bind ?resp ?input)
     else
        (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))
  )
  ?resp
)

;; MÒDULS DE CONTROL I CLASSIFICACIÓ HEURÍSTICA-------------------------------
(defmodule ControlFlux (import MAIN ?ALL))
(defrule ControlFlux::arrencada
  (declare (salience 1000) (auto-focus TRUE))
  (initial-fact)
  =>
  (focus RefinamentHeuristica)
  (focus AssociacioHeuristica)
  (focus AbstraccioHeuristica)
  (focus PreferenciesMenu)
)

;; PAS 1: RECOLLIR PREFERÈNCIES -------------------------------
(defmodule PreferenciesMenu (import MAIN ?ALL) (export ?ALL))
; ??????????????

; AFEGIR PREU MIN I PREU MAX --> REVISAR ENUNCIAT PROBLEMA !!!!!
; AFEGIR TYPES ? O NO CAL SI JA ESTAN A ONTOLOGIA ????
(defrule PreferenciesMenu::iniciar-peticio
  (declare (auto-focus TRUE))
  (not (peticio))
  (not (iniciat))
  =>
  (printout t "Benvingut/da al recomanador de menús RicoRico!" crlf)
  (printout t "Si us plau respon a les preguntes següents per personalitzar les propostes." crlf)
  (assert (peticio))
  (assert (iniciat))
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

; AMPLIAR PER A QUE ACCEPTI DATA CONCRETA!!!!!!!
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

; (defrule PreferenciesMenu::preguntar-adreca
;   (exists (preguntat-interior-exterior))
;   (not (exists (preguntat-adreca)))
;   =>
  
;   (assert (preguntat-adreca))
; )

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

(defrule PreferenciesMenu::preguntar-infantil-senior
  ?p <- (peticio (infantil-senior ?x&nil))
  (preguntat-num-comensals)
  (not (preguntat-infantil-senior))
=>
  (bind ?r (valida-boolea "Cal una opció infantil o suau per gent gran? (sí/no)"))
  (modify ?p (infantil-senior ?r))
  (assert (preguntat-infantil-senior))
)

; MODIFICAR LÍMIT MÀXIM
(defrule PreferenciesMenu::preguntar-pressupost
  ?p <- (peticio (pressupost ?pp&nil))
  (preguntat-infantil-senior)
  (not (preguntat-pressupost))
=>
  (bind ?r (valida-num "Quin és el pressupost per persona aproximat?" 1 1000))
  (modify ?p (pressupost ?r))
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
  (bind ?r (valida-boolea "Hi ha al·lèrgies o ingredients prohibits que s'han d'evitar? (sí/no)"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits))
)
; (defrule PreferenciesMenu::detallar-alergens
;   ?p <- (peticio (alergies-si ?r&:(or (eq ?r "si") (eq ?r "sí"))) (alergens ?al&nil))
;   (preguntat-alergens-prohibits)
;   (not (alergens-detalats))
; =>
;   (printout t "Indica'ls separats per espais (ex: gluten marisc lactosa): " crlf)
;   (bind ?txt (lowcase (readline)))
;   (modify ?p (alergens ?txt))
;   (assert (alergens-detalats))
; )
;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))
; (defrule genera-candidat-basic-plat
; )






;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))

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
; AFEGIR ID MENU A ONTOLOGIA EN COMPTES DE NOM I GENERAR NOM EN FUNCIO ATRIBUTS
; (defrule ComposicioMenus::calcula-preu-venta-menu

; )

