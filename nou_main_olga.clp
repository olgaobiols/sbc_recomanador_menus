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
  (slot alergies-si (type SYMBOL STRING) (default nil))
  (multislot alergen (type STRING SYMBOL))
) 

(deftemplate grup
  (slot nom (type STRING))
  (multislot dietes (type SYMBOL))
  (multislot alergens-prohibits (type SYMBOL))
)

(deftemplate plat-valid-final
  (slot nom))

(deftemplate beguda-valida-final
  (slot nom))

(deftemplate plat-valid-grup
  (slot grup)
  (slot nom))

(deftemplate beguda-valida-grup
  (slot grup)
  (slot nom))

(deftemplate menu-valid
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT)))

(deftemplate menu-seleccionat
  (slot idx (type INTEGER))
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT)))

(deffunction trim (?value)
  (bind ?text (str-cat ?value))
  (bind ?length (str-length ?text))
  (if (<= ?length 0) then (return ""))
  (bind ?whites (create$ " " (format nil "%c" 9) (format nil "%c" 10) (format nil "%c" 13)))
  (bind ?start 1)
  (while (and (<= ?start ?length)
              (member$ (sub-string ?start ?start ?text) ?whites))
    (bind ?start (+ ?start 1)))
  (if (> ?start ?length) then (return ""))
  (bind ?end ?length)
  (while (and (>= ?end ?start)
              (member$ (sub-string ?end ?end ?text) ?whites))
    (bind ?end (- ?end 1)))
  (if (< ?end ?start) then (return ""))
  (sub-string ?start ?end ?text))

(deffunction norm (?x)
  (lowcase (trim (str-cat ?x))))

;; Dietes -> símbols canònics: {vega, vegetaria, halal, kosher}
(deffunction diet-token->sym (?x)
  (bind ?s (norm ?x))
  (if (or (eq ?s "vg") (eq ?s "vega") (eq ?s "vegan") (eq ?s "vegana") (eq ?s "vegà")) then (return vega))
  (if (or (eq ?s "v") (eq ?s "vegetaria") (eq ?s "vegetari") (eq ?s "vegetariana") (eq ?s "vegetarian")) then (return vegetaria))
  (if (eq ?s "halal") then (return halal))
  (if (eq ?s "kosher") then (return kosher))
  nil)

(deffunction print-dietes-ajuda ()
  (printout t crlf
    "DIETES disponibles (pots combinar-ne diverses):" crlf
    "  - vega        (vegana)" crlf
    "  - vegetaria   (vegetariana)" crlf
    "  - halal" crlf
    "  - kosher" crlf
    "Exemples: 'vega', 'vegetaria halal', 'kosher'." crlf crlf))

(deffunction parse-dietes-resposta (?line)
  (bind ?clean (norm (str-replace (str-replace ?line "," " ") ";" " ")))
  (if (eq ?clean "") then (return (create$)))
  (bind ?OUT (create$))
  (foreach ?tk (explode$ ?clean)
    (bind ?d (diet-token->sym ?tk))
    (if (and ?d (not (member$ ?d ?OUT))) then (bind ?OUT (create$ $?OUT ?d))))
  ?OUT)

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

(deffunction string->ue14-sym (?s)
  (bind ?x (norm ?s))
  (if (eq ?x "gluten") then (return gluten))
  (if (or (eq ?x "llet") (eq ?x "lactosa")) then (return llet))
  (if (or (eq ?x "ou") (eq ?x "ous")) then (return ous))
  (if (eq ?x "peix") then (return peix))
  (if (or (eq ?x "crustaci") (eq ?x "crustacis")) then (return crustacis))
  (if (or (eq ?x "mollusc") (eq ?x "mol·luscs") (eq ?x "molluscs")) then (return molluscs))
  (if (or (eq ?x "fruits") (eq ?x "fruits-secs") (eq ?x "fruits_secs")
          (eq ?x "fruit-sec") (eq ?x "ametlla") (eq ?x "avellana")
          (eq ?x "nou") (eq ?x "festuc") (eq ?x "anacard")) then (return fruits_secs))
  (if (or (eq ?x "cacauet") (eq ?x "cacauets") (eq ?x "peanut") (eq ?x "peanuts")) then (return cacauet))
  (if (eq ?x "soja") then (return soja))
  (if (eq ?x "api") then (return api))
  (if (eq ?x "mostassa") then (return mostassa))
  (if (or (eq ?x "sesam") (eq ?x "sèsam")) then (return sesam))
  (if (or (eq ?x "sulfit") (eq ?x "sulfits")) then (return sulfites))
  (if (or (eq ?x "tramussos") (eq ?x "tramús") (eq ?x "lupin")) then (return tramussos))
  nil)

(deffunction print-ue14-ajuda ()
  (printout t crlf
    "AL·LÈRGENS UE-14 (pots posar números i/o noms, separats per espais o comes):" crlf
    "  1  gluten      2  llet       3  ous        4  peix" crlf
    "  5  crustacis   6  molluscs   7  fruits_secs 8  cacauet" crlf
    "  9  soja       10  api       11  mostassa  12  sesam" crlf
    " 13  sulfites   14  tramussos" crlf
    "Exemples:  '2 7'   |   'llet, fruits_secs'   |   'gluten sesam 14'." crlf crlf))


;; VALIDADORS DE RESPOSTES 
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

(deffunction valida-num-o-indif "Valida una resposta numèrica dins d'un rang però accepta 'indiferent'"
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
      (bind ?fld (string-to-field ?raw))
      (if (numberp ?fld) then
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

(deffunction parse-alergens-resposta (?line)
  (bind ?clean (norm (str-replace (str-replace ?line "," " ") ";" " ")))
  (if (eq ?clean "") then (return (create$)))
  (bind ?OUT (create$))
  (foreach ?tk (explode$ ?clean)
    (if (integerp ?tk) then
      (bind ?sym (ue14-num->sym (integer ?tk)))
      (if (and ?sym (not (member$ ?sym ?OUT))) then (bind ?OUT (create$ $?OUT ?sym))))
    (if (not (integerp ?tk)) then
      (bind ?sym2 (string->ue14-sym ?tk))
      (if (and ?sym2 (not (member$ ?sym2 ?OUT))) then (bind ?OUT (create$ $?OUT ?sym2)))))
  ?OUT)

;; Beguda/Plat: slot 'dietes' ja és SYMBOL → retorn directe
(deffunction get-obj-dietes ($?d)
  (if (multifieldp $?d) then $?d else (create$)))

;; Beguda: slot 'alergens' és STRING → normalitzem a símbols UE-14
(deffunction get-obj-alergens-syms (?obj)
  (bind ?cls (class ?obj))
  (if (not (slot-existp ?cls alergen)) then (return (create$)))
  (bind $?raw (send ?obj get-alergen))
  (bind ?OUT (create$))
  (foreach ?x $?raw
    (bind ?s (string->ue14-sym ?x))
    (if (and ?s (not (member$ ?s ?OUT))) then
      (bind ?OUT (create$ $?OUT ?s))))
  ?OUT)



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

(defrule PreferenciesMenu::preguntar-tipus-esdeveniment
  (declare (auto-focus TRUE))
  ?p <- (peticio (tipus-esdeveniment ?te&nil))
  (not (preguntat-tipus))
=>
  (bind ?res (valida-opcio 
              "Quin tipus d’esdeveniment estàs organitzant? (casament/aniversari/comunio/congrés/empresa/altres)"
              casament aniversari comunio congres empresa altres)  )
  (modify ?p (tipus-esdeveniment ?res))
  (assert (preguntat-tipus)))

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

(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
  (preguntat-alcohol)
  (not (preguntat-alergens-prohibits))
=>
  (bind ?r (valida-boolea "Vols definir grups amb dietes o al·lèrgies específiques?"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits))
  (if (eq ?r no) then
     (assert (respostes-completes))
     (focus AbstraccioHeuristica))
)

(defrule PreferenciesMenu::crear-grups
  (declare (auto-focus TRUE))
  (peticio (alergies-si si))
  (not (grups-creats))
  =>
  (printout t crlf "Perfecte! Definirem grups amb restriccions." crlf)
  (printout t "Quan acabis, escriu 'fi' a la pregunta del nom." crlf)

  (bind ?continuar TRUE)
  (while ?continuar
    (printout t crlf "Nom del grup (o 'fi' per acabar): ")
    (bind ?nom (readline))
    (if (eq (norm ?nom) "fi") then
      (bind ?continuar FALSE)
    else
      (print-dietes-ajuda)
      (printout t "Escriu dietes del grup (o deixa en blanc si cap): " crlf)
      (bind ?diet-line (readline))
      (bind $?dietes (parse-dietes-resposta ?diet-line))

      (print-ue14-ajuda)
      (printout t "Escriu al·lèrgens prohibits (o deixa en blanc si cap): " crlf)
      (bind ?al-line (readline))
      (bind $?alergs (parse-alergens-resposta ?al-line))

      (assert (grup (nom ?nom) (dietes $?dietes) (alergens-prohibits $?alergs)))

      (printout t "→ Grup creat: '" ?nom "'  |  dietes=" $?dietes "  |  alergens=" $?alergs crlf)
    )
  )
  (assert (grups-creats))
  (assert (respostes-completes))
  (focus AbstraccioHeuristica)
)



; fUNCIONS DE VALIDACIÓ DE PLATS SEGONS PREFERÈNCIES
(deffunction check-temperatura (?estacio ?espai ?temp $?ordres)
  (if (member$ ordre-postres $?ordres) then (return TRUE))
  (if (or (eq ?estacio indiferent) (eq ?espai indiferent)) then (return TRUE))
  (if (or (eq ?estacio primavera) (eq ?estacio estiu)) then
      (return (or (eq ?temp "fred") (eq ?temp "tebi")
                  (and (eq ?temp "calent") (eq ?espai interior)))))
  (if (or (eq ?estacio tardor) (eq ?estacio hivern)) then
      (return (or (eq ?temp "calent") (eq ?temp "tebi"))))
  FALSE)

(deffunction check-formalitat (?f ?form-str)
  (or (eq ?f indiferent)
      (and (eq ?f formal)   (eq ?form-str "formal"))
      (and (eq ?f informal) (eq ?form-str "informal"))))

(deffunction check-complexitat (?n ?cx)
  (if (not (numberp ?n)) then (return TRUE))            ; 'indiferent'
  (if (<= ?n 50)  then (return (or (eq ?cx alta) (eq ?cx mitjana) (eq ?cx baixa))))
  (if (and (> ?n 50) (<= ?n 150)) then (return (or (eq ?cx mitjana) (eq ?cx baixa))))
  (if (> ?n 150) then (return (eq ?cx baixa)))
  FALSE)

(deffunction check-dispo (?estacio $?dispo)
  (or (eq ?estacio indiferent) (member$ ?estacio (create$ $?dispo))))

(deffunction check-event (?te $?apte)
  (or (eq ?te indiferent)
      (member$ tots (create$ $?apte))
      (member$ ?te  (create$ $?apte))))

; FUNCIÓ DE VALIDACIÓ DE BEGUDES SEGONS PREFERÈNCIES
(deffunction check-beguda (?f ?alc-pet ?beg $?formalitats)
  (and
    ;; Alcohol: només filtra si l'usuari ho especifica
    (or (eq ?alc-pet indiferent)
        (eq ?alc-pet (send ?beg get-alcohol)))

    ;; Formalitat: relaxada (si no coincideix, però la beguda no especifica res, també OK)
    (or (eq ?f indiferent)
        (member$ ?f $?formalitats)
        (<= (length$ $?formalitats) 0))
  ))

(deffunction beguda-acceptable (?beg ?formalitat-usuari ?alcohol-usuari)
  (bind $?formalitats (send ?beg get-formalitat))
  (check-beguda ?formalitat-usuari ?alcohol-usuari ?beg $?formalitats))

; FUNCIÓ DE VALIDACIÓ D'AL·LÈRGIES I DIETES
;; --- Helper mínima: cerca Ingredient pel nom (string) ---
(deffunction ingredient-by-name (?nom-str)
  (bind ?needle (lowcase (trim (str-cat ?nom-str))))
  (bind ?hits
        (find-all-instances ((?i Ingredient))
          (or (eq (send ?i get-nom) ?nom-str)
              (eq (lowcase (send ?i get-nom)) ?needle))))
  (if (> (length$ ?hits) 0) then (nth$ 1 ?hits) else FALSE))

;; --- SUBSTITUEIX la teva check-alergies-dietes per aquesta ---
(deffunction check-alergies-dietes (?dietes-grup ?obj ?alerg-grup)
  ;; normalitza paràmetres del grup
  (bind $?DG (if (multifieldp ?dietes-grup) then ?dietes-grup else (create$ ?dietes-grup)))
  (bind $?AG (if (multifieldp ?alerg-grup)  then ?alerg-grup  else (create$ ?alerg-grup)))

  (bind ?cls (class ?obj))

  ;; --- CAS 1: Beguda ---
  (if (eq ?cls Beguda) then
    (bind $?d-obj (get-obj-dietes (send ?obj get-dietes)))
    (bind $?a-obj (get-obj-alergens-syms ?obj))

    ;; cap al·lergen prohibit present
    (bind ?alg-ok TRUE)
    (foreach ?a $?AG
      (if (member$ ?a $?a-obj) then (bind ?alg-ok FALSE)))

    ;; dieta: ara és estricte (grup ⊆ beguda)
    (bind ?diet-ok (or (= (length$ $?DG) 0)
                      (subsetp $?DG (create$ $?d-obj))))

    ;; si el grup és halal, l'alcohol ha de ser no
    (if (and ?diet-ok (member$ halal $?DG) (eq (send ?obj get-alcohol) si))
      then (bind ?diet-ok FALSE))

    (return (and ?diet-ok ?alg-ok))
  )

  ;; --- CAS 2: Plat -> derive'm de TOTS els ingredients ---
  (if (eq ?cls Plat) then
    (bind $?noms (send ?obj get-te_ingredients_noms))
    (bind ?ok TRUE)

    (foreach ?nom $?noms
      (if ?ok then
        (bind ?I (ingredient-by-name ?nom))
        (if ?I then
          ;; dietes / al·lèrgens de l'ingredient
          (bind $?ids (get-obj-dietes (send ?I get-dietes)))
          (bind $?ial (get-obj-alergens-syms ?I))

          ;; 2a) al·lèrgens: si n’hi ha un de prohibit -> KO
          (foreach ?a $?AG
            (if (and ?ok (member$ ?a $?ial)) then (bind ?ok FALSE)))

          ;; 2b) dietes: l’ingredient ha de satisfer TOTES les dietes del grup
          (foreach ?d $?DG
            (if ?ok then
              (bind ?ok
                (or
                  (and (eq ?d vega)       (member$ VG $?ids))
                  (and (eq ?d vegetaria)  (or (member$ V $?ids) (member$ VG $?ids)))
                  (and (eq ?d halal)      (member$ HALAL_POT $?ids))
                  (and (eq ?d kosher)     (member$ KOSHER_POT $?ids))
                  ;; si el grup no demana res, o etiqueta desconeguda (no n’hauria d’haver), no tombem
                  (and (= (length$ $?DG) 0) TRUE))))))
        ;; ingredient no trobat -> mode "lax": no tombem
      ))

    (return ?ok)
  )

  ;; Altres classes: no tombem
  TRUE)

;; PAS 2: ABSTRACCIÓ HEURÍSTICA ------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(defrule AbstraccioHeuristica::validar-plat-basic "Condensa tots els filtres en una sola passada i marca plat-valid-final."
  (peticio (data ?estacio) (espai ?espai) (formalitat ?f) (num-comensals ?n) (tipus-esdeveniment ?te))
  ?pl <- (object (is-a Plat) (nom ?nom) (temperatura ?temp) (formalitat ?form-str) (complexitat ?cx) (te_ordre $?ordres) (disponibilitat_plats $?dispo) (apte_esdeveniment $?apte))
  (test (check-temperatura ?estacio ?espai ?temp $?ordres))
  (test (check-formalitat ?f ?form-str))
  (test (check-complexitat ?n ?cx))
  (test (check-dispo ?estacio $?dispo))
  (test (check-event ?te $?apte))
  =>
  (assert (plat-valid-final (nom ?nom)))
)

(defrule AbstraccioHeuristica::validar-beguda-basic
  "Marca com a vàlides les begudes que passen alcohol, formalitat i maridatge coherent amb el mode."
  (peticio (formalitat ?f) (alcohol ?a) (beguda-mode ?bm))
  ?b <- (object (is-a Beguda) (nom ?nom) (formalitat $?formalitats)
                (alcohol ?alc) (maridatge ?mari) (es_general ?gen))
  =>
  ;; Filtra per alcohol i formalitat
  (if (and (or (eq ?a indiferent) (eq ?a ?alc))
           (or (eq ?f indiferent) (member$ ?f $?formalitats)))
    then
      ;; Mode general: accepta només begudes marcades com generals
      (if (and (eq ?bm general) (eq ?gen si))
          then (assert (beguda-valida-final (nom ?nom))))
      ;; Mode per-plat: accepta les que tinguin maridatge específic
      (if (and (eq ?bm per-plat)
               (or (eq ?mari ordre-primer)
                   (eq ?mari ordre-segon)
                   (eq ?mari ordre-postres)))
          then (assert (beguda-valida-final (nom ?nom))))
  )
)

(defrule AbstraccioHeuristica::validar-plat-per-grup
  (grup (nom ?g) (dietes $?dietes) (alergens-prohibits $?alergs))
  ?pl <- (object (is-a Plat) (nom ?nom))
  (test (check-alergies-dietes (create$ $?dietes) ?pl (create$ $?alergs)))
  =>
  (assert (plat-valid-grup (grup ?g) (nom ?nom)))
)

(defrule AbstraccioHeuristica::validar-beguda-per-grup
  (grup (nom ?g) (dietes $?dietes) (alergens-prohibits $?alergs))
  ?b <- (object (is-a Beguda) (nom ?nom))
  (test (check-alergies-dietes (create$ $?dietes) ?b (create$ $?alergs)))
  =>
  (assert (beguda-valida-grup (grup ?g) (nom ?nom)))
)

;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))
;; Disponibilitat: si data = 'indiferent', accepta totes les temporades del plat


;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))
(defmodule ComposicioMenus (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(deffunction menu-apte-per-grup (?mv ?g)
  (bind ?pr (fact-slot-value ?mv primer))
  (bind ?sg (fact-slot-value ?mv segon))
  (bind ?po (fact-slot-value ?mv postres))
  (bind $?bgs (fact-slot-value ?mv begudes))

  (bind ?ok-pr (> (length$ (find-all-facts ((?f plat-valid-grup))
                      (and (eq (fact-slot-value ?f grup) ?g)
                           (eq (fact-slot-value ?f nom)  ?pr)))) 0))
  (bind ?ok-sg (> (length$ (find-all-facts ((?f plat-valid-grup))
                      (and (eq (fact-slot-value ?f grup) ?g)
                           (eq (fact-slot-value ?f nom)  ?sg)))) 0))
  (bind ?ok-po (> (length$ (find-all-facts ((?f plat-valid-grup))
                      (and (eq (fact-slot-value ?f grup) ?g)
                           (eq (fact-slot-value ?f nom)  ?po)))) 0))

  (bind ?ok-bg TRUE)
  (foreach ?b $?bgs
    (if ?ok-bg then
      (bind ?ok-bg (> (length$ (find-all-facts ((?fb beguda-valida-grup))
                            (and (eq (fact-slot-value ?fb grup) ?g)
                                 (eq (fact-slot-value ?fb nom)  ?b)))) 0))))

  (and ?ok-pr ?ok-sg ?ok-po ?ok-bg)
)

(deffunction sort-menus-by-preu ($?menus)
  (bind ?sorted (create$))
  (bind ?prices (sort < (create$ (foreach ?mv ?menus (fact-slot-value ?mv preu)))))
  (foreach ?p ?prices
    (foreach ?mv ?menus
      (if (and (= (fact-slot-value ?mv preu) ?p)
               (not (member$ ?mv ?sorted)))
        then (bind ?sorted (create$ $?sorted ?mv)))))
  ?sorted)

(deffunction menu-fits (?mv ?used-plats ?used-begs)
  (bind $?used-plats-mf (if (multifieldp ?used-plats) then ?used-plats else (create$ ?used-plats)))
  (bind $?used-begs-mf  (if (multifieldp ?used-begs)  then ?used-begs  else (create$ ?used-begs)))

  (bind ?pr (fact-slot-value ?mv primer))
  (bind ?sg (fact-slot-value ?mv segon))
  (bind $?bg (fact-slot-value ?mv begudes))

  ;; unicitat només per primer i segon
  (bind ?conflict (or (member$ ?pr $?used-plats-mf)
                      (member$ ?sg $?used-plats-mf)))

  ;; si el mode és per-plat, també evitem repetir begudes; en "general", NO
  (bind ?pet (nth$ 1 (find-all-facts ((?x peticio)) TRUE)))
  (bind ?bm (fact-slot-value ?pet beguda-mode))
  (if (eq ?bm per-plat) then
    (foreach ?b $?bg
      (if (and (not ?conflict) (member$ ?b $?used-begs-mf)) then
        (bind ?conflict TRUE))))

  (not ?conflict))


;; 2) Selecció comuna: tria fins a 3 menús ordenats per preu, sense repetir plats
;; Tria fins a 3 menús sense repetir CAP plat ni CAP beguda (ordenats per preu)
(deffunction select-3-unique-menus ($?menus)
  ;; Si no hi ha candidats, res
  (if (<= (length$ ?menus) 0) then (return (create$)))

  ;; Extreu pressupost d'usuari
  (bind ?p (nth$ 1 (find-all-facts ((?x peticio)) TRUE)))
  (bind ?umin (fact-slot-value ?p pressupost-min))
  (bind ?umax (fact-slot-value ?p pressupost-max))
  (bind ?bm (fact-slot-value ?p beguda-mode))

  ;; Calcula min/max dels candidats (per fallback i per limitar franges)
  (bind ?prices (create$ (foreach ?mv ?menus (fact-slot-value ?mv preu))))
  (bind ?pmin 1.0e+15) (bind ?pmax -1.0e+15)
  (foreach ?q ?prices
    (if (< ?q ?pmin) then (bind ?pmin ?q))
    (if (> ?q ?pmax) then (bind ?pmax ?q)))

  ;; Si l'usuari ha dit 'indiferent', fem servir extrems dels candidats
  (bind ?lo (if (eq ?umin indiferent) then ?pmin else ?umin))
  (bind ?hi (if (eq ?umax indiferent) then ?pmax else ?umax))
  (if (< ?hi ?lo) then (bind ?tmp ?lo) (bind ?lo ?hi) (bind ?hi ?tmp)) ;; seguretat

  ;; Defineix franges: barat [lo, T1], mitjà (T1, T2), car [T2, hi]
  (bind ?range (- ?hi ?lo))
  (bind ?T1 (+ ?lo (/ ?range 3.0)))
  (bind ?T2 (+ ?lo (* 2 (/ ?range 3.0))))

  ;; Partició per franges (i ordenació dins de cada franja)
  (bind ?cheap (create$)) (bind ?mid (create$)) (bind ?exp (create$))
  (foreach ?mv ?menus
    (bind ?prc (fact-slot-value ?mv preu))
    (if (and (>= ?prc ?lo) (<= ?prc ?T1)) then
      (bind ?cheap (create$ $?cheap ?mv))
    else
      (if (and (> ?prc ?T1) (< ?prc ?T2)) then
        (bind ?mid (create$ $?mid ?mv))
      else
        (if (and (>= ?prc ?T2) (<= ?prc ?hi)) then
          (bind ?exp (create$ $?exp ?mv))))))

  (bind ?cheap (sort-menus-by-preu $?cheap))
  (bind ?mid   (sort-menus-by-preu $?mid))
  (bind ?exp   (sort-menus-by-preu $?exp))

  ;; Selecció: assegurar unicitat de PLATS i BEGUDES
  (bind ?picked (create$))
  (bind ?used-plats (create$))
  (bind ?used-begs  (create$))

  ;; 1) BARAT
  (foreach ?mv ?cheap
    (if (and (< (length$ ?picked) 1) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (if (eq ?bm per-plat) then
          (foreach ?b $?bg
            (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))))
  ))
  ;; 2) MITJÀ (el primer que compleix; ja van ordenats)
  (foreach ?mv ?mid
    (if (and (< (length$ ?picked) 2) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (foreach ?b $?bg
          (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))))

  ;; 3) CAR
  (foreach ?mv ?exp
    (if (and (< (length$ ?picked) 3) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (foreach ?b $?bg
          (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))))

  ;; Fallback: si encara no n’hi ha 3, omple amb la resta de candidats per preu
  (if (< (length$ ?picked) 3) then
    (bind ?rest (sort-menus-by-preu $?menus))
    (foreach ?mv ?rest
      (if (and (< (length$ ?picked) 3)
               (not (member$ ?mv ?picked))
               (menu-fits ?mv ?used-plats ?used-begs))
        then
          (bind ?picked (create$ $?picked ?mv))
          (bind ?pr (fact-slot-value ?mv primer))
          (bind ?sg (fact-slot-value ?mv segon))
          (bind ?po (fact-slot-value ?mv postres))
          (bind $?bg (fact-slot-value ?mv begudes))
          (foreach ?dish (create$ ?pr ?sg)
            (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
          (foreach ?b $?bg
            (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b)))))))

  ?picked)

(deffunction print-menu-block (?idx ?primer ?segon ?postres ?preu $?begudes)
  (printout t crlf "*** Menú " ?idx " ***" crlf)
  (printout t "  Entrant:   " ?primer  crlf)
  (printout t "  Principal: " ?segon   crlf)
  (printout t "  Postres:   " ?postres crlf)
  (printout t "  Begudes:   " (if (> (length$ (create$ $?begudes)) 0)
                                  then (implode$ $?begudes)
                                  else "--") crlf)
  (printout t "  TOTAL:     " ?preu " €" crlf)
  (printout t "  ----------------------------------------" crlf))


;; 3) Templates per marcar el que s'ha presentat per grup (no barrejar amb el general)
(deftemplate menus-presentats-grup (slot grup))
(deftemplate menu-seleccionat-grup
  (slot grup)
  (slot idx (type INTEGER))
  (slot primer)
  (slot segon)
  (slot postres)
  (multislot begudes)
  (slot preu (type FLOAT))
)

;; --- Compatibilitat entre primer/segon/postres (minimalista) ---
(deffunction compat-ok (?pr ?sg ?po)
  (bind ?c1 (send ?pr get-categoria))
  (bind ?c2 (send ?sg get-categoria))
  (bind ?c3 (send ?po get-categoria))
  (bind ?m1 (send ?pr get-mida_racio))
  (bind ?m2 (send ?sg get-mida_racio))
  (bind ?m3 (send ?po get-mida_racio))

  ;; 1) Mides: com a màxim un GRAN
  (bind ?gran 0)
  (if (eq ?m1 gran) then (bind ?gran (+ ?gran 1)))
  (if (eq ?m2 gran) then (bind ?gran (+ ?gran 1)))
  (if (eq ?m3 gran) then (bind ?gran (+ ?gran 1)))
  (if (> ?gran 1) then (return FALSE))

  ;; 2) Farinaci doble (entrant + principal) no
  (bind ?far1 (eq ?c1 farinaci_entrant))
  (bind ?far2 (eq ?c2 farinaci_principal))
  (if (and ?far1 ?far2) then (return FALSE))

  ;; 3) Parella pesada entrant→segon
  (bind ?heavy1 (or (eq ?c1 sopa_crema) (eq ?c1 entrant_calent) (eq ?c1 farinaci_entrant)))
  (bind ?heavy2 (or (eq ?c2 guisat) (eq ?c2 forn_brasa) (eq ?c2 carn)
                    (eq ?c2 farinaci_principal) (eq ?c2 entrant_calent)))
  (if (and ?heavy1 ?heavy2) then (return FALSE))

  ;; 4) Postres molt pesades si 1 i 2 ja són pesats
  (bind ?dessHeavy (or (eq ?c3 xoco_intens) (eq ?c3 pastisseria)))
  (if (and ?heavy1 ?heavy2 ?dessHeavy) then (return FALSE))

  TRUE)

(deffunction origen-compatible (?pr ?sg ?po)
  (bind ?p1 (lowcase (send ?pr get-procedencia_plat)))
  (bind ?p2 (lowcase (send ?sg get-procedencia_plat)))
  (bind ?p3 (lowcase (send ?po get-procedencia_plat)))

  ;; Si alguna procedència és "internacional" o "tots", la considerem neutra
  (bind ?neutres (create$ "internacional" "tots" "altres" ""))

  ;; Nombre de procedències úniques (sense neutres)
  (bind $?ori (create$))
  (foreach ?o (create$ ?p1 ?p2 ?p3)
    (if (and (not (member$ ?o ?neutres)) (not (member$ ?o $?ori)))
      then (bind $?ori (create$ $?ori ?o))))

  ;; Permetem fins a 2 orígens forts (p. ex. "Itàlia" + "França")
  (if (> (length$ $?ori) 2) then (return FALSE))
  TRUE)

(deffunction categoria-pes (?cat)
  (if (or (eq ?cat sopa_crema) (eq ?cat amanida_fresca) (eq ?cat entrant_fred) (eq ?cat vegetal_entrant))
      then (return 1))  ;; lleuger
  (if (or (eq ?cat farinaci_entrant) (eq ?cat entrant_calent) (eq ?cat vegetal_proteic))
      then (return 2))  ;; mig
  (if (or (eq ?cat carn) (eq ?cat aus) (eq ?cat peix) (eq ?cat marisc)
          (eq ?cat forn_brasa) (eq ?cat guisat) (eq ?cat farinaci_principal))
      then (return 3))  ;; pesat
  (return 1))           ;; per defecte

(deffunction equilibri-categoria (?pr ?sg ?po)
  (bind ?p1 (categoria-pes (send ?pr get-categoria)))
  (bind ?p2 (categoria-pes (send ?sg get-categoria)))
  (bind ?p3 (categoria-pes (send ?po get-categoria)))
  (bind ?max (max ?p1 ?p2 ?p3))
  (bind ?min (min ?p1 ?p2 ?p3))
  ;; abans: (if (<= (- ?max ?min) 0) then (return FALSE))
  ;; ara permet igualtat
  TRUE)


;; ====== GENERADOR DE MENÚS — versió curta, sense helpers nous ======
(defrule ComposicioMenus::generar-menus-valids
  (declare (auto-focus TRUE))
  (respostes-completes)
  ?req <- (peticio (beguda-mode ?bm) (pressupost-min ?pmin) (pressupost-max ?pmax) (formalitat ?form) (alcohol ?alc))
  (not (menus-generats))
=>
  ;; Normalitza rang pressupost
  (bind ?LO (if (eq ?pmin indiferent) then 0.0 else ?pmin))
  (bind ?HI (if (eq ?pmax indiferent) then 1.0e+15 else ?pmax))

  ;; Plats vàlids per ordre
  (bind ?primers (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (member$ ordre-primer (send ?p get-te_ordre)))))
  (bind ?segons  (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (member$ ordre-segon (send ?p get-te_ordre)))))
  (bind ?postres (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (member$ ordre-postres (send ?p get-te_ordre)))))

  (bind ?primers (subseq$ ?primers 1 (min 70 (length$ ?primers))))
  (bind ?segons  (subseq$ ?segons  1 (min 70 (length$ ?segons))))
  (bind ?postres (subseq$ ?postres 1 (min 50 (length$ ?postres))))

  ;; Begudes candidates filtrades segons preferències declarades
  (bind ?bG (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-es_general) si)
                 (beguda-acceptable ?b ?form ?alc))))
  (bind ?bPr (find-all-instances ((?b Beguda))
             (and (eq (send ?b get-maridatge) ordre-primer)
                  (beguda-acceptable ?b ?form ?alc))))
  (bind ?bSg (find-all-instances ((?b Beguda))
             (and (eq (send ?b get-maridatge) ordre-segon)
                  (beguda-acceptable ?b ?form ?alc))))
  (bind ?bPo (find-all-instances ((?b Beguda))
             (and (eq (send ?b get-maridatge) ordre-postres)
                  (beguda-acceptable ?b ?form ?alc))))

  ;; --- Filtra begudes segons dietes/al·lèrgens globals si l'usuari n'ha definit ---
  (bind ?glob (find-all-facts ((?p peticio)) TRUE))
  (if (> (length$ ?glob) 0) then
    (bind ?pg (nth$ 1 ?glob))
    (bind ?flag (fact-slot-value ?pg alergies-si))
    (if (eq ?flag si) then
      (bind $?grups (find-all-facts ((?g grup)) TRUE))
      (foreach ?g $?grups
        (bind $?diet (fact-slot-value ?g dietes))
        (bind $?alrg (fact-slot-value ?g alergens-prohibits))
        ;; mantén només begudes aptes per almenys un grup
        (bind ?bG (create$ (foreach ?b ?bG
                        (if (check-alergies-dietes (create$ $?diet) ?b (create$ $?alrg)) then ?b))))
        (bind ?bPr (create$ (foreach ?b ?bPr
                        (if (check-alergies-dietes (create$ $?diet) ?b (create$ $?alrg)) then ?b))))
        (bind ?bSg (create$ (foreach ?b ?bSg
                        (if (check-alergies-dietes (create$ $?diet) ?b (create$ $?alrg)) then ?b))))
        (bind ?bPo (create$ (foreach ?b ?bPo
                        (if (check-alergies-dietes (create$ $?diet) ?b (create$ $?alrg)) then ?b)))))))


  ;; Tria la BEGUDA més barata de cada llista (inline, amb protecció d'instàncies)
  (bind ?BG FALSE) (bind ?BGp 0.0)
  (if (> (length$ ?bG) 0) then
    (foreach ?x ?bG
      (if (and ?x (instancep ?x)) then
        (bind ?px (send ?x get-preu_cost))
        (if (or (not ?BG) (< ?px ?BGp)) then
          (bind ?BG ?x) (bind ?BGp ?px)))))

  (bind ?BPR FALSE) (bind ?BPRp 0.0)
  (if (> (length$ ?bPr) 0) then
    (foreach ?x ?bPr
      (if (and ?x (instancep ?x)) then
        (bind ?px (send ?x get-preu_cost))
        (if (or (not ?BPR) (< ?px ?BPRp)) then
          (bind ?BPR ?x) (bind ?BPRp ?px)))))

  (bind ?BSG FALSE) (bind ?BSGp 0.0)
  (if (> (length$ ?bSg) 0) then
    (foreach ?x ?bSg
      (if (and ?x (instancep ?x)) then
        (bind ?px (send ?x get-preu_cost))
        (if (or (not ?BSG) (< ?px ?BSGp)) then
          (bind ?BSG ?x) (bind ?BSGp ?px)))))

  (bind ?BPO FALSE) (bind ?BPOp 0.0)
  (if (> (length$ ?bPo) 0) then
    (foreach ?x ?bPo
      (if (and ?x (instancep ?x)) then
        (bind ?px (send ?x get-preu_cost))
        (if (or (not ?BPO) (< ?px ?BPOp)) then
          (bind ?BPO ?x) (bind ?BPOp ?px)))))


  ;; Multiplicador de formalitat (únic)
  (bind ?Ffor (if (eq ?form formal) then 1.30 else 1.0))

  ;; Combinacions de plats
  (foreach ?pr ?primers
    (foreach ?sg ?segons
      (foreach ?po ?postres
        (if (and (compat-ok ?pr ?sg ?po)
                 (origen-compatible ?pr ?sg ?po)
                 (equilibri-categoria ?pr ?sg ?po))
            then
          (progn
            ;; ====== preu inline de cada plat ======
            ;; PRIMER
            (bind ?pc1 (send ?pr get-preu_cost))
            (bind ?cx1 (send ?pr get-complexitat))
            (bind ?md1 (send ?pr get-mida_racio))
            (bind ?n1  (length$ (send ?pr get-disponibilitat_plats)))
            (bind ?Fcx1 (if (eq ?cx1 alta) then 1.35 else (if (eq ?cx1 mitjana) then 1.15 else 1.0)))
            (bind ?Fmd1 (if (eq ?md1 gran) then 1.10 else (if (eq ?md1 petita) then 0.90 else 1.0)))
            (bind ?Fdis1 (if (>= ?n1 4) then 1.00 else (if (eq ?n1 3) then 1.05 else (if (eq ?n1 2) then 1.10 else 1.20))))
            (bind ?p1 (* ?pc1 ?Fcx1 ?Fmd1 ?Fdis1 ?Ffor))
            (bind ?p1 (max ?p1 5.50))  ;; mínim primer
            (bind ?p1 (/ (round (* ?p1 100)) 100.0))
            ;; SEGON
            (bind ?pc2 (send ?sg get-preu_cost))
            (bind ?cx2 (send ?sg get-complexitat))
            (bind ?md2 (send ?sg get-mida_racio))
            (bind ?n2  (length$ (send ?sg get-disponibilitat_plats)))
            (bind ?Fcx2 (if (eq ?cx2 alta) then 1.35 else (if (eq ?cx2 mitjana) then 1.15 else 1.0)))
            (bind ?Fmd2 (if (eq ?md2 gran) then 1.10 else (if (eq ?md2 petita) then 0.90 else 1.0)))
            (bind ?Fdis2 (if (>= ?n2 4) then 1.00 else (if (eq ?n2 3) then 1.05 else (if (eq ?n2 2) then 1.10 else 1.20))))
            (bind ?p2 (* ?pc2 ?Fcx2 ?Fmd2 ?Fdis2 ?Ffor))
            (bind ?p2 (max ?p2 9.00))  ;; mínim segon
            (bind ?p2 (/ (round (* ?p2 100)) 100.0))
            ;; POSTRES
            (bind ?pc3 (send ?po get-preu_cost))
            (bind ?cx3 (send ?po get-complexitat))
            (bind ?md3 (send ?po get-mida_racio))
            (bind ?n3  (length$ (send ?po get-disponibilitat_plats)))
            (bind ?Fcx3 (if (eq ?cx3 alta) then 1.35 else (if (eq ?cx3 mitjana) then 1.15 else 1.0)))
            (bind ?Fmd3 (if (eq ?md3 gran) then 1.10 else (if (eq ?md3 petita) then 0.90 else 1.0)))
            (bind ?Fdis3 (if (>= ?n3 4) then 1.00 else (if (eq ?n3 3) then 1.05 else (if (eq ?n3 2) then 1.10 else 1.20))))
            (bind ?p3 (* ?pc3 ?Fcx3 ?Fmd3 ?Fdis3 ?Ffor))
            (bind ?p3 (max ?p3 3.00))  ;; mínim postres
            (bind ?p3 (/ (round (* ?p3 100)) 100.0))

            (bind ?base (+ ?p1 ?p2 ?p3))

            ;; ====== Decideix begudes i asserta UN sol menú per combinació ======
            (if (eq ?bm general) then
              (if (and ?BG (>= (+ ?base ?BGp) ?LO) (<= (+ ?base ?BGp) ?HI)) then
                (assert (menu-valid
                          (primer (send ?pr get-nom))
                          (segon  (send ?sg get-nom))
                          (postres (send ?po get-nom))
                          (begudes (create$ (send ?BG get-nom)))
                          (preu (+ ?base ?BGp))))
              else
                (if (and (>= ?base ?LO) (<= ?base ?HI)) then
                  (assert (menu-valid
                            (primer (send ?pr get-nom))
                            (segon  (send ?sg get-nom))
                            (postres (send ?po get-nom))
                            (begudes (create$))
                            (preu ?base))))))
             else
              (bind ?ok3 (and ?BPR ?BSG ?BPO))
              (bind ?bSum (if ?ok3 then (+ ?BPRp ?BSGp ?BPOp) else 0.0))
              (if (and ?ok3 (>= (+ ?base ?bSum) ?LO) (<= (+ ?base ?bSum) ?HI)) then
                (assert (menu-valid
                          (primer (send ?pr get-nom))
                          (segon  (send ?sg get-nom))
                          (postres (send ?po get-nom))
                          (begudes (create$ (send ?BPR get-nom) (send ?BSG get-nom) (send ?BPO get-nom)))
                          (preu (+ ?base ?bSum))))
              else
                (if (and (>= ?base ?LO) (<= ?base ?HI)) then
                  (assert (menu-valid
                            (primer (send ?pr get-nom))
                            (segon  (send ?sg get-nom))
                            (postres (send ?po get-nom))
                            (begudes (create$))
                            (preu ?base)))))))
        )
  (assert (menus-generats))
  )
))

;; 4) Impressió de 3 menús per cada grup definit
(defrule ComposicioMenus::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
  =>
  (bind ?menus (find-all-facts ((?m menu-valid)) TRUE))
  (bind ?n (length$ ?menus))

  (if (<= ?n 0) then
    (printout t crlf "*** No hi ha menús vàlids dins del pressupost. ***" crlf)
    (assert (menus-presentats))
   else
    (printout t crlf "=== MENÚS DISPONIBLES (" ?n " en total) ===" crlf)

    ;; Tria top-3 sense repetir plats
    (bind ?picked (select-3-unique-menus $?menus))

    ;; Neteja menús seleccionats previs
    (foreach ?old (find-all-facts ((?x menu-seleccionat)) TRUE) (retract ?old))

    (bind ?nsel (length$ ?picked))
    (if (<= ?nsel 0) then
      (printout t crlf "*** No hi ha menús que compleixin la unicitat de plats. ***" crlf)
     else
      (printout t crlf "=== MENÚS DISPONIBLES (" ?nsel " únics) ===" crlf)
      (bind ?index 1)
      (foreach ?m ?picked
        (bind ?pr   (fact-slot-value ?m primer))
        (bind ?sg   (fact-slot-value ?m segon))
        (bind ?po   (fact-slot-value ?m postres))
        (bind $?bgs (fact-slot-value ?m begudes))
        (bind ?preu (fact-slot-value ?m preu))

        (print-menu-block ?index ?pr ?sg ?po ?preu $?bgs)

        (assert (menu-seleccionat
                  (idx ?index)
                  (primer  ?pr)
                  (segon   ?sg)
                  (postres ?po)
                  (begudes $?bgs)
                  (preu    ?preu)))
        (bind ?index (+ ?index 1))
      )
    )
    (assert (menus-presentats))
  )
)

(defrule ComposicioMenus::mostrar-menus-per-grup
  (declare (auto-focus TRUE))
  (menus-presentats)                       ;; ja hem acabat el general
  (grup (nom ?g))
  (not (menus-presentats-grup (grup ?g)))
  =>
  (bind ?tots (find-all-facts ((?m menu-valid)) TRUE))

  ;; Filtra només menús aptes per al grup ?g
  (bind ?cand (create$))
  (foreach ?mv ?tots
    (if (menu-apte-per-grup ?mv ?g) then
      (bind ?cand (create$ $?cand ?mv))))

  ;; Tria top-3 sense repetir plats
  (bind ?picked (select-3-unique-menus $?cand))

  (printout t crlf "=== MENÚS PER AL GRUP: " ?g " ===" crlf)
  (if (<= (length$ ?picked) 0) then
    (printout t "*** No hi ha menús aptes per aquest grup. ***" crlf)
   else
    (bind ?idx 1)
    (foreach ?m ?picked
      (bind ?pr   (fact-slot-value ?m primer))
      (bind ?sg   (fact-slot-value ?m segon))
      (bind ?po   (fact-slot-value ?m postres))
      (bind $?bgs (fact-slot-value ?m begudes))
      (bind ?preu (fact-slot-value ?m preu))

      (print-menu-block ?idx ?pr ?sg ?po ?preu $?bgs)

      (assert (menu-seleccionat-grup
                (grup ?g)
                (idx ?idx)
                (primer  ?pr)
                (segon   ?sg)
                (postres ?po)
                (begudes $?bgs)
                (preu    ?preu)))
      (bind ?idx (+ ?idx 1))
    )
  )
  (assert (menus-presentats-grup (grup ?g)))
)