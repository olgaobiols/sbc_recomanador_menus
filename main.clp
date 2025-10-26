(defmodule MAIN (export ?ALL))

(deftemplate peticio
  (slot tipus-esdeveniment (type SYMBOL) (default nil))
  (slot data (type SYMBOL) (default nil))
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

; --- Helpers de cadenes ---

(deffunction trim (?s)
  (bind ?len (str-length ?s))
  (if (<= ?len 0) then (return ""))
  (bind ?start 1)
  (bind ?end ?len)
  ; ltrim: espai o tab
  (while (and (<= ?start ?end)
              (or (eq (sub-string ?start ?start ?s) " ")
                  (eq (sub-string ?start ?start ?s) "\t")))
    (bind ?start (+ ?start 1)))
  ; rtrim: espai o tab
  (while (and (>= ?end ?start)
              (or (eq (sub-string ?end ?end ?s) " ")
                  (eq (sub-string ?end ?end ?s) "\t")))
    (bind ?end (- ?end 1)))
  (if (< ?start 1) then (bind ?start 1))
  (if (< ?end ?start) then (return ""))
  (return (sub-string ?start ?end ?s))
)

(deffunction str-trim-lower (?s)
  (lowcase (trim ?s))
)

(deffunction string->ue14-sym (?s)
  (bind ?x (str-trim-lower ?s))
  (if (eq ?x "gluten") then (return gluten))
  (if (or (eq ?x "llet") (eq ?x "lactosa")) then (return llet))
  (if (or (eq ?x "ou") (eq ?x "ous")) then (return ous))
  (if (eq ?x "peix") then (return peix))
  (if (or (eq ?x "crustaci") (eq ?x "crustacis")) then (return crustacis))
  (if (or (eq ?x "mollusc") (eq ?x "mol·lusc") (eq ?x "mol·luscs") (eq ?x "molluscs")) then (return molluscs))
  (if (or (eq ?x "fruits secs") (eq ?x "fruit sec") (eq ?x "ametlla") (eq ?x "avellana")
          (eq ?x "nou") (eq ?x "festuc") (eq ?x "anacard")) then (return fruits_secs))
  (if (or (eq ?x "cacauet") (eq ?x "cacauets") (eq ?x "peanut") (eq ?x "peanuts")) then (return cacauet))
  (if (eq ?x "soja") then (return soja))
  (if (eq ?x "api") then (return api))
  (if (eq ?x "mostassa") then (return mostassa))
  (if (or (eq ?x "sesam") (eq ?x "sèsam")) then (return sesam))
  (if (or (eq ?x "sulfit") (eq ?x "sulfits")) then (return sulfites))
  (if (or (eq ?x "tramussos") (eq ?x "tramús") (eq ?x "lupin")) then (return tramussos))
  (return nil)
)

; Converteix qualsevol valor d'al·lergen a SÍMBOL UE-14 o nil
(deffunction any->ue14-sym (?x)
  (if (symbolp ?x) then
    ; Ja és un símbol -> si és un dels UE-14, retorna'l; si no, nil
    (if (member$ ?x (create$ gluten llet ous peix crustacis molluscs fruits_secs cacauet soja api mostassa sesam sulfites tramussos))
        then ?x else nil)
  else
    ; Assumeix string o número -> passa per string->ue14-sym
    ; Coerció segura a string
    (string->ue14-sym (str-cat ?x)))

)


; Normalitza una llista heterogènia d'al·lèrgens (strings/símbols/números) → llista de SÍMBOLS UE-14 (sense duplicats)
(deffunction normalize-alergen-list ($?xs)
  (bind ?OUT (create$))
  (foreach ?x ?xs
    (bind ?s (any->ue14-sym ?x))
    (if (and ?s (not (member$ ?s ?OUT))) then
      (bind ?OUT (create$ $?OUT ?s))))
  (return ?OUT)
)


; --- Necessari abans de parse-alergens-resposta ---
(deffunction ue14-num->sym (?n)
  (if (eq ?n 1) then gluten
  else (if (eq ?n 2) then llet
  else (if (eq ?n 3) then ous
  else (if (eq ?n 4) then peix
  else (if (eq ?n 5) then crustacis
  else (if (eq ?n 6) then molluscs
  else (if (eq ?n 7) then fruits_secs
  else (if (eq ?n 8) then cacauet
  else (if (eq ?n 9) then soja
  else (if (eq ?n 10) then api
  else (if (eq ?n 11) then mostassa
  else (if (eq ?n 12) then sesam
  else (if (eq ?n 13) then sulfites
  else (if (eq ?n 14) then tramussos
  else nil)))))))))))))))

; ---------- Ajuda d’entrada d’al·lèrgens i dietes ----------

(deffunction print-alergens-ajuda ()
  (printout t crlf
    "Indica els al·lèrgens a evitar. Pots escriure NÚMEROS o NOMS, separats per espais o comes." crlf
    "  1  Gluten" crlf
    "  2  Llet" crlf
    "  3  Ous" crlf
    "  4  Peix" crlf
    "  5  Crustacis" crlf
    "  6  Mol·luscs" crlf
    "  7  Fruits secs" crlf
    "  8  Cacauet" crlf
    "  9  Soja" crlf
    " 10  Api" crlf
    " 11  Mostassa" crlf
    " 12  Sèsam" crlf
    " 13  Sulfits" crlf
    " 14  Tramussos" crlf
    "Exemples:  '2 7'  |  'llet, fruits secs'  |  'gluten sèsam 14'." crlf crlf))

; Converteix una resposta d’usuari (nums i/o noms) -> llista de símbols UE-14
(deffunction parse-alergens-resposta (?line)
  (bind ?clean (lowcase (trim (str-replace (str-replace ?line "," " ") ";" " "))))
  (if (eq ?clean "") then (return (create$)))
  (bind ?tokens (explode$ ?clean))
  (bind ?OUT (create$))
  (foreach ?tk ?tokens
    (if (integerp ?tk) then
      (bind ?sym (ue14-num->sym (integer ?tk)))
      (if (neq ?sym nil) then (bind ?OUT (create$ $?OUT ?sym))))
    (if (not (integerp ?tk)) then
      (bind ?sym2 (string->ue14-sym ?tk))
      (if (neq ?sym2 nil) then (bind ?OUT (create$ $?OUT ?sym2))))
  )
  ; dedup
  (bind ?RES (create$))
  (foreach ?a ?OUT (if (not (member$ ?a ?RES)) then (bind ?RES (create$ $?RES ?a))))
  ?RES
)

; ============================================================
; GRUPS DE RESTRICCIONS (dieta + al·lèrgens + altres + quantitat)
; ============================================================
(deftemplate grup-restriccio
  (slot id             (type INTEGER) (default 1))
  (slot nom            (type STRING)  (default ""))
  (slot quantitat      (type INTEGER) (default 0))
  (multislot dieta     (type SYMBOL)
                       (allowed-symbols cap vega vegetaria halal kosher)
                       (default cap))
  (slot alergia-mode   (type SYMBOL)
                       (allowed-symbols unificat per-alergia)
                       (default unificat))
  (multislot alergens  (type SYMBOL)
                       (allowed-symbols
                         gluten llet ous peix crustacis molluscs fruits_secs
                         cacauet soja api mostassa sesam sulfites tramussos))
  (slot estat          (type SYMBOL) (allowed-symbols pendent validat) (default pendent))
)



; Fets de control per recollir N grups
(deftemplate num-grups (slot total (type INTEGER)))
(deftemplate grup-pendent (slot id (type INTEGER)))
(deftemplate menus-presentats-grup (slot gid (type INTEGER)))
(deftemplate imprimir-grup (slot id (type INTEGER)))

; ============================================================
; RESULTATS INTERMEDIS PER GRUP (nous)
; ============================================================
(deftemplate plat-valid-alergen (slot nom) (slot gid (type INTEGER)))
(deftemplate plat-valid-dieta   (slot nom) (slot gid (type INTEGER)))
(deftemplate plat-valid-final-grup (slot nom) (slot gid (type INTEGER)))

(deftemplate beguda-valida-alergen (slot nom) (slot gid (type INTEGER)))
(deftemplate beguda-valida-dieta (slot nom) (slot gid (type INTEGER)))
(deftemplate beguda-valida-final-grup (slot nom) (slot gid (type INTEGER)))

(deftemplate plat-valid-final (slot nom))   ; Nom del plat que passa totes les restriccions
(deftemplate plat-valid-temp (slot nom))          ;; Nom del plat que passa la restricció de temperatura
(deftemplate plat-valid-formal (slot nom))
(deftemplate plat-valid-complexitat (slot nom))
(deftemplate plat-valid-event (slot nom))
(deftemplate plat-valid-dispo (slot nom))
(deftemplate preu-venta (slot nom (type STRING SYMBOL)) (slot valor (type FLOAT)))
(deftemplate plat-amb-ingredients (slot nom))

(deftemplate beguda-valida-alcohol (slot nom))
(deftemplate beguda-valida-formal (slot nom))
(deftemplate beguda-valida-final (slot nom))

; --- Normalització d'etiquetes de dieta a símbols canònics ---
(deffunction diet-token->sym (?x)
  (bind ?s (if (symbolp ?x) then (lowcase (str-cat ?x)) else (lowcase (trim (str-cat ?x)))))
  (if (or (eq ?s "v") (eq ?s "vegetaria") (eq ?s "vegetari") (eq ?s "vegetarian") (eq ?s "vegetariana")) then (return V))
  (if (or (eq ?s "vg") (eq ?s "vega") (eq ?s "vegà") (eq ?s "vegà") (eq ?s "vegan") (eq ?s "vegana")) then (return VG))
  (if (or (eq ?s "halal") (eq ?s "halal_pot") (eq ?s "halal-pot")) then (return HALAL_POT))
  (if (or (eq ?s "kosher") (eq ?s "kosher_pot") (eq ?s "kosher-pot")) then (return KOSHER_POT))
  (return nil))

(deffunction normalize-dieta-list ($?tags)
  (bind ?OUT (create$))
  (foreach ?t ?tags
    (bind ?sym (diet-token->sym ?t))
    (if (and ?sym (not (member$ ?sym ?OUT))) then
      (bind ?OUT (create$ $?OUT ?sym))))
  ?OUT)


(deffunction ingredient-apte-dieta (?diet ?dietes-ing)
  ; Accepta strings o símbols dins ?dietes-ing i els normalitza a {V, VG, HALAL_POT, KOSHER_POT}
  (if (or (eq ?diet cap) (eq ?diet indiferent)) then (return TRUE))

  (bind $?norm (normalize-dieta-list $?dietes-ing))

  ; Si l'ingredient NO porta etiquetes de dieta, no el tombem (mode “lax”)
  (if (= (length$ $?norm) 0) then (return TRUE))

  (if (eq ?diet vega)       then (return (member$ VG (create$ $?norm))))
  (if (eq ?diet vegetaria)  then (return (or (member$ V (create$ $?norm))
                                             (member$ VG (create$ $?norm)))))
  (if (eq ?diet halal)      then (return (member$ HALAL_POT (create$ $?norm))))
  (if (eq ?diet kosher)     then (return (member$ KOSHER_POT (create$ $?norm))))

  FALSE)

(deffunction noms-plats-valids-base ()
  (bind ?out (create$))
  (foreach ?f (find-all-facts ((?fv plat-valid-final)) TRUE)
    (bind ?out (create$ $?out (fact-slot-value ?f nom))))
  ?out)

(deffunction noms-candidats-ordre (?ordre-sym)
  (bind $?base (noms-plats-valids-base))
  (bind ?res (create$))
  (foreach ?p (find-all-instances ((?pl Plat))
                (and (member$ ?ordre-sym (send ?pl get-te_ordre))
                     (member$ (send ?pl get-nom) $?base)))
    (bind ?res (create$ $?res (send ?p get-nom))))
  ?res)

; Helper: cerca l’objecte Ingredient pel seu nom (string)
(deffunction ingredient-by-name (?nom-str)
  (bind ?needle (lowcase (trim ?nom-str)))
  (bind ?cand (find-all-instances ((?i Ingredient))
               (or
                 (eq (send ?i get-nom) ?nom-str)
                 (eq (lowcase (trim (send ?i get-nom))) ?needle))))
  (if (> (length$ ?cand) 0)
      then (return (nth$ 1 ?cand))
      else (return FALSE)))

(deffunction preu-plat-by-name (?nom)
  (bind ?ff (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?nom)))
  (if (> (length$ ?ff) 0)
      then (fact-slot-value (nth$ 1 ?ff) valor)
      else 0.0))

(deffunction sum-preu-begudes ($?noms)
  (bind ?s 0.0)
  (foreach ?b ?noms
    (bind ?insts (find-all-instances ((?x Beguda)) (eq (send ?x get-nom) ?b)))
    (if (> (length$ ?insts) 0)
        then (bind ?s (+ ?s (send (nth$ 1 ?insts) get-preu_cost)))))
  ?s)

(deffunction budget-ok (?total)
  (bind ?p (nth$ 1 (find-all-facts ((?x peticio)) TRUE)))
  (bind ?pmin (fact-slot-value ?p pressupost-min))
  (bind ?pmax (fact-slot-value ?p pressupost-max))
  (and (or (eq ?pmin indiferent) (<= ?pmin ?total))
       (or (eq ?pmax indiferent) (>= ?pmax ?total))))


; Retorna TRUE si el PLAT (?platNom) és apte per al GRUP ?gid
; Criteri:
;  - Si el grup té al·lèrgens i algun ingredient no té info d'al·lèrgens -> NO apte
;  - Si hi ha intersecció d'al·lèrgens -> NO apte
;  - Si el grup té dieta (≠ cap) i l'ingredient no porta etiquetes de dieta -> NO apte
;  - Si la dieta no és compatible amb l'ingredient -> NO apte

(deffunction plat-apte-per-grup (?platNom ?gid)
  (bind ?glist (find-all-facts ((?gr grup-restriccio))
                 (eq (fact-slot-value ?gr id) ?gid)))
  (if (<= (length$ ?glist) 0) then (return TRUE))
  (bind ?g (nth$ 1 ?glist))

  ;; AL·LÈRGENS del grup (multislot) i DIETA com a SÍMBOL (no multifield)
  (bind $?ALS (fact-slot-value ?g alergens))
  (bind ?dietMF (fact-slot-value ?g dieta))
  (bind ?diet   (if (multifieldp ?dietMF)
                    then (if (> (length$ ?dietMF) 0) then (nth$ 1 ?dietMF) else cap)
                    else ?dietMF))

  ;; Plat
  (bind ?pl (nth$ 1 (find-all-instances ((?p Plat))
                 (eq (send ?p get-nom) ?platNom))))
  (if (not ?pl) then (return TRUE))  ;; mode lax: si no trobem el plat, no tombem
  (bind $?ings (send ?pl get-te_ingredients_noms))

  (bind ?apte TRUE)
  (foreach ?ing ?ings
    (if ?apte then
      (bind ?I (ingredient-by-name ?ing))
      ;; mode lax: ingredient desconegut -> no tombem
      (if ?I then
        ;; --- Al·lèrgens / dieta de l'ingredient ?I ---
        (bind ?cls (class ?I))

        ;; al·lergen singular (si existeix el slot)
        (bind $?ialgs-slot
              (if (slot-existp ?cls alergen)
                  then
                    (bind ?val (send ?I get-alergen))
                    (if (lexemep ?val) then (create$ ?val) else (create$))
                  else
                    (create$)))

        ;; al·lergens en multislot (si existeix el slot)
        (bind $?ialgs-plu
              (if (slot-existp ?cls alergens)
                  then (send ?I get-alergens)
                  else (create$)))

        ;; combinem i normalitzem
        (bind $?ialgs-mixed (create$ $?ialgs-slot $?ialgs-plu))
        (bind $?ialgs_sym   (normalize-alergen-list $?ialgs-mixed))

        ;; col·lisió amb els al·lèrgens del grup?
        (foreach ?a $?ialgs_sym
          (if (and ?apte (member$ ?a (create$ $?ALS)))
              then (bind ?apte FALSE)))

        ;; --- Dieta (només tombem si hi ha etiquetes i són incompatibles) ---
        (if (and ?apte (neq ?diet cap)) then
          (bind $?diets-raw
                (if (slot-existp ?cls dietes)
                    then (send ?I get-dietes)
                    else (create$)))
          (bind $?diets (if (multifieldp $?diets-raw) then $?diets-raw else (create$)))
          (if (> (length$ (create$ $?diets)) 0) then
            (if (not (ingredient-apte-dieta ?diet $?diets))
                then (bind ?apte FALSE))))

      )
    )
  )
  ?apte
)




;; VALIDADORS DE RESPOSTES -------------------------------------------------
(deffunction valida-boolea "Valida sí/no/indiferent"
  (?prompt)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)
  (while (not ?resp_valida)
    (printout t ?prompt " (sí/no/indiferent): " crlf)
    (bind ?x (lowcase (readline)))
    (if (or (eq ?x "sí") (eq ?x "si") (eq ?x "s") (eq ?x "y") (eq ?x "yes")) then
        (bind ?resp_valida TRUE) (bind ?resp si)
    else
    (if (or (eq ?x "no") (eq ?x "n")) then
        (bind ?resp_valida TRUE) (bind ?resp no)
    else
    (if (eq ?x "indiferent") then
        (bind ?resp_valida TRUE) (bind ?resp indiferent)
    else
        (printout t "Respon 'sí', 'no' o 'indiferent'." crlf))))
 ) ?resp)


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

(deffunction valida-num-o-indif "Com valida-num però accepta 'indiferent'"
  (?prompt ?min ?max)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)
  (while (not ?resp_valida)
    (printout t ?prompt " (" ?min "-" ?max ", o 'indiferent'): " crlf)
    (bind ?raw (lowcase (readline)))
    (if (eq ?raw "indiferent") then
      (bind ?resp_valida TRUE)
      (bind ?resp indiferent)
    else
      ; Converteix la línia a camp CLIPS (pot ser nombre si és vàlid)
      (bind ?fld (string-to-field ?raw))
      (if (numberp ?fld) then
        ; Si és float, el passem a enter només per comparar/retornar enters
        (bind ?n (if (integerp ?fld) then ?fld else (integer ?fld)))
        (if (and (>= ?n ?min) (<= ?n ?max)) then
          (bind ?resp_valida TRUE)
          (bind ?resp ?n)
        else
          (printout t "Si us plau introdueix un valor dins del rang (" ?min " - " ?max ")." crlf))
      else
        (printout t "Introdueix un número vàlid o 'indiferent'." crlf))))
  ?resp)


(deffunction valida-opcio (?pregunta $?opcions)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)
  (while (not ?resp_valida)
    (printout t ?pregunta crlf)
    (bind ?input (string-to-field (lowcase (readline))))
    (if (eq ?input indiferent) then
        (bind ?resp_valida TRUE)
        (bind ?resp indiferent)
     else
      (if (member$ ?input ?opcions) then
        (bind ?resp_valida TRUE)
        (bind ?resp ?input)
       else
        (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))))
  ?resp)



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
  (printout t "Per a totes les preguntes tens l'opció de respondre 'indiferent' si encara no ho tens clar." crlf crlf)
  (assert (peticio))
  (focus PreferenciesMenu))

; PREGUNTES DE CONTEXT GENERAL DE L'ESDEVENIMENT
(defrule PreferenciesMenu::preguntar-tipus-esdeveniment
  (declare (auto-focus TRUE))
  ?p <- (peticio (tipus-esdeveniment ?te&nil))
  (not (preguntat-tipus))
=>
  (bind ?res (valida-opcio 
              "Quin tipus d’esdeveniment estàs organitzant? (casament/aniversari/comunio/congrés/empresa/altres)"
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
              "Quina època de l’any? (primavera/estiu/tardor/hivern)"
              primavera estiu tardor hivern))
  (modify ?p (data ?r))
  (assert (preguntat-data)))

(defrule PreferenciesMenu::preguntar-interior-exterior
  ?p <- (peticio (espai ?s&nil))
  (preguntat-data)
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
  (bind ?r (valida-num-o-indif "Quants comensals assistiran aproximadament?" 1 5000))
  (modify ?p (num-comensals ?r))
  (assert (preguntat-num-comensals)))

(defrule PreferenciesMenu::preguntar-pressupost-min
  ?p <- (peticio (pressupost-min ?ppmin&nil))
  (preguntat-num-comensals)
  (not (preguntat-pressupost))
=>
  (bind ?min (valida-num-o-indif "Quin és el pressupost mínim per persona?" 1 1000))
  (modify ?p (pressupost-min ?min))
  (assert (preguntat-pressupost-min)))

(defrule PreferenciesMenu::preguntar-pressupost-max
  ?p <- (peticio (pressupost-min ?min&~nil) (pressupost-max ?ppmax&nil))
  (preguntat-pressupost-min)
  (not (preguntat-pressupost-max))
=>
  (bind ?max (valida-num-o-indif "I quin és el pressupost màxim per persona?" 5 2000))
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
  (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques?"))
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
  (preguntat-alcohol)
  (not (preguntat-alergens-prohibits))
=>
  (bind ?r (valida-boolea
     "Vols definir grups amb dietes o al·lèrgies específiques?"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits))

  (if (eq ?r no) then
     (assert (respostes-completes))
     (focus AbstraccioHeuristica))
)


; ----------------------------------------------------------------
; 2A) Preguntar N GRUPS
; ----------------------------------------------------------------
(defrule PreferenciesMenu::preguntar-num-grups
  (declare (auto-focus TRUE))
  (peticio (alergies-si si))
  (not (num-grups))
=>
  (bind ?n (valida-num
    "Quants grups diferents amb dietes/al·lèrgies vols definir? (1-10)"
    1 10))
  (assert (num-grups (total ?n)))
  (assert (grup-pendent (id 1)))
)



; Text d’ajuda UE-14
(deffunction print-ue14-menu ()
  (printout t crlf "Llista d'al·lèrgens (UE-14). Escriu els números separats per espais:" crlf)
  (printout t "  1  Gluten      |  2  Llet (lactosa) |  3  Ous         |  4  Peix" crlf)
  (printout t "  5  Crustacis   |  6  Mol·luscs     |  7  Fruits secs |  8  Cacauet" crlf)
  (printout t "  9  Soja        | 10  Api           | 11  Mostassa    | 12  Sèsam" crlf)
  (printout t " 13  Sulfits     | 14  Tramussos" crlf)
  (printout t "Exemple: 2 7   o   'llet, fruits secs'" crlf crlf)
)

; ----------------------------------------------------------------
; 2B) Per a cada GRUP: nom, quantitat, dieta, mode i al·lèrgens
; ----------------------------------------------------------------
(defrule PreferenciesMenu::omplir-grup
  ?pend <- (grup-pendent (id ?gid))
  (num-grups (total ?tot))
=>
  (printout t crlf "=== Grup " ?gid " ===" crlf)

  (printout t "Nom del grup (opcional): " crlf)
  (bind ?nom (readline))

  (bind ?q (valida-num "Quants comensals té aquest grup?" 1 5000))

  ; DIETA
  (printout t crlf "Tria la DIETA del grup:" crlf
                "  cap / vegetaria / vega / halal / kosher" crlf)
  (bind ?diet (valida-opcio "Escriu l’opció:" cap vegetaria vega halal kosher))


  ; AL·LÈRGENS (nums o noms)
  (print-alergens-ajuda)
  (printout t "Escriu els al·lèrgens a evitar (números o noms), o deixa en blanc si cap:" crlf)
  (bind ?aline (readline))
  (bind ?al (parse-alergens-resposta ?aline))

  ; ASSEMBLATGE DEL GRUP (sense altres-ingredients)
  (assert (grup-restriccio
            (id ?gid)
            (nom ?nom)
            (quantitat ?q)
            (dieta ?diet)
            (alergia-mode unificat)
            (alergens $?al)
            (estat pendent)))

  ; RESUM
  (printout t crlf "Resum grup " ?gid ":" crlf
              "  Nom: " ?nom crlf
              "  Quantitat: " ?q crlf
              "  Dieta: " ?diet crlf
              "  Al·lèrgens: " (if (> (length$ ?al) 0) then ?al else "cap") crlf)

  ; següent o fi
  (retract ?pend)
  (if (< ?gid ?tot) then
      (assert (grup-pendent (id (+ ?gid 1))))
   else
      (assert (grups-definits)))
)



; ----------------------------------------------------------------
; 2C) Tancar fase de preguntes quan ja tenim tots els grups
; ----------------------------------------------------------------
(defrule PreferenciesMenu::finalitzar-preguntes-amb-grups
  (declare (auto-focus TRUE))
  (not (respostes-completes))
  (grups-definits)
=>
  (assert (respostes-completes))
  (focus AbstraccioHeuristica))


;; PAS 2: ABSTRACCIÓ HEURÍSTICA ------------------------------


(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(defrule AbstraccioHeuristica::indexar-plats-amb-ingredients
  ?p <- (object (is-a Plat) (nom ?np))
  =>
  (bind $?ings (send ?p get-te_ingredients_noms))
  (if (and (multifieldp ?ings) (> (length$ (create$ $?ings)) 0)) then
    (bind ?ok TRUE)
    (foreach ?ing ?ings
      (if (not (ingredient-by-name ?ing)) then (bind ?ok FALSE)))
    (if ?ok then
      (assert (plat-amb-ingredients (nom ?np)))))
)

(defrule AbstraccioHeuristica::filtrar-plats-per-temperatura
   ?p <- (peticio (data ?estacio) (espai ?espai))
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
                   (or (eq ?temp "fred") (eq ?temp "tebi")))
              (and (or (eq ?estacio primavera) (eq ?estacio estiu))
                   (eq ?temp "calent") (eq ?espai interior))
              (and (or (eq ?estacio tardor) (eq ?estacio hivern))
                   (or (eq ?temp "calent") (eq ?temp "tebi"))))
            then
               (assert (plat-valid-temp (nom ?nom)))
         )
   )
)
(defrule AbstraccioHeuristica::temp-indiferent
  (peticio (data indiferent))
  ?p <- (object (is-a Plat) (nom ?nom))
  =>
  (assert (plat-valid-temp (nom ?nom))))


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
(defrule AbstraccioHeuristica::formalitat-indiferent
  (peticio (formalitat indiferent))
  ?p <- (object (is-a Plat) (nom ?nom))
  =>
  (assert (plat-valid-formal (nom ?nom))))

(defrule AbstraccioHeuristica::filtrar-complexitat-per-num-comensals
    ?p <- (peticio (num-comensals ?n))
    (test (numberp ?n))
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


(defrule AbstraccioHeuristica::complexitat-indiferent
  (peticio (num-comensals indiferent))
  ?p <- (object (is-a Plat) (nom ?nom))
  =>
  (assert (plat-valid-complexitat (nom ?nom))))


(defrule AbstraccioHeuristica::filtrar-postres-per-esdeveniment
  (peticio (tipus-esdeveniment ?ev))
  ?plat <- (object (is-a Plat) (nom ?nom) (te_ordre $?ordres))
=>
  ;; A LA FASE BASE: tots els plats (incloent postres) passen l’event.
  ;; Ja validarem després per grups (i, si vols, també per esdeveniment).
  (assert (plat-valid-event (nom ?nom)))
)


(defrule AbstraccioHeuristica::filtrar-begudes-alcohol
   ?p <- (peticio (alcohol ?alc))
   ?b <- (object (is-a Beguda)
                 (nom ?nom)
                 (alcohol ?alcohol))
=>
   (if (or
         (and (eq ?alc si) (eq ?alcohol si))
         (and (eq ?alc no) (eq ?alcohol no)))
      then 
        (assert (beguda-valida-alcohol (nom ?nom)))
    )
)

(defrule AbstraccioHeuristica::filtrar-begudes-per-formalitat
  ?p <- (peticio (formalitat ?f))
  ?beguda <- (object (is-a Beguda)
                (nom ?nom)
                (formalitat $?form))
  =>
  (if (or
        (and (eq ?f formal)   (member$ "formal"   ?form))
        (and (eq ?f informal) (member$ "informal" ?form))
        (eq ?f indiferent)) ;; afegit per cobrir el cas "indiferent"
    then
      (assert (beguda-valida-formal (nom ?nom)))
  )
)


; ============================================================
; Abans dieta: marquem plats aptes d'al·lèrgens per grup
; ============================================================
(defrule AbstraccioHeuristica::filtrar-plats-per-alergens-grup
  (grup-restriccio (id ?gid) (alergens $?ALS))
  ?pl <- (object (is-a Plat) (nom ?np))
  (not (plat-valid-alergen (nom ?np) (gid ?gid)))
=>
  (bind ?restriccions (length$ (create$ $?ALS)))
  (bind $?ings (send ?pl get-te_ingredients_noms))
  (bind ?apte TRUE)

  (foreach ?ing ?ings
    (if ?apte then
      (bind ?I (ingredient-by-name ?ing))

      ; Ingredient inexistent → si hi ha restriccions, NO apte
      (if (not ?I) then
        (if (> ?restriccions 0) then (bind ?apte FALSE))
      else
        (bind ?ialgs-raw (send ?I get-alergens))
        (bind $?ialgs (if (multifieldp ?ialgs-raw) then ?ialgs-raw else (create$)))

        ; >>> CANVI CLAU: multifield buit == sense info → FAIL si hi ha restriccions
        (if (and (> ?restriccions 0) (= (length$ (create$ $?ialgs)) 0)) then
          (bind ?apte FALSE)
        else
          (bind $?ialgs_sym (normalize-alergen-list $?ialgs))
          (foreach ?a $?ialgs_sym
            (if (and ?apte (member$ ?a (create$ $?ALS))) then
              (bind ?apte FALSE)))
        )
      )
    )
  )

  (if ?apte then
    (assert (plat-valid-alergen (nom ?np) (gid ?gid))))
)

(defrule AbstraccioHeuristica::filtrar-begudes-per-alergens-grup
  (grup-restriccio (id ?gid) (alergens $?ALS))
  ?b <- (object (is-a Beguda) (nom ?nb))
  (not (beguda-valida-alergen (nom ?nb) (gid ?gid)))
=>
  (bind $?ialgs (send ?b get-alergens)) ; multislot d'al·lèrgens

  ; Comprovem si algun al·lèrgens de la beguda coincideix amb el grup
  (if (not (member$ $?ialgs $?ALS)) then
      (assert (beguda-valida-alergen (nom ?nb) (gid ?gid)))
  )
)

(defrule AbstraccioHeuristica::filtrar-begudes-per-dietes-grup
  (grup-restriccio (id ?gid) (dieta $?DIET))
  ?b <- (object (is-a Beguda) (nom ?nb))
  (not (beguda-valida-dieta (nom ?nb) (gid ?gid)))
=>
  (bind $?idiet (send ?b get-dietes)) ; multislot de dietes

  ; Comprovem si alguna dieta de la beguda coincideix amb el grup
  (if (not (member$ $?idiet $?DIET)) then
      (assert (beguda-valida-dieta (nom ?nb) (gid ?gid)))
  )
)


(defrule AbstraccioHeuristica::marcar-alergen-ok-si-cap
  "Si el grup no té cap al·lergen definit, tots els plats passen la fase d'al·lèrgens per a aquell grup."
  (grup-restriccio (id ?gid) (alergens $?ALS&:(= (length$ (create$ $?ALS)) 0)))
  ?pl <- (object (is-a Plat) (nom ?np))
  (not (plat-valid-alergen (nom ?np) (gid ?gid)))
=>
  (assert (plat-valid-alergen (nom ?np) (gid ?gid))))


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

(defrule AssociacioHeuristica::disponibilitat-indiferent
  (peticio (data indiferent))
  ?p <- (object (is-a Plat) (nom ?nom))
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


; ============================================================
; Després d'al·lèrgens: marquem plats aptes per dieta, per grup
; ============================================================
(defrule RefinamentHeuristica::filtrar-plats-per-dieta-grup
  (grup-restriccio (id ?gid) (dieta ?diet))
  (plat-valid-alergen (nom ?np) (gid ?gid))
  ?pl <- (object (is-a Plat) (nom ?np))
  (not (plat-valid-dieta (nom ?np) (gid ?gid)))
=>
  (bind ?ok TRUE)

  (if (neq ?diet cap) then
    (bind $?ings (send ?pl get-te_ingredients_noms))
    (foreach ?ing ?ings
      (if ?ok then
        (bind ?I (ingredient-by-name ?ing))
        (if (not ?I) then
          (bind ?ok FALSE)
        else
          (bind ?diets-raw (send ?I get-dietes))
          (bind $?diets (if (multifieldp ?diets-raw) then ?diets-raw else (create$)))

          ; >>> CANVI CLAU: multifield buit == sense info → FAIL
          (if (= (length$ (create$ $?diets)) 0) then
            (bind ?ok FALSE)
          else
            (if (not (ingredient-apte-dieta ?diet $?diets)) then
              (bind ?ok FALSE))
          )
        )
      )
    )
  )

  (if ?ok then
    (assert (plat-valid-dieta (nom ?np) (gid ?gid))))
)

; ; ============================================================
; ; COMBINE per GRUP: afegeix requisits de sempre + al·lergen+dieta per grup
; ; ============================================================
(defrule RefinamentHeuristica::combinar-validacions-per-grup
  (plat-amb-ingredients (nom ?nom))
  (plat-valid-temp (nom ?nom))
  (plat-valid-formal (nom ?nom))
  (plat-valid-complexitat (nom ?nom))
  (plat-valid-event (nom ?nom))
  (plat-valid-dispo (nom ?nom))
  (plat-valid-alergen (nom ?nom) (gid ?gid))
  (plat-valid-dieta (nom ?nom)   (gid ?gid))
=>
  (assert (plat-valid-final-grup (nom ?nom) (gid ?gid)))
)

(defrule RefinamentHeuristica::combinar-validacions-base
  (plat-amb-ingredients (nom ?nom)) 
  (plat-valid-temp (nom ?nom))
  (plat-valid-formal (nom ?nom))
  (plat-valid-complexitat (nom ?nom))
  (plat-valid-event (nom ?nom))
  (plat-valid-dispo (nom ?nom))
=>
  (assert (plat-valid-final (nom ?nom)))
)

(defrule RefinamentHeuristica::b-combinar-validacions-per-grup
  (beguda-valida-alcohol (nom ?nom))
  (beguda-valida-formal (nom ?nom))
  (beguda-valida-alergen (nom ?nom) (gid ?gid))
  (beguda-valida-dieta (nom ?nom) (gid ?gid))
=>
  (assert (beguda-valida-final-grup (nom ?nom) (gid ?gid)))
)

(defrule RefinamentHeuristica::b-combinar-validacions-base
  (beguda-valida-alcohol (nom ?nom))
  (beguda-valida-formal (nom ?nom))
=>
  (assert (beguda-valida-final (nom ?nom)))
)


(defrule RefinamentHeuristica::final-refinament
   (declare (auto-focus TRUE))
   (not (plat-pendent-pressupost))
   =>
   (printout t ">> Final Refinament: canviant focus a Composició" crlf)
   (focus ComposicioMenus)
)

; ============================================================
; MOSTRAR MENÚS PER GRUP
; ============================================================
(defrule ComposicioMenus::mostrar-menus-per-grup
  (declare (auto-focus TRUE))
  (respostes-completes)
  (menus-presentats)
  ?imp <- (imprimir-grup (id ?gid))
  (grup-restriccio (id ?gid) (nom ?gnom) (alergens $?ALS) (dieta ?diet))
  (not (menus-presentats-grup (gid ?gid)))
  (peticio (beguda-mode ?bm))
  =>
  ; Recollim noms finals vàlids per aquest grup
  (bind ?facts (find-all-facts ((?f plat-valid-final-grup)) (eq (fact-slot-value ?f gid) ?gid)))
  (bind ?noms-valids (create$))
  (foreach ?f ?facts
     (bind ?noms-valids (create$ $?noms-valids (fact-slot-value ?f nom))))

  ; Busquem plats per ordre
  (bind ?primers (find-all-instances ((?p Plat))
                 (and (member$ ordre-primer (send ?p get-te_ordre))
                      (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?segons  (find-all-instances ((?p Plat))
                 (and (member$ ordre-segon (send ?p get-te_ordre))
                      (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?postres (find-all-instances ((?p Plat))
                 (and (member$ ordre-postres (send ?p get-te_ordre))
                      (member$ (send ?p get-nom) ?noms-valids))))

  ; Recollim noms de begudes finals
  (bind ?begudes-valides (find-all-facts ((?bf beguda-valida-final-grup)) (eq (fact-slot-value ?bf gid) ?gid)))
  (bind ?b-noms-valids (create$))
  (foreach ?bf ?begudes-valides
     (bind ?b-noms-valids (create$ $?b-noms-valids (fact-slot-value ?bf nom)))
  )
  ; Busquem begudes per mode i ordre
  (if (eq ?bm general)
    then
      (bind ?b-generals (find-all-instances ((?b Beguda))
                      (and (eq (send ?b get-es_general) si)
                           (member$ (send ?b get-nom) ?b-noms-valids))))
    else 
      (bind ?b-primers (find-all-instances ((?b Beguda))
                      (and (eq (send ?b get-maridatge) ordre-primer)
                           (member$ (send ?b get-nom) ?b-noms-valids))))
      (bind ?b-segons (find-all-instances ((?b Beguda))
                      (and (eq (send ?b get-maridatge) ordre-segon)
                           (member$ (send ?b get-nom) ?b-noms-valids))))
      (bind ?b-postres (find-all-instances ((?b Beguda))
                       (and (eq (send ?b get-maridatge) ordre-postres)
                            (member$ (send ?b get-nom) ?b-noms-valids))))
  )
  
  ;; LÍMIT DE MENÚS (pel menjar)
  (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))

  (printout t crlf "=== Menús per al grup " ?gid " (" ?gnom ") ===" crlf)

  (if (<= ?limit 0) then
     (printout t "*** No hi ha prou plats aptes amb aquestes restriccions. ***" crlf)
   else
     (loop-for-count (?i 1 ?limit)
       (bind ?pr (nth$ ?i ?primers))
       (bind ?sg (nth$ ?i ?segons))
       (bind ?po (nth$ ?i ?postres))

       ;; Begudes: només si existeixen per a l'índex
       (if (eq ?bm general)
         then
           (if (<= ?i (length$ ?b-generals))
               then (bind ?bg (nth$ ?i ?b-generals))
               else (bind ?bg FALSE))
         else
           (if (<= ?i (length$ ?b-primers)) then (bind ?bpr (nth$ ?i ?b-primers)) else (bind ?bpr FALSE))
           (if (<= ?i (length$ ?b-segons))  then (bind ?bsg (nth$ ?i ?b-segons))   else (bind ?bsg FALSE))
           (if (<= ?i (length$ ?b-postres)) then (bind ?bpo (nth$ ?i ?b-postres))  else (bind ?bpo FALSE))
       )

       (bind ?npr (send ?pr get-nom))
       (bind ?nsg (send ?sg get-nom))
       (bind ?npo (send ?po get-nom))

       (if (eq ?bm general)
         then (bind ?nbg (if ?bg then (send ?bg get-nom) else "--"))
         else
           (bind ?nbpr (if ?bpr then (send ?bpr get-nom) else "--"))
           (bind ?nbsg (if ?bsg then (send ?bsg get-nom) else "--"))
           (bind ?nbpo (if ?bpo then (send ?bpo get-nom) else "--"))
       )

       ;; Preus dels plats
       (bind ?ppr (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta))
                       (eq (fact-slot-value ?f nom) ?npr))) valor))
       (bind ?psg (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta))
                       (eq (fact-slot-value ?f nom) ?nsg))) valor))
       (bind ?ppo (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta))
                       (eq (fact-slot-value ?f nom) ?npo))) valor))

       ;; Preus de beguda si existeixen; si no, 0
       (if (eq ?bm general)
         then (bind ?pbg (if ?bg then (send ?bg get-preu_cost) else 0))
         else
           (bind ?pbpr (if ?bpr then (send ?bpr get-preu_cost) else 0))
           (bind ?pbsg (if ?bsg then (send ?bsg get-preu_cost) else 0))
           (bind ?pbpo (if ?bpo then (send ?bpo get-preu_cost) else 0))
       )

       ;; Total del menú
       (if (eq ?bm general)
         then (bind ?total (+ ?ppr ?psg ?ppo ?pbg))
         else (bind ?total (+ ?ppr ?psg ?ppo ?pbpr ?pbsg ?pbpo))
       )

       ;; Impressió
       (printout t crlf "*** Menú " ?i " ***" crlf)
       (printout t "  Entrant:   " ?npr "  [" ?ppr " €]" crlf)
       (printout t "  Principal: " ?nsg "  [" ?psg " €]" crlf)
       (printout t "  Postres:   " ?npo "  [" ?ppo " €]" crlf)

       (if (eq ?bm general)
         then
           (if ?bg
               then (printout t "  Beguda Recomanada: " ?nbg "  [" ?pbg " €]" crlf)
               else (printout t "  Beguda Recomanada: --" crlf))
         else
           (printout t "  Beguda Entrant:   " ?nbpr (if ?bpr then (str-cat "  [" ?pbpr " €]") else "") crlf)
           (printout t "  Beguda Principal: " ?nbsg (if ?bsg then (str-cat "  [" ?pbsg " €]") else "") crlf)
           (printout t "  Beguda Postres:   " ?nbpo (if ?bpo then (str-cat "  [" ?pbpo " €]") else "") crlf)
       )

       (printout t "  ----------------------------------------------------------------------" crlf)
       (printout t "  TOTAL per persona: " ?total " €" crlf)
     )
  )
  (assert (menus-presentats-grup (gid ?gid)))
  (bind ?next (+ ?gid 1))
  (if (> (length$ (find-all-facts ((?g grup-restriccio))
              (eq (fact-slot-value ?g id) ?next))) 0)
      then (assert (imprimir-grup (id ?next))))
  (retract ?imp)

)



(deftemplate menu-valid
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT))
)

(deftemplate menu-seleccionat
  (slot idx (type INTEGER))
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT))
)

(deftemplate menu-reparat-grup
  (slot gid (type INTEGER))
  (slot idx (type INTEGER))
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT))
)

(deftemplate menu-noapte
  (slot gid (type INTEGER))
  (slot idx (type INTEGER)))

(defrule ComposicioMenus::iniciar-impressio-grups
  (declare (auto-focus TRUE))
  (respostes-completes)
  (menus-presentats)
  (grup-restriccio (id 1))
  (not (imprimir-grup (id 1)))
=>
  (assert (imprimir-grup (id 1))))


(defrule ComposicioMenus::generador-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (peticio (pressupost-min ?pmin) (pressupost-max ?pmax) (beguda-mode ?bm))
  =>
  ;; Plats vàlids -> noms
  (bind ?plats-valids (find-all-facts ((?f plat-valid-final)) TRUE))
  (bind ?noms-valids (create$))
  (foreach ?f ?plats-valids
    (bind ?noms-valids (create$ $?noms-valids (fact-slot-value ?f nom))))

  ;; Classificació per ordre
  (bind ?primers (find-all-instances ((?p Plat))
                   (and (member$ ordre-primer (send ?p get-te_ordre))
                        (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?segons  (find-all-instances ((?p Plat))
                   (and (member$ ordre-segon (send ?p get-te_ordre))
                        (member$ (send ?p get-nom) ?noms-valids))))
  (bind ?postres (find-all-instances ((?p Plat))
                   (and (member$ ordre-postres (send ?p get-te_ordre))
                        (member$ (send ?p get-nom) ?noms-valids))))

  ;; Begudes vàlides -> noms
  (bind ?begudes-valides (find-all-facts ((?bf beguda-valida-final)) TRUE))
  (bind ?b-noms-valids (create$))
  (foreach ?bf ?begudes-valides
    (bind ?b-noms-valids (create$ $?b-noms-valids (fact-slot-value ?bf nom))))

  ;; Inicialitza llistes de begudes
  (bind ?b-generals (create$))
  (bind ?b-primers  (create$))
  (bind ?b-segons   (create$))
  (bind ?b-postres  (create$))

  ;; Carrega llistes segons mode
  (if (eq ?bm general)
    then
      (progn
        (bind ?b-generals
          (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-es_general) si)
                 (member$ (send ?b get-nom) ?b-noms-valids)))))
    else
      (progn
        (bind ?b-primers
          (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-primer)
                 (member$ (send ?b get-nom) ?b-noms-valids))))
        (bind ?b-segons
          (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-segon)
                 (member$ (send ?b get-nom) ?b-noms-valids))))
        (bind ?b-postres
          (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-postres)
                 (member$ (send ?b get-nom) ?b-noms-valids))))))
  (printout t crlf "— Disponibilitat de plats després de filtres —" crlf)
  (printout t "Primers: " (length$ ?primers) " | Segons: " (length$ ?segons) " | Postres: " (length$ ?postres) crlf)

  (printout t crlf "=== Generant menús dins del pressupost ===" crlf)
  (bind ?count 0)
  ;; (printout t "[DEBUG] primers=" (length$ ?primers)
  ;;                " segons=" (length$ ?segons)
  ;;                " postres=" (length$ ?postres)
  ;;                " b-generals=" (length$ ?b-generals) crlf)

  ;; Combinacions de plats
  (foreach ?pr ?primers
    (foreach ?sg ?segons
      (foreach ?po ?postres
        (bind ?npr (send ?pr get-nom))
        (bind ?nsg (send ?sg get-nom))
        (bind ?npo (send ?po get-nom))

        ;; Preus dels plats
        (bind ?ppr (fact-slot-value
                      (nth$ 1 (find-all-facts ((?f preu-venta))
                               (eq (fact-slot-value ?f nom) ?npr)))
                      valor))
        (bind ?psg (fact-slot-value
                      (nth$ 1 (find-all-facts ((?f preu-venta))
                               (eq (fact-slot-value ?f nom) ?nsg)))
                      valor))
        (bind ?ppo (fact-slot-value
                      (nth$ 1 (find-all-facts ((?f preu-venta))
                               (eq (fact-slot-value ?f nom) ?npo)))
                      valor))

        (bind ?total (+ ?ppr ?psg ?ppo))

        ;; Decisió per mode de beguda
        (if (eq ?bm general)
          then
            (progn
              ;; 1) Si hi ha begudes generals, tria la millor dins pressupost
              (bind ?best-bg FALSE)
              (bind ?best-nom "")
              (bind ?best-total 1.0e+15)
              (foreach ?bg ?b-generals
                (bind ?nbg (send ?bg get-nom))
                (bind ?pbg (send ?bg get-preu_cost))
                (bind ?total2 (+ ?total ?pbg))
                (if (and (>= ?total2 ?pmin) (<= ?total2 ?pmax))
                  then
                    (if (< ?total2 ?best-total)
                      then
                        (bind ?best-bg ?bg)
                        (bind ?best-nom ?nbg)
                        (bind ?best-total ?total2))))
              (if ?best-bg
                then
                  (progn
                    (assert (menu-valid
                              (primer ?npr)
                              (segon ?nsg)
                              (postres ?npo)
                              (begudes (create$ ?best-nom))
                              (preu ?best-total)))
                    (bind ?count (+ ?count 1)))
                else
                  ;; 2) Fallback: sense beguda si ja compleix pressupost
                  (if (and (>= ?total ?pmin) (<= ?total ?pmax))
                    then
                      (progn
                        (assert (menu-valid
                                  (primer ?npr)
                                  (segon ?nsg)
                                  (postres ?npo)
                                  (begudes (create$))
                                  (preu ?total)))
                        (bind ?count (+ ?count 1)))))))
          else
            (progn
              ;; Per-plat: totes les combinacions
              (foreach ?bpr ?b-primers
                (foreach ?bsg ?b-segons
                  (foreach ?bpo ?b-postres
                    (bind ?pbpr (send ?bpr get-preu_cost))
                    (bind ?pbsg (send ?bsg get-preu_cost))
                    (bind ?pbpo (send ?bpo get-preu_cost))
                    (bind ?total2 (+ ?total ?pbpr ?pbsg ?pbpo))
                    (if (and (>= ?total2 ?pmin) (<= ?total2 ?pmax))
                      then
                        (progn
                          (assert (menu-valid
                                    (primer ?npr)
                                    (segon ?nsg)
                                    (postres ?npo)
                                    (begudes (create$ (send ?bpr get-nom)
                                                      (send ?bsg get-nom)
                                                      (send ?bpo get-nom)))
                                    (preu ?total2))
                          (bind ?count (+ ?count 1))))))))))))

  ;; Resum
  (if (> ?count 0)
    then
      (printout t "S'han generat " ?count " menús vàlids dins del pressupost." crlf)
    else
      (printout t "*** Cap menú dins del rang de pressupost. ***" crlf))
)



(defrule ComposicioMenus::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
  =>
  (bind ?menus (find-all-facts ((?m menu-valid)) TRUE))
  (bind ?n (length$ ?menus))

  (if (<= ?n 0) then
    (printout t crlf "*** No hi ha menús vàlids dins del pressupost. ***" crlf)
   else
    (printout t crlf "=== MENÚS DISPONIBLES (" ?n " en total) ===" crlf)

    ;; Ordenem per preu
    (bind ?sorted (sort < (create$ (foreach ?mv ?menus (fact-slot-value ?mv preu)))))

    ;; Triem fins a 3 menús sense repetir plats
    (bind ?picked (create$))
    (bind ?used-primers (create$))
    (bind ?used-segons  (create$))
    (bind ?used-postres (create$))

    (foreach ?p ?sorted
      (if (< (length$ ?picked) 3) then
        (foreach ?mv ?menus
          (if (and (= (fact-slot-value ?mv preu) ?p)
                   (< (length$ ?picked) 3))
            then
              (bind ?pr (fact-slot-value ?mv primer))
              (bind ?sg (fact-slot-value ?mv segon))
              (bind ?po (fact-slot-value ?mv postres))
              (if (and (not (member$ ?pr ?used-primers))
                       (not (member$ ?sg ?used-segons))
                       (not (member$ ?po ?used-postres)))
                then
                  (bind ?picked (create$ $?picked ?mv))
                  (bind ?used-primers (create$ $?used-primers ?pr))
                  (bind ?used-segons  (create$ $?used-segons  ?sg))
                  (bind ?used-postres (create$ $?used-postres ?po)))))))

    ;; Neteja menús seleccionats previs
    (foreach ?old (find-all-facts ((?x menu-seleccionat)) TRUE)
      (retract ?old))

    ;; Impressió i indexat (assert) dels triats
    (bind ?nsel (length$ ?picked))
    (if (<= ?nsel 0) then
      (printout t crlf "*** No hi ha menús que compleixin la unicitat de plats. ***" crlf)
     else
      (printout t crlf "=== MENÚS DISPONIBLES (" ?nsel " únics) ===" crlf)
      (bind ?index 1)

      (foreach ?m ?picked
        (printout t crlf "*** Menú " ?index " ***" crlf)
        (printout t "  Entrant:   " (fact-slot-value ?m primer) crlf)
        (printout t "  Principal: " (fact-slot-value ?m segon) crlf)
        (printout t "  Postres:   " (fact-slot-value ?m postres) crlf)
        (printout t "  Begudes:   " (implode$ (fact-slot-value ?m begudes)) crlf)
        (printout t "  TOTAL:     " (fact-slot-value ?m preu) " €" crlf)
        (printout t "  ----------------------------------------" crlf)

        ;; Assertem el menú indexat
        (bind $?bgs (fact-slot-value ?m begudes))
        (assert (menu-seleccionat
                  (idx ?index)
                  (primer  (fact-slot-value ?m primer))
                  (segon   (fact-slot-value ?m segon))
                  (postres (fact-slot-value ?m postres))
                  (begudes $?bgs)
                  (preu    (fact-slot-value ?m preu))))

        (bind ?index (+ ?index 1))
      )
    )
    (assert (menus-presentats))
  )
)


(defrule ComposicioMenus::informar-validesa-menus-grups
  (declare (auto-focus TRUE))
  (menus-presentats)
=>
  (bind ?menus (find-all-facts ((?m menu-seleccionat)) TRUE))
  (bind ?grups (find-all-facts ((?g grup-restriccio)) TRUE))

  (if (<= (length$ ?menus) 0) then
    (printout t crlf "— No hi ha menús seleccionats per validar (cap 'menu-seleccionat'). —" crlf))

  (if (<= (length$ ?grups) 0) then
    (printout t crlf "— Sense grups definits: no cal validar al·lèrgens/dieta per grups. —" crlf)
  else
    (foreach ?g ?grups
      (bind ?gid  (fact-slot-value ?g id))
      (bind ?gnom (fact-slot-value ?g nom))
      (printout t crlf "— Validació d'al·lèrgens/dieta per al grup " ?gid " (" ?gnom ") —" crlf)

      (foreach ?m ?menus
        (bind ?idx (fact-slot-value ?m idx))
        (bind ?pr  (fact-slot-value ?m primer))
        (bind ?sg  (fact-slot-value ?m segon))
        (bind ?po  (fact-slot-value ?m postres))

        (bind ?ok-pr (plat-apte-per-grup ?pr ?gid))
        (bind ?ok-sg (plat-apte-per-grup ?sg ?gid))
        (bind ?ok-po (plat-apte-per-grup ?po ?gid))

        (bind ?ok (and ?ok-pr ?ok-sg ?ok-po))
        (if (not ?ok) then
          (assert (menu-noapte (gid ?gid) (idx ?idx))))
        (printout t "Menú " ?idx ": [" ?pr " | " ?sg " | " ?po "]  ->  "
                    (if ?ok then "APTE" else "NO apte") crlf)

        (if (not ?ok) then
          (if (not ?ok-pr) then (printout t "   ✖ No apte pel plat ENTRANT:   " ?pr crlf))
          (if (not ?ok-sg) then (printout t "   ✖ No apte pel plat PRINCIPAL: " ?sg crlf))
          (if (not ?ok-po) then (printout t "   ✖ No apte pel plat POSTRES:   " ?po crlf))
        )
      )
    )
  )
)

(deffunction tria-substitut (?ordre-sym ?gid ?preu-fix-1 ?preu-fix-2 ?begudes-total $?exclusions)
  ;; ?preu-fix-1 i ?preu-fix-2 = preus dels altres dos plats
  ;; ?begudes-total = suma preu begudes del menú
  (bind $?cand (noms-candidats-ordre ?ordre-sym))
  (bind ?millor FALSE)
  (bind ?millorTotal 1.0e+15)
  (foreach ?nom $?cand
    (if (not (member$ ?nom $?exclusions)) then
      (if (plat-apte-per-grup ?nom ?gid) then
        (bind ?p (preu-plat-by-name ?nom))
        (bind ?total (+ ?begudes-total ?preu-fix-1 ?preu-fix-2 ?p))
        (if (and (budget-ok ?total) (< ?total ?millorTotal)) then
          (bind ?millor ?nom)
          (bind ?millorTotal ?total)))))
  (if ?millor then
      (return (create$ ?millor ?millorTotal))
    else
      (return (create$ FALSE 0.0)))
) ;; <— AQUESTA era la que faltava per tancar el deffunction

(deftemplate repair-state
  (slot gid (type INTEGER))
  (slot idx (type INTEGER))
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT))
  (multislot tried-primer)
  (multislot tried-segon)
  (multislot tried-postres))

(defrule ComposicioMenus::repair-start
  (declare (auto-focus TRUE))
  (menus-presentats)
  (menu-noapte (gid ?gid) (idx ?idx)) 
  (grup-restriccio (id ?gid))
  ?m <- (menu-seleccionat (idx ?idx) (primer ?pr) (segon ?sg) (postres ?po) (begudes $?bgs) (preu ?pp))
  (test (or (not (plat-apte-per-grup ?pr ?gid))
            (not (plat-apte-per-grup ?sg ?gid))
            (not (plat-apte-per-grup ?po ?gid))))
  (not (repair-state (gid ?gid) (idx ?idx)))
=>
  (assert (repair-state (gid ?gid) (idx ?idx)
                        (primer ?pr) (segon ?sg) (postres ?po)
                        (begudes $?bgs) (preu ?pp)))
)

(defrule ComposicioMenus::repair-primer
  ?rs <- (repair-state (gid ?gid) (idx ?idx)
                       (primer ?pr) (segon ?sg) (postres ?po)
                       (begudes $?bgs) (preu ?base)
                       (tried-primer $?tp))
  (test (not (plat-apte-per-grup ?pr ?gid)))
=>
  (bind ?begT (sum-preu-begudes $?bgs))
  (bind $?r (tria-substitut ordre-primer ?gid (preu-plat-by-name ?sg) (preu-plat-by-name ?po) ?begT (create$ ?pr ?sg ?po $?tp)))
  (bind ?sub (nth$ 1 $?r))
  (bind ?tot (nth$ 2 $?r))
  (retract ?rs)
  (if ?sub then
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?sub) (segon ?sg) (postres ?po)
                          (begudes $?bgs) (preu ?tot)
                          (tried-primer $?tp ?pr)))
   else
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?pr) (segon ?sg) (postres ?po)
                          (begudes $?bgs) (preu ?base)
                          (tried-primer $?tp ?pr))))
)

(defrule ComposicioMenus::repair-segon
  ?rs <- (repair-state (gid ?gid) (idx ?idx)
                       (primer ?pr) (segon ?sg) (postres ?po)
                       (begudes $?bgs) (preu ?base)
                       (tried-segon $?ts))
  (test (and (plat-apte-per-grup ?pr ?gid)
             (not (plat-apte-per-grup ?sg ?gid))))
=>
  (bind ?begT (sum-preu-begudes $?bgs))
  (bind $?r (tria-substitut ordre-segon ?gid (preu-plat-by-name ?pr) (preu-plat-by-name ?po) ?begT (create$ ?pr ?sg ?po $?ts)))
  (bind ?sub (nth$ 1 $?r))
  (bind ?tot (nth$ 2 $?r))
  (retract ?rs)
  (if ?sub then
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?pr) (segon ?sub) (postres ?po)
                          (begudes $?bgs) (preu ?tot)
                          (tried-segon $?ts ?sg)))
   else
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?pr) (segon ?sg) (postres ?po)
                          (begudes $?bgs) (preu ?base)
                          (tried-segon $?ts ?sg))))
)

(defrule ComposicioMenus::repair-postres
  ?rs <- (repair-state (gid ?gid) (idx ?idx)
                       (primer ?pr) (segon ?sg) (postres ?po)
                       (begudes $?bgs) (preu ?base)
                       (tried-postres $?tp))
  (test (and (plat-apte-per-grup ?pr ?gid)
             (plat-apte-per-grup ?sg ?gid)
             (not (plat-apte-per-grup ?po ?gid))))
=>
  (bind ?begT (sum-preu-begudes $?bgs))
  (bind $?r (tria-substitut ordre-postres ?gid (preu-plat-by-name ?pr) (preu-plat-by-name ?sg) ?begT (create$ ?pr ?sg ?po $?tp)))
  (bind ?sub (nth$ 1 $?r))
  (bind ?tot (nth$ 2 $?r))
  (retract ?rs)
  (if ?sub then
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?pr) (segon ?sg) (postres ?sub)
                          (begudes $?bgs) (preu ?tot)
                          (tried-postres $?tp ?po)))
   else
    (assert (repair-state (gid ?gid) (idx ?idx)
                          (primer ?pr) (segon ?sg) (postres ?po)
                          (begudes $?bgs) (preu ?base)
                          (tried-postres $?tp ?po))))
)

(defrule ComposicioMenus::repair-finish-ok
  ?rs <- (repair-state (gid ?gid) (idx ?idx)
                       (primer ?pr) (segon ?sg) (postres ?po)
                       (begudes $?bgs) (preu ?tot))
  (test (and (plat-apte-per-grup ?pr ?gid)
             (plat-apte-per-grup ?sg ?gid)
             (plat-apte-per-grup ?po ?gid)))
=>
  (retract ?rs)
  (assert (menu-reparat-grup (gid ?gid) (idx ?idx)
                             (primer ?pr) (segon ?sg) (postres ?po)
                             (begudes $?bgs) (preu ?tot)))
)

(defrule ComposicioMenus::repair-stuck
  ?rs <- (repair-state (gid ?gid) (idx ?idx)
                       (primer ?pr) (segon ?sg) (postres ?po)
                       (begudes $?bgs) (preu ?tot)
                       (tried-primer $?tp1)
                       (tried-segon  $?tp2)
                       (tried-postres $?tp3))
  (test (or (not (plat-apte-per-grup ?pr ?gid))
            (not (plat-apte-per-grup ?sg ?gid))
            (not (plat-apte-per-grup ?po ?gid))))
=>
  (printout t "Menú " ?idx " (grup " ?gid "): no s'ha pogut reparar completament dins del pressupost." crlf)
  (retract ?rs))

(deftemplate repair-done (slot gid (type INTEGER)))
(deftemplate reparats-impressos (slot gid (type INTEGER)))

(defrule ComposicioMenus::mostrar-menus-reparats-per-grup
  (declare (auto-focus TRUE))
  (menus-presentats)
  ?g <- (grup-restriccio (id ?gid) (nom ?gnom))
  (repair-done (gid ?gid))                                   ;; assegura que hem acabat
  (exists (menu-reparat-grup (gid ?gid)))
  (not (reparats-impressos (gid ?gid)))                      ;; evita doble impressió
=>
  (printout t crlf "=== Menús REPARATS per al grup " ?gid " (" ?gnom ") ===" crlf)

  ;; 1) recull índexs reparats d’aquest grup
  (bind ?mx (find-all-facts ((?m menu-reparat-grup)) (eq (fact-slot-value ?m gid) ?gid)))
  (bind ?idxs (create$))
  (foreach ?m ?mx
    (bind ?idxs (create$ $?idxs (fact-slot-value ?m idx))))

  ;; 2) ordena per idx creixent
  (bind ?ord (sort < (create$ $?idxs)))

  ;; 3) imprimeix en ordre
  (foreach ?i ?ord
    (bind ?m2 (nth$ 1 (find-all-facts ((?z menu-reparat-grup))
                   (and (eq (fact-slot-value ?z gid)  ?gid)
                        (eq (fact-slot-value ?z idx)  ?i)))))
    (printout t crlf "*** Menú " ?i " ***" crlf)
    (printout t "  Entrant:   " (fact-slot-value ?m2 primer)  crlf)
    (printout t "  Principal: " (fact-slot-value ?m2 segon)   crlf)
    (printout t "  Postres:   " (fact-slot-value ?m2 postres) crlf)
    (printout t "  Begudes:   " (implode$ (fact-slot-value ?m2 begudes)) crlf)
    (printout t "  TOTAL:     " (fact-slot-value ?m2 preu) " €" crlf)
    (printout t "  ----------------------------------------" crlf)
  )

  (assert (reparats-impressos (gid ?gid)))
)








; ;; PAS 5: COMPOSICIÓ DE MENÚS -------------------------------
; (defrule ComposicioMenus::mostrar-menus-inicials
;   (declare (auto-focus TRUE))
;   (respostes-completes)
;   (not (menus-presentats))
;   (peticio (beguda-mode ?bm))
;   =>
;   ;; Recollim noms finals vàlids
;   (bind ?plats-valids (find-all-facts ((?f plat-valid-final)) TRUE))
;   (bind ?noms-valids (create$))
;   (foreach ?f ?plats-valids
;      (bind ?noms-valids (create$ $?noms-valids (fact-slot-value ?f nom)))
;   )

;   ;; Busquem plats per ordre
;   (bind ?primers (find-all-instances
;                ((?p Plat))
;                (and (member$ ordre-primer (send ?p get-te_ordre))
;                   (member$ (send ?p get-nom) ?noms-valids))))
;   (bind ?segons (find-all-instances
;                ((?p Plat))
;                (and (member$ ordre-segon (send ?p get-te_ordre))
;                   (member$ (send ?p get-nom) ?noms-valids))))
;   (bind ?postres (find-all-instances
;                ((?p Plat))
;                (and (member$ ordre-postres (send ?p get-te_ordre))
;                   (member$ (send ?p get-nom) ?noms-valids))))


;   ; Recollim noms de begudes finals
;   (bind ?begudes-valides (find-all-facts ((?bf beguda-valida-final)) TRUE))
;   (bind ?b-noms-valids (create$))
;   (foreach ?bf ?begudes-valides
;      (bind ?b-noms-valids (create$ $?b-noms-valids (fact-slot-value ?bf nom)))
;   )

;   ; Busquem begudes per mode i ordre
;   (if (eq ?bm general)
;     then
;       (bind ?b-generals (find-all-instances ((?b Beguda))
;                       (and (eq (send ?b get-es_general) si)
;                            (member$ (send ?b get-nom) ?b-noms-valids))))
;     else 
;       (bind ?b-primers (find-all-instances ((?b Beguda))
;                       (and (eq (send ?b get-maridatge) ordre-primer)
;                            (member$ (send ?b get-nom) ?b-noms-valids))))
;       (bind ?b-segons (find-all-instances ((?b Beguda))
;                       (and (eq (send ?b get-maridatge) ordre-segon)
;                            (member$ (send ?b get-nom) ?b-noms-valids))))
;       (bind ?b-postres (find-all-instances ((?b Beguda))
;                        (and (eq (send ?b get-maridatge) ordre-postres)
;                             (member$ (send ?b get-nom) ?b-noms-valids))))
;   )

;   ;; LÍMIT DE MENÚS PEL MENJAR
;   (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))

;   ;; LÍMIT DE BEGUDES (no forcem el límit final pels menús: si no hi ha beguda per a un i,
;   ;; imprimirem el menjar i posarem "Sense beguda recomanada")
;   (bind ?drink-limit
;         (if (eq ?bm general)
;             then (length$ ?b-generals)
;             else (min (length$ ?b-primers) (length$ ?b-segons) (length$ ?b-postres))))

;   (if (<= ?limit 0) then
;      (printout t crlf "*** No s'han trobat menus per mostrar dins del pressupost. ***" crlf)
;    else
;      (printout t crlf "Et proposem " ?limit " menus dins del pressupost:" crlf)
;      (loop-for-count (?i 1 ?limit)
;        (bind ?pr  (nth$ ?i ?primers))
;        (bind ?sg  (nth$ ?i ?segons))
;        (bind ?po  (nth$ ?i ?postres))

;        ;; Begudes: només vinculem si existeixen per a aquest índex
;        (if (eq ?bm general)
;          then
;            (if (<= ?i (length$ ?b-generals))
;                then (bind ?bg (nth$ ?i ?b-generals))
;                else (bind ?bg FALSE))
;          else
;            (if (<= ?i (length$ ?b-primers)) then (bind ?bpr (nth$ ?i ?b-primers)) else (bind ?bpr FALSE))
;            (if (<= ?i (length$ ?b-segons))  then (bind ?bsg (nth$ ?i ?b-segons))   else (bind ?bsg FALSE))
;            (if (<= ?i (length$ ?b-postres)) then (bind ?bpo (nth$ ?i ?b-postres))  else (bind ?bpo FALSE))
;        )

;        (bind ?npr (send ?pr get-nom))
;        (bind ?nsg (send ?sg get-nom))
;        (bind ?npo (send ?po get-nom))

;        ;; Noms de beguda si n'hi ha; altrament, marquem "--"
;        (if (eq ?bm general)
;          then
;            (bind ?nbg (if ?bg then (send ?bg get-nom) else "--"))
;          else
;            (bind ?nbpr (if ?bpr then (send ?bpr get-nom) else "--"))
;            (bind ?nbsg (if ?bsg then (send ?bsg get-nom) else "--"))
;            (bind ?nbpo (if ?bpo then (send ?bpo get-nom) else "--"))
;        )

;        ;; Preus dels plats
;        (bind ?ppr (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npr))) valor))
;        (bind ?psg (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?nsg))) valor))
;        (bind ?ppo (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npo))) valor))

;        ;; Preus de beguda si existeixen; si no, 0
;        (if (eq ?bm general)
;          then
;            (bind ?pbg (if ?bg then (send ?bg get-preu_cost) else 0))
;          else
;            (bind ?pbpr (if ?bpr then (send ?bpr get-preu_cost) else 0))
;            (bind ?pbsg (if ?bsg then (send ?bsg get-preu_cost) else 0))
;            (bind ?pbpo (if ?bpo then (send ?bpo get-preu_cost) else 0))
;        )

;        ;; Total
;        (if (eq ?bm general)
;          then (bind ?total (+ ?ppr ?psg ?ppo ?pbg))
;          else (bind ?total (+ ?ppr ?psg ?ppo ?pbpr ?pbsg ?pbpo))
;        )

;        ;; Impressió
;        (printout t crlf "*** Menu " ?i " ***" crlf)
;        (printout t "  Entrant:   " ?npr "  [" ?ppr " €]" crlf)
;        (printout t "  Principal: " ?nsg "  [" ?psg " €]" crlf)
;        (printout t "  Postres:   " ?npo "  [" ?ppo " €]" crlf)

;        (if (eq ?bm general)
;          then
;            (if ?bg
;                then (printout t "  Beguda Recomanada: " ?nbg "  [" ?pbg " €]" crlf)
;                else (printout t "  Beguda Recomanada: --" crlf))
;          else
;            (printout t "  Beguda Entrant:   " ?nbpr (if ?bpr then (str-cat "  [" ?pbpr " €]") else "") crlf)
;            (printout t "  Beguda Principal: " ?nbsg (if ?bsg then (str-cat "  [" ?pbsg " €]") else "") crlf)
;            (printout t "  Beguda Postres:   " ?nbpo (if ?bpo then (str-cat "  [" ?pbpo " €]") else "") crlf)
;        )

;        (printout t "  ----------------------------------------------------------------------" crlf)
;        (printout t "  TOTAL per persona: " ?total " €" crlf)
;      )
;   )
;   (assert (menus-presentats))
; )
; (defrule ComposicioMenus::iniciar-impressio-grups
;   (declare (auto-focus TRUE))
;   (respostes-completes)
;   (menus-presentats)
;   (grup-restriccio (id 1))
;   (not (imprimir-grup (id 1)))
; =>
;   (assert (imprimir-grup (id 1)))
; )