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

(deftemplate abstraccio-finalitzada)

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

;; AFEGIT PER GESTIONAR IMPRESSIÓ JUSTIFICACIÓ (he pujat templates a dalt per que funcioni)
(deftemplate frase-grups-impresa)
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

(deffunction print-justificacio-global ()
  (bind ?SEL (find-all-facts ((?m menu-seleccionat)) TRUE))
  (if (<= (length$ ?SEL) 0) then (return))
  (bind ?E (nth$ 1 (find-all-instances ((?x Esdeveniment)) TRUE)))
  (if ?E then
    (bind ?tipus   (send ?E get-ocasio))
    (bind ?estacio (send ?E get-data))
    (bind ?espai   (send ?E get-interior))
    (bind ?ncom    (send ?E get-num_comensals))
    (bind ?lo      (send ?E get-pressupost_min))
    (bind ?hi      (send ?E get-pressupost_max))
    (bind ?form    (send ?E get-formalitat))
    (bind ?bm      (send ?E get-beguda_mode))
    (bind ?alc     (send ?E get-alcohol))
   else
    (bind ?P (nth$ 1 (find-all-facts ((?p peticio)) TRUE)))
    (bind ?tipus   (fact-slot-value ?P tipus-esdeveniment))
    (bind ?estacio (fact-slot-value ?P data))
    (bind ?espai   (fact-slot-value ?P espai))
    (bind ?ncom    (fact-slot-value ?P num-comensals))
    (bind ?lo      (fact-slot-value ?P pressupost-min))
    (bind ?hi      (fact-slot-value ?P pressupost-max))
    (bind ?form    (fact-slot-value ?P formalitat))
    (bind ?bm      (fact-slot-value ?P beguda-mode))
    (bind ?alc     (fact-slot-value ?P alcohol)))


  ;; Rang de preus reals
  (bind ?preus (create$))
  (foreach ?m ?SEL
    (bind ?preu (fact-slot-value ?m preu))
    (bind ?preus (create$ $?preus ?preu)))
  (bind ?pmin (nth$ 1 (sort < ?preus)))
  (bind ?pmax (nth$ (length$ ?preus) (sort < ?preus)))

  ;; Begudes
  (bind ?begudes (create$))
  (foreach ?m ?SEL
    (bind $?bgs (fact-slot-value ?m begudes))
    (foreach ?b $?bgs
      (if (not (member$ ?b ?begudes)) then
        (bind ?begudes (create$ $?begudes ?b)))))
  (bind ?bgs-str (if (> (length$ ?begudes) 0)
                    then (implode$ ?begudes)
                    else "les begudes seleccionades"))

  ;; Etiquetes textuals
  (bind ?modeStr (if (eq ?bm general) then "general" else "per plat"))
  (bind ?alcText
        (if (eq ?alc si) then "amb alcohol"
         else (if (eq ?alc no) then "sense alcohol"
               else "amb o sense alcohol segons preferència")))

  ;; --- Introducció general ---
  (printout t crlf)
  (printout t
    "Les propostes seleccionades s’ajusten a les preferències indicades per l’usuari. "
    "L’esdeveniment és de tipus " ?tipus ", amb un nivell de formalitat " ?form
    ", previst per a " ?estacio " en espai " ?espai ", "
    "per a un total de " ?ncom " comensals i amb un pressupost per persona entre "
    ?lo " € i " ?hi " €. "
    "Els menús seleccionats es troben dins d’aquest marge, amb preus reals entre "
    ?pmin " € i " ?pmax " €." crlf crlf)

  ;; --- Condicions aplicades ---
  (printout t
    "Les principals condicions aplicades han estat:" crlf crlf)

  ;; Estació i espai
  (if (and (or (eq ?estacio primavera) (eq ?estacio estiu))
           (eq ?espai exterior)) then
    (printout t
      "• En ser un esdeveniment exterior en temporada càlida, s’han prioritzat plats freds o tebis, lleugers i refrescants." crlf))
  (if (and (or (eq ?estacio primavera) (eq ?estacio estiu))
           (eq ?espai interior)) then
    (printout t
      "• En ser un esdeveniment interior en temporada càlida, s’han prioritzat elaboracions fresques o de cocció curta." crlf))
  (if (or (eq ?estacio tardor) (eq ?estacio hivern)) then
    (printout t
      "• En ser una estació freda, s’han seleccionat plats calents o tebis, amb productes de temporada." crlf))
  (if (eq ?estacio indiferent) then
    (printout t
      "• No s’han aplicat restriccions per estació ni espai." crlf))

  ;; Tipus d’esdeveniment
  (if (eq ?tipus casament) then
    (printout t
      "• Com que es tracta d’un casament, s’han escollit plats de complexitat mitjana o alta i racions mitjanes o grans, amb un to celebratiu i cuidat." crlf))
  (if (eq ?tipus aniversari) then
    (printout t
      "• En ser un aniversari, s’han prioritzat plats de complexitat mitjana o baixa i racions petites o mitjanes, per afavorir un ambient festiu i distès." crlf))
  (if (eq ?tipus comunio) then
    (printout t
      "• Per a una comunió, s’han seleccionat plats suaus i equilibrats, adequats per a un públic familiar." crlf))
  (if (eq ?tipus congres) then
    (printout t
      "• En tractar-se d’un congrés, s’han escollit plats petits i de baixa complexitat per facilitar un servei àgil i còmode." crlf))
  (if (eq ?tipus empresa) then
    (printout t
      "• Per a un esdeveniment d’empresa, s’han mantingut plats de complexitat mitjana o baixa i racions petites o mitjanes, coherents amb un entorn professional." crlf))
  (if (eq ?tipus altres) then
    (printout t
      "• En no especificar un tipus concret d’esdeveniment, s’han mantingut criteris generals d’equilibri i coherència." crlf))

  ;; Formalitat
  (if (eq ?form formal) then
    (printout t
      "• En indicar un esdeveniment formal, només s’han inclòs plats i begudes amb presentacions i característiques formals." crlf))
  (if (eq ?form informal) then
    (printout t
      "• En indicar un esdeveniment informal, s’han seleccionat propostes més senzilles i de presentació relaxada." crlf))

  ;; Nombre de comensals
  (if (and (numberp ?ncom) (<= ?ncom 50)) then
    (printout t
      "• Amb menys de 50 comensals, s’han permès totes les complexitats de plats." crlf))
  (if (and (numberp ?ncom) (> ?ncom 50) (<= ?ncom 150)) then
    (printout t
      "• Entre 50 i 150 comensals, s’han descartat plats d’alta complexitat per assegurar un servei àgil." crlf))
  (if (and (numberp ?ncom) (> ?ncom 150)) then
    (printout t
      "• Amb més de 150 comensals, només s’han acceptat plats de complexitat baixa per facilitar la producció i el servei." crlf))

  ;; Maridatge
  (if (and (eq ?bm general) (eq ?alc no)) then
    (printout t
      "• S’ha aplicat maridatge general sense alcohol, buscant begudes equilibrades i refrescants." crlf))
  (if (and (eq ?bm general) (eq ?alc si)) then
    (printout t
      "• S’ha aplicat maridatge general amb alcohol, amb begudes que complementen el to festiu." crlf))
  (if (eq ?bm per-plat) then
    (printout t
      "• S’ha aplicat maridatge per plat, amb begudes associades específicament a cada elaboració." crlf))
  (if (eq ?alc indiferent) then
    (printout t
      "• Com que la preferència d’alcohol és indiferent, s’han considerat opcions amb i sense alcohol." crlf))
  (printout t
    "• Begudes seleccionades: " ?bgs-str "." crlf)

  ;; Grups amb restriccions
  (bind ?SELGR (find-all-facts ((?g menu-seleccionat-grup)) TRUE))
  (if (> (length$ ?SELGR) 0) then
    (printout t
      "• S’han generat menús específics per a grups amb dietes o al·lèrgies, garantint la compatibilitat dels ingredients i begudes." crlf))
  (if (<= (length$ ?SELGR) 0) then
    (printout t
      "• No s’han definit grups amb dietes o al·lèrgies, de manera que no s’han aplicat filtres addicionals." crlf))

  ;; Tancament
  (printout t crlf
    "En resum, les propostes finals respecten totes les preferències introduïdes i els criteris de coherència entre plats, estació, pressupost i maridatge." crlf crlf)
)

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

;; Beguda: slot 'alergen' pot venir com string únic → normalitzem a símbols UE-14
(deffunction get-obj-alergens-syms (?obj)
  (bind ?cls (class ?obj))
  (if (not (slot-existp ?cls alergen)) then (return (create$)))
  (bind ?slotVal (send ?obj get-alergen))
  (if (or (eq ?slotVal FALSE) (eq ?slotVal nil)) then (return (create$)))
  (bind $?vals (create$))
  (if (multifieldp ?slotVal)
      then (bind $?vals ?slotVal)
      else
        (if (or (lexemep ?slotVal) (numberp ?slotVal))
            then (bind $?vals (create$ ?slotVal))))
  (bind ?OUT (create$))
  (foreach ?x $?vals
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
  (printout t crlf crlf "Benvingut/da al recomanador de menús RicoRico!" crlf crlf)
  (printout t "T’ajudaré a trobar el menú ideal per al teu esdeveniment." crlf)
  (printout t "Et faré algunes preguntes curtes. Si no tens clara la resposta encara, pots respondre 'indiferent'." crlf crlf)
  (assert (peticio))
  (focus PreferenciesMenu))

(defrule PreferenciesMenu::preguntar-tipus-esdeveniment
  (declare (auto-focus TRUE))
  ?p <- (peticio (tipus-esdeveniment ?te&nil))
  (not (preguntat-tipus))
=>
  (printout t crlf "Comencem!" crlf)
  (bind ?res (valida-opcio 
              "Quin tipus d’esdeveniment estàs organitzant? (casament/aniversari/comunio/congres/empresa/altres)"
              casament aniversari comunio congres empresa altres)  )
  (modify ?p (tipus-esdeveniment ?res))
  (printout t crlf "Perfecte, un " ?res ". Bona tria!" crlf)
  (assert (preguntat-tipus)))

(defrule PreferenciesMenu::preguntar-data
  ?p <- (peticio (data ?e&nil))
  (preguntat-tipus)
  (not (preguntat-data))
=>
  (bind ?r (valida-opcio
              "En quina època de l’any se celebrarà l’esdeveniment? (primavera/estiu/tardor/hivern)"
              primavera estiu tardor hivern))
  (modify ?p (data ?r))
  (printout t crlf "Entès, " ?r "." crlf)
  (assert (preguntat-data)))

(defrule PreferenciesMenu::preguntar-interior-exterior
  ?p <- (peticio (espai ?s&nil))
  (preguntat-data)
  (not (preguntat-interior-exterior))
  =>
  (bind ?r (valida-opcio 
            "Es farà en un espai interior o exterior? (interior/exterior)" 
            interior exterior))
  (modify ?p (espai ?r))
  (printout t crlf "Perfecte, serà en espai " ?r "." crlf)
  (assert (preguntat-interior-exterior)))

(defrule PreferenciesMenu::preguntar-num-comensals 
  ?p <- (peticio (num-comensals ?n&nil)) 
  (preguntat-interior-exterior) 
  (not (preguntat-num-comensals)) 
=> 
  (bind ?r (valida-num-o-indif "Quants comensals assistiran aproximadament?" 1 5000)) 
  (modify ?p (num-comensals ?r)) 
  (printout t crlf "Apuntat, uns " ?r " comensals." crlf)
  (assert (preguntat-num-comensals)))

(defrule PreferenciesMenu::preguntar-pressupost-min
  ?p <- (peticio (pressupost-min ?ppmin&nil))
  (preguntat-num-comensals)
  (not (preguntat-pressupost))
=>
  (bind ?min (valida-num-o-indif "Pel que fa al preu, quin és el pressupost mínim per persona?" 1 1000))
  (modify ?p (pressupost-min ?min))
  (assert (preguntat-pressupost-min)))

(defrule PreferenciesMenu::preguntar-pressupost-max
  ?p <- (peticio (pressupost-min ?min&~nil) (pressupost-max ?ppmax&nil))
  (preguntat-pressupost-min)
  (not (preguntat-pressupost-max))
=>
  (bind ?lb (if (numberp ?min) then ?min else 5))
  (bind ?max (valida-num-o-indif "I el màxim?" ?lb 2000))
  (modify ?p (pressupost-max ?max))
    (printout t crlf "Perfecte, buscarem menús entre " ?min " € i " ?max " € per persona." crlf)
  (assert (preguntat-pressupost-max))
  (assert (preguntat-pressupost)))

(defrule PreferenciesMenu::preguntar-formalitat
  ?p <- (peticio (formalitat ?f&nil))
  (preguntat-pressupost-max)
  (not (preguntat-formalitat))
=>
  (printout t crlf "Seguim. Parlem ara del to de l’esdeveniment." crlf)
  (bind ?r (valida-opcio "Quin grau de formalitat busques? (formal/informal)" 
            informal formal))
  (modify ?p (formalitat ?r))
  (printout t crlf "D’acord, apuntat com a " ?r "." crlf)
  (assert (preguntat-formalitat)))

(defrule PreferenciesMenu::preguntar-beguda-general
  ?p <- (peticio (beguda-mode ?bm&nil))
  (preguntat-formalitat)
  (not (preguntat-beguda-general))
=>
  (printout t crlf "Perfecte. Seguim amb la beguda." crlf)
  (bind ?r (valida-opcio "Vols la mateixa beguda per tot el menú o una per a cada plat? (general/per-plat)" general per-plat))
  (modify ?p (beguda-mode ?r))
  (printout t crlf "Perfecte, beguda " ?r "." crlf)
  (assert (preguntat-beguda-general)))

(defrule PreferenciesMenu::preguntar-alcohol
  ?p <- (peticio (alcohol ?a&nil))
  (preguntat-beguda-general)
  (not (preguntat-alcohol))
=>
  (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques?"))
  (modify ?p (alcohol ?r))
  (printout t crlf "Entesos, begudes alcohòliques: " ?r "." crlf)
  (assert (preguntat-alcohol)))

(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
  (preguntat-alcohol)
  (not (preguntat-alergens-prohibits))
=>
  (printout t crlf "Per acabar, un tema important." crlf)
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
(deffunction check-temperatura (?estacio ?espai ?temp ?ordres)
  (if (eq ?ordres ordre-postres) then (return TRUE))
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

(deffunction check-event (?te ?cx ?mida ?ordres $?apte)
  ;; Cas especial: postres de casament
  (if (and (eq ?te casament)
           (eq ?ordres ordre-postres))
    then
      ;; Només permetre postres amb casament_only
      (return (member$ casament_only $?apte))
  )

  ;; En la resta de casos, només cal comprovar que sigui apte per tots
  (if (not (member$ tots (create$ $?apte)))
    then (return FALSE))

  ;; Ara filtrem per tipus d’esdeveniment (només si és casament, la resta = TRUE)
  (if (eq ?te casament) then
      (return (and (or (eq ?cx alta) (eq ?cx mitjana))
                   (or (eq ?mida gran) (eq ?mida mitjana))))
  )
  ;; Altres tipus → no es filtra
  (return TRUE)
)


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
  (bind $?AG (if (multifieldp ?alerg-grup) then ?alerg-grup else (create$ ?alerg-grup)))

  (bind ?cls (class ?obj))

  ;; --- CAS 1: Beguda ---
  (if (eq ?cls Beguda) then
    (bind $?d-obj (send ?obj get-dietes))       ;; dietes directament del beguda
    (bind $?a-obj (send ?obj get-alergen))      ;; al·lèrgens directament del beguda

    (bind ?ok TRUE)

    ;; 1) comprova al·lèrgens
    (foreach ?a $?AG
      (if (and ?ok (member$ ?a $?a-obj)) then (bind ?ok FALSE)))

    ;; 2) comprova dietes: totes les dietes del grup han d’estar presents
    (foreach ?d $?DG
      (if ?ok then
        (bind ?ok
          (or
            (and (eq ?d vega)       (member$ VG $?d-obj))
            (and (eq ?d vegetaria)  (or (member$ V $?d-obj) (member$ VG $?d-obj)))
            (and (eq ?d halal)      (member$ HALAL_POT $?d-obj))
            (and (eq ?d kosher)     (member$ KOSHER_POT $?d-obj))
            ;; si el grup està buit o etiqueta desconeguda -> TRUE
            (and (= (length$ $?DG) 0) TRUE)))))

    (return ?ok)
  )

  ;; --- CAS 2: Plat ---
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
                  ;; si el grup està buit -> TRUE
                  (and (= (length$ $?DG) 0) TRUE))))))))

    (return ?ok)
  )
)


;; PAS 2: ABSTRACCIÓ HEURÍSTICA ------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(defrule AbstraccioHeuristica::validar-plat-basic
  "Condensa tots els filtres en una sola passada i marca plat-valid-final."
  (peticio (data ?estacio)
           (espai ?espai)
           (formalitat ?f)
           (num-comensals ?n)
           (tipus-esdeveniment ?te))
  ?pl <- (object (is-a Plat)
                 (nom ?nom)
                 (temperatura ?temp)
                 (formalitat ?form-str)
                 (complexitat ?cx)
                 (mida_racio ?mida)
                 (te_ordre ?ordres)
                 (disponibilitat_plats $?dispo)
                 (apte_esdeveniment $?apte))
  (test (check-temperatura ?estacio ?espai ?temp ?ordres))
  (test (check-formalitat ?f ?form-str))
  (test (check-complexitat ?n ?cx))
  (test (check-dispo ?estacio $?dispo))
  (test (check-event ?te ?cx ?mida ?ordres $?apte))
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

(defrule AbstraccioHeuristica::marcar-abstraccio-finalitzada
  (declare (salience -100))
  (respostes-completes)
  (not (abstraccio-finalitzada))
  =>
  (assert (abstraccio-finalitzada))
)


(defrule AbstraccioHeuristica::materialitza-esdeveniment
  (declare (salience 50))
  (respostes-completes)
  (not (exists (object (is-a Esdeveniment))))
=>
  (bind ?P  (nth$ 1 (find-all-facts ((?p peticio)) TRUE)))
  (bind ?n  (fact-slot-value ?P num-comensals))
  (bind ?mi (fact-slot-value ?P pressupost-min))
  (bind ?ma (fact-slot-value ?P pressupost-max))
  (make-instance [esdeveniment-1] of Esdeveniment
    (ocasio        (fact-slot-value ?P tipus-esdeveniment))
    (data          (fact-slot-value ?P data))
    (interior      (fact-slot-value ?P espai))
    (formalitat    (fact-slot-value ?P formalitat))
    (num_comensals (if (numberp ?n) then (if (integerp ?n) then ?n else (integer ?n)) else 0))
    (pressupost_min (if (numberp ?mi) then (float ?mi) else 0.0))
    (pressupost_max (if (numberp ?ma) then (float ?ma) else 0.0))
    (beguda_mode   (fact-slot-value ?P beguda-mode))
    (alcohol       (fact-slot-value ?P alcohol))))

;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))


;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
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

  ;; evita reutilitzar primers i segons (sempre)
  (bind ?conflict (or (member$ ?pr $?used-plats-mf)
                      (member$ ?sg $?used-plats-mf)))

  ;; NOMÉS bloqueja per repetició de begudes si el mode és GENERAL
  (bind ?bm (fact-slot-value (nth$ 1 (find-all-facts ((?p peticio)) TRUE)) beguda-mode))
  (foreach ?b $?bg
    (if (and (not ?conflict)
             (eq ?bm general)
             (member$ ?b $?used-begs-mf))
        then (bind ?conflict TRUE)))

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

  ;; Calcula min/max dels candidats
  (bind ?pmin 1.0e+15)
  (bind ?pmax -1.0e+15)
  (foreach ?mv $?menus
    (bind ?prc (fact-slot-value ?mv preu))
    (if (< ?prc ?pmin) then (bind ?pmin ?prc))
    (if (> ?prc ?pmax) then (bind ?pmax ?prc)))

  ;; Expandeix rang per franges
  (bind ?pmin (- ?pmin 1.0))
  (bind ?pmax (+ ?pmax 1.0))
  (bind ?range (- ?pmax ?pmin))
  (bind ?T1 (+ ?pmin (/ ?range 3.0)))
  (bind ?T2 (+ ?pmin (* 2 (/ ?range 3.0))))

  (printout t crlf "*** Rangs de preus ***" crlf)
  (printout t "  Barat: [" ?pmin " , " ?T1 "]" crlf)
  (printout t "  Mitjà: (" ?T1 " , " ?T2 "]" crlf)
  (printout t "  Car:   (" ?T2 " , " ?pmax "]" crlf)

  ;; Partició per franges
  (bind ?cheap (create$)) (bind ?mid (create$)) (bind ?exp (create$))
  (foreach ?mv ?menus
    (bind ?prc (fact-slot-value ?mv preu))
    (if (and (>= ?prc ?pmin) (<= ?prc ?T1)) then
      (bind ?cheap (create$ $?cheap ?mv))
    else
      (if (and (> ?prc ?T1) (<= ?prc ?T2)) then
        (bind ?mid (create$ $?mid ?mv))
      else
        (if (and (> ?prc ?T2) (<= ?prc ?pmax)) then
          (bind ?exp (create$ $?exp ?mv))))))

  ;; Ordena dins de cada franja
  (bind ?cheap (sort-menus-by-preu $?cheap))
  (bind ?mid   (sort-menus-by-preu $?mid))
  (bind ?exp   (sort-menus-by-preu $?exp))

  ;; Inicialitza seleccionats
  (bind ?picked (create$))
  (bind ?used-plats (create$))
  (bind ?used-begs  (create$))

  ;; 1) Tria BARAT si length$=0
  (foreach ?mv ?cheap
    (if (and (= (length$ ?picked) 0) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (foreach ?b $?bg
          (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))
        (printout t "barat" crlf)))

  ;; 2) Tria MITJÀ si length$=1
  (foreach ?mv ?mid
    (if (and (= (length$ ?picked) 1) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (foreach ?b $?bg
          (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))
        (printout t "mid" crlf)))

  ;; 3) Tria CAR si length$=2
  (foreach ?mv ?exp
    (if (and (= (length$ ?picked) 2) (menu-fits ?mv ?used-plats ?used-begs))
      then
        (bind ?picked (create$ $?picked ?mv))
        (bind ?pr (fact-slot-value ?mv primer))
        (bind ?sg (fact-slot-value ?mv segon))
        (bind ?po (fact-slot-value ?mv postres))
        (bind $?bg (fact-slot-value ?mv begudes))
        (foreach ?dish (create$ ?pr ?sg)
          (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
        (foreach ?b $?bg
          (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))
        (printout t "CAR" crlf)))

  ;; Fallback si encara no n’hi ha 3
  (if (< (length$ ?picked) 3) then
    (bind ?rest (sort-menus-by-preu $?menus))
    (printout t "FALLBACK" crlf)
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

  ?picked
)

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
  TRUE)

;; ====== GENERADOR DE MENÚS — versió curta, sense helpers nous ======
(defrule RefinamentHeuristica::generar-menus-valids
  (declare (auto-focus TRUE))
  (respostes-completes)
  ?req <- (peticio (beguda-mode ?bm)
                   (pressupost-min ?pmin)
                   (pressupost-max ?pmax)
                   (formalitat ?form)
                   (alcohol ?alc))
  (abstraccio-finalitzada)
  (not (menus-generats))
=>
  ;; Normalitza rang pressupost
  (bind ?LO (if (eq ?pmin indiferent) then 0.0 else ?pmin))
  (bind ?HI (if (eq ?pmax indiferent) then 1.0e+15 else ?pmax))

  ;; Plats vàlids per ordre
  (bind ?primers (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (eq (send ?p get-te_ordre) ordre-primer))))
  (bind ?segons  (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (eq (send ?p get-te_ordre) ordre-segon))))
  (bind ?postres (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (eq (send ?p get-te_ordre) ordre-postres))))

  ;; Begudes candidates segons maridatge, només valides finalment
  (bind ?bG (find-all-instances ((?b Beguda))
            (> (length$ (find-all-facts ((?f beguda-valida-final))
                  (eq (fact-slot-value ?f nom) (send ?b get-nom)))) 0)))

  (bind ?bPr (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-primer)
                  (> (length$ (find-all-facts ((?f beguda-valida-final))
                        (eq (fact-slot-value ?f nom) (send ?b get-nom)))) 0))))

  (bind ?bSg (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-segon)
                  (> (length$ (find-all-facts ((?f beguda-valida-final))
                        (eq (fact-slot-value ?f nom) (send ?b get-nom)))) 0))))

  (bind ?bPo (find-all-instances ((?b Beguda))
            (and (eq (send ?b get-maridatge) ordre-postres)
                  (> (length$ (find-all-facts ((?f beguda-valida-final))
                        (eq (fact-slot-value ?f nom) (send ?b get-nom)))) 0))))


  ;; Multiplicador de formalitat
  (bind ?Ffor (if (eq ?form formal) then 1.30 else 1.0))

  ;; Generació combinada de plats + begudes
  (foreach ?pr ?primers
    (foreach ?sg ?segons
      (foreach ?po ?postres
        (if (and (compat-ok ?pr ?sg ?po)
                 (origen-compatible ?pr ?sg ?po)
                 (equilibri-categoria ?pr ?sg ?po))
          then
            (progn
              ;; ====== Preu plats ======
              (bind ?p1 (* (send ?pr get-preu_cost)
                           (if (eq (send ?pr get-complexitat) alta) then 1.35 else (if (eq (send ?pr get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?pr get-mida_racio) gran) then 1.10 else (if (eq (send ?pr get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?pr get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?pr get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?pr get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor))
              (bind ?p1 (max ?p1 5.50))
              (bind ?p1 (/ (round (* ?p1 100)) 100.0))

              (bind ?p2 (* (send ?sg get-preu_cost)
                           (if (eq (send ?sg get-complexitat) alta) then 1.35 else (if (eq (send ?sg get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?sg get-mida_racio) gran) then 1.10 else (if (eq (send ?sg get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?sg get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?sg get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?sg get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor))
              (bind ?p2 (max ?p2 9.00))
              (bind ?p2 (/ (round (* ?p2 100)) 100.0))

              (bind ?p3 (* (send ?po get-preu_cost)
                           (if (eq (send ?po get-complexitat) alta) then 1.35 else (if (eq (send ?po get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?po get-mida_racio) gran) then 1.10 else (if (eq (send ?po get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?po get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?po get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?po get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor))
              (bind ?p3 (max ?p3 3.00))
              (bind ?p3 (/ (round (* ?p3 100)) 100.0))

              (bind ?base (+ ?p1 ?p2 ?p3))


                ;; ====== Combinació amb beguda ======
                (if (eq ?bm general) then
                  ;; Només 1 beguda general per menú
                  (foreach ?GB ?bG
                    (bind ?total (+ ?base (send ?GB get-preu_cost)))
                    (bind ?total (/ (round (* ?total 100)) 100.0))
                    (if (and (>= ?total ?LO) (<= ?total ?HI)) then
                      (assert (menu-valid
                                (primer (send ?pr get-nom))
                                (segon  (send ?sg get-nom))
                                (postres (send ?po get-nom))
                                (begudes (create$ (send ?GB get-nom)))
                                (preu ?total)))))
                  else
                  ;; Beguda per plat
                  (foreach ?bPrC ?bPr
                    (foreach ?bSgC ?bSg
                      (foreach ?bPoC ?bPo
                        (bind ?total (+ ?base
                                        (send ?bPrC get-preu_cost)
                                        (send ?bSgC get-preu_cost)
                                        (send ?bPoC get-preu_cost)))
                        (bind ?total (/ (round (* ?total 100)) 100.0))
                        (if (and (>= ?total ?LO) (<= ?total ?HI))
                          then
                            (assert (menu-valid
                                      (primer (send ?pr get-nom))
                                      (segon  (send ?sg get-nom))
                                      (postres (send ?po get-nom))
                                      (begudes (create$ (send ?bPrC get-nom)
                                                        (send ?bSgC get-nom)
                                                        (send ?bPoC get-nom)))
                                      (preu ?total)))))))
                )
              
            )
        )
      )
    )
  )
  (assert (menus-generats))
)

;; 4) Impressió de 3 menús per cada grup definit
(defrule RefinamentHeuristica::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (menus-generats)
  (not (menus-presentats))
  =>
  (bind ?menus (find-all-facts ((?m menu-valid)) TRUE))
  (bind ?n (length$ ?menus))

  (if (<= ?n 0) then
    (printout t crlf "*** Ho sentim... no hem trobat menús vàlids dins del pressupost. ***" crlf)
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
    (print-justificacio-global)
    (assert (menus-presentats))
  )
)

(defrule RefinamentHeuristica::mostrar-menus-per-grup
  (declare (auto-focus TRUE))
  (menus-presentats)                       ;; ja hem acabat el general
  (grup (nom ?g))
  (not (menus-presentats-grup (grup ?g)))
  =>
  ;; Imprimeix la frase global per a grups un únic cop (abans del primer grup)
  (if (<= (length$ (find-all-facts ((?f frase-grups-impresa)) TRUE)) 0) then
    (printout t crlf
      "A més, s’han identificat menús específics per als grups amb restriccions definides, "
      "garantint la compatibilitat en plats i begudes sense alterar el ritme del servei." crlf crlf)
    (assert (frase-grups-impresa)))

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
