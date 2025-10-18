(defmodule MAIN (export ?ALL))




; HELPERS --------------------------------------------------------------
(deffunction round2 (?x) "Arrodoneix un float a 2 decimals"
  (/ (float (round (* ?x 100))) 100.0))

(deffunction factor-complexitat (?c) "Factor de complexitat segons la classificació baixa/mitjana/alta"
  (if (eq ?c baixa) then 1.10
   else (if (eq ?c mitjana) then 1.25
   else (if (eq ?c alta) then 1.50 else 1.20))))

(deffunction factor-formalitat (?f)  "Factor de formalitat segons la classificació informal/formal"
  (if (eq ?f formal) then 1.15 else 1.00))

; Templates de control de flux
(deftemplate respostes-completes
  (slot estat (default TRUE)))

(deftemplate menus-presentats
  (slot estat (default TRUE)))

(deftemplate peticio
  (slot tipus-esdeveniment (type SYMBOL) (default nil))
  (slot data (type SYMBOL) (default nil))
  (slot torn (type SYMBOL) (default nil))
  (slot espai (type SYMBOL) (default nil))
  (slot num-comensals (type SYMBOL INTEGER) (default nil))
  (slot pressupost-min (type SYMBOL NUMBER) (default nil))
  (slot pressupost-max (type SYMBOL NUMBER) (default nil))
  (slot formalitat (type SYMBOL STRING) (default nil))
  (slot beguda-mode (type SYMBOL) (default nil))
  (slot alcohol (type SYMBOL STRING) (default nil))
  (slot menu-mode (type SYMBOL) (default nil))
  (slot alergies-si (type SYMBOL STRING) (default nil))
  (slot alergens (type SYMBOL STRING) (default nil)))

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
        (printout t "Si us plau, respon 'sí' o 'no'." crlf)))
 ) ?resp
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
  ) ?resp ; retorna la resposta validada  
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
  ) ?resp
)

;; MÒDULS DE CONTROL I CLASSIFICACIÓ HEURÍSTICA-------------------------------
(defmodule ControlFlux (import MAIN ?ALL))
(defrule ControlFlux::arrencada
  (declare (auto-focus TRUE))
  (initial-fact)
  =>
  (focus ComposicioMenus)
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
  (focus PreferenciesMenu))

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
  (assert (preguntat-tipus)))

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
  (assert (preguntat-data)))

(defrule PreferenciesMenu::preguntar-dinar-sopar 
  ?p <- (peticio (torn ?t&nil))
  (preguntat-data)
  (not (preguntat-dinar-sopar))
=>
  (bind ?r (valida-opcio "Serà dinar o sopar?" dinar sopar))
  (modify ?p (torn ?r))
  (assert (preguntat-dinar-sopar)))

(defrule PreferenciesMenu::preguntar-interior-exterior
  ?p <- (peticio (espai ?s&nil))
  (preguntat-dinar-sopar)
  (not (preguntat-interior-exterior))
=>
  (bind ?r (valida-opcio "Es farà en interior o exterior?" interior exterior))
  (modify ?p (espai ?r))
  (assert (preguntat-interior-exterior)))

; MODIFICAR LÍMIT MÀXIM
(defrule PreferenciesMenu::preguntar-num-comensals
  ?p <- (peticio (num-comensals ?n&nil))
  (preguntat-interior-exterior)
  (not (preguntat-num-comensals))
=>
  (bind ?r (valida-num "Quants comensals assistiran aproximadament?" 1 5000))
  (modify ?p (num-comensals ?r))
  (assert (preguntat-num-comensals)))

(defrule PreferenciesMenu::preguntar-pressupost-min
  ?p <- (peticio (pressupost-min ?ppmin&nil))
  (preguntat-num-comensals)
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
  (assert (preguntat-pressupost)))

(defrule PreferenciesMenu::preguntar-formalitat
  ?p <- (peticio (formalitat ?f&nil))
  (preguntat-pressupost-max)
  (not (preguntat-formalitat))
=>
  (bind ?r (valida-opcio "Quin grau de formalitat vols? (formal/ informal)" 
            informal formal))
  (modify ?p (formalitat ?r))
  (assert (preguntat-formalitat)))

(defrule PreferenciesMenu::preguntar-beguda-general
  ?p <- (peticio (beguda-mode ?bm&nil))
  (preguntat-formalitat)
  (not (preguntat-beguda-general))
=>
  (bind ?r (valida-opcio "Beguda per a tot el menú o per a cada plat? (general/per-plat)" general per-plat))
  (modify ?p (beguda-mode ?r))
  (assert (preguntat-beguda-general)))

(defrule PreferenciesMenu::preguntar-alcohol
  ?p <- (peticio (alcohol ?a&nil))
  (preguntat-beguda-general)
  (not (preguntat-alcohol))
=>
  (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques? (sí/no)"))
  (modify ?p (alcohol ?r))
  (assert (preguntat-alcohol)))

(defrule PreferenciesMenu::preguntar-menu-unic
  ?p <- (peticio (menu-mode ?mm&nil))
  (preguntat-alcohol)
  (not (preguntat-menu-unic))
=>
  (bind ?r (valida-opcio "Vols un menú únic per a tothom o opcions alternatives? (unic/alternatiu)" unic alternatiu))
  (modify ?p (menu-mode ?r))
  (assert (preguntat-menu-unic)))

(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
  (preguntat-menu-unic)
  (not (preguntat-alergens-prohibits))
=>
  (bind ?r (valida-boolea "Hi ha al·lèrgies o ingredients prohibits? (sí/no)"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits)))

(defrule PreferenciesMenu::detallar-alergens
  ?p <- (peticio (alergies-si ?r&:(or (eq ?r "si") (eq ?r "sí"))) (alergens ?al&nil))
  (preguntat-alergens-prohibits)
  (not (alergens-detalats))
=>
  (printout t "Indica'ls separats per espais (ex: gluten marisc lactosa): " crlf)
  (bind ?txt (lowcase (readline)))
  (modify ?p (alergens ?txt))
  (assert (alergens-detalats)))

(defrule PreferenciesMenu::finalitzar-preguntes
  (not (respostes-completes))
  (preguntat-alergens-prohibits)
  ?p <- (peticio (alergies-si ?r&~nil))
=>
  (assert (respostes-completes)))

;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))

;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))

; VEURE A QUIN MODUL IMPORTAR-HO
(defmodule ComposicioMenus (import MAIN ?ALL)(import PreferenciesMenu ?ALL)(export ?ALL))

(defrule ComposicioMenus::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
=>
  (bind ?primers (find-all-instances ((?p Plat)) (member$ ordre-primer (send ?p get-te_ordre))))
  (bind ?segons (find-all-instances ((?p Plat)) (member$ ordre-segon (send ?p get-te_ordre))))
  (bind ?postres (find-all-instances ((?p Plat)) (member$ ordre-postres (send ?p get-te_ordre))))
  (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))
  (if (<= ?limit 0) then
    (printout t crlf "*** No s'han trobat menus per mostrar. ***" crlf)
   else
    (printout t crlf "Et proposem " ?limit " menus inicials:" crlf)
    (loop-for-count (?i 1 ?limit)
      (bind ?primer (nth$ ?i ?primers))
      (bind ?segon (nth$ ?i ?segons))
      (bind ?postre (nth$ ?i ?postres))
      (printout t crlf "*** Menu " ?i " ***" crlf)
      (printout t "  Entrant: " (send ?primer get-nom) crlf)
      (printout t "  Principal: " (send ?segon get-nom) crlf)
      (printout t "  Postres: " (send ?postre get-nom) crlf)))
  (assert (menus-presentats)))

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

; (defrule ComposicioMenus::calcula-preu-venta-menu)
