; (defmodule MAIN (export ?ALL))

; (deftemplate MAIN::peticio
;   (slot tipus-esdeveniment)               ; SYMBOL (nil al principi)
;   (slot data)                             ; SYMBOL
;   (slot torn)                             ; SYMBOL
;   (slot espai)                            ; SYMBOL
;   (slot num-comensals (type INTEGER SYMBOL)) ; permet nil al principi
;   (slot infantil-senior (type SYMBOL)) ; "si"/"no" en minúscules
;   (slot pressupost-min (type NUMBER SYMBOL))  ; permet nil al principi
;   (slot pressupost-max (type NUMBER SYMBOL))
;   (slot servei)                           ; SYMBOL: emplatat/buffet/pica-pica/mixt/indiferent
;   (slot formalitat)                       ; SYMBOL: informal/formal
;   (slot beguda-mode )                      ; SYMBOL: general/per-plat
;   (slot alcohol )                          ; SYMBOL: si/no
;   (slot menu-mode )                        ; SYMBOL: unic/alternatiu
;   (slot requereix-pastis (type SYMBOL)) ; si/no/indiferent
;   (slot public-aniversari)                ; adults/nens/mixt
;   (slot necessita-pica-pica (type SYMBOL)) ; si/no/indiferent
;   (slot diferenciar-edats (type SYMBOL)) ; si/no
;   (slot num-nens (type INTEGER SYMBOL))
;   (slot num-adults (type INTEGER SYMBOL))
;   (slot num-vegans (type INTEGER SYMBOL))
;   (slot num-vegetarians (type INTEGER SYMBOL))
;   (slot num-celiacs (type INTEGER SYMBOL))
;   (slot num-halal (type INTEGER SYMBOL))
;   (slot estrategia-dietes (type SYMBOL)) ; adaptar/alternatiu/mixt/nil
;   (slot alergies-si (type SYMBOL)) ; si/no
;   (slot alergens)                         ; TEXT/SYMBOL
; )

;; COMENTARIS GENERALS ---------------------------------------------------
; definir usa-ingredient ??
; DEFINIR QUANTITAT INGREDIENT ??
; CORREGIR ALCOHOL NO --> MILLOR FALSE PER PODER FER NOT??
; MODIFICAR LÍMIT MÀXIM i MÍNIM  MENU??? --> VEURE ENUNCIAT -> NO PREU APROXIMAT PER CAP
; AFEGIR ID MENU A ONTOLOGIA EN COMPTES DE NOM I GENERAR NOM EN FUNCIO ATRIBUTS ???
; AFEGIR POSSIBILITAT PER PART DE L USUARI  DE DIR QUE LI ES IGUAL EL FILTRE
;; ------------------------------------------------------------------

; HELPERS
; (deffunction round2 (?x) "Arrodoneix un float a 2 decimals"
;   (/ (float (round (* ?x 100))) 100.0))

; (deffunction factor-complexitat (?c) "Factor de complexitat segons la classificació baixa/mitjana/alta"
;   (if (eq ?c baixa) then 1.10
;    else (if (eq ?c mitjana) then 1.25
;    else (if (eq ?c alta) then 1.50 else 1.20))))

; (deffunction factor-formalitat (?f)  "Factor de formalitat segons la classificació informal/formal"
;   (if (eq ?f formal) then 1.15 else 1.00))

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
; (deffunction valida-boolea "Valida una resposta booleana (sí/no)"
;   (?prompt)
;   (bind ?resp_valida FALSE)
;   (bind ?resp nil)

;   (while (not ?resp_valida)
;     (printout t ?prompt " (sí/no): " crlf)
;     (bind ?x (lowcase (readline)))
;     (if (or (eq ?x "sí") (eq ?x "si") (eq ?x "s") (eq ?x "y") (eq ?x "yes")) then
;         (bind ?resp_valida TRUE) (bind ?resp si)
;     else
;     (if (or (eq ?x "no") (eq ?x "n")) then
;         (bind ?resp_valida TRUE) (bind ?resp no)
;     else
;         (printout t "Si us plau, respon 'sí' o 'no'." crlf))))
;   ?resp
; )


; (deffunction valida-num "Valida una resposta numèrica dins d'un rang"
;   (?prompt ?min ?max)
;   (bind ?resp_valida FALSE)
;   (bind ?resp nil)

;   (while (not ?resp_valida)
;     (printout t ?prompt " (" ?min "-" ?max "): " crlf)
;     (bind ?resp (read))
;     (if (numberp ?resp) then
;         (if (and (>= ?resp ?min) (<= ?resp ?max)) then ; resposta dins del rang 
;             (bind ?resp_valida TRUE)
;         else
;             (printout t "Si us plau introdueix un valor dins del rang ("?min " - "?max ")."  crlf)
;         )
;     else
;         (printout t "Si us plau introdueix un valor numèric." crlf)
;     )
;   )
;   ?resp ; retorna la resposta validada  
; )

; (deffunction valida-opcio (?pregunta $?opcions)
;   (bind ?resp_valida FALSE)
;   (bind ?resp nil)

;   (while (not ?resp_valida)
;     (printout t ?pregunta crlf)
;     (bind ?input (string-to-field (lowcase (readline)))) 

;     ; comprova si l’entrada és una de les opcions vàlides
;     (if (member$ ?input ?opcions) then
;         (bind ?resp_valida TRUE)
;         (bind ?resp ?input)
;      else
;         (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))
;   )
;   ?resp
; )

;; MÒDULS DE CONTROL I CLASSIFICACIÓ HEURÍSTICA-------------------------------
; (defmodule ControlFlux (import MAIN ?ALL))
; (defrule ControlFlux::arrencada
;   (declare (auto-focus TRUE))
;   (initial-fact)
;   =>
;   (focus RefinamentHeuristica)
;   (focus AssociacioHeuristica)
;   (focus AbstraccioHeuristica)
;   (focus PreferenciesMenu)
; )

;; PAS 1: RECOLLIR PREFERÈNCIES -------------------------------
; (defmodule PreferenciesMenu (import MAIN ?ALL) (export ?ALL))
; ; ??????????????

; ; AFEGIR PREU MIN I PREU MAX --> REVISAR ENUNCIAT PROBLEMA !!!!!
; ; AFEGIR TYPES ? O NO CAL SI JA ESTAN A ONTOLOGIA ????
; (defrule PreferenciesMenu::iniciar-peticio
;   (declare (auto-focus TRUE))
;   (not (peticio))
;   (not (iniciat))
;   =>
;   (printout t "Benvingut/da al recomanador de menús RicoRico!" crlf)
;   (printout t "Si us plau respon a les preguntes següents per personalitzar les propostes." crlf)
;   (assert (peticio))
;   (assert (iniciat))
;   (focus PreferenciesMenu)
; )

; ; PREGUNTES DE CONTEXT GENERAL DE L'ESDEVENIMENT
; (defrule PreferenciesMenu::preguntar-tipus-esdeveniment
;   (declare (auto-focus TRUE))
;   ?p <- (peticio (tipus-esdeveniment ?te&nil))
;   (not (preguntat-tipus))
; =>
;   (bind ?res (valida-opcio 
;               "Quin tipus d’esdeveniment estàs organitzant? (casament/ aniversari/ comunió/ congrés/ empresa/ altres)"
;               casament aniversari comunio congres empresa altres)
  
;   )
;   (modify ?p (tipus-esdeveniment ?res))
;   (assert (preguntat-tipus))
; )

; ; AMPLIAR PER A QUE ACCEPTI DATA CONCRETA!!!!!!!
; (defrule PreferenciesMenu::preguntar-data
;   ?p <- (peticio (data ?e&nil))
;   (preguntat-tipus)
;   (not (preguntat-data))
; =>
;   (bind ?r (valida-opcio
;               "Quina època de l’any? (primavera/ estiu/ tardor/ hivern)"
;               primavera estiu tardor hivern))
;   (modify ?p (data ?r))
;   (assert (preguntat-data))
; )

; (defrule PreferenciesMenu::preguntar-dinar-sopar 
;   ?p <- (peticio (torn ?t&nil))
;   (preguntat-data)
;   (not (preguntat-dinar-sopar))
; =>
;   (bind ?r (valida-opcio "Serà dinar o sopar?" dinar sopar))
;   (modify ?p (torn ?r))
;   (assert (preguntat-dinar-sopar))
; )

; (defrule PreferenciesMenu::preguntar-interior-exterior
;   ?p <- (peticio (espai ?s&nil))
;   (preguntat-dinar-sopar)
;   (not (preguntat-interior-exterior))
; =>
;   (bind ?r (valida-opcio "Es farà en interior o exterior?" interior exterior))
;   (modify ?p (espai ?r))
;   (assert (preguntat-interior-exterior))
; )

; ; (defrule PreferenciesMenu::preguntar-adreca
; ;   (exists (preguntat-interior-exterior))
; ;   (not (exists (preguntat-adreca)))
; ;   =>
  
; ;   (assert (preguntat-adreca))
; ; )

; ; MODIFICAR LÍMIT MÀXIM
; (defrule PreferenciesMenu::preguntar-num-comensals
;   ?p <- (peticio (num-comensals ?n&nil))
;   (preguntat-interior-exterior)
;   (not (preguntat-num-comensals))
; =>
;   (bind ?r (valida-num "Quants comensals assistiran aproximadament?" 1 5000))
;   (modify ?p (num-comensals ?r))
;   (assert (preguntat-num-comensals))
; )

; (defrule PreferenciesMenu::preguntar-infantil-senior
;   ?p <- (peticio (infantil-senior ?x&nil))
;   (preguntat-num-comensals)
;   (not (preguntat-infantil-senior))
; =>
;   (bind ?r (valida-boolea "Cal una opció infantil o suau per gent gran? (sí/no)"))
;   (modify ?p (infantil-senior ?r))
;   (assert (preguntat-infantil-senior))
; )


; (defrule PreferenciesMenu::preguntar-pressupost-min
;   ?p <- (peticio (pressupost-min ?ppmin&nil))
;   (preguntat-infantil-senior)
;   (not (preguntat-pressupost))
; =>
;   (bind ?min (valida-num "Quin és el pressupost mínim per persona?" 1 1000))
;   (modify ?p (pressupost-min ?min))
;   (assert (preguntat-pressupost-min)))

; (defrule PreferenciesMenu::preguntar-pressupost-max
;   ?p <- (peticio (pressupost-min ?min&~nil) (pressupost-max ?ppmax&nil))
;   (preguntat-pressupost-min)
;   (not (preguntat-pressupost-max))
; =>
;   (bind ?max (valida-num "I quin és el pressupost màxim per persona?" ?min 2000))
;   (modify ?p (pressupost-max ?max))
;   (assert (preguntat-pressupost-max))
;   (assert (preguntat-pressupost))
; )

; (defrule PreferenciesMenu::preguntar-servei
;   ?p <- (peticio (servei ?s&nil))
;   (preguntat-pressupost)
;   (not (preguntat-servei))
; =>
;   (bind ?r (valida-opcio "Quin tipus de servei prefereixes? (emplatat/ buffet/ pica-pica/ mixt/ indiferent)"
;             emplatat buffet pica-pica mixt indiferent))
;   (modify ?p (servei ?r))
;   (assert (preguntat-servei)))

; (defrule PreferenciesMenu::preguntar-formalitat
;   ?p <- (peticio (formalitat ?f&nil))
;   (preguntat-servei)
;   (not (preguntat-formalitat))
; =>
;   (bind ?r (valida-opcio "Quin grau de formalitat vols? (formal/ informal)" 
;             informal formal))
;   (modify ?p (formalitat ?r))
;   (assert (preguntat-formalitat))
; )

; (defrule PreferenciesMenu::preguntar-detall-casament
;   ?p <- (peticio (tipus-esdeveniment casament) (requereix-pastis ?rp&nil))
;   (preguntat-formalitat)
;   (not (preguntat-pastis-casament))
; =>
;   (bind ?r (valida-opcio "Vols assegurar un pastís cerimonial per al casament? (si/no/indiferent)"
;             si no indiferent))
;   (modify ?p (requereix-pastis ?r))
;   (assert (preguntat-pastis-casament)))

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

; (defrule PreferenciesMenu::preguntar-beguda-general
;   ?p <- (peticio (beguda-mode ?bm&nil))
;   (preguntat-formalitat)
;   (not (preguntat-beguda-general))
; =>
;   (bind ?r (valida-opcio "Beguda per a tot el menú o per a cada plat? (general/per-plat)" general per-plat))
;   (modify ?p (beguda-mode ?r))
;   (assert (preguntat-beguda-general))
; )

; (defrule PreferenciesMenu::preguntar-alcohol
;   ?p <- (peticio (alcohol ?a&nil))
;   (preguntat-beguda-general)
;   (not (preguntat-alcohol))
; =>
;   (bind ?r (valida-boolea "Prefereixes que el menú inclogui begudes alcohòliques? (sí/no)"))
;   (modify ?p (alcohol ?r))
;   (assert (preguntat-alcohol))
; )

; (defrule PreferenciesMenu::preguntar-menu-unic
;   ?p <- (peticio (menu-mode ?mm&nil))
;   (preguntat-alcohol)
;   (not (preguntat-menu-unic))
; =>
;   (bind ?r (valida-opcio "Vols un menú únic per a tothom o opcions alternatives? (unic/alternatiu)" unic alternatiu))
;   (modify ?p (menu-mode ?r))
; ;   (assert (preguntat-menu-unic))
; ; )

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






; (defrule PreferenciesMenu::preguntar-alergens-prohibits
;   ?p <- (peticio (alergies-si ?as&nil))
;   (preguntat-menu-unic)
;   (not (preguntat-alergens-prohibits))
; =>
;   (bind ?r (valida-boolea "Hi ha al·lèrgies o ingredients prohibits que s'han d'evitar? (sí/no)"))
;   (modify ?p (alergies-si ?r))
;   (assert (preguntat-alergens-prohibits))
; )

; (defrule PreferenciesMenu::detallar-alergens
;   ?p <- (peticio (alergies-si si) (alergens ?al&nil))
;   (preguntat-alergens-prohibits)
;   (not (alergens-detalats))
;   =>
;   (printout t "Indica'ls separats per espais (ex: gluten marisc lactosa): " crlf)
;   (modify ?p (alergens (lowcase (readline))))
;   (assert (alergens-detalats))
; ; )

; ;; PAS 2: ABSTRACCIÓ HEURÍSTICA -------------------------------
; (defmodule AbstraccioHeuristica (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))
; (deffunction separa-paraules (?txt) "Separa un text en paraules individuals"
;   (if (or (eq ?txt nil) (eq ?txt "")) then (create$) else (explode$ ?txt)))

; (deftemplate AbstraccioHeuristica::perfil-usuari
;   (slot temporada)        ; primavera/estiu/tardor/hivern
;   (slot torn)             ; dinar/sopar
;   (slot espai)            ; interior/exterior
;   (slot tipus-esdeveniment)
;   (slot formalitat)       ; informal/formal
;   (slot alcohol)          ; si/no
;   (slot infantil-senior)  ; si/no
;   (slot num-comensals (type INTEGER))
;   (slot beguda-mode)
;   (slot menu-mode)
;   (slot pressupost-min (type NUMBER))
;   (slot pressupost-max (type NUMBER))
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
;   (multislot alergens-prohibits)

;   ; AJUSTAR SEGONS CRITERIS !!!!!!!!!
;   ;; pesos per al matching (ajustables)
;   (slot pes-formalitat (type FLOAT) (default 1.0))
;   (slot pes-temporada  (type FLOAT) (default 0.8))
;   (slot pes-beguda     (type FLOAT) (default 0.5))
;   (slot pes-alergies   (type FLOAT) (default 2.0))
;   (slot pes-torn       (type FLOAT) (default 0.5))
;   (slot pes-espai      (type FLOAT) (default 0.5))
; )

; (defrule AbstraccioHeuristica::construir-perfil
;   ?p <- (peticio (tipus-esdeveniment ?te&~nil)
;           (data ?temp&~nil) (torn ?t&~nil)
;           (espai ?e&~nil) (formalitat ?f&~nil) (alcohol ?al&~nil)
;           (infantil-senior ?infsen&~nil) (num-comensals ?n&~nil)
;           (pressupost-min ?ppmin&~nil) (pressupost-max ?ppmax&~nil)
;           (servei ?serv) (beguda-mode ?bm&~nil) (menu-mode ?mm&~nil)
;           (requereix-pastis ?rp) (public-aniversari ?pa)
;           (necessita-pica-pica ?pic) (diferenciar-edats ?de)
;           (num-nens ?nn) (num-adults ?ns)
;           (num-vegans ?veg) (num-vegetarians ?vege)
;           (num-celiacs ?cel) (num-halal ?hal)
;           (estrategia-dietes ?estrat)
;           (alergies-si ?asi&~nil) (alergens ?als))
;   (not (perfil-usuari))
;   =>
;   (bind ?al-list (if (eq ?asi si) then (separa-paraules ?als) else (create$)))
;   (bind ?serv-final (if (eq ?serv nil) then indiferent else ?serv))
;   (bind ?rp-final (if (eq ?rp nil) then indiferent else ?rp))
;   (bind ?pa-final (if (eq ?pa nil) then indiferent else ?pa))
;   (bind ?pic-final (if (eq ?pic nil) then indiferent else ?pic))
;   (bind ?de-final (if (eq ?de nil) then no else ?de))
;   (bind ?nn-final (if (numberp ?nn) then ?nn else 0))
;   (bind ?ns-final (if (numberp ?ns) then ?ns else 0))
;   (bind ?veg-final (if (numberp ?veg) then ?veg else 0))
;   (bind ?vege-final (if (numberp ?vege) then ?vege else 0))
;   (bind ?cel-final (if (numberp ?cel) then ?cel else 0))
;   (bind ?hal-final (if (numberp ?hal) then ?hal else 0))
;   (bind ?estrat-final (if (eq ?estrat nil) then indiferent else ?estrat))
;   (assert (perfil-usuari
;             (temporada ?temp) (torn ?t) (espai ?e) (tipus-esdeveniment ?te)
;             (formalitat ?f) (alcohol ?al) (infantil-senior ?infsen)
;             (num-comensals ?n) (beguda-mode ?bm) (menu-mode ?mm)
;             (servei ?serv-final)
;             (requereix-pastis ?rp-final)
;             (public-aniversari ?pa-final)
;             (necessita-pica-pica ?pic-final)
;             (diferenciar-edats ?de-final)
;             (num-nens ?nn-final)
;             (num-adults ?ns-final)
;             (num-vegans ?veg-final)
;             (num-vegetarians ?vege-final)
;             (num-celiacs ?cel-final)
;             (num-halal ?hal-final)
;             (estrategia-dietes ?estrat-final)
;             (pressupost-min ?ppmin) (pressupost-max ?ppmax)
;             (alergens-prohibits ?al-list)))
; )

; (defrule AbstraccioHeuristica::temperatura-espai-temporada
;   ; defineix la temperatura que ha de tenir un plat segons 
;   ; l'espai (interior/exterior) i la temporada (estiu/hivern/primavera/tardor)

; )

;; PAS 3: ASSOCIACIÓ HEURÍSTICA -------------------------------
; (defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))

; (deftemplate AssociacioHeuristica::menu-base
;   (slot id (type SYMBOL))
;   (slot nom (type STRING))
;   (slot categoria (type SYMBOL))      ; barat/mitja/car
;   (slot preu-pp (type FLOAT))
;   (slot formalitat)
;   (multislot temporades)
;   (multislot torns)
;   (multislot espais)
;   (multislot esdeveniments)
;   (slot alcohol)
;   (slot beguda-mode)
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
;   (multislot plats)
;   (multislot begudes)
;   (multislot alergens)
;   (slot descripcio (type STRING)))

; (deftemplate AssociacioHeuristica::candidat-menu
;   (slot id-menu)
;   (slot nom (type STRING))
;   (slot franja-preu) ; barat/mitjà/car
;   (slot preu-pp (type FLOAT))
;   (slot formalitat)
;   (multislot temporades)
;   (multislot torns)
;   (multislot espais)
;   (multislot esdeveniments)
;   (slot alcohol)
;   (slot beguda-mode)
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
;   (multislot plats)
;   (multislot begudes)
;   (multislot alergens)
;   (slot descripcio (type STRING))
;   (slot puntuacio (type FLOAT))
;   (multislot motius))

; (defrule AssociacioHeuristica::genera-candidat-menu
;   (perfil-usuari)
;   (menu-base (id ?id) (nom ?nom) (categoria ?cat) (preu-pp ?pp)
;              (formalitat ?f) (temporades $?temps) (torns $?torns)
;              (espais $?espais) (esdeveniments $?events) (alcohol ?alc)
;              (beguda-mode ?bm) (infantil-friendly ?inf)
;              (serveis $?serveis) (temperatura-dominant ?tempdom)
;              (disponibilitat $?disp) (complexitat-max ?cmax)
;              (dietes-suportades $?dietes) (public-objectiu $?public)
;              (postres-cerimonial ?ceri) (format-picapica ?pic)
;              (etiquetes $?tags) (plats $?plats) (begudes $?begudes)
;              (alergens $?als) (descripcio ?desc))
;   (not (candidat-menu (id-menu ?id)))
;   =>
;   (bind ?preu-text (format nil "%.2f" ?pp))
;   (assert (candidat-menu
;             (id-menu ?id) (nom ?nom) (franja-preu ?cat) (preu-pp ?pp)
;             (formalitat ?f) (temporades $?temps) (torns $?torns)
;             (espais $?espais) (esdeveniments $?events) (alcohol ?alc)
;             (beguda-mode ?bm) (infantil-friendly ?inf)
;             (serveis $?serveis) (temperatura-dominant ?tempdom)
;             (disponibilitat $?disp) (complexitat-max ?cmax)
;             (dietes-suportades $?dietes) (public-objectiu $?public)
;             (postres-cerimonial ?ceri) (format-picapica ?pic)
;             (etiquetes $?tags) (plats $?plats) (begudes $?begudes)
;             (alergens $?als) (descripcio ?desc)
;             (puntuacio 0.0)
;             (motius (create$ (str-cat "Categoria " ?cat " (~" ?preu-text " €/comensal)"))))))

(defrule AssociacioHeuristica::puntua-formalitat
  (perfil-usuari (formalitat ?f) (pes-formalitat ?w))
  ?c <- (candidat-menu (formalitat ?f) (puntuacio ?s) (motius $?m))
  =>
  (bind ?txt (format nil "%.2f" ?w))
  (modify ?c
    (puntuacio (+ ?s ?w))
    (motius (create$ $?m (str-cat "+ " ?txt " formalitat adequada")))))

(defrule AssociacioHeuristica::puntua-temporada
  (perfil-usuari (temporada ?temp) (pes-temporada ?w))
  ?c <- (candidat-menu (temporades $?temps) (puntuacio ?s) (motius $?m))
  (test (member$ ?temp $?temps))
  =>
  (bind ?txt (format nil "%.2f" ?w))
  (modify ?c
    (puntuacio (+ ?s ?w))
    (motius (create$ $?m (str-cat "+ " ?txt " adaptat a la temporada")))))

(defrule AssociacioHeuristica::puntua-torn
  (perfil-usuari (torn ?t) (pes-torn ?w))
  ?c <- (candidat-menu (torns $?torns) (puntuacio ?s) (motius $?m))
  (test (member$ ?t $?torns))
  =>
  (bind ?txt (format nil "%.2f" ?w))
  (modify ?c
    (puntuacio (+ ?s ?w))
    (motius (create$ $?m (str-cat "+ " ?txt " pensat per a " ?t)))))

(defrule AssociacioHeuristica::puntua-espai
  (perfil-usuari (espai ?e) (pes-espai ?w))
  ?c <- (candidat-menu (espais $?espais) (puntuacio ?s) (motius $?m))
  (test (member$ ?e $?espais))
  =>
  (bind ?txt (format nil "%.2f" ?w))
  (modify ?c
    (puntuacio (+ ?s ?w))
    (motius (create$ $?m (str-cat "+ " ?txt " pensat per espais " ?e)))))

(defrule AssociacioHeuristica::puntua-alcohol
  (perfil-usuari (alcohol ?pref) (pes-beguda ?w))
  ?c <- (candidat-menu (alcohol ?pref) (puntuacio ?s) (motius $?m))
  =>
  (bind ?txt (format nil "%.2f" ?w))
  (modify ?c
    (puntuacio (+ ?s ?w))
    (motius (create$ $?m (str-cat "+ " ?txt " preferència de beguda respectada")))))

(defrule AssociacioHeuristica::penalitza-falta-alcohol
  (perfil-usuari (alcohol si) (pes-beguda ?w))
  ?c <- (candidat-menu (alcohol no) (puntuacio ?s) (motius $?m))
  =>
  (bind ?penalty (* 0.5 ?w))
  (bind ?txt (format nil "%.2f" (- 0 ?penalty)))
  (modify ?c
    (puntuacio (- ?s ?penalty))
    (motius (create$ $?m (str-cat ?txt " falta opció alcohòlica")))))

(defrule AssociacioHeuristica::penalitza-sobra-alcohol
  (perfil-usuari (alcohol no) (pes-beguda ?w))
  ?c <- (candidat-menu (alcohol si) (puntuacio ?s) (motius $?m))
  =>
  (bind ?penalty (* 0.5 ?w))
  (bind ?txt (format nil "%.2f" (- 0 ?penalty)))
  (modify ?c
    (puntuacio (- ?s ?penalty))
    (motius (create$ $?m (str-cat ?txt " inclou alcohol")))))

(defrule AssociacioHeuristica::puntua-beguda-mode
  (perfil-usuari (beguda-mode ?bm) (pes-beguda ?w))
  ?c <- (candidat-menu (beguda-mode ?bm) (puntuacio ?s) (motius $?m))
  =>
  (bind ?bonus (* 0.5 ?w))
  (bind ?txt (format nil "%.2f" ?bonus))
  (modify ?c
    (puntuacio (+ ?s ?bonus))
    (motius (create$ $?m (str-cat "+ " ?txt " servei de beguda " ?bm)))))

(defrule AssociacioHeuristica::puntua-infantil
  (perfil-usuari (infantil-senior si))
  ?c <- (candidat-menu (infantil-friendly ?inf) (puntuacio ?s) (motius $?m))
  =>
  (if (eq ?inf si) then
      (bind ?bonus 0.60)
      (modify ?c (puntuacio (+ ?s ?bonus))
                (motius (create$ $?m (str-cat "+ " (format nil "%.2f" ?bonus) " opció adaptable a infants/sèniors"))))
   else
      (bind ?pen -0.60)
      (modify ?c (puntuacio (+ ?s ?pen))
                (motius (create$ $?m (str-cat (format nil "%.2f" ?pen) " sense opció infantil"))))))

(defrule AssociacioHeuristica::puntua-esdeveniment
  (perfil-usuari (tipus-esdeveniment ?evt))
  ?c <- (candidat-menu (esdeveniments $?events) (puntuacio ?s) (motius $?m))
  (test (member$ ?evt $?events))
  =>
  (bind ?bonus 0.7)
  (bind ?txt (format nil "%.2f" ?bonus))
  (modify ?c
    (puntuacio (+ ?s ?bonus))
    (motius (create$ $?m (str-cat "+ " ?txt " pensat per a " ?evt)))))

(defrule AssociacioHeuristica::puntua-pressupost
  (perfil-usuari (pressupost-min ?min) (pressupost-max ?max))
  ?c <- (candidat-menu (preu-pp ?pp) (puntuacio ?s) (motius $?m))
  (test (> ?pp 0.0))
  =>
  (bind ?adjust 0.0)
  (bind ?txt "")
  (if (and (>= ?pp ?min) (<= ?pp ?max)) then
    (bind ?adjust 0.80)
    (bind ?txt (str-cat "+ " (format nil "%.2f" ?adjust) " dins del pressupost"))
   else
    (if (< ?pp ?min) then
      (bind ?gap (- ?min ?pp))
      (bind ?ratio (/ ?gap (max 1 ?min)))
      (bind ?adjust (* -0.40 (min ?ratio 2.0)))
      (bind ?txt (str-cat (format nil "%.2f" ?adjust) " per sota del pressupost mínim"))
     else
      (bind ?gap (- ?pp ?max))
      (bind ?ratio (/ ?gap (max 1 ?max)))
      (bind ?adjust (* -0.40 (min ?ratio 2.0)))
      (bind ?txt (str-cat (format nil "%.2f" ?adjust) " per sobre del pressupost màxim"))))
  (modify ?c
    (puntuacio (+ ?s ?adjust))
    (motius (create$ $?m ?txt))))

(defrule AssociacioHeuristica::puntua-servei
  (perfil-usuari (servei ?serv))
  ?c <- (candidat-menu (serveis $?srv) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (neq ?serv indiferent) then
      (if (servei-compatible ?serv $?srv) then
          (progn
            (bind ?ajust 0.60)
            (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " servei " ?serv)))
       else
          (progn
            (bind ?ajust -0.70)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " servei preferit no disponible")))))
  (if (neq ?ajust 0.0) then
      (modify ?c (puntuacio (+ ?s ?ajust))
                (motius (create$ $?m ?msg)))))

(defrule AssociacioHeuristica::puntua-temperatura-suau
  (perfil-usuari (temporada ?temp) (espai exterior))
  ?c <- (candidat-menu (temperatura-dominant ?td) (puntuacio ?s) (motius $?m))
  (test (or (eq ?temp estiu) (eq ?temp primavera)))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (or (eq ?td fred) (eq ?td mixt)) then
      (progn
        (bind ?ajust 0.50)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " plats frescos per exterior")))
   else
      (progn
        (bind ?ajust -0.50)
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " menú molt calent en espai exterior"))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::puntua-temperatura-calada
  (perfil-usuari (temporada ?temp))
  ?c <- (candidat-menu (temperatura-dominant ?td) (puntuacio ?s) (motius $?m))
  (test (or (eq ?temp tardor) (eq ?temp hivern)))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (eq ?td calent) then
      (progn
        (bind ?ajust 0.50)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " menú reconfortant")))
   else
      (progn
        (bind ?ajust -0.40)
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " menú massa fred per la temporada"))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::bonus-servei-gran-format
  (perfil-usuari (num-comensals ?n) (servei ?serv))
  ?c <- (candidat-menu (serveis $?srv) (puntuacio ?s) (motius $?m))
  (test (> ?n 150))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (or (member$ buffet $?srv) (member$ pica-pica $?srv)) then
      (progn
        (bind ?ajust 0.40)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " servei àgil per grans grups")))
   else
      (if (or (eq ?serv indiferent) (eq ?serv mixt)) then
          (progn
            (bind ?ajust -0.30)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " servei emplatat exigent per grans grups")))))
  (if (neq ?ajust 0.0) then
      (modify ?c (puntuacio (+ ?s ?ajust))
                (motius (create$ $?m ?msg)))))

(defrule AssociacioHeuristica::puntua-public-aniversari
  (perfil-usuari (public-aniversari ?pa&:(neq ?pa indiferent)))
  ?c <- (candidat-menu (public-objectiu $?pub) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (member$ ?pa $?pub) then
      (progn
        (bind ?ajust 0.50)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " pensat per a " ?pa)))
   else
      (progn
        (bind ?ajust -0.45)
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " no pensat per a " ?pa))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::bonus-cerimonial-casament
  (perfil-usuari (tipus-esdeveniment casament) (requereix-pastis ?req))
  ?c <- (candidat-menu (postres-cerimonial ?pc) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (eq ?pc si) then
      (progn
        (bind ?ajust (if (eq ?req si) then 0.60 else 0.20))
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " inclou postres cerimonial")))
   else
      (if (eq ?req si) then
          (progn
            (bind ?ajust -0.60)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " manca pastís nupcial")))
       else
          (progn
            (bind ?ajust -0.20)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " no hi ha postres cerimonial")))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::penalitza-cerimonial-empresa
  (perfil-usuari (tipus-esdeveniment empresa))
  ?c <- (candidat-menu (postres-cerimonial si) (puntuacio ?s) (motius $?m))
  =>
  (bind ?pen -0.35)
  (modify ?c (puntuacio (+ ?s ?pen))
            (motius (create$ $?m (str-cat (format nil "%.2f" ?pen) " evitant postres cerimonials en entorn corporatiu")))))

(defrule AssociacioHeuristica::formalitat-casament
  (perfil-usuari (tipus-esdeveniment casament))
  ?c <- (candidat-menu (formalitat ?f) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (eq ?f formal) then
      (progn
        (bind ?ajust 0.50)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " protocol nupcial")))
   else
      (progn
        (bind ?ajust -0.40)
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " massa informal per casament"))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::formalitat-aniversari-nens
  (perfil-usuari (tipus-esdeveniment aniversari) (public-aniversari nens))
  ?c <- (candidat-menu (formalitat ?f) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (eq ?f informal) then
      (progn
        (bind ?ajust 0.40)
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " to adequat per nens")))
   else
      (progn
        (bind ?ajust -0.30)
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " massa formal per aniversari infantil"))))
  (modify ?c (puntuacio (+ ?s ?ajust))
            (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::puntua-picapica
  (perfil-usuari (necessita-pica-pica ?picpref&:(neq ?picpref indiferent)))
  ?c <- (candidat-menu (format-picapica ?pic) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (eq ?picpref si) then
      (if (eq ?pic si) then
          (progn
            (bind ?ajust 0.60)
            (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " disposa de pica-pica ràpid")))
       else
          (progn
            (bind ?ajust -0.80)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " manca format pica-pica"))))
   else
      (if (eq ?pic si) then
          (progn
            (bind ?ajust -0.30)
            (bind ?msg (str-cat (format nil "%.2f" ?ajust) " evitem format pica-pica")))))
  (if (neq ?ajust 0.0) then
      (modify ?c (puntuacio (+ ?s ?ajust))
                (motius (create$ $?m ?msg)))))

(defrule AssociacioHeuristica::puntua-dieta-vegana
  (perfil-usuari (num-vegans ?nv&:(> ?nv 0)) (estrategia-dietes ?estrat) (num-comensals ?total))
  ?c <- (candidat-menu (dietes-suportades $?dietes) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ratio (min 1.0 (/ (float ?nv) (max 1 ?total))))
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (suporta-dieta vegana $?dietes) then
      (progn
        (bind ?ajust (* 1.2 ?ratio))
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " opció vegana disponible")))
   else
      (progn
        (bind ?ajust (if (eq ?estrat adaptar) then (* -0.6 ?ratio) else (* -1.2 ?ratio)))
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " falta opció vegana"))))
  (modify ?c (puntuacio (+ ?s ?ajust)) (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::puntua-dieta-vegetariana
  (perfil-usuari (num-vegetarians ?nv&:(> ?nv 0)) (estrategia-dietes ?estrat) (num-comensals ?total))
  ?c <- (candidat-menu (dietes-suportades $?dietes) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ratio (min 1.0 (/ (float ?nv) (max 1 ?total))))
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (suporta-dieta vegetariana $?dietes) then
      (progn
        (bind ?ajust (* 0.9 ?ratio))
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " opció vegetariana")))
   else
      (progn
        (bind ?ajust (if (eq ?estrat adaptar) then (* -0.4 ?ratio) else (* -0.9 ?ratio)))
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " sense opció vegetariana"))))
  (modify ?c (puntuacio (+ ?s ?ajust)) (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::puntua-dieta-celiacs
  (perfil-usuari (num-celiacs ?nv&:(> ?nv 0)) (estrategia-dietes ?estrat) (num-comensals ?total))
  ?c <- (candidat-menu (dietes-suportades $?dietes) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ratio (min 1.0 (/ (float ?nv) (max 1 ?total))))
  (bind ?ajust 0.0)
  (bind ?msg "" )
  (if (suporta-dieta sense-gluten $?dietes) then
      (progn
        (bind ?ajust (* 1.0 ?ratio))
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " opció sense gluten")))
   else
      (progn
        (bind ?ajust (if (eq ?estrat adaptar) then (* -0.5 ?ratio) else (* -1.0 ?ratio)))
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " sense opció per celíacs"))))
  (modify ?c (puntuacio (+ ?s ?ajust)) (motius (create$ $?m ?msg))))

(defrule AssociacioHeuristica::puntua-dieta-halal
  (perfil-usuari (num-halal ?nv&:(> ?nv 0)) (estrategia-dietes ?estrat) (num-comensals ?total))
  ?c <- (candidat-menu (dietes-suportades $?dietes) (puntuacio ?s) (motius $?m))
  =>
  (bind ?ratio (min 1.0 (/ (float ?nv) (max 1 ?total))))
  (bind ?ajust 0.0)
  (bind ?msg "")
  (if (suporta-dieta halal $?dietes) then
      (progn
        (bind ?ajust (* 0.8 ?ratio))
        (bind ?msg (str-cat "+ " (format nil "%.2f" ?ajust) " opció halal")))
   else
      (progn
        (bind ?ajust (if (eq ?estrat adaptar) then (* -0.3 ?ratio) else (* -0.8 ?ratio)))
        (bind ?msg (str-cat (format nil "%.2f" ?ajust) " sense opció halal"))))
  (modify ?c (puntuacio (+ ?s ?ajust)) (motius (create$ $?m ?msg))))


















(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))
; (defrule RefinamentHeuristica::filtra-disponibilitat
;   (perfil-usuari (temporada ?temp))
;   ?c <- (candidat-menu (id-menu ?id) (disponibilitat $?disp))
;   (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
;   (test (not (disponibilitat-compatible ?temp $?disp)))
;   =>
;   (retract ?c))

(defrule RefinamentHeuristica::filtra-pressupost
  (perfil-usuari (pressupost-min ?min) (pressupost-max ?max))
  ?c <- (candidat-menu (id-menu ?id) (preu-pp ?pp))
  (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
  (test (or (< ?pp ?min) (> ?pp ?max)))
  =>
  (retract ?c))

(defrule RefinamentHeuristica::filtra-complexitat
  (perfil-usuari (num-comensals ?n))
  ?c <- (candidat-menu (id-menu ?id) (complexitat-max ?cmax))
  (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
  =>
  (bind ?allowed (if (<= ?n 60) then 3
                 else (if (<= ?n 150) then 2 else 1)))
  (bind ?menu-nivell (nivell-complexitat ?cmax))
  (if (> ?menu-nivell ?allowed) then (retract ?c)))

(defrule RefinamentHeuristica::filtra-alergens
  (perfil-usuari (alergens-prohibits $?ban&:(> (length$ $?ban) 0)))
  ?c <- (candidat-menu (id-menu ?id) (alergens $?pre ?a $?post))
  (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
  (test (member$ ?a $?ban))
  =>
  (retract ?c))

(defrule RefinamentHeuristica::filtra-pastis-casament
  (perfil-usuari (tipus-esdeveniment casament) (requereix-pastis si))
  ?c <- (candidat-menu (id-menu ?id) (postres-cerimonial ?pc))
  (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
  (test (neq ?pc si))
  =>
  (retract ?c))

(defrule RefinamentHeuristica::filtra-format-picapica
  (perfil-usuari (necessita-pica-pica si))
  ?c <- (candidat-menu (id-menu ?id) (format-picapica ?pic))
  (test (not (member$ ?id (create$ fallback-barat fallback-mitja fallback-car))))
  (test (neq ?pic si))
  =>
  (retract ?c))

(defrule RefinamentHeuristica::fallback-barat
  (declare (salience -5))
  (perfil-usuari)
  (not (candidat-menu (franja-preu barat)))
  =>
  (assert (candidat-menu
            (id-menu fallback-barat)
            (nom "Cap menú barat compatible")
            (franja-preu barat)
            (preu-pp 0.0)
            (formalitat cap)
            (temporades)
            (torns)
            (espais)
            (esdeveniments)
            (alcohol cap)
            (beguda-mode cap)
            (infantil-friendly no)
            (serveis)
            (temperatura-dominant indiferent)
            (disponibilitat)
            (complexitat-max baixa)
            (dietes-suportades)
            (public-objectiu)
            (postres-cerimonial cap)
            (format-picapica cap)
            (etiquetes)
            (plats)
            (begudes)
            (alergens)
            (descripcio "No hi ha propostes barates sense conflictes. Considera relaxar algun criteri.")
            (puntuacio -1.0)
            (motius (create$ "Sense opcions compatibles en aquesta franja.")))))

(defrule RefinamentHeuristica::fallback-mitja
  (declare (salience -5))
  (perfil-usuari)
  (not (candidat-menu (franja-preu mitja)))
  =>
  (assert (candidat-menu
            (id-menu fallback-mitja)
            (nom "Cap menú mig compatible")
            (franja-preu mitja)
            (preu-pp 0.0)
            (formalitat cap)
            (temporades)
            (torns)
            (espais)
            (esdeveniments)
            (alcohol cap)
            (beguda-mode cap)
            (infantil-friendly no)
            (serveis)
            (temperatura-dominant indiferent)
            (disponibilitat)
            (complexitat-max baixa)
            (dietes-suportades)
            (public-objectiu)
            (postres-cerimonial cap)
            (format-picapica cap)
            (etiquetes)
            (plats)
            (begudes)
            (alergens)
            (descripcio "No hi ha propostes mitjanes sense conflictes. Revisa requisits o pressupost.")
            (puntuacio -1.0)
            (motius (create$ "Sense opcions compatibles en aquesta franja.")))))

(defrule RefinamentHeuristica::fallback-car
  (declare (salience -5))
  (perfil-usuari)
  (not (candidat-menu (franja-preu car)))
  =>
  (assert (candidat-menu
            (id-menu fallback-car)
            (nom "Cap menú car compatible")
            (franja-preu car)
            (preu-pp 0.0)
            (formalitat cap)
            (temporades)
            (torns)
            (espais)
            (esdeveniments)
            (alcohol cap)
            (beguda-mode cap)
            (infantil-friendly no)
            (serveis)
            (temperatura-dominant indiferent)
            (disponibilitat)
            (complexitat-max baixa)
            (dietes-suportades)
            (public-objectiu)
            (postres-cerimonial cap)
            (format-picapica cap)
            (etiquetes)
            (plats)
            (begudes)
            (alergens)
            (descripcio "No hem trobat opcions premium sense conflictes. Intenta flexibilitzar les preferències.")
            (puntuacio -1.0)
            (motius (create$ "Sense opcions compatibles en aquesta franja.")))))




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
