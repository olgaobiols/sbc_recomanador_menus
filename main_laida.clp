(defmodule MAIN (export ?ALL))

(deftemplate MAIN::peticio
    (slot tipus-esdeveniment)               ; SYMBOL (nil al principi)
    (slot data)                             ; SYMBOL
    (slot torn)                             ; SYMBOL
    (slot espai)                            ; SYMBOL
    (slot num-comensals (type INTEGER SYMBOL))  ; permet nil al principi
    (slot pressupost-min (type NUMBER SYMBOL))  ; permet nil al principi
    (slot pressupost-max (type NUMBER SYMBOL))  ; permet nil al principi
    (slot formalitat)                       ; SYMBOL: informal/formal
    (slot beguda-mode)                      ; SYMBOL: general/per-plat
    (slot alcohol)                          ; SYMBOL: si/no    
    (slot alergies-si (type SYMBOL))        ; si/no
    (multislot alergens (type SYMBOL STRING))
)


(deftemplate Plat
   (slot nom)
   (slot formalitat)
   (slot temperatura)
   (multislot alergens)
   (slot complexitat)
   (slot mida_racio)
   (slot procedencia)
)

(deftemplate Beguda
   (slot nom)
   (slot preu_cost)
   (slot alcohol)
   (slot formalitat)
   (slot procedencia)
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

(deffunction valida-llista-numeros (?input ?min ?max)
  "Valida una llista de números separats per espais dins d’un rang concret.
   Retorna la llista com a multislot si és vàlida, sinó retorna nil."
  (bind ?nums (explode$ ?input))
  (bind ?valid TRUE)

  ;; comprova cada element
  (foreach ?x ?nums
    (if (or (not (integerp (integer ?x)))
            (< (integer ?x) ?min)
            (> (integer ?x) ?max)) then
        (bind ?valid FALSE)
    )
  )

  ;; elimina duplicats
  (if ?valid then
    (bind ?sense-repetits (create$))
    (foreach ?x ?nums
      (if (not (member$ ?x ?sense-repetits)) then
        (bind ?sense-repetits (create$ $?sense-repetits ?x))
      )
    )
    (return ?sense-repetits)
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
  (preguntat-num-comensals)
  (not (preguntat-pressupost-min))
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
  (preguntat-pressupost-max)
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




(defrule PreferenciesMenu::preguntar-alergens-prohibits
  ?p <- (peticio (alergies-si ?as&nil))
  (preguntat-alcohol)
  (not (preguntat-alergens-prohibits))
=>
  (bind ?r (valida-boolea "Hi ha alguna condició alimentària general? (al·lèrgies, dietes especials o ingredients prohibits)? (sí/no)"))
  (modify ?p (alergies-si ?r))
  (assert (preguntat-alergens-prohibits))
)

(defrule PreferenciesMenu::detallar-alergens
  ?p <- (peticio (alergies-si si))
  (not (detallar-alergens))
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
      (assert (detallar-alergens))
      (printout t "Has indicat: " ?noms crlf)
    else
      (printout t " Si us plau introdueix només números entre 1 i 10 separats per espais." crlf)
    )
  )
)

(defrule PreferenciesMenu::anar-a-abstraccio
  (peticio 
    (tipus-esdeveniment ?te&~nil)
    (data ?d&~nil)
    (torn ?t&~nil)
    (espai ?e&~nil)
    (num-comensals ?n&~nil)
    (pressupost-min ?min&~nil)
    (pressupost-max ?max&~nil)
    (formalitat ?f&~nil)
    (beguda-mode ?bm&~nil)
    (alcohol ?a&~nil)
    (alergies-si ?asi&~nil))
  (not (abstraccio-iniciada))
=>
  (printout t crlf "Construint perfil d'usuari..." crlf)
  (assert (abstraccio-iniciada))
  (focus AbstraccioHeuristica)
)



;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
(defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
(deftemplate AbstraccioHeuristica::perfil-usuari
  (slot temporada)
  (slot torn)
  (slot espai)
  (slot tipus-esdeveniment)
  (slot formalitat)
  (slot alcohol)
  (slot num-comensals (type INTEGER))
  (slot beguda-mode)
  (slot pressupost-min (type NUMBER))
  (slot pressupost-max (type NUMBER))
  (multislot alergens-prohibits)  ;; accepta múltiples valors
)

;; Regla que converteix una peticio en un perfil-usuari
(defrule AbstraccioHeuristica::construir-perfil
  ?p <- (peticio
          (tipus-esdeveniment ?te&~nil)
          (data ?temp&~nil)
          (torn ?t&~nil)
          (espai ?esp&~nil)
          (num-comensals ?n&~nil)
          (pressupost-min ?min&~nil)
          (pressupost-max ?max&~nil)
          (formalitat ?form&~nil)
          (beguda-mode ?bm&~nil)
          (alcohol ?alc&~nil)
          (alergies-si ?asi&~nil)
          (alergens $?als) )            ;; agafem el multislot tal qual
  (not (perfil-usuari))
  =>
  ;; Normalitzar els al·lèrgens:
  ;; si l'usuari ha dit que sí i hi ha algun valor en $?als -> els usem
  ;; si no, deixem llista buida
  (bind ?alergies (if (and (eq ?asi si) (> (length$ $?als) 0))
                     then $?als
                     else (create$)))
  ;; Assertem perfil-usuari amb tots els camps pertinents
  (assert (perfil-usuari
            (temporada ?temp)
            (torn ?t)
            (espai ?esp)
            (tipus-esdeveniment ?te)
            (formalitat ?form)
            (alcohol ?alc)
            (num-comensals ?n)
            (beguda-mode ?bm)
            (pressupost-min ?min)
            (pressupost-max ?max)
            (alergens-prohibits ?alergies)))
)

;; Regla per imprimir totes les preferències del perfil-usuari (un cop)
(defrule AbstraccioHeuristica::imprimeix-perfil
  ?pf <- (perfil-usuari
           (temporada ?temp)
           (torn ?torn)
           (espai ?esp)
           (tipus-esdeveniment ?te)
           (formalitat ?form)
           (alcohol ?alc)
           (num-comensals ?n)
           (beguda-mode ?bm)
           (pressupost-min ?min)
           (pressupost-max ?max)
           (alergens-prohibits $?alergs))
  (not (perfil-impresa))
  =>
  (printout t crlf "=== PERFIL D'USUARI CONSTRUIT ===" crlf)
  (printout t "Tipus esdeveniment: " ?te crlf)
  (printout t "Temporada / època:    " ?temp crlf)
  (printout t "Torn:                 " ?torn crlf)
  (printout t "Espai:                " ?esp crlf)
  (printout t "Nombre comensals:     " ?n crlf)
  (printout t "Pressupost (min-max): " ?min " - " ?max " €/pp" crlf)
  (printout t "Formalitat:           " ?form crlf)
  (printout t "Beguda-mode:          " ?bm crlf)
  (printout t "Alcohol permès:       " ?alc crlf)
  (if (> (length$ $?alergs) 0)
    then (printout t "Al·lèrgens / dietes: " $?alergs crlf)
    else (printout t "Al·lèrgens / dietes: cap" crlf))
  (printout t "=================================" crlf crlf)
  (assert (perfil-impresa))
)

(defrule AbstraccioHeuristica::anar-a-associacio
  (perfil-usuari)
  (not (associacio-iniciada))
=>
  (assert (associacio-iniciada))
  (focus AssociacioHeuristica))


;; PAS 3: ASSOCIACIÓ HEURÍSTICA ---------------------------
(defmodule AssociacioHeuristica
  (import MAIN ?ALL)
  (import AbstraccioHeuristica ?ALL)
  (export ?ALL))

(deftemplate AssociacioHeuristica::candidat-menu
  (slot id-menu)
  (slot nom (type STRING))
  (multislot plats)
  (multislot begudes)
  (slot puntuacio (type FLOAT))
)

;; Regla per generar candidats combinant plats i begudes
(defrule AssociacioHeuristica::genera-candidat-desde-plats
   ?perfil <- (perfil-usuari 
                 (alergens-prohibits $?prohibits)
                 (formalitat ?usu-form)
                 (torn ?usu-torn)
                 (temporada ?usu-temp)
                 (espai ?usu-esp)
                 (tipus-esdeveniment ?usu-event)
                 (alcohol ?usu-alc)
                 (beguda-mode ?usu-beguda))
   (not (candidat-menu)) ; només generar si no hi ha candidats
   =>
   (bind ?plats-seleccionats (create$))
   (bind ?begudes-seleccionades (create$))

   ;; -------------------------------
   ;; Selecció de plats
   ;; -------------------------------
   (foreach ?plat (find-all-facts ((?p Plat)) TRUE)
      ;; Filtra al·lèrgens prohibits
      (bind ?skip FALSE)
      (foreach ?al (fact-slot-value ?plat alergens)
         (if (member$ ?al $?prohibits) then (bind ?skip TRUE)))
      ;; Filtra formalitat
      (if (not (eq ?usu-form (fact-slot-value ?plat formalitat))) then (bind ?skip TRUE))
      ;; Si el plat és compatible, afegeix-lo
      (if (not ?skip) then
         (bind ?plats-seleccionats (create$ $?plats-seleccionats ?plat))
      )
   )

   ;; -------------------------------
   ;; Selecció de begudes
   ;; -------------------------------
   (foreach ?b (find-all-facts ((?bev Beguda)) TRUE)
      ;; Filtra alcohol segons preferència
      (if (eq ?usu-alc (fact-slot-value ?b alcohol)) then
         (bind ?begudes-seleccionades (create$ $?begudes-seleccionades ?b))
      )
   )

   ;; -------------------------------
   ;; Puntuació heurística simple
   ;; -------------------------------
   (bind ?score 0)
   (bind ?score (+ ?score (length$ ?plats-seleccionats)))
   (bind ?score (+ ?score (length$ ?begudes-seleccionades)))

   ;; -------------------------------
   ;; Assert del candidat-menu
   ;; -------------------------------
   (assert (candidat-menu 
           (id-menu (str-cat "MENU-" (gensym)))
           (plats $?plats-seleccionats)
           (begudes $?begudes-seleccionades)
           (puntuacio ?score)))


   (printout t "→ S'ha generat un candidat combinant plats i begudes amb puntuació " ?score crlf)
)

(defrule AssociacioHeuristica::activar-refinament
   (declare (salience -50))
   (candidat-menu)
   (not (refinament-iniciat))
   =>
   (assert (refinament-iniciat))
   (printout t crlf "=== Fase de REFINAMENT activada ===" crlf)
   ;; Aquí és important fer focus explícit al mòdul Refinament
   (focus RefinamentHeuristica)
)


;; PAS 4: REFINAMENT HEURÍSTICA -------------------------------------------------
(defmodule RefinamentHeuristica
   (import MAIN ?ALL)
   (import AssociacioHeuristica ?ALL)
   (export ?ALL))

;; Activació automàtica del mòdul Refinament
(defrule RefinamentHeuristica::activar-refinament
  (declare (auto-focus TRUE))
  (candidat-menu)
  (not (refinament-iniciat))
  =>
  (assert (refinament-iniciat))
  (printout t crlf "=== Fase de REFINAMENT activada ===" crlf)
  (focus RefinamentHeuristica)
)

;; Selecció del millor menú (puntuació més alta)
(defrule RefinamentHeuristica::selecciona-millor-menu
   (declare (salience -10))
   ?c <- (candidat-menu (id-menu ?id)
                        (nom ?nom)
                        (plats $?plats)
                        (begudes $?begudes)
                        (puntuacio ?p))
   (not (millor-trobat))
   =>
   ;; Inicialitzar la millor opció amb aquesta candidata
   (bind ?millor-id ?id)
   (bind ?millor-nom ?nom)
   (bind ?millor-punt ?p)
   
   ;; Comparar amb totes les altres candidates
   (foreach ?cm (find-all-facts ((?x candidat-menu)) TRUE)
      (bind ?punt (fact-slot-value ?cm puntuacio))
      (if (> ?punt ?millor-punt) then
         (bind ?millor-id (fact-slot-value ?cm id-menu))
         (bind ?millor-nom (fact-slot-value ?cm nom))
         (bind ?millor-punt ?punt)))
   
   (assert (millor-trobat))
   
   ;; Mostrar resultats
   (printout t crlf "==============================" crlf)
   (printout t " MENÚ RECOMANAT" crlf)
   (printout t " Nom: " ?millor-nom crlf)
   (printout t " ID: " ?millor-id crlf)
   (printout t " Puntuació heurística: " ?millor-punt crlf)
   (printout t "Plats:" crlf)
   (foreach ?pl $?plats
      (printout t " - " (fact-slot-value ?pl nom) crlf))
   (printout t "Begudes:" crlf)
   (foreach ?bev $?begudes
      (printout t " - " (fact-slot-value ?bev nom) crlf))
   (printout t "==============================" crlf crlf))


;; Mostrar tots els candidats generats
(defrule RefinamentHeuristica::mostra-top-candidats
  (declare (salience -20))
  (millor-trobat)
  =>
  (printout t "Altres menús candidats:" crlf)
  (foreach ?c (find-all-facts ((?f candidat-menu)) TRUE)
     (printout t
       " - " (fact-slot-value ?c nom)
       " | Puntuació: " (fact-slot-value ?c puntuacio)
       crlf))
  (printout t "==============================" crlf crlf)
)
