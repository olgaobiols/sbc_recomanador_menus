(defmodule MAIN (export ?ALL))

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
;   (slot menu-mode (type SYMBOL) (default nil))
  (slot alergies-si (type SYMBOL STRING) (default nil))
  (multislot alergens (type STRING SYMBOL)))

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

(deffunction valida-llista-numeros (?input ?min ?max) "Valida una llista de números separats per espais dins d'un rang concret. Retorna la llista com a multislot si és vàlida, sinó retorna nil."
    (bind ?resp_valida TRUE)
    (bind ?nums_input (explode$ ?input))
    (bind ?llista_validada (create$))
    (foreach ?x ?nums_input
        (if (numberp ?x) then
            (if (and (>= ?x ?min) (<= ?x ?max)) then
                (bind ?llista_validada (insert$ ?llista_validada (+ (length$ ?llista_validada) 1) ?x))
            else
                (bind ?resp_valida FALSE)
                (printout t "El valor " ?x " està fora del rang (" ?min " - " ?max ")." crlf)
            )
        else
            (bind ?resp_valida FALSE)
            (printout t "El valor '" ?x "' no és un número vàlid." crlf)
        )
    )
    
    (if ?resp_valida then
        (return ?llista_validada)
    else
        (return nil)
    )
)

(deffunction mapa-alergens (?nums)
    (bind ?result (create$))
    (foreach ?n ?nums
        (bind ?val (integer ?n))
        (bind ?nom
        (if (eq ?val 1) then "Gluten"
        else (if (eq ?val 2) then "Lactosa"
        else (if (eq ?val 3) then "Fruits secs"
        else (if (eq ?val 4) then "Marisc"
        else (if (eq ?val 5) then "Ous"
        else (if (eq ?val 6) then "Soja"
        else (if (eq ?val 7) then "Peix"
        else (if (eq ?val 8) then "Vegetarià"
        else (if (eq ?val 9) then "Vegà"
        else (if (eq ?val 10) then "Halal"
        else nil)))))))))))
        (if (neq ?nom nil) then
        (bind ?result (create$ $?result ?nom))
        )
    )
  ?result
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
  =>
  (printout t "Benvingut/da al recomanador de menús RicoRico!" crlf)
  (printout t "Si us plau respon a les preguntes següents per personalitzar les propostes." crlf)
  (assert (peticio))
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

; (defrule PreferenciesMenu::preguntar-menu-unic
;   ?p <- (peticio (menu-mode ?mm&nil))
;   (preguntat-alcohol)
;   (not (preguntat-menu-unic))
; =>
;   (bind ?r (valida-opcio "Vols un menú únic per a tothom o opcions alternatives? (unic/alternatiu)" unic alternatiu))
;   (modify ?p (menu-mode ?r))
;   (assert (preguntat-menu-unic)))

(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
;   (preguntat-menu-unic)
    (preguntat-alcohol)
    (not (preguntat-alergens-prohibits))
  =>
  (bind ?r (valida-boolea "Hi ha alguna condició alimentària general? (al·lèrgies, dietes especials o ingredients prohibits)? (sí/no)"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits)))

(defrule PreferenciesMenu::detallar-alergens
  ?p <- (peticio (alergies-si si))  
  (preguntat-alergens-prohibits)
  (not (alergens-detallats))
=>
  (printout t crlf "Llista d’al·lèrgens o ingredients prohibits habituals:" crlf)
  (printout t "--------------------------------------" crlf)
  (printout t "Al·lèrgens:" crlf)
  (printout t "1. Gluten" crlf)
  (printout t "2. Lactosa" crlf)
  (printout t "3. Fruits secs" crlf)
  (printout t "4. Marisc" crlf)
  (printout t "5. Ous" crlf)
  (printout t "6. Soja" crlf)
  (printout t "7. Peix" crlf crlf)
  (printout t "Dietes especials:" crlf)
  (printout t "8. Vegetarià" crlf)
  (printout t "9. Vegà" crlf)
  (printout t "10. Halal" crlf)

  (bind ?validat FALSE)
  (while (not ?validat)
    (printout t "Indica els números corresponents separats per espais (ex: 1 3 8): " crlf)
    (bind ?input (readline))
    (bind ?nums (valida-llista-numeros ?input 1 10))
    (if (neq ?nums nil) then
      (bind ?validat TRUE)
      (bind ?noms (mapa-alergens ?nums))
      (modify ?p (alergens ?noms))
      (assert (alergens-detallats))
      (printout t "Has indicat: " ?noms crlf)
    else
      (printout t " Si us plau introdueix només números entre 1 i 10 separats per espais." crlf)
    )
  )
)

(defrule PreferenciesMenu::finalitzar-preguntes
  (not (respostes-completes))
  (preguntat-alergens-prohibits)
  ?p <- (peticio (alergies-si ?r&~nil))
=>
  (assert (respostes-completes))
  (focus AbstraccioHeuristica))

;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(deftemplate plat-valid-final (slot nom))   ; Nom del plat que passa totes les restriccions
(deftemplate plat-valid-temp (slot nom))          ;; Nom del plat que passa la restricció de temperatura
(deftemplate plat-valid-formal (slot nom))
(deftemplate plat-valid-complexitat (slot nom))
(deftemplate plat-valid-event
   (slot nom))
(deftemplate plat-valid-dispo (slot nom))
(deftemplate preu-venta (slot nom (type STRING SYMBOL)) (slot valor (type FLOAT)))


(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(defrule AbstraccioHeuristica::filtrar-plats-per-temperatura
   ?p <- (peticio (data ?estacio))
   ?plat <- (object (is-a Plat)
           (nom ?nom)
           (temperatura ?temp)
           (te_ordre $?ordres))
   =>
   (if (member$ ordre-postres ?ordres) ; les postres passen sempre
      then
         (assert (plat-valid-temp (nom ?nom)))
      else
         (if (or
              (and (or (eq ?estacio primavera) (eq ?estacio estiu))
                   (or (eq ?temp "Fred") (eq ?temp "Tebi")))
              (and (or (eq ?estacio tardor) (eq ?estacio hivern))
                   (or (eq ?temp "Calent") (eq ?temp "Tebi"))))
            then
               (assert (plat-valid-temp (nom ?nom)))
         )
   )
)

(defrule AbstraccioHeuristica::filtrar-plats-per-formalitat
    ?p <- (peticio (formalitat ?f))
    ?plat <- (object (is-a Plat)
              (nom ?nom)
              (formalitat ?form))
=>
    (if (or
         (and (eq ?f formal) (eq ?form "formal"))
         (and (eq ?f informal) (eq ?form "informal")))
      then 
        (assert (plat-valid-formal (nom ?nom)))
    )
)

(defrule AbstraccioHeuristica::filtrar-complexitat-per-num-comensals
    ?p <- (peticio (num-comensals ?n))
    ?plat <- (object (is-a Plat) (nom ?nom) (complexitat ?cx))
=>
    (if (or
        (and (<= ?n 50) (or (eq ?cx alta) (eq ?cx mitjana) (eq ?cx baixa)))
        (and (> ?n 50) (<= ?n 150) (or (eq ?cx mitjana) (eq ?cx baixa)))
        (and (> ?n 150) (eq ?cx baixa)))
      then 
        (assert (plat-valid-complexitat (nom ?nom)))
    )
)

(defrule AbstraccioHeuristica::filtrar-postres-per-esdeveniment
  (peticio (tipus-esdeveniment ?ev))
  ?plat <- (object (is-a Plat) (nom ?nom) (apte_esdeveniment ?apt) (te_ordre $?ordres))
=>
  (if (member$ ordre-postres ?ordres)
      then
        ; És un postre: aplica la lògica d’esdeveniment
        (if (or
              (and (eq ?ev casament)   (eq ?apt casament))     ; boda → pastís apte per casament
              (and (eq ?ev aniversari) (eq ?apt aniversari))   ; aniversari → postre apte per aniversari
              (and (not (or (eq ?ev casament) (eq ?ev aniversari)))
                   (eq ?apt tots))                            ; resta d’esdeveniments → només “tots”
             )
          then
            (assert (plat-valid-event (nom ?nom)))
        )
      else
        ; No és postre: no apliquem cap filtre d’esdeveniment, passa
        (assert (plat-valid-event (nom ?nom)))
  )
)

(defrule AbstraccioHeuristica::final-abstraccio
   (declare (auto-focus TRUE))
   (not (plat-pendent-temp))  ;; o alguna condició que indica que ja ha acabat
   =>
   (printout t ">> Final Abstracció: canviant focus a Associació" crlf)
   (focus AssociacioHeuristica)
)


;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))

(defrule AssociacioHeuristica::filtrar-plats-per-disponibilitat
  (peticio (data ?estacio))   ; primavera / estiu / tardor / hivern
  ?p <- (object (is-a Plat) (nom ?nom) (disponibilitat_plats $?dispo))
  (test (member$ ?estacio (create$ $?dispo)))
  =>
  (assert (plat-valid-dispo (nom ?nom)))
)

(defrule AssociacioHeuristica::final-associacio
   (declare (auto-focus TRUE))
   (not (plat-pendent-formalitat))
   =>
   (printout t ">> Final Associació: canviant focus a Refinament" crlf)
   (focus RefinamentHeuristica)
)

;; Declaració anticipada del mòdul de composició per permetre la importació des del refinament
(defmodule ComposicioMenus (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))

(defrule RefinamentHeuristica::calcular-preu-venta
  (peticio (formalitat ?form))
  ?p <- (object (is-a Plat)
           (nom ?nom)
           (te_ordre $?ordres)
           (complexitat ?comp)
           (mida_racio ?mida)
           (disponibilitat_plats $?dispo_plats)
           (preu_cost ?pc&:(> ?pc 0)))
  (not (preu-venta (nom ?nom)))
=>
  ;; Factors
  (bind ?Fcx  (if   (or (eq ?comp alta) (eq ?comp "alta")) then 1.35
               else (if (or (eq ?comp mitjana) (eq ?comp "mitjana")) then 1.15 else 1.0)))

  (bind ?Ffor (if   (or (eq ?form formal) (eq ?form "formal")) then 1.30 else 1.0))

  (bind ?Fmd  (if (or (eq ?mida gran) (eq ?mida "gran")) then 1.10
            else (if (or (eq ?mida petita) (eq ?mida "petita")) then 0.90 else 1.0)))

  ;; Factor de disponibilitat basat en el nombre d'estacions disponibles
  (bind ?n (length$ ?dispo_plats))
  (bind ?Fdis (if (>= ?n 4) then 1.00
             else (if (eq ?n 3) then 1.05
             else (if (eq ?n 2) then 1.10
             else (if (eq ?n 1) then 1.20 
             else 1.00)))))

  ;; Càlcul
  (bind ?mult (* ?Fcx ?Ffor ?Fmd ?Fdis))
  (bind ?pv   (* ?pc ?mult))

  ;; Determinar ordre principal del plat per ajustar mínims
  (bind ?tipus
        (if (member$ ordre-primer ?ordres) then primer
        else (if (member$ ordre-segon ?ordres) then segon
        else (if (member$ ordre-postres ?ordres) then postres else desconegut))))

  ;; Preus mínims segons ordre
  (if (or (eq ?tipus primer) (eq ?tipus "primer")) then (bind ?pv (max ?pv 5.50)))
  (if (or (eq ?tipus segon)  (eq ?tipus "segon"))  then (bind ?pv (max ?pv 9.00)))
  (if (or (eq ?tipus postres)(eq ?tipus "postres"))then (bind ?pv (max ?pv 3.00)))

  ;; Arrodonir i asserta
  (bind ?pv (/ (round (* ?pv 100)) 100.0))
  (assert (preu-venta (nom ?nom) (valor ?pv)))
)

(deftemplate plat-valid-pressupost (slot nom))
(defrule RefinamentHeuristica::filtrar-plats-per-pressupost
  (peticio (pressupost-min ?pmin) (pressupost-max ?pmax))
  (preu-venta (nom ?nom) (valor ?pv))
=>
  (bind ?min-plat (/ ?pmin 3.0)) ; per assegurar que hi ha pressupost per a 3 plats
  (bind ?max-plat (/ ?pmax 3.0))
  (if (and (>= ?pv ?min-plat) (<= ?pv ?max-plat)) then
      (assert (plat-valid-pressupost (nom ?nom)))))

(defrule RefinamentHeuristica::combinar-validacions
    (plat-valid-temp (nom ?nom))
    (plat-valid-formal (nom ?nom))
    (plat-valid-complexitat (nom ?nom))
    (plat-valid-event (nom ?nom)) 
    (plat-valid-dispo (nom ?nom))
    (plat-valid-pressupost (nom ?nom))
    =>
    (assert (plat-valid-final (nom ?nom)))
)

(defrule RefinamentHeuristica::final-refinament
   (declare (auto-focus TRUE))
   (not (plat-pendent-pressupost))
   =>
   (printout t ">> Final Refinament: canviant focus a Composició" crlf)
   (focus ComposicioMenus)
)

;; PAS 5: COMPOSICIÓ DE MENÚS -------------------------------
(defrule ComposicioMenus::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
  =>
  ;; Recollim noms finals vàlids
  (bind ?plats-valids (find-all-facts ((?f plat-valid-final)) TRUE))
  (bind ?noms-valids (create$))
  (foreach ?f ?plats-valids
     (bind ?noms-valids (create$ $?noms-valids (fact-slot-value ?f nom)))
  )

  ;; Busquem plats per ordre
  (bind ?primers (find-all-instances
               ((?p Plat))
               (and (member$ ordre-primer (send ?p get-te_ordre))
                  (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?segons (find-all-instances
               ((?p Plat))
               (and (member$ ordre-segon (send ?p get-te_ordre))
                  (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?postres (find-all-instances
               ((?p Plat))
               (and (member$ ordre-postres (send ?p get-te_ordre))
                  (member$ (send ?p get-nom) ?noms-valids))))

  (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))

  (if (<= ?limit 0) then
     (printout t crlf "*** No s'han trobat menus per mostrar dins del pressupost. ***" crlf)
   else
     (printout t crlf "Et proposem " ?limit " menus dins del pressupost:" crlf)
     (loop-for-count (?i 1 ?limit)
      (bind ?pr  (nth$ ?i ?primers))
      (bind ?sg  (nth$ ?i ?segons))
      (bind ?po  (nth$ ?i ?postres))
      (bind ?npr (send ?pr get-nom))
      (bind ?nsg (send ?sg get-nom))
      (bind ?npo (send ?po get-nom))

      ;; busca preu-venta de cada plat
      (bind ?ppr (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npr))) valor))
      (bind ?psg (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?nsg))) valor))
      (bind ?ppo (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npo))) valor))

      (bind ?total (+ ?ppr ?psg ?ppo))

      (printout t crlf "*** Menu " ?i " ***" crlf)
      (printout t "  Entrant:   " ?npr "  [" ?ppr " €]" crlf)
      (printout t "  Principal: " ?nsg "  [" ?psg " €]" crlf)
      (printout t "  Postres:   " ?npo "  [" ?ppo " €]" crlf)
      (printout t "  ----------------------------------------------------------------------" crlf)
      (printout t "  TOTAL per persona: " ?total " €" crlf)
     )
  )
  (assert (menus-presentats))
)
