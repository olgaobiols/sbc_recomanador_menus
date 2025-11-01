;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MÒDUL PRINCIPAL: MAIN
;; Aquest mòdul conté els templates, funcions i elements comuns utilitzats
;; per a la recollida de preferències de l’usuari, la normalització de dades
;; i la generació d’informació de justificació dels menús seleccionats.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule MAIN (export ?ALL))
;---------------------------- TEMPLATES DE DADES -------------------------------
; Petició inicial de l'usuari: info sobre l'esdeveniment i preferències bàsiques
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
  (multislot alergen (type STRING SYMBOL))) 

; Grups específics de comensals amb dietes o al·lèrgies concretes
(deftemplate grup
  (slot nom (type STRING))
  (multislot dietes (type SYMBOL))
  (multislot alergens-prohibits (type SYMBOL)))

; Plats i begudes considerats vàlids segons les restriccions
(deftemplate plat-valid-final (slot nom))
(deftemplate beguda-valida-final (slot nom))
(deftemplate plat-valid-grup (slot grup) (slot nom))
(deftemplate beguda-valida-grup (slot grup) (slot nom))

; Menús complets (primers, segons, postres i begudes) seleccionats com a propostes finals per a l'usuari
(deftemplate menu-valid (slot primer) (slot segon) (slot postres) (multislot begudes) (slot preu (type FLOAT)))
(deftemplate menu-seleccionat (slot idx (type INTEGER)) (slot primer) (slot segon) (slot postres) (multislot begudes) (slot preu (type FLOAT)))

;---------------------------- FUNCIONS AUXILIARS -------------------------------
; Elimina espais en blanc i caràcters de control d'un string
(deffunction trim (?value) 
  (bind ?text (str-cat ?value)) (bind ?length (str-length ?text))
  (if (<= ?length 0) then (return ""))
  (bind ?whites (create$ " " (format nil "%c" 9) (format nil "%c" 10) (format nil "%c" 13)))
  (bind ?start 1)
  (while (and (<= ?start ?length) (member$ (sub-string ?start ?start ?text) ?whites))
    (bind ?start (+ ?start 1)))
  (if (> ?start ?length) then (return ""))
  (bind ?end ?length)
  (while (and (>= ?end ?start) (member$ (sub-string ?end ?end ?text) ?whites))
    (bind ?end (- ?end 1)))
  (if (< ?end ?start) then (return ""))
  (sub-string ?start ?end ?text))

; Normalització de text: elimina espais i passa a minúscules
(deffunction norm (?x) 
 (lowcase (trim (str-cat ?x))))

; Converteix respostes textuals de dietes a símbols interns
(deffunction token-dieta->sym (?x) 
  (bind ?s (norm ?x))
  (if (or (eq ?s "vg") (eq ?s "vega") (eq ?s "vegan") (eq ?s "vegana") (eq ?s "vegà")) then (return vega))
  (if (or (eq ?s "v") (eq ?s "vegetaria") (eq ?s "vegetari") (eq ?s "vegetariana") (eq ?s "vegetarian")) then (return vegetaria))
  (if (eq ?s "halal") then (return halal))
  (if (eq ?s "kosher") then (return kosher))
  nil)





;----------------------- GESTIÓ DE JUSTIFICACIONS ------------------------------
; Mostra a l’usuari les dietes reconegudes pel sistema i com introduir-les.
(deffunction print-dietes-ajuda ()
  (printout t crlf
    "Tria alguna de les següents dietes disponibles (pots combinar-ne diverses):" crlf
    "  - vega        (vegana)" crlf
    "  - vegetaria   (vegetariana)" crlf
    "  - halal" crlf
    "  - kosher" crlf
    "Exemples: 'vega', 'vegetaria halal', 'kosher'." crlf crlf))

; Converteix la resposta de l’usuari en una llista de símbols normalitzats.
(deffunction parse-dietes-resposta (?line)
  (bind ?clean (norm (str-replace (str-replace ?line "," " ") ";" " ")))
  (if (eq ?clean "") then (return (create$)))
  (bind ?OUT (create$))
  (foreach ?tk (explode$ ?clean)
    (bind ?d (token-dieta->sym ?tk))
    (if (and ?d (not (member$ ?d ?OUT))) then (bind ?OUT (create$ $?OUT ?d))))
  ?OUT)

; Mapeig entre el número oficial (UE-14) i el símbol intern del sistema.
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

; Tradueix noms d’al·lèrgens escrits en text a símbols interns.
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

; Mostra la llista d’al·lèrgens reconeguts per la Unió Europea (UE-14)
(deffunction print-ue14-ajuda ()
  (printout t crlf
    "AL·LÈRGENS UE-14 (pots posar números i/o noms, separats per espais o comes):" crlf
    "  1  gluten      2  llet       3  ous        4  peix" crlf
    "  5  crustacis   6  molluscs   7  fruits_secs 8  cacauet" crlf
    "  9  soja       10  api       11  mostassa  12  sesam" crlf
    " 13  sulfites   14  tramussos" crlf
    "Exemples:  '2 7'   |   'llet, fruits_secs'   |   'gluten sesam 14'." crlf crlf))

; Templates auxiliars per a controlar la impressió i seguiment dels menús
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

; Genera un text explicatiu coherent amb les preferències de l’usuari.
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

  ; Rang de preus reals
  (bind ?preus (create$))
  (foreach ?m ?SEL
    (bind ?preu (fact-slot-value ?m preu))
    (bind ?preus (create$ $?preus ?preu)))
  (bind ?pmin (nth$ 1 (sort < ?preus)))
  (bind ?pmax (nth$ (length$ ?preus) (sort < ?preus)))

  ; Begudes
  (bind ?begudes (create$))
  (foreach ?m ?SEL
    (bind $?bgs (fact-slot-value ?m begudes))
    (foreach ?b $?bgs
      (if (not (member$ ?b ?begudes)) then
        (bind ?begudes (create$ $?begudes ?b)))))
  (bind ?bgs-str (if (> (length$ ?begudes) 0)
                    then (implode$ ?begudes)
                    else "les begudes seleccionades"))

  ; Etiquetes textuals
  (bind ?modeStr (if (eq ?bm general) then "general" else "per plat"))
  (bind ?alcText
        (if (eq ?alc si) then "amb alcohol"
         else (if (eq ?alc no) then "sense alcohol"
               else "amb o sense alcohol segons preferència")))
  (printout t crlf)
  (printout t
    "Les propostes seleccionades s’ajusten a les preferències indicades per l’usuari. "
    "L’esdeveniment és de tipus " ?tipus ", amb un nivell de formalitat " ?form
    ", previst per a " ?estacio " en espai " ?espai ", "
    "per a un total de " ?ncom " comensals i amb un pressupost per persona entre "
    ?lo " € i " ?hi " €. "
    "Els menús seleccionats es troben dins d’aquest marge, amb preus reals entre "
    ?pmin " € i " ?pmax " €." crlf crlf)
  (printout t
    "Les principals condicions aplicades han estat:" crlf crlf)

  ; Estació i espai
  (if (and (or (eq ?estacio primavera) (eq ?estacio estiu)) 
           (eq ?espai exterior)) then
    (printout t "• En ser un esdeveniment exterior en temporada càlida, s’han prioritzat plats freds o tebis, lleugers i refrescants." crlf))
  (if (and (or (eq ?estacio primavera) (eq ?estacio estiu))
           (eq ?espai interior)) then
    (printout t "• En ser un esdeveniment interior en temporada càlida, s’han prioritzat elaboracions fresques o de cocció curta." crlf))
  (if (or (eq ?estacio tardor) (eq ?estacio hivern)) then
    (printout t "• En ser una estació freda, s’han seleccionat plats calents o tebis, amb productes de temporada." crlf))
  (if (eq ?estacio indiferent) then
    (printout t "• No s’han aplicat restriccions per estació ni espai." crlf))
  (printout t "• S’ha comprovat la disponibilitat d’ingredients segons l’estació escollida; "
    "si algun plat contenia productes no disponibles en aquesta època, s’ha descartat o substituït per alternatives adequades." crlf)
  
  ; Tipus d’esdeveniment
  (if (eq ?tipus casament) then
    (printout t "• Com que es tracta d’un casament, s’han escollit plats de complexitat mitjana o alta i racions mitjanes o grans, amb un to celebratiu i cuidat." crlf))
  (if (eq ?tipus aniversari) then
    (printout t "• En ser un aniversari, s’han prioritzat plats de complexitat mitjana o baixa i racions petites o mitjanes, per afavorir un ambient festiu i distès." crlf))
  (if (eq ?tipus comunio) then
    (printout t "• Per a una comunió, s’han seleccionat plats suaus i equilibrats, adequats per a un públic familiar." crlf))
  (if (eq ?tipus congres) then
    (printout t "• En tractar-se d’un congrés, s’han escollit plats petits i de baixa complexitat per facilitar un servei àgil i còmode." crlf))
  (if (eq ?tipus empresa) then
    (printout t "• Per a un esdeveniment d’empresa, s’han mantingut plats de complexitat mitjana o baixa i racions petites o mitjanes, coherents amb un entorn professional." crlf))
  (if (eq ?tipus altres) then
    (printout t "• En no especificar un tipus concret d’esdeveniment, s’han mantingut criteris generals d’equilibri i coherència." crlf))

  ; Formalitat
  (if (eq ?form formal) then
    (printout t "• En indicar un esdeveniment formal, només s’han inclòs plats i begudes amb presentacions i característiques formals." crlf))
  (if (eq ?form informal) then
    (printout t "• En indicar un esdeveniment informal, s’han seleccionat propostes més senzilles i de presentació relaxada." crlf))

  ; Nombre de comensals
  (if (and (numberp ?ncom) (<= ?ncom 150)) then
    (printout t "• Amb menys de 150 comensals, s’han permès totes les complexitats de plats." crlf))
  (if (and (numberp ?ncom) (> ?ncom 150) (<= ?ncom 500)) then
    (printout t "• Entre 150 i 500 comensals, s’han descartat plats d’alta complexitat per assegurar un servei àgil." crlf))
  (if (and (numberp ?ncom) (> ?ncom 500)) then
    (printout t "• Amb més de 500 comensals, només s’han acceptat plats de complexitat baixa per facilitar la producció i el servei." crlf))

  ; Maridatge
  (if (and (eq ?bm general) (eq ?alc no)) then
    (printout t "• S’ha aplicat maridatge general sense alcohol, buscant begudes equilibrades i refrescants." crlf))
  (if (and (eq ?bm general) (eq ?alc si)) then
    (printout t "• S’ha aplicat maridatge general amb alcohol, amb begudes que complementen el to festiu." crlf))
  (if (eq ?bm per-plat) then
    (printout t "• S’ha aplicat maridatge per plat, amb begudes associades específicament a cada elaboració." crlf))
  (if (eq ?alc indiferent) then
    (printout t "• Com que la preferència d’alcohol és indiferent, s’han considerat opcions amb i sense alcohol." crlf))
  
  ; Grups amb restriccions
  (bind ?SELGR (find-all-facts ((?g menu-seleccionat-grup)) TRUE))
  (if (> (length$ ?SELGR) 0) then
    (printout t "• S’han generat menús específics per a grups amb dietes o al·lèrgies, garantint la compatibilitat dels ingredients i begudes." crlf)))

;----------------------- VALIDACIÓ DE RESPOSTES -------------------------------
; Demana una resposta de tipus sí/no/indiferent i valida l’entrada.
(deffunction valida-boolea 
  (?prompt)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)
  (while (not ?resp_valida)
    (printout t ?prompt " (si/no/indiferent): " crlf)
    (bind ?x (lowcase (readline)))
    (if (or (eq ?x "sí") (eq ?x "si") (eq ?x "s") (eq ?x "y") (eq ?x "yes")) then
        (bind ?resp_valida TRUE) (bind ?resp si)
    else
    (if (or (eq ?x "no") (eq ?x "n")) then
        (bind ?resp_valida TRUE) (bind ?resp no)
    else
    (if (eq ?x "indiferent") then
        (bind ?resp_valida TRUE) (bind ?resp indiferent)
    else (printout t "Respon 'sí', 'no' o 'indiferent'." crlf))))
 ) ?resp)

; Accepta un valor numèric dins d’un rang o el valor 'indiferent'.
(deffunction valida-num-o-indif 
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
        else (printout t "Si us plau introdueix un valor dins del rang (" ?min " - " ?max ")." crlf))
      else (printout t "Introdueix un número vàlid o 'indiferent'." crlf))))
  ?resp)

; Permet triar entre opcions predefinides, amb control d’errors.
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
       else (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))))
  ?resp)

; Converteix una resposta sobre al·lergògens en una llista de símbols normalitzats.
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

; Obté la llista de dietes d’un objecte (plats o begudes).
(deffunction get-obj-dietes ($?d) (if (multifieldp $?d) then $?d else (create$)))

; Extreu i normalitza els al·lergògens associats a un objecte.
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

;-------------------------- CONTROL DE FLUX -----------------------------------
; Mòdul encarregat de controlar l’ordre d’execució dels diferents blocs heurístics  
(defmodule ControlFlux (import MAIN ?ALL))

; Regla inicial que estableix el focus dels mòduls que defineixen la lògica heurística
(defrule ControlFlux::arrencada
  (declare (auto-focus TRUE))
  (initial-fact)
  =>
  (focus RefinamentHeuristica)
  (focus AssociacioHeuristica)
  (focus AbstraccioHeuristica)
  (focus PreferenciesMenu))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAS 1: RECOLLIDA DE PREFERÈNCIES
;; Mòdul encarregat d’interactuar amb l’usuari per obtenir totes les dades
;; necessàries sobre l’esdeveniment, pressupost, formalitat i restriccions.
;; Un cop completades, es crea el fet (peticio) amb la informació i
;; s’activa el flux cap al mòdul d’Abstracció Heurística.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmodule PreferenciesMenu (import MAIN ?ALL) (export ?ALL))

;---------------------- INICIALITZACIÓ I INTRODUCCIÓ ---------------------------
; Inicia la petició i presenta el sistema a l’usuari.
(defrule PreferenciesMenu::iniciar-peticio
  (declare (auto-focus TRUE))
  (not (peticio))
  =>
  (printout t crlf crlf "Benvingut/da al recomanador de menús RicoRico!" crlf crlf)
  (printout t "T’ajudaré a trobar el menú ideal per al teu esdeveniment." crlf)
  (printout t "Et faré algunes preguntes curtes. Si no tens clara la resposta encara, pots respondre 'indiferent'." crlf crlf)
  (assert (peticio))
  (focus PreferenciesMenu))

;---------------------- PREGUNTES SEQÜENCIALS A L’USUARI ----------------------
; Demana el tipus d’esdeveniment (casament, aniversari, etc.)
(defrule PreferenciesMenu::preguntar-tipus-esdeveniment 
  (declare (auto-focus TRUE))
  ?p <- (peticio (tipus-esdeveniment ?te&nil))
  (not (preguntat-tipus))
=>
  (printout t crlf "Comencem!" crlf)
  (bind ?res (valida-opcio "Quin tipus d’esdeveniment estàs organitzant? (casament/aniversari/comunio/congres/empresa/altres)"
              casament aniversari comunio congres empresa altres)  )
  (modify ?p (tipus-esdeveniment ?res))
  (printout t crlf "Perfecte, un " ?res ". Bona tria!" crlf)
  (assert (preguntat-tipus)))

; Demana l’època de l’any en què se celebrarà
(defrule PreferenciesMenu::preguntar-data 
  ?p <- (peticio (data ?e&nil))
  (preguntat-tipus)
  (not (preguntat-data))
=>
  (bind ?r (valida-opcio "En quina època de l’any se celebrarà l’esdeveniment? (primavera/estiu/tardor/hivern)"
              primavera estiu tardor hivern))
  (modify ?p (data ?r))
  (printout t crlf "Entès, " ?r "." crlf)
  (assert (preguntat-data)))  

; Pregunta si l’esdeveniment serà interior o exterior
(defrule PreferenciesMenu::preguntar-interior-exterior "Demanar tipus d’espai"
  ?p <- (peticio (espai ?s&nil))
  (preguntat-data)
  (not (preguntat-interior-exterior))
  =>
  (bind ?r (valida-opcio "Es farà en un espai interior o exterior? (interior/exterior)" 
            interior exterior))
  (modify ?p (espai ?r))
  (printout t crlf "Perfecte, serà en espai " ?r "." crlf)
  (assert (preguntat-interior-exterior)))

; Pregunta el nombre aproximat de comensals
(defrule PreferenciesMenu::preguntar-num-comensals 
  ?p <- (peticio (num-comensals ?n&nil)) 
  (preguntat-interior-exterior) 
  (not (preguntat-num-comensals)) 
=> 
  (bind ?r (valida-num-o-indif "Quants comensals assistiran aproximadament?" 1 5000)) 
  (modify ?p (num-comensals ?r)) 
  (printout t crlf "Apuntat, uns " ?r " comensals." crlf)
  (assert (preguntat-num-comensals)))

; Pregunta el pressupost mínim per persona
(defrule PreferenciesMenu::preguntar-pressupost-min 
  ?p <- (peticio (pressupost-min ?ppmin&nil))
  (preguntat-num-comensals)
  (not (preguntat-pressupost))
=>
  (bind ?min (valida-num-o-indif "Pel que fa al preu, quin és el pressupost mínim per persona?" 1 1000))
  (modify ?p (pressupost-min ?min))
  (assert (preguntat-pressupost-min)))

; Pregunta el pressupost màxim per persona
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

; Pregunta el nivell de formalitat de l’esdeveniment  
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

; Pregunta si la beguda serà comuna o diferent per cada plat
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

; Pregunta si es volen incloure begudes alcohòliques
(defrule PreferenciesMenu::preguntar-alcohol
  ?p <- (peticio (alcohol ?a&nil))
  (preguntat-beguda-general)
  (not (preguntat-alcohol))
=>
  (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques?"))
  (modify ?p (alcohol ?r))
  (printout t crlf "Entesos, begudes alcohòliques: " ?r "." crlf)
  (assert (preguntat-alcohol)))

; Pregunta si es volen definir grups amb dietes o al·lèrgies específiques
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

;------------------------- CREACIÓ DE GRUPS ------------------------------------
; Permet a l’usuari crear diversos grups amb dietes o al·lèrgies personalitzades.
(defrule PreferenciesMenu::crear-grups
  (declare (auto-focus TRUE))
  (peticio (alergies-si si))
  (not (grups-creats))
  =>
  (printout t crlf "D'acord! Definirem a continuació grups amb restriccions." crlf)
  (printout t "Quan acabis, escriu 'fi' a la pregunta del nom." crlf)
  (bind ?continuar TRUE)
  (while ?continuar
    (printout t crlf "Escriu primer com vols anomenar el teu grup (o bé'fi' per acabar): ")
    (bind ?nom (readline))
    (if (eq (norm ?nom) "fi") then
      (bind ?continuar FALSE)
    else
      (print-dietes-ajuda)
      (printout t "Escriu ara les dietes del grup (o deixa en blanc si cap): " crlf)
      (bind ?diet-line (readline))
      (bind $?dietes (parse-dietes-resposta ?diet-line))
      (print-ue14-ajuda)
      (printout t "Indica a coninuació els al·lèrgens prohibits (o deixa en blanc si cap): " crlf)
      (bind ?al-line (readline))
      (bind $?alergs (parse-alergens-resposta ?al-line))
      (assert (grup (nom ?nom) (dietes $?dietes) (alergens-prohibits $?alergs)))
      (printout t "Perfecte! Has creat el grup: '" ?nom "'  |  dietes=" $?dietes "  |  alergens=" $?alergs crlf)
    )
  )
  (assert (grups-creats))
  (assert (respostes-completes))
  (focus AbstraccioHeuristica))

;------------------- FUNCIONS DE VALIDACIÓ DE PLATS ----------------------------.
(deffunction check-temperatura (?estacio ?espai ?temp $?ordres) "Verifica la coherència de la temperatura del plat amb l’estació i l’espai"
  (if (member$ ordre-postres $?ordres) then (return TRUE))                     ; els postres no es filtren per temperatura
  (if (or (eq ?estacio indiferent) (eq ?espai indiferent)) then (return TRUE)) ; si no es defineix estació o espai, no es filtra
  (if (or (eq ?estacio primavera) (eq ?estacio estiu)) then                    ; si temperatura càlida (primavera/estiu)
      (return (or (eq ?temp "fred") (eq ?temp "tebi")                          ; es permet fred o tebi
                  (and (eq ?temp "calent") (eq ?espai interior)))))            ; o calent només si és l'espai és interior
  (if (or (eq ?estacio tardor) (eq ?estacio hivern)) then                      ; si temperatura freda (tardor/hivern)
      (return (or (eq ?temp "calent") (eq ?temp "tebi"))))                     ; es permet calent o tebi
  FALSE)

(deffunction check-formalitat (?f ?form-str) "Comprova si el nivell de formalitat del plat coincideix amb el demanat"
  (or (eq ?f indiferent)
      (and (eq ?f formal)   (eq ?form-str "formal"))
      (and (eq ?f informal) (eq ?form-str "informal"))))

(deffunction check-complexitat (?n ?cx) "Limita la complexitat del plat segons el nombre de comensals"
  (if (not (numberp ?n)) then (return TRUE))                                            ; si no es defineix nombre de comensals, no es filtra
  (if (<= ?n 150)  then (return (or (eq ?cx alta) (eq ?cx mitjana) (eq ?cx baixa))))    ; fins a 150 comensals, totes les complexitats permeses (alta/mitjana/baixa)
  (if (and (> ?n 150) (<= ?n 500)) then (return (or (eq ?cx mitjana) (eq ?cx baixa))))  ; entre 150 i 500, només mitjana o baixa
  (if (> ?n 500) then (return (eq ?cx baixa)))                                          ; més de 500, només baixa permesa
  FALSE)

(deffunction check-dispo (?estacio $?dispo) "Comprova la disponibilitat del plat segons l’estació"
  (or (eq ?estacio indiferent) (member$ ?estacio (create$ $?dispo))))                  ; si no es defineix estació, o l’estació està a la llista de disponibilitat, permès

(deffunction check-event (?te ?cx ?mida $?apte)
  (if (not (or (eq ?te indiferent)                                         ; si no es defineix tipus d’esdeveniment
               (member$ tots (create$ $?apte))                             ; o el tipus és 'tots'
               (member$ ?te (create$ $?apte))))                            ; o el tipus està a la llista d’aptes -> retorna FALSE
    then (return FALSE))                                                   ; sinó, comprova segons tipus d’esdeveniment
  (if (eq ?te indiferent) then (return TRUE))                              ; si és indiferent, tot permès
  
  (if (eq ?te casament) then                                               ; si és casament: 
    (return (and (or (eq ?cx alta) (eq ?cx mitjana))                       ; complexitat alta o mitjana
                 (or (eq ?mida gran) (eq ?mida mitjana))))                 ; ració gran o mitjana
  else
  (if (or (eq ?te aniversari) (eq ?te comunio)) then                       ; si és aniversari o comunió:
    (return (and (or (eq ?cx mitjana) (eq ?cx baixa))                      ; complexitat mitjana o baixa
                 (or (eq ?mida petita) (eq ?mida mitjana))))               ; ració petita o mitjana
  else
  (if (eq ?te congres) then                                                ; si és congrés:
    (return (eq ?mida petita))                                             ; només ració petita
  else
  (if (eq ?te empresa) then                                                ; si és esdeveniment d’empresa:
    (return (and (or (eq ?cx mitjana) (eq ?cx baixa))                      ; complexitat mitjana o baixa
                 (or (eq ?mida petita) (eq ?mida mitjana))))               ; ració petita o mitjana
  else (return TRUE))))))


;------------------- FUNCIONS DE VALIDACIÓ DE BEGUDES --------------------------
(deffunction check-beguda (?f ?alc-pet ?beg $?formalitats) "Determina si una beguda és adequada segons alcohol i formalitat"
  (and
    (or (eq ?alc-pet indiferent)                     ; Alcohol: només filtra si l'usuari ho especifica
        (eq ?alc-pet (send ?beg get-alcohol)))
    (or (eq ?f indiferent)                           ; Formalitat: només filtra si l'usuari ho especifica
        (member$ ?f $?formalitats)
        (<= (length$ $?formalitats) 0))
  ))

;------------------ VALIDACIÓ D’AL·LÈRGIES I DIETES ----------------------------
(deffunction busca-ingredient (?nom-str) "Localitza un ingredient pel seu nom dins la base de coneixement"
  (bind ?needle (lowcase (trim (str-cat ?nom-str))))
  (bind ?hits
        (find-all-instances ((?i Ingredient))
          (or (eq (send ?i get-nom) ?nom-str)
              (eq (lowcase (send ?i get-nom)) ?needle))))
  (if (> (length$ ?hits) 0) then (nth$ 1 ?hits) else FALSE))

(deffunction check-alergies-dietes (?dietes-grup ?obj ?alerg-grup) "Comprova si un plat o beguda és compatible amb les dietes i al·lèrgies del grup."
  (bind $?DG (if (multifieldp ?dietes-grup) then ?dietes-grup else (create$ ?dietes-grup)))
  (bind $?AG (if (multifieldp ?alerg-grup) then ?alerg-grup else (create$ ?alerg-grup)))
  (bind ?cls (class ?obj))

  ; CAS 1: Beguda
  (if (eq ?cls Beguda) then
    (bind $?d-obj (send ?obj get-dietes))                          ; dietes directament del beguda
  (bind $?a-obj (send ?obj get-alergen))                           ; al·lèrgens directament del beguda
    (bind ?ok TRUE)                             
    (foreach ?a $?AG
      (if (and ?ok (member$ ?a $?a-obj)) then (bind ?ok FALSE)))    ; comprova al·lèrgens prohibits

    (foreach ?d $?DG                                             
      (if ?ok then
        (bind ?ok
          (or (and (eq ?d vega)       (member$ VG $?d-obj))
              (and (eq ?d vegetaria)  (or (member$ V $?d-obj) (member$ VG $?d-obj)))
              (and (eq ?d halal)      (member$ HALAL_POT $?d-obj))
              (and (eq ?d kosher)     (member$ KOSHER_POT $?d-obj))
              (and (= (length$ $?DG) 0) TRUE)))))                  ; comprova dietes: totes les dietes del grup han d’estar presents

    (return ?ok))

  ; CAS 2: Plat 
  (if (eq ?cls Plat) then
    (bind $?noms (send ?obj get-te_ingredients_noms))
    (bind ?ok TRUE)
    (foreach ?nom $?noms
      (if ?ok then
        (bind ?I (busca-ingredient ?nom))
        (if ?I then                                                 ; si es troba l’ingredient a la base de coneixement
          (bind $?ids (get-obj-dietes (send ?I get-dietes)))        ; obté les dietes de l’ingredient
          (bind $?ial (get-obj-alergens-syms ?I))                   ; obté els al·lèrgens de l’ingredient
          (foreach ?a $?AG
            (if (and ?ok (member$ ?a $?ial)) then (bind ?ok FALSE))); si algun al·lèrgens prohibit està present, marca com a no vàlid

          (foreach ?d $?DG                                          ; comprova dietes: totes les dietes del grup s'han de satisfer
            (if ?ok then
              (bind ?ok
                (or (and (eq ?d vega)       (member$ VG $?ids))
                    (and (eq ?d vegetaria)  (or (member$ V $?ids) (member$ VG $?ids)))
                    (and (eq ?d halal)      (member$ HALAL_POT $?ids))
                    (and (eq ?d kosher)     (member$ KOSHER_POT $?ids))
                    (and (= (length$ $?DG) 0) TRUE))))))))
    (return ?ok)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAS 2: ABSTRACCIÓ HEURÍSTICA
;; Aquest mòdul aplica les primeres regles d’inferència sobre la base de
;; coneixement. A partir de les preferències recollides, filtra i valida
;; quins plats i begudes són compatibles amb l’esdeveniment i amb els grups
;; definits per dietes o al·lèrgies.
;;
;; També materialitza la petició de l’usuari com a instància de la classe
;; Esdeveniment per permetre-ne un tractament objectual posterior.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

;------------------- VALIDACIÓ DE PLATS GENERALS -------------------------------
; Si un plat compleix totes les condicions, s’afegeix com a plat vàlid final.
(defrule AbstraccioHeuristica::validar-plat-basic "Condensa tots els filtres en una sola passada i marca plat-valid-final."
  (peticio (data ?estacio) (espai ?espai) (formalitat ?f) (num-comensals ?n) (tipus-esdeveniment ?te))
  ?pl <- (object (is-a Plat)
                 (nom ?nom) (temperatura ?temp) (formalitat ?form-str)
                 (complexitat ?cx) (mida_racio ?mida) (te_ordre $?ordres)
                 (disponibilitat_plats $?dispo) (apte_esdeveniment $?apte))
  (test (check-temperatura ?estacio ?espai ?temp $?ordres))   
  (test (check-formalitat ?f ?form-str))
  (test (check-complexitat ?n ?cx))
  (test (check-dispo ?estacio $?dispo))
  (test (check-event ?te ?cx ?mida $?apte))
  =>
  (assert (plat-valid-final (nom ?nom)))
)

; Regla específica per a casaments: permet postres amb etiqueta 'casament_only'
(defrule AbstraccioHeuristica::validar-pastis-boda
  (declare (salience 15))
  (peticio (tipus-esdeveniment casament))
  ?pl <- (object (is-a Plat)
                 (nom ?nom)
                 (te_ordre $?ords)
                 (apte_esdeveniment $?apte))
  (test (member$ ordre-postres $?ords))
  (test (member$ casament_only (create$ $?apte)))
  =>
  (if (<= (length$ (find-all-facts ((?f plat-valid-final)) (eq (fact-slot-value ?f nom) ?nom))) 0)
      then (assert (plat-valid-final (nom ?nom)))))

;------------------- VALIDACIÓ DE BEGUDES GENERALS -----------------------------
(defrule AbstraccioHeuristica::validar-beguda-basic "Marca com a vàlides les begudes que passen alcohol, formalitat i maridatge coherent amb el mode."
  (peticio (formalitat ?f) (alcohol ?a) (beguda-mode ?bm))
  ?b <- (object (is-a Beguda) (nom ?nom) (formalitat $?formalitats)
                (alcohol ?alc) (maridatge ?mari) (es_general ?gen))
  =>
  ; Filtra per alcohol i formalitat
  (if (and (or (eq ?a indiferent) (eq ?a ?alc))
           (or (eq ?f indiferent) (member$ ?f $?formalitats)))
    then 
      ;Mode general: accepta només begudes marcades com generals
      (if (and (eq ?bm general) (eq ?gen si))               
          then (assert (beguda-valida-final (nom ?nom))))
      ; Mode per-plat: accepta les que tinguin maridatge específic
      (if (and (eq ?bm per-plat)
               (or (eq ?mari ordre-primer)
                   (eq ?mari ordre-segon)
                   (eq ?mari ordre-postres)))
          then (assert (beguda-valida-final (nom ?nom))))
  ))

;------------------- VALIDACIÓ PER GRUPS (DIETES/AL·LÈRGIES) ------------------
; Comprova, per a cada grup amb restriccions alimentàries, quins plats i begudes
; compleixen les condicions de dietes i al·lèrgies. Els marca com a vàlids
; dins d’aquell grup específic.
(defrule AbstraccioHeuristica::validar-plat-per-grup
  (grup (nom ?g) (dietes $?dietes) (alergens-prohibits $?alergs))
  ?pl <- (object (is-a Plat) (nom ?nom))
  (test (check-alergies-dietes (create$ $?dietes) ?pl (create$ $?alergs)))
  =>
  (assert (plat-valid-grup (grup ?g) (nom ?nom))))

(defrule AbstraccioHeuristica::validar-beguda-per-grup
  (grup (nom ?g) (dietes $?dietes) (alergens-prohibits $?alergs))
  ?b <- (object (is-a Beguda) (nom ?nom))
  (test (check-alergies-dietes (create$ $?dietes) ?b (create$ $?alergs)))
  =>
  (assert (beguda-valida-grup (grup ?g) (nom ?nom))))

;------------------- MATERIALITZACIÓ DE L’ESDEVENIMENT ------------------------
; Crea una instància d’Esdeveniment a partir de la petició de l’usuari
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAS 3: ASSOCIACIÓ HEURÍSTICA
;; En aquest mòdul es durà a terme la combinació de plats i begudes
;; validats per formar menús complets. 
;; La generació de menús es resol posteriorment al mòdul de Refinament.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PAS 4: REFINAMENT HEURÍSTIC
;; Aquesta fase aplica lògica més precisa per generar menús complets
;; (primer, segon, postres i begudes), calcular-ne el cost, assegurar
;; compatibilitat gastronòmica, i seleccionar les millors combinacions
;; segons criteris heurístics i pressupost.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL)(import AssociacioHeuristica ?ALL)(export ?ALL))

;------------------- FUNCIONS D’AVALUACIÓ I FILTRAT ----------------------------
(deffunction menu-apte-per-grup (?mv ?g) "Verifica que tots els plats i begudes d’un menú siguin vàlids per a un grup"
  (bind ?pr (fact-slot-value ?mv primer))
  (bind ?sg (fact-slot-value ?mv segon))
  (bind ?po (fact-slot-value ?mv postres))
  (bind $?bgs (fact-slot-value ?mv begudes))

  ; Comprova que el primer, segon i postres siguin vàlids per al grup
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
  
  ; Comprova que totes les begudes siguin vàlides per al grup
  (foreach ?b $?bgs
    (if ?ok-bg then
      (bind ?ok-bg (> (length$ (find-all-facts ((?fb beguda-valida-grup))
                            (and (eq (fact-slot-value ?fb grup) ?g)
                                 (eq (fact-slot-value ?fb nom)  ?b)))) 0))))

  (and ?ok-pr ?ok-sg ?ok-po ?ok-bg)
)

; Ordena els menús per preu descendent per facilitar la selecció.
(deffunction sort-menus-by-preu ($?menus)
  (bind ?sorted (create$))
  (bind ?prices (sort > (create$ (foreach ?mv ?menus (fact-slot-value ?mv preu)))))
  (foreach ?p ?prices
    (foreach ?mv ?menus
      (if (and (= (fact-slot-value ?mv preu) ?p)
               (not (member$ ?mv ?sorted)))
        then (bind ?sorted (create$ $?sorted ?mv)))))
  ?sorted)

; Determina si un menú pot ser triat evitant repetir plats o begudes
(deffunction menu-fits (?mv ?used-plats ?used-begs)
  (bind $?used-plats-mf (if (multifieldp ?used-plats) then ?used-plats else (create$ ?used-plats))) 
  (bind $?used-begs-mf  (if (multifieldp ?used-begs)  then ?used-begs  else (create$ ?used-begs)))
  (bind ?pr (fact-slot-value ?mv primer))
  (bind ?sg (fact-slot-value ?mv segon))
  (bind $?bg (fact-slot-value ?mv begudes))

  ; Evita reutilitzar primers i segons (sempre)
  (bind ?conflict (or (member$ ?pr $?used-plats-mf)
                      (member$ ?sg $?used-plats-mf)))

  ; Només bloqueja per repetició de begudes si el mode és GENERAL
  (bind ?bm (fact-slot-value (nth$ 1 (find-all-facts ((?p peticio)) TRUE)) beguda-mode))
  (foreach ?b $?bg
    (if (and (not ?conflict)
             (eq ?bm general)
             (member$ ?b $?used-begs-mf))
        then (bind ?conflict TRUE)))
  (not ?conflict))

; Tria fins a 3 menús sense repetir CAP plat ni CAP beguda (ordenats per preu)
(deffunction select-3-unique-menus ($?menus)
  (if (<= (length$ ?menus) 0) then (return (create$)))
  (if (< (length$ ?menus) 4) then (return $?menus))
  (bind ?picked (create$))
  (bind ?used-plats (create$))
  (bind ?used-begs (create$))

  ;Troba el menú mínim
  (bind ?pmin 1.0e+15)
  (foreach ?mv $?menus
    (bind ?prc (fact-slot-value ?mv preu))
    (if (< ?prc ?pmin) then (bind ?pmin ?prc)))
  (bind ?min-menu (create$))
  (foreach ?mv $?menus
    (if (= (fact-slot-value ?mv preu) ?pmin)
        then (bind ?min-menu (create$ $?min-menu ?mv))))
  (if (> (length$ ?min-menu) 0) then
    (bind ?mv (nth$ 1 ?min-menu))
    (bind ?picked (create$ $?picked ?mv))
    (foreach ?dish (create$ (fact-slot-value ?mv primer) (fact-slot-value ?mv segon))
      (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
    (foreach ?b (fact-slot-value ?mv begudes)
      (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b)))))

  ;Menú del mig aleatori
  (bind ?mid-menu (create$))
  (foreach ?mv $?menus
    (if (and (not (member$ ?mv ?picked))
             (menu-fits ?mv ?used-plats ?used-begs))
        then (bind ?mid-menu (create$ $?mid-menu ?mv))))
  (bind ?n (length$ ?mid-menu))
  (if (> ?n 0) then
    (bind ?rand-index (+ 1 (random 0 (- ?n 1))))
    (bind ?mv (nth$ ?rand-index ?mid-menu))
    (bind ?picked (create$ $?picked ?mv))
    (foreach ?dish (create$ (fact-slot-value ?mv primer) (fact-slot-value ?mv segon))
      (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
    (foreach ?b (fact-slot-value ?mv begudes)
      (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b)))))

  ; Menú CAR: prova el més car, si no encaixa prova el següent menys car 
  (bind ?sorted-desc (sort-menus-by-preu $?menus)) 
  (foreach ?mv ?sorted-desc
    (if (and (not (member$ ?mv ?picked))
             (menu-fits ?mv ?used-plats ?used-begs))
        then
          (bind ?picked (create$ $?picked ?mv))
          (foreach ?dish (create$ (fact-slot-value ?mv primer) (fact-slot-value ?mv segon))
            (if (not (member$ ?dish ?used-plats)) then (bind ?used-plats (create$ $?used-plats ?dish))))
          (foreach ?b (fact-slot-value ?mv begudes)
            (if (not (member$ ?b ?used-begs)) then (bind ?used-begs (create$ $?used-begs ?b))))
          (return ?picked))) 
  ?picked
)

; Imprimeix un bloc de menú amb formatació adequada
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

;------------------- COMPROVACIÓ DE COMPATIBILITAT ----------------------------
(deffunction compat-ok (?pr ?sg ?po)  "Avalua si tres plats són compatibles en termes de mida, categoria i estructura de menú"
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

  ;; 3) Parella pesada entrant→segon no
  (bind ?heavy1 (or (eq ?c1 sopa_crema) (eq ?c1 entrant_calent) (eq ?c1 farinaci_entrant)))
  (bind ?heavy2 (or (eq ?c2 guisat) (eq ?c2 forn_brasa) (eq ?c2 carn)
                    (eq ?c2 farinaci_principal) (eq ?c2 entrant_calent)))
  (if (and ?heavy1 ?heavy2) then (return FALSE))

  ;; 4) Postres molt pesades si 1 i 2 ja són pesats no
  (bind ?dessHeavy (or (eq ?c3 xoco_intens) (eq ?c3 pastisseria)))
  (if (and ?heavy1 ?heavy2 ?dessHeavy) then (return FALSE))
  TRUE)

; Comprova que les procedències dels plats siguin coherents
(deffunction origen-compatible (?pr ?sg ?po) "Es permet un màxim de dues cuines d’origen fort per menú."
  (bind ?p1 (lowcase (send ?pr get-procedencia_plat)))
  (bind ?p2 (lowcase (send ?sg get-procedencia_plat)))
  (bind ?p3 (lowcase (send ?po get-procedencia_plat)))
  (bind ?neutres (create$ "internacional" "tots" "altres" ""))  ; Considerem neurtres aquestes procedències
  (bind $?ori (create$))                                        ; llista d’orígens forts trobats
  (foreach ?o (create$ ?p1 ?p2 ?p3)
    (if (and (not (member$ ?o ?neutres)) (not (member$ ?o $?ori)))
      then (bind $?ori (create$ $?ori ?o))))
  (if (> (length$ $?ori) 2) then (return FALSE))                ; permetem un màxim de 2 orígens forts
  TRUE)

; Assigna un valor de “pes” segons la categoria del plat, per avaluar l’equilibri del menú
(deffunction categoria-pes (?cat) 
  (if (or (eq ?cat sopa_crema) (eq ?cat amanida_fresca) (eq ?cat entrant_fred) (eq ?cat vegetal_entrant)) then (return 1))                                    ; lleuger
  (if (or (eq ?cat farinaci_entrant) (eq ?cat entrant_calent) (eq ?cat vegetal_proteic)) then (return 2))                                                     ; mig
  (if (or (eq ?cat carn) (eq ?cat aus) (eq ?cat peix) (eq ?cat marisc) (eq ?cat forn_brasa) (eq ?cat guisat) (eq ?cat farinaci_principal)) then (return 3))   ; pesat
  (return 1))
(deffunction equilibri-categoria (?pr ?sg ?po) "Avalua si les categories del menú estan equilibrades (lleuger, mig, pesat)"
  (bind ?p1 (categoria-pes (send ?pr get-categoria)))  
  (bind ?p2 (categoria-pes (send ?sg get-categoria)))
  (bind ?p3 (categoria-pes (send ?po get-categoria)))
  (bind ?max (max ?p1 ?p2 ?p3))
  (bind ?min (min ?p1 ?p2 ?p3))
  TRUE)

;------------------- CÀLCUL DE COSTOS I FEE DE SERVEI --------------------------
; Calcula un recàrrec de servei (fee) additiu que s’afegeix al preu total del menú segons:
; - tipus d’esdeveniment (casament, empresa, etc.)
; - grau de formalitat
; - mode de beguda (general o per-plat)
; - complexitat dels plats
(deffunction calc-service-fee (?req ?pr ?sg ?bm)
  (bind ?te   (fact-slot-value ?req tipus-esdeveniment))
  (bind ?form (fact-slot-value ?req formalitat))

  ; Per tipus d’esdeveniment: casament > empresa > aniversari > comunio > congres > altres/indiferent
  (bind ?fee-event
    (if (eq ?te casament)    then 8.0
    else (if (eq ?te empresa)    then 4.0
    else (if (eq ?te aniversari) then 2.0
    else (if (eq ?te comunio)    then 1.0
    else (if (eq ?te congres)    then 0.0
    else 1.0))))))  

  ; Per formalitat
  (bind ?fee-form (if (eq ?form formal) then 6.0 else 0.0))

  ; Per mode de beguda: per-plat implica més servei/ vidre → +3; General → +1 (muntatge)
  (bind ?fee-beg (if (eq ?bm per-plat) then 3.0 else 1.0))

  ; Per “carrega” dels plats (complexitat primer i segon) -> alta:+2, mitjana:+1, baixa:+0 per cada plat (max 4 €)
  (bind ?c1 (send ?pr get-complexitat))
  (bind ?c2 (send ?sg get-complexitat))
  (bind ?fee-cx 0.0)
  (if (eq ?c1 alta)    then (bind ?fee-cx (+ ?fee-cx 2.0))
   else (if (eq ?c1 mitjana) then (bind ?fee-cx (+ ?fee-cx 1.0))))
  (if (eq ?c2 alta)    then (bind ?fee-cx (+ ?fee-cx 2.0))
   else (if (eq ?c2 mitjana) then (bind ?fee-cx (+ ?fee-cx 1.0))))

  ; Cost total del fee
  (return (/ (round (* (+ ?fee-event ?fee-form ?fee-beg ?fee-cx) 100)) 100.0))
)

;------------------- GENERACIÓ DE MENÚS VÀLIDS --------------------------------
; Combina tots els plats i begudes vàlids per construir menús complets.
; Aplica criteris de compatibilitat, preu, formalitat i estacionalitat.
; Genera fets de tipus (menu-valid) per a cada combinació vàlida.
(defrule RefinamentHeuristica::generar-menus-valids
  (declare (auto-focus TRUE))
  (respostes-completes)
  ?req <- (peticio (beguda-mode ?bm) (pressupost-min ?pmin) (pressupost-max ?pmax) (formalitat ?form) (alcohol ?alc) (tipus-esdeveniment ?te))
  (not (menus-generats))
=>
  ; Normalitza rang pressupost
  (bind ?LO (if (eq ?pmin indiferent) then 0.0 else ?pmin))
  (bind ?HI (if (eq ?pmax indiferent) then 1.0e+15 else ?pmax))

  ; Plats vàlids per ordre
  (bind ?primers (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (member$ ordre-primer (send ?p get-te_ordre)))))
  (bind ?segons  (find-all-instances ((?p Plat))
                   (and (> (length$ (find-all-facts ((?f plat-valid-final))
                                 (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                        (member$ ordre-segon (send ?p get-te_ordre)))))
  (bind ?postres
    (if (eq ?te casament)
        then 
          (find-all-instances ((?p Plat))
            (and (> (length$ (find-all-facts ((?f plat-valid-final))
                        (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                (member$ ordre-postres (send ?p get-te_ordre))
                (member$ casament_only (send ?p get-apte_esdeveniment))))
        else
          (find-all-instances ((?p Plat))
            (and (> (length$ (find-all-facts ((?f plat-valid-final))
                        (eq (fact-slot-value ?f nom) (send ?p get-nom)))) 0)
                (member$ ordre-postres (send ?p get-te_ordre))))))

  ; Limita el nombre de plats per limitar explosió combinatòria
  (bind ?primers (subseq$ ?primers 1 (min 50 (length$ ?primers))))
  (bind ?segons  (subseq$ ?segons  1 (min 50 (length$ ?segons))))
  (bind ?postres (subseq$ ?postres 1 (min 30 (length$ ?postres))))

  ; Begudes candidates segons maridatge, només valides finalment
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

  ; Multiplicadors
  (bind ?Ffor (if (eq ?form formal) then 1.30 else 1.0))
  (bind ?Fev (if (or (eq ?te congres) (eq ?te empresa) (and (eq ?te aniversari) (eq ?form informal))) then 0.45 else 1.0))

  ; Generació combinada de plats + begudes
  (foreach ?pr ?primers
    (foreach ?sg ?segons
      (foreach ?po ?postres
        (if (and (compat-ok ?pr ?sg ?po)
                 (origen-compatible ?pr ?sg ?po)
                 (equilibri-categoria ?pr ?sg ?po))
          then (progn
              ; Càlcul de preu base sense begudes
              (bind ?p1 (* (send ?pr get-preu_cost)
                           (if (eq (send ?pr get-complexitat) alta) then 1.35 else (if (eq (send ?pr get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?pr get-mida_racio) gran) then 1.10 else (if (eq (send ?pr get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?pr get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?pr get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?pr get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor
                           ?Fev))
              (bind ?p1 (max ?p1 5.50))
              (bind ?p1 (/ (round (* ?p1 100)) 100.0))

              (bind ?p2 (* (send ?sg get-preu_cost)
                           (if (eq (send ?sg get-complexitat) alta) then 1.35 else (if (eq (send ?sg get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?sg get-mida_racio) gran) then 1.10 else (if (eq (send ?sg get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?sg get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?sg get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?sg get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor
                           ?Fev))
              (bind ?p2 (max ?p2 9.00))
              (bind ?p2 (/ (round (* ?p2 100)) 100.0))

              (bind ?p3 (* (send ?po get-preu_cost)
                           (if (eq (send ?po get-complexitat) alta) then 1.35 else (if (eq (send ?po get-complexitat) mitjana) then 1.15 else 1.0))
                           (if (eq (send ?po get-mida_racio) gran) then 1.10 else (if (eq (send ?po get-mida_racio) petita) then 0.90 else 1.0))
                           (if (>= (length$ (send ?po get-disponibilitat_plats)) 4) then 1.0 else (if (eq (length$ (send ?po get-disponibilitat_plats)) 3) then 1.05 else (if (eq (length$ (send ?po get-disponibilitat_plats)) 2) then 1.10 else 1.20)))
                           ?Ffor
                           ?Fev))
              (bind ?p3 (max ?p3 3.00))
              (bind ?p3 (/ (round (* ?p3 100)) 100.0))

              ; Càlcul preu total amb begudes segons mode
              (bind ?base (+ ?p1 ?p2 ?p3))
              (bind ?fee (calc-service-fee ?req ?pr ?sg ?bm))
              (bind ?base2 (+ ?base ?fee))

                ; Combinació amb beguda 
                (if (eq ?bm general) then
                  ; Només 1 beguda general per menú
                  (foreach ?GB ?bG
                    (bind ?total (+ ?base2 (send ?GB get-preu_cost)))
                    (bind ?total (/ (round (* ?total 100)) 100.0))
                    (if (and (>= ?total ?LO) (<= ?total ?HI)) then
                      (assert (menu-valid
                                (primer (send ?pr get-nom))
                                (segon  (send ?sg get-nom))
                                (postres (send ?po get-nom))
                                (begudes (create$ (send ?GB get-nom)))
                                (preu ?total)))))
                  else
                  ; Beguda per plat
                  (foreach ?bPrC ?bPr
                    (foreach ?bSgC ?bSg
                      (foreach ?bPoC ?bPo
                        (bind ?total (+ ?base2
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

;------------------- PRESENTACIÓ DE MENÚS A L’USUARI ---------------------------
; Mostra per pantalla fins a tres menús seleccionats com a recomanacions finals.
(defrule RefinamentHeuristica::mostrar-menus-inicials
  (declare (auto-focus TRUE))
  (respostes-completes)
  (not (menus-presentats))
  =>
  (bind ?menus (find-all-facts ((?m menu-valid)) TRUE))
  (bind ?n (length$ ?menus))
  (if (<= ?n 0) then
    (printout t crlf "*** Ho sentim, no disposem de menús vàlids per a les teves restriccions. ***" crlf)
    (assert (menus-presentats))
   else
    (bind ?picked (select-3-unique-menus $?menus))
    (foreach ?old (find-all-facts ((?x menu-seleccionat)) TRUE) (retract ?old))
    (bind ?nsel (length$ ?picked))
    (if (<= ?nsel 0) then
      (printout t crlf "*** No hi ha menús que compleixin la unicitat de plats. ***" crlf)
     else
      (printout t crlf "=== MENÚS DISPONIBLES ===" crlf)
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

; Un cop presentats els menús generals, genera i mostra menús específics
; per a cada grup amb restriccions (dietes o al·lèrgies).
; Cada grup obté les seves tres millors opcions.
(defrule RefinamentHeuristica::mostrar-menus-per-grup
  (declare (auto-focus TRUE))
  (menus-presentats)                       
  (grup (nom ?g))
  (not (menus-presentats-grup (grup ?g)))
  =>
  (if (<= (length$ (find-all-facts ((?f frase-grups-impresa)) TRUE)) 0) then
    (printout t crlf
      "A més, s’han identificat menús específics per als grups amb restriccions definides, "
      "garantint la compatibilitat en plats i begudes sense alterar el ritme del servei." crlf crlf)
    (assert (frase-grups-impresa)))
  (bind ?tots (find-all-facts ((?m menu-valid)) TRUE))

  ; Filtra només menús aptes per al grup ?g
  (bind ?cand (create$))
  (foreach ?mv ?tots
    (if (menu-apte-per-grup ?mv ?g) then
      (bind ?cand (create$ $?cand ?mv))))
 
  ; Tria top-3 sense repetir plats
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