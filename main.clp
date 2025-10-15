; =========================
; PETICIO (interactiu)
; =========================
(deftemplate peticio
  (slot formalitat (type STRING))
  (slot pressupost_per_cap (type NUMBER))   ; accepta 60 o 60.0
  (slot num_comensals (type INTEGER))
  (slot beguda_general (type SYMBOL) (default si)) ; si/no
  (multislot restriccions-alergen (type SYMBOL))
)

; =========================
; INPUT HELPERS + PREGUNTES
; =========================
(deffunction ask-default (?prompt ?default)
  (printout t ?prompt " [" ?default "]: ")
  (bind ?in (readline))
  (if (eq ?in "") then (return ?default) else (return ?in))
)

(deffunction ask-number-default (?prompt ?default)
  (printout t ?prompt " [" ?default "]: ")
  (bind ?in (readline))
  (if (eq ?in "") then (return ?default)
   else
     (bind ?x (string-to-field ?in))
     (if (numberp ?x) then (return ?x) else (return ?default)))
)

(deffunction ask-yn-default (?prompt ?defaultSym)
  (printout t ?prompt " [" ?defaultSym "]: ")
  (bind ?in (lowcase (readline)))
  (if (or (eq ?in "") (eq ?in "s") (eq ?in "si") (eq ?in "sí")) then (return si))
  (if (or (eq ?in "n") (eq ?in "no")) then (return no))
  (return ?defaultSym)
)

(defrule ask-peticio
  (not (peticio))
  =>
  (bind ?f  (ask-default        "Formalitat (informal/familiar/tradicional/formal)" "familiar"))
  (bind ?pp (ask-number-default "Pressupost per cap (€)" 35.0))
  (bind ?nc (ask-number-default "Nombre de comensals" 20))
  (bind ?bg (ask-yn-default     "Beguda general per a tot el menú? (s/n)" si))
  (printout t "Alergens a evitar (separa amb espais, ENTER si cap): ")
  (bind ?aline (readline))
  (bind $?als (if (eq ?aline "") then (create$) else (explode$ (lowcase ?aline))))
  (assert (peticio
            (formalitat (str-cat ?f))
            (pressupost_per_cap ?pp)
            (num_comensals (if (integerp ?nc) then ?nc else (round ?nc)))
            (beguda_general ?bg)
            (restriccions-alergen $?als)))
  (printout t crlf)
)

; =========================
; ABSTRACCIO
; =========================
(deftemplate tag-formalitat (slot val))
(deftemplate llindars (slot preu_min) (slot preu_max))

(deffunction norm-str->sym (?s)
  (if (stringp ?s) then (return (string-to-field (lowcase ?s))) else (return ?s))
)

(defrule deriva-formalitat
  (peticio (formalitat ?f))
  =>
  (assert (tag-formalitat (val (norm-str->sym ?f))))
)

(defrule deriva-llindars
  (peticio (pressupost_per_cap ?pp))
  =>
  ; MVP: reparteix tot el per-cap entre 3 plats
  (bind ?pplat (/ ?pp 3.0))
  (assert (llindars (preu_min 0.0) (preu_max ?pplat)))
)

; =========================
; ASSOCIACIO
; =========================
(deftemplate candidat-plat
  (slot plat)              ; instance-name Plat
  (slot ordre)             ; instance-name Ordre
  (slot preu (type NUMBER))
  (slot formalitat (type SYMBOL))
  (slot temperatura (type SYMBOL))
  (multislot alergens (type SYMBOL))
  (slot score (type NUMBER))
)

(defrule genera-candidat-basic
  (object (is-a Plat)
          (name ?plat)
          (preu_venta ?pv)
          (formalitat ?fstr)
          (temperatura ?tstr)
          (alergens $?als)
          (te_ordre $?ords))
  (llindars (preu_min ?mn) (preu_max ?mx))
  (test (and (numberp ?pv) (>= ?pv ?mn) (<= ?pv ?mx)))
  =>
  (bind ?f (norm-str->sym ?fstr))
  (bind ?t (norm-str->sym ?tstr))
  (progn$ (?o $?ords)
    (assert (candidat-plat
              (plat ?plat)
              (ordre ?o)
              (preu ?pv)
              (formalitat ?f)
              (temperatura ?t)
              (alergens $?als)
              (score 0))))
)

(defrule bonus-formalitat
  ?c <- (candidat-plat (formalitat ?fp) (score ?s))
  (tag-formalitat (val ?fe))
  (test (or (eq ?fp ?fe) (eq ?fp tradicional)))
  =>
  (modify ?c (score (+ (if (numberp ?s) then ?s else 0) 10)))
)

(defrule penalitza-alergen
  ?c <- (candidat-plat (alergens $?als) (score ?s))
  (peticio (restriccions-alergen $?rs))
  (test (intersection$ $?als $?rs))
  =>
  (modify ?c (score (- (if (numberp ?s) then ?s else 0) 100)))
)

(defrule bonus-temperatura
  ?c <- (candidat-plat (temperatura ?t) (score ?s))
  (test (or (eq ?t fred) (eq ?t tebi) (eq ?t calent)))
  =>
  (modify ?c (score (+ (if (numberp ?s) then ?s else 0) 2)))
)

; =========================
; REFINAMENT
; =========================
(deftemplate seleccio
  (slot primer)
  (slot principal)
  (slot postre)
  (slot beguda)
  (slot preu_total (type NUMBER))
)

; Tria el millor primer/principal/postre
(deffunction finalize-menu ()
  (bind ?bestPr nil) (bind ?sPr -1.0e9)
  (bind ?bestPg nil) (bind ?sPg -1.0e9)
  (bind ?bestPo nil) (bind ?sPo -1.0e9)
  (do-for-all-facts ((?c candidat-plat)) TRUE
    (bind ?oname (instance-name ?c:ordre))
    (if (eq ?oname [primer]) then
      (if (> ?c:score ?sPr) then (bind ?sPr ?c:score) (bind ?bestPr ?c)))
    (if (eq ?oname [principal]) then
      (if (> ?c:score ?sPg) then (bind ?sPg ?c:score) (bind ?bestPg ?c)))
    (if (eq ?oname [postre]) then
      (if (> ?c:score ?sPo) then (bind ?sPo ?c:score) (bind ?bestPo ?c))))
  (if (and ?bestPr ?bestPg ?bestPo) then
    (bind ?p1 (fact-slot-value ?bestPr plat))
    (bind ?p2 (fact-slot-value ?bestPg plat))
    (bind ?p3 (fact-slot-value ?bestPo plat))
    (bind ?preuTot (+ (fact-slot-value ?bestPr preu)
                      (fact-slot-value ?bestPg preu)
                      (fact-slot-value ?bestPo preu)))
    (assert (seleccio (primer ?p1) (principal ?p2) (postre ?p3) (preu_total ?preuTot)))
   else
    (printout t "No hi ha candidats suficients per a primer/principal/postre (revisa llindars o dades)." crlf))
)

(defrule try-build-menu
  (declare (salience -10))
  (exists (candidat-plat))
  =>
  (finalize-menu)
)

; Beguda del plat principal si hi ha maridatge
(defrule assigna-beguda
  ?s <- (seleccio (principal ?p2) (beguda ?b&nil))
  (object (is-a Plat) (name ?p2) (marida_amb $?bgs))
  (test (> (length$ $?bgs) 0))
  =>
  (modify ?s (beguda (nth$ 1 $?bgs)))
)

(defrule mostrar
  (seleccio (primer ?p1) (principal ?p2) (postre ?p3) (beguda ?b) (preu_total ?pt))
  =>
  (printout t crlf "*** MENU PROPOSAT ***" crlf)
  (printout t "Primer:    " ?p1 crlf)
  (printout t "Principal: " ?p2 crlf)
  (printout t "Postres:   " ?p3 crlf)
  (if ?b then (printout t "Beguda:    " ?b crlf))
  (printout t "Preu 3 plats (sense beguda): " ?pt crlf crlf))
