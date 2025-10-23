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

(deffunction nums->ue14-syms ($?nums)
  (bind ?res (create$))
  (foreach ?k ?nums
    (bind ?s (ue14-num->sym (integer ?k)))
    (if (neq ?s nil) then (bind ?res (create$ $?res ?s))))
  ?res)

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
  (slot dieta          (type SYMBOL)
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
(deftemplate menus-presentats-grup
  (slot gid (type INTEGER)))

; ============================================================
; RESULTATS INTERMEDIS PER GRUP (nous)
; ============================================================
(deftemplate plat-valid-alergen (slot nom) (slot gid (type INTEGER)))
(deftemplate plat-valid-dieta   (slot nom) (slot gid (type INTEGER)))
(deftemplate plat-valid-final-grup (slot nom) (slot gid (type INTEGER)))


(deffunction ingredient-apte-dieta (?diet ?dietes-ing)
  (if (or (eq ?diet cap) (eq ?diet indiferent)) then (return TRUE))

  ; Vegà: cal etiqueta VG
  (if (eq ?diet vega) then
    (return (member$ VG (create$ $?dietes-ing))))

  ; Vegetarià: V o VG
  (if (eq ?diet vegetaria) then
    (return (or (member$ V  (create$ $?dietes-ing))
                (member$ VG (create$ $?dietes-ing)))))

  ; Halal: només tenim HALAL_POT al CSV
  (if (eq ?diet halal) then
    (return (member$ HALAL_POT (create$ $?dietes-ing))))

  ; Kosher: només tenim KOSHER_POT al CSV
  (if (eq ?diet kosher) then
    (return (member$ KOSHER_POT (create$ $?dietes-ing))))

  FALSE
)

; Helper: cerca l’objecte Ingredient pel seu nom (string)
(deffunction ingredient-by-name (?nom-str)
  (bind ?cand (find-all-instances ((?i Ingredient))
               (eq (send ?i get-nom) ?nom-str)))
  (if (> (length$ ?cand) 0) then (return (nth$ 1 ?cand)) else (return FALSE)))


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
              "Quin tipus d’esdeveniment estàs organitzant? (casament/aniversari/comunió/congrés/empresa/altres)"
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
  (printout t " 0 Cap" crlf)
  (printout t " 1 Gluten   | 2 Llet   | 3 Ous   | 4 Peix" crlf)
  (printout t " 5 Crustacis| 6 Mol·luscs | 7 Fruits secs | 8 Cacauet" crlf)
  (printout t " 9 Soja     | 10 Api | 11 Mostassa | 12 Sèsam" crlf)
  (printout t " 13 Sulfits | 14 Tramussos | 15 Altres (especifica)" crlf)
  (printout t "Exemple: 2 7" crlf crlf)
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


;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(deftemplate plat-valid-final (slot nom))   ; Nom del plat que passa totes les restriccions
(deftemplate plat-valid-temp (slot nom))          ;; Nom del plat que passa la restricció de temperatura
(deftemplate plat-valid-formal (slot nom))
(deftemplate plat-valid-complexitat (slot nom))
(deftemplate plat-valid-event
   (slot nom))
(deftemplate plat-valid-dispo (slot nom))
(deftemplate preu-venta (slot nom (type STRING SYMBOL)) (slot valor (type FLOAT)))

(deftemplate beguda-valida-alcohol (slot nom))
(deftemplate beguda-valida-formal (slot nom))
(deftemplate beguda-valida-final (slot nom))


(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
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
                   (or (eq ?temp "Fred") (eq ?temp "Tebi")))
              (and (or (eq ?estacio primavera) (eq ?estacio estiu))
                   (eq ?temp "Calent") (eq ?espai interior))
              (and (or (eq ?estacio tardor) (eq ?estacio hivern))
                   (or (eq ?temp "Calent") (eq ?temp "Tebi"))))
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
              (formalitat ?form))
=>
    (if (or
         (and (eq ?f formal) (eq ?form "formal"))
         (and (eq ?f informal) (eq ?form "informal")))
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
  (bind $?ings (send ?pl get-te_ingredients_noms))  ; <-- LLEGEIX els ingredients aquí
  (bind ?apte TRUE)

  (foreach ?ing ?ings
    (if ?apte then
      (bind ?I (ingredient-by-name ?ing))
      (if ?I then
        (bind $?ialgs (send ?I get-alergens))
        (if (> (length$ $?ialgs) 0) then
          (foreach ?a $?ialgs
            (if (and ?apte (member$ ?a (create$ $?ALS))) then (bind ?apte FALSE)))
         else
          (bind ?alg-str (send ?I get-alergen))
          (bind ?asym (string->ue14-sym ?alg-str))
          (if (and ?asym (member$ ?asym (create$ $?ALS))) then (bind ?apte FALSE))
        )
      )
    )
  )

  (if ?apte then
    (assert (plat-valid-alergen (nom ?np) (gid ?gid))))
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

(deftemplate plat-valid-pressupost (slot nom))

(defrule RefinamentHeuristica::filtrar-plats-per-pressupost
  (peticio (pressupost-min ?pmin) (pressupost-max ?pmax))
  (test (and (numberp ?pmin) (numberp ?pmax)))
  (preu-venta (nom ?nom) (valor ?pv))
=>
  (bind ?min-plat (/ ?pmin 3.0))
  (bind ?max-plat (/ ?pmax 3.0))
  (if (and (>= ?pv ?min-plat) (<= ?pv ?max-plat)) then
      (assert (plat-valid-pressupost (nom ?nom)))))

(defrule RefinamentHeuristica::pressupost-indiferent
  (peticio (pressupost-min ?pmin) (pressupost-max ?pmax))
  (test (or (eq ?pmin indiferent) (eq ?pmax indiferent)))
  ?p <- (object (is-a Plat) (nom ?nom))
  =>
  (assert (plat-valid-pressupost (nom ?nom))))

; ============================================================
; Després d'al·lèrgens: marquem plats aptes per dieta, per grup
; ============================================================
(defrule RefinamentHeuristica::filtrar-plats-per-dieta-grup
  (grup-restriccio (id ?gid) (dieta ?diet))
  (plat-valid-alergen (nom ?np) (gid ?gid))
  ?pl <- (object (is-a Plat) (nom ?np))
  (not (plat-valid-dieta (nom ?np) (gid ?gid)))
=>
  (bind $?ings (send ?pl get-te_ingredients_noms))  ; <-- LLEGEIX els ingredients aquí
  (bind ?ok TRUE)

  (if (neq ?diet cap) then
    (foreach ?ing ?ings
      (if ?ok then
        (bind ?I (ingredient-by-name ?ing))
        (if (not ?I) then
            (bind ?ok FALSE)
         else
            (bind ?diets (send ?I get-dietes))
            (if (not (ingredient-apte-dieta ?diet ?diets)) then
                (bind ?ok FALSE))
        )
      )
    )
  )

  (if ?ok then (assert (plat-valid-dieta (nom ?np) (gid ?gid))))
)


; ============================================================
; COMBINE per GRUP: afegeix requisits de sempre + al·lergen+dieta per grup
; ============================================================
(defrule RefinamentHeuristica::combinar-validacions-per-grup
  (plat-valid-temp (nom ?nom))
  (plat-valid-formal (nom ?nom))
  (plat-valid-complexitat (nom ?nom))
  (plat-valid-event (nom ?nom))
  (plat-valid-dispo (nom ?nom))
  (plat-valid-pressupost (nom ?nom))
  (plat-valid-alergen (nom ?nom) (gid ?gid))
  (plat-valid-dieta (nom ?nom)   (gid ?gid))
=>
  (assert (plat-valid-final-grup (nom ?nom) (gid ?gid)))
)

(defrule RefinamentHeuristica::combinar-validacions-base
  (plat-valid-temp (nom ?nom))
  (plat-valid-formal (nom ?nom))
  (plat-valid-complexitat (nom ?nom))
  (plat-valid-event (nom ?nom))
  (plat-valid-dispo (nom ?nom))
  (plat-valid-pressupost (nom ?nom))
=>
  (assert (plat-valid-final (nom ?nom)))
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
  (menus-presentats)                     ; <-- AFEGIT: assegura ordre
  (grup-restriccio (id ?gid) (nom ?gnom))
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
  (bind ?begudes-valides (find-all-facts ((?bf beguda-valida-final)) TRUE))
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

  (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))

  (printout t crlf "=== Menús per al grup " ?gid " (" ?gnom ") ===" crlf)

  (if (<= ?limit 0) then
     (printout t "*** No hi ha prou plats aptes amb aquestes restriccions. ***" crlf)
   else
     (loop-for-count (?i 1 ?limit)
       (bind ?pr (nth$ ?i ?primers))
       (bind ?sg (nth$ ?i ?segons))
       (bind ?po (nth$ ?i ?postres))
       (if (eq ?bm general)
                  then (bind ?bg (nth$ ?i ?b-generals))
                  else 
                    (bind ?bpr (nth$ ?i ?b-primers))
                    (bind ?bsg (nth$ ?i ?b-segons))
                    (bind ?bpo (nth$ ?i ?b-postres))
       )
       (bind ?npr (send ?pr get-nom))
       (bind ?nsg (send ?sg get-nom))
       (bind ?npo (send ?po get-nom))
       (if (eq ?bm general)
                  then (bind ?nbg (send ?bg get-nom))
                  else 
                    (bind ?nbpr (send ?bpr get-nom))
                    (bind ?nbsg (send ?bsg get-nom))
                    (bind ?nbpo (send ?bpo get-nom))
        )

       (bind ?ppr (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npr))) valor))
       (bind ?psg (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?nsg))) valor))
       (bind ?ppo (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npo))) valor))
       (if (eq ?bm general)
                then (bind ?pbg (send ?bg get-preu_cost))
                else 
                  (bind ?pbpr (send ?bpr get-preu_cost))
                  (bind ?pbsg (send ?bsg get-preu_cost))
                  (bind ?pbpo (send ?bpo get-preu_cost))
       )

       (printout t crlf "*** Menú " ?i " ***" crlf)
       (printout t "  Entrant:   " ?npr "  [" ?ppr " €]" crlf)
       (printout t "  Principal: " ?nsg "  [" ?psg " €]" crlf)
       (printout t "  Postres:   " ?npo "  [" ?ppo " €]" crlf)
       (if (eq ?bm general)
               then (printout t "  Beguda Recomanada: " ?nbg "  [" ?pbg " €]" crlf)
               else (printout t "  Beguda Entrant:   " ?nbpr "  [" ?pbpr " €]" crlf)
                    (printout t "  Beguda Principal: " ?nbsg "  [" ?pbsg " €]" crlf)
                    (printout t "  Beguda Postres:   " ?nbpo "  [" ?pbpo " €]" crlf)
            )

     )
  )

  (assert (menus-presentats-grup (gid ?gid)))
)

;; PAS 5: COMPOSICIÓ DE MENÚS -------------------------------
(defrule ComposicioMenus::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
  (peticio (beguda-mode ?bm))
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


  ; Recollim noms de begudes finals
  (bind ?begudes-valides (find-all-facts ((?bf beguda-valida-final)) TRUE))
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


  (bind ?limit (min (length$ ?primers) (length$ ?segons) (length$ ?postres) 3))

  (if (<= ?limit 0) then
     (printout t crlf "*** No s'han trobat menus per mostrar dins del pressupost. ***" crlf)
   else
     (printout t crlf "Et proposem " ?limit " menus dins del pressupost:" crlf)
     (loop-for-count (?i 1 ?limit)
      (bind ?pr  (nth$ ?i ?primers))
      (bind ?sg  (nth$ ?i ?segons))
      (bind ?po  (nth$ ?i ?postres))
      (if (eq ?bm general)
                  then (bind ?bg (nth$ ?i ?b-generals))
                  else 
                    (bind ?bpr (nth$ ?i ?b-primers))
                    (bind ?bsg (nth$ ?i ?b-segons))
                    (bind ?bpo (nth$ ?i ?b-postres))
      )
      (bind ?npr (send ?pr get-nom))
      (bind ?nsg (send ?sg get-nom))
      (bind ?npo (send ?po get-nom))
      (if (eq ?bm general)
                  then (bind ?nbg (send ?bg get-nom))
                  else 
                    (bind ?nbpr (send ?bpr get-nom))
                    (bind ?nbsg (send ?bsg get-nom))
                    (bind ?nbpo (send ?bpo get-nom))
      )

      ;; busca preu-venta de cada plat
      (bind ?ppr (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npr))) valor))
      (bind ?psg (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?nsg))) valor))
      (bind ?ppo (fact-slot-value (nth$ 1 (find-all-facts ((?f preu-venta)) (eq (fact-slot-value ?f nom) ?npo))) valor))
      (if (eq ?bm general)
                then (bind ?pbg (send ?bg get-preu_cost))
                else 
                  (bind ?pbpr (send ?bpr get-preu_cost))
                  (bind ?pbsg (send ?bsg get-preu_cost))
                  (bind ?pbpo (send ?bpo get-preu_cost))
      )


      (if (eq ?bm general)
               then (bind ?total (+ ?ppr ?psg ?ppo ?pbg))
               else (bind ?total (+ ?ppr ?psg ?ppo ?pbpr ?pbsg ?pbpo))
      )

      (printout t crlf "*** Menu " ?i " ***" crlf)
      (printout t "  Entrant:   " ?npr "  [" ?ppr " €]" crlf)
      (printout t "  Principal: " ?nsg "  [" ?psg " €]" crlf)
      (printout t "  Postres:   " ?npo "  [" ?ppo " €]" crlf)
      (if (eq ?bm general)
               then (printout t "  Beguda Recomanada: " ?nbg "  [" ?pbg " €]" crlf)
               else (printout t "  Beguda Entrant:   " ?nbpr "  [" ?pbpr " €]" crlf)
                    (printout t "  Beguda Principal: " ?nbsg "  [" ?pbsg " €]" crlf)
                    (printout t "  Beguda Postres:   " ?nbpo "  [" ?pbpo " €]" crlf)
            )
      (printout t "  ----------------------------------------------------------------------" crlf)
      (printout t "  TOTAL per persona: " ?total " €" crlf)
     )
  )
  (assert (menus-presentats))
)