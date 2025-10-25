; ============================================================
; RicoRico – MAIN (únic fitxer) amb mòduls
; Mòduls: PreferenciesMenu -> AbstraccioHeuristica
;         -> AssociacioHeuristica -> RefinamentHeuristica
;         -> ComposicioMenus
; ============================================================
(defmodule MAIN (export ?ALL))

; ------------------------------------------------------------
; TEMPLATES I HELPERS
; ------------------------------------------------------------
(deftemplate peticio
  (slot tipus-esdeveniment (type SYMBOL) (default nil)) ; boda/baptisme/comunio/congres
  (slot epoca            (type SYMBOL) (default nil))   ; primavera/estiu/tardor/hivern
  (slot interior         (type SYMBOL) (default nil))   ; si/no
  (slot num-comensals    (type SYMBOL INTEGER) (default nil))
  (slot pressupost-min   (type SYMBOL FLOAT) (default nil))
  (slot pressupost-max   (type SYMBOL FLOAT) (default nil))
  (slot formalitat       (type SYMBOL STRING) (default nil)) ; formal/informal/indiferent
  (slot beguda-mode      (type SYMBOL) (default nil))        ; general/per_plat
  (slot alcohol          (type SYMBOL STRING) (default nil)) ; si/no/indiferent
  (slot grups?           (type SYMBOL) (default no))         ; si/no
)

(deftemplate grup-restriccio
  (slot id (type INTEGER))
  (slot nom (type STRING) (default ""))
  (slot quantitat (type INTEGER) (default 0))
  (slot dieta (type SYMBOL) (allowed-symbols cap VG V HALAL KOSHER) (default cap))
  (multislot alergens (type SYMBOL)
    (allowed-symbols gluten llet ous peix crustacis molluscs fruits_secs
                      cacauet soja api mostassa sesam sulfites tramussos))
  (slot estat (type SYMBOL) (allowed-symbols pendent validat) (default pendent))
)

(deftemplate num-grups (slot total (type INTEGER)))
(deftemplate grup-pendent (slot id (type INTEGER)))
(deftemplate respostes-completes)

; Validacions intermitges per PLAT/Beguda
(deftemplate plat-candidat (slot nom) (slot ordre) (slot preu (type FLOAT)))
(deftemplate plat-ok-base (slot nom))
(deftemplate plat-ok-grup (slot nom) (slot gid (type INTEGER)))
(deftemplate beguda-ok-base (slot nom))
(deftemplate beguda-ok-grup (slot nom) (slot gid (type INTEGER)))

; Disponibilitat derivada per PLAT a partir d’ingredients
(deftemplate plat-estacio-ok (slot nom) (slot epoca))  ; el plat és servible a aquesta època

; ---- NOVES ESTRUCTURES DE PUNTUACIÓ ----
(deftemplate plat-score
  (slot nom)                      ; nom del plat
  (slot ordre)                    ; primer/segon/postres
  (slot preu (type FLOAT))
  (slot score (type INTEGER))
)

(deftemplate menu-candidat
  (slot pr) (slot sg) (slot po)   ; plats escollits
  (slot bmode)                    ; general / per_plat
  (slot bgen (default ""))        ; beguda general, si escau
  (slot bpr  (default ""))        ; beguda per primer
  (slot bsg  (default ""))        ; beguda per segon
  (slot bpo  (default ""))        ; beguda per postres
  (slot preu (type FLOAT))
  (slot score (type INTEGER))
)

; ---- “Pesos” i paràmetres suaus (ajustables fàcilment) ----
(defglobal
  ?*TOPK* = 5     ; quants candidats top per ordre considerem
)

; ---- HELPERS DE SCORING ----

(deffunction score-temp (?ep ?in ?t)
  (if (eq ?ep indiferent) then (return 0))
  (bind ?s 0)
  (if (or (and (member$ ?ep (create$ primavera estiu)) (member$ ?t (create$ fred tebi)))
          (and (member$ ?ep (create$ tardor hivern))   (member$ ?t (create$ tebi calent))))
      then (bind ?s 2))
  ; interior permet “calent” com a acceptable addicional
  (if (and (eq ?in si) (eq ?t calent) (< ?s 2)) then (bind ?s 1))
  ?s
)

(deffunction score-complexitat (?cx ?n)
  (if (not (numberp ?n)) then (bind ?n 50))
  (if (<= ?n 50) then
      (return (if (or (eq ?cx alta) (eq ?cx mitjana)) then 2 else 1)))
  (if (and (> ?n 50) (<= ?n 150)) then
      (return (if (eq ?cx mitjana) then 2 else (if (eq ?cx baixa) then 1 else 0))))
  ; >150 comensals
  (return (if (eq ?cx alta) then -1 else 2))
)

(deffunction score-mida (?ordre ?m)
  (if (eq ?ordre primer)   then (return (if (member$ ?m (create$ petita mitjana)) then 1 else 0)))
  (if (eq ?ordre segon)    then (return (if (member$ ?m (create$ gran   mitjana)) then 1 else 0)))
  (if (eq ?ordre postres)  then (return (if (member$ ?m (create$ petita mitjana)) then 1 else 0)))
  0
)

(deffunction get-peticio ()
  (nth$ 1 (find-all-facts ((?r peticio)) TRUE))
)

(deffunction calc-plat-score (?np ?ordre)
  (bind ?P (nth$ 1 (find-all-instances ((?p Plat)) (eq (send ?p get-nom) ?np))))
  (if (not ?P) then (return 0))
  (bind ?pet (get-peticio))
  (bind ?ep (if ?pet then (fact-slot-value ?pet epoca) else indiferent))
  (bind ?in (if ?pet then (fact-slot-value ?pet interior) else indiferent))
  (bind ?n  (if ?pet then (fact-slot-value ?pet num-comensals) else 50))
  (bind ?t  (send ?P get-temperatura))
  (bind ?cx (send ?P get-complexitat))
  (bind ?mr (send ?P get-mida_racio))
  (+ (score-temp ?ep ?in ?t)
     (score-complexitat ?cx ?n)
     (score-mida ?ordre ?mr))
)

; helpers de selecció
(deffunction remove-fact (?f $?facts)
  (bind $?out (create$))
  (foreach ?x $?facts (if (neq ?x ?f) then (bind $?out (create$ $?out ?x))))
  $?out
)

(deffunction pick-best-score-fact (?facts)
  (if (<= (length$ ?facts) 0) then (return FALSE))
  (bind ?best (nth$ 1 ?facts))
  (foreach ?f ?facts
    (bind ?sb (fact-slot-value ?best score))
    (bind ?sp (fact-slot-value ?f score))
    (if (or (> ?sp ?sb)
            (and (= ?sp ?sb)
                 (< (fact-slot-value ?f preu) (fact-slot-value ?best preu))))
        then (bind ?best ?f)))
  ?best
)


; ----- helpers de cadenes / parsing -----
(deffunction trim (?s)
  (if (not (stringp ?s)) then (return ""))
  (bind ?len (str-length ?s))
  (if (<= ?len 0) then (return ""))
  (bind ?i 1) (bind ?j ?len)
  (while (and (<= ?i ?j)
              (or (eq (sub-string ?i ?i ?s) " ") (eq (sub-string ?i ?i ?s) "\t")))
    (bind ?i (+ ?i 1)))
  (while (and (>= ?j ?i)
              (or (eq (sub-string ?j ?j ?s) " ") (eq (sub-string ?j ?j ?s) "\t")))
    (bind ?j (- ?j 1)))
  (if (< ?i 1) then (bind ?i 1))
  (if (< ?j ?i) then (return ""))
  (sub-string ?i ?j ?s)
)

(deffunction lower (?x) (lowcase (if (symbolp ?x) then (str-cat ?x) else (if (stringp ?x) then ?x else (str-cat ?x)))))

; map noms -> símbols UE14
(deffunction str->ue14 (?s)
  (bind ?x (lower (trim ?s)))
  (if (eq ?x "gluten") then (return gluten))
  (if (or (eq ?x "llet") (eq ?x "lactosa")) then (return llet))
  (if (or (eq ?x "ou") (eq ?x "ous")) then (return ous))
  (if (eq ?x "peix") then (return peix))
  (if (or (eq ?x "crustaci") (eq ?x "crustacis")) then (return crustacis))
  (if (or (eq ?x "mol·lusc") (eq ?x "mollusc") (eq ?x "molluscs")) then (return molluscs))
  (if (or (eq ?x "fruits secs") (eq ?x "ametlla") (eq ?x "avellana") (eq ?x "nou") (eq ?x "festuc")) then (return fruits_secs))
  (if (or (eq ?x "cacauet") (eq ?x "cacauets")) then (return cacauet))
  (if (eq ?x "soja") then (return soja))
  (if (eq ?x "api") then (return api))
  (if (eq ?x "mostassa") then (return mostassa))
  (if (or (eq ?x "sesam") (eq ?x "sèsam")) then (return sesam))
  (if (or (eq ?x "sulfit") (eq ?x "sulfits")) then (return sulfites))
  (if (or (eq ?x "tramussos") (eq ?x "tramús") (eq ?x "lupin")) then (return tramussos))
  (return nil)
)


(deffunction parse-alergens-line (?line)
  (bind ?clean (lowcase (trim (str-replace (str-replace ?line "," " ") ";" " "))))
  (if (eq ?clean "") then (return (create$)))
  (bind $?tokens (explode$ ?clean))
  (bind $?out (create$))
  (foreach ?t ?tokens
    (bind ?sym (if (integerp ?t) then
                    (nth$ (integer ?t) (create$ gluten llet ous peix crustacis molluscs fruits_secs cacauet soja api mostassa sesam sulfites tramussos))
                  else
                    (str->ue14 ?t)))
    (if (and ?sym (not (member$ ?sym $?out))) then
      (bind $?out (create$ $?out ?sym))))
  $?out
)

(deffunction ingredient-by-name (?nom-str)
  (bind ?needle (lowcase (trim ?nom-str)))
  (bind ?cand (find-all-instances ((?i Ingredient))
               (or (eq (send ?i get-nom) ?nom-str)
                   (eq (lowcase (trim (send ?i get-nom))) ?needle))))
  (if (> (length$ ?cand) 0) then (return (nth$ 1 ?cand)) else (return FALSE))
)

(deffunction dieta-ing-compatible (?diet $?dietes-ing)
  (if (or (eq ?diet cap) (eq ?diet indiferent)) then (return TRUE))
  (if (eq ?diet VG) then (return (member$ VG (create$ $?dietes-ing))))
  (if (eq ?diet V) then (return (or (member$ V (create$ $?dietes-ing)) (member$ VG (create$ $?dietes-ing)))))
  (if (eq ?diet HALAL) then (return (member$ HALAL (create$ $?dietes-ing))))
  (if (eq ?diet KOSHER) then (return (member$ KOSHER (create$ $?dietes-ing))))
  FALSE
)

; ------------------------------------------------------------
; MÒDUL DE CONTROL (ordena focus)
; ------------------------------------------------------------

(defmodule ControlFlux
  (import MAIN ?ALL)
)

(defrule ControlFlux::arrencada
  (declare (auto-focus TRUE))
  (initial-fact)
  =>
  ; 1) Preguntes a l’usuari
  (focus PreferenciesMenu)
  ; 2) Filtres durs (formalitat + estacionalitat des del PLAT)
  (focus AbstraccioHeuristica)
  ; 3) Al·lèrgens/dietes per grup
  (focus AssociacioHeuristica)
  ; 4) Indexa candidats
  (focus RefinamentHeuristica)
  ; 5) Puntuació
  (focus Puntuacio)
  ; 6) Composició final de menús
  (focus ComposicioMenus)
)


; ------------------------------------------------------------
; MÒDUL: PREFERENCIES (interactiu)
; ------------------------------------------------------------
(defmodule PreferenciesMenu (import MAIN ?ALL) (export ?ALL))

(deffunction ask-opcio (?prompt $?opc)
  (bind ?ok FALSE)
  (bind ?res nil)
  (while (not ?ok)
    (printout t ?prompt " → " crlf)
    (bind ?in (string-to-field (lowcase (readline))))
    (if (member$ ?in (create$ $?opc)) then
      (bind ?ok TRUE) (bind ?res ?in)
     else
      (printout t "Opcions vàlides: " (create$ $?opc) crlf)))
  ?res
)

(deffunction ask-num-o-indif (?prompt ?min ?max)
  (bind ?ok FALSE)
  (bind ?res nil)
  (while (not ?ok)
    (printout t ?prompt " (" ?min "-" ?max " o 'indiferent'): " crlf)
    (bind ?ln (lowcase (readline)))
    (if (eq ?ln "indiferent") then (bind ?ok TRUE) (bind ?res indiferent)
    else
      (bind ?fld (string-to-field ?ln))
      (if (numberp ?fld)
          then (if (and (>= ?fld ?min) (<= ?fld ?max)) then (bind ?ok TRUE) (bind ?res ?fld)
                else (printout t "Fora de rang." crlf))
          else (printout t "Introdueix número o 'indiferent'." crlf))))
  ?res
)

(deffunction ask-yesno-indif (?prompt)
  (bind ?ok FALSE)
  (bind ?res nil)
  (while (not ?ok)
    (printout t ?prompt " (si/no/indiferent): " crlf)
    (bind ?x (lowcase (readline)))
    (if (or (eq ?x "si") (eq ?x "sí") (eq ?x "s") (eq ?x "y")) then (bind ?ok TRUE) (bind ?res si)
    else (if (or (eq ?x "no") (eq ?x "n")) then (bind ?ok TRUE) (bind ?res no)
    else (if (eq ?x "indiferent") then (bind ?ok TRUE) (bind ?res indiferent)
    else (printout t "Respon si/no/indiferent." crlf)))))
  ?res
)

(defrule PreferenciesMenu::inici
  (declare (auto-focus TRUE))
  (not (peticio))
  =>
  (printout t crlf "*** Benvingut/da al recomanador de menús RicoRico ***" crlf)
  (bind ?ev (ask-opcio "Tipus d’esdeveniment? (boda/baptisme/comunio/congres)" boda baptisme comunio congres))
  (bind ?ep (ask-opcio "Època de l’any? (primavera/estiu/tardor/hivern/indiferent)" primavera estiu tardor hivern indiferent))
  (bind ?in (ask-yesno-indif "L’event és a l’interior o exterior? (si=interior / no=exterior)"))
  (bind ?n  (ask-num-o-indif "Nombre aproximat de comensals?" 1 5000))
  (bind ?pmin (ask-num-o-indif "Pressupost mínim €/pp?" 5 1000))
  (bind ?pmax (ask-num-o-indif "Pressupost màxim €/pp?" 10 2000))
  (bind ?form (ask-opcio "Grau de formalitat? (formal/informal/indiferent)" formal informal indiferent))
  (bind ?bmode (ask-opcio "Beguda general o per plat? (general/per_plat/indiferent)" general per_plat indiferent))
  (bind ?alc (ask-yesno-indif "Incloure begudes alcohòliques?"))
  (bind ?g (ask-opcio "Vols definir GRUPS amb dietes/al·lèrgens específics? (si/no)" si no))

  (assert (peticio
    (tipus-esdeveniment ?ev)
    (epoca ?ep)
    (interior ?in)
    (num-comensals ?n)
    (pressupost-min ?pmin)
    (pressupost-max ?pmax)
    (formalitat ?form)
    (beguda-mode ?bmode)
    (alcohol ?alc)
    (grups? ?g)
  ))

  (if (eq ?g si) then
    (bind ?ng (ask-num-o-indif "Quants grups diferents vols definir? (1-10)" 1 10))
    (bind ?ng (if (eq ?ng indiferent) then 1 else ?ng))
    (assert (num-grups (total ?ng)))
    (assert (grup-pendent (id 1)))
   else
    (assert (respostes-completes)))
)

(defrule PreferenciesMenu::omplir-grup
  ?pend <- (grup-pendent (id ?gid))
  (num-grups (total ?tot))
  =>
  (printout t crlf "== Grup " ?gid " ==" crlf)
  (printout t "Nom (opcional): " crlf)
  (bind ?nom (readline))
  (bind ?q   (ask-num-o-indif "Quants comensals té el grup?" 1 5000))
  (bind ?q   (if (eq ?q indiferent) then 0 else ?q))
  (printout t "Dieta (cap/V/VG/HALAL/KOSHER): " crlf)
  (bind ?diet (ask-opcio "Tria dieta" cap V VG HALAL KOSHER))
  (printout t crlf "Introdueix al·lèrgens UE-14 (número o nom), separats per espais/comes. Buit = cap." crlf)
  (bind ?aline (readline))
  (bind $?ALS (parse-alergens-line ?aline))

  (assert (grup-restriccio (id ?gid) (nom ?nom) (quantitat ?q) (dieta ?diet) (alergens $?ALS) (estat pendent)))

  (retract ?pend)
  (if (< ?gid ?tot) then
      (assert (grup-pendent (id (+ ?gid 1))))
   else
      (assert (respostes-completes)))
)

; ------------------------------------------------------------
; MÒDUL: ABSTRACCIÓ HEURÍSTICA (estacionalitat + formalitat durs)
; ------------------------------------------------------------
(defmodule AbstraccioHeuristica
  (import MAIN ?ALL)
  (import PreferenciesMenu ?ALL)
  (export ?ALL))

(defrule AbstraccioHeuristica::derivar-dispo-plat-per-epoca
  (declare (salience 50))
  (peticio (epoca ?ep))
  ?pl <- (object (is-a Plat))
  =>
  (bind ?np (send ?pl get-nom))
  (bind $?ov (create$ (send ?pl get-disponibilitat_plats))) ; només del PLAT

  ; Epoca “indiferent” del client → tot serveix
  (if (eq ?ep indiferent) then
    (assert (plat-estacio-ok (nom ?np) (epoca ?ep)))
    (return))

  ; Si no han definit estacionalitat al plat, o hi ha 'tot_any', o hi ha l'època demanada → OK
  (if (or (= (length$ $?ov) 0)
          (member$ tot_any $?ov)
          (member$ ?ep $?ov))
      then
        (assert (plat-estacio-ok (nom ?np) (epoca ?ep)))
      else
        (printout t
          "[SEASON-FAIL] \"" ?np "\" no disponible a " ?ep
          " (disponibilitat_plats=" $?ov ")" crlf))
)

; 2) Formalitat (DUR) — itera totes les instàncies de Plat
(defrule AbstraccioHeuristica::plat-formalitat
  (peticio (formalitat ?f))
  =>
  (do-for-all-instances ((?pl Plat)) TRUE
    (bind ?np (send ?pl get-nom))
    (bind ?pf (send ?pl get-formalitat))
    (if (or (eq ?f indiferent) (eq ?f ?pf))
        then
          (if (<= (length$ (find-all-facts ((?x plat-ok-base))
                            (eq (fact-slot-value ?x nom) ?np))) 0)
              then (assert (plat-ok-base (nom ?np)))))))

; 3) Begudes base (DUR: formalitat+alcohol) — itera totes les Begudes
(defrule AbstraccioHeuristica::beguda-base
  (peticio (alcohol ?alc) (formalitat ?f))
  =>
  (do-for-all-instances ((?b Beguda)) TRUE
    (bind ?nb (send ?b get-nom))
    (bind ?ba (send ?b get-alcohol))
    (bind $?forms (create$ (send ?b get-formalitat)))
    (bind ?fok (or (member$ (if (symbolp ?f) then ?f else (string-to-field (lowcase ?f)))
                            (create$ $?forms))
                   (eq ?f indiferent)))
    (bind ?aok (or (eq ?alc indiferent) (eq ?alc ?ba)))
    (if (and ?fok ?aok) then
      (if (<= (length$ (find-all-facts ((?fb beguda-ok-base))
                        (eq (fact-slot-value ?fb nom) ?nb))) 0)
          then (assert (beguda-ok-base (nom ?nb)))))))

; --- DEBUG ABS (comptes de formalitat i estacionalitat) ---
(defrule AbstraccioHeuristica::debug-abs
  (declare (salience -1))
  (respostes-completes)
  =>
  (bind $?okb (find-all-facts ((?f plat-ok-base)) TRUE))
  (bind $?est (find-all-facts ((?f plat-estacio-ok)) TRUE))

  (bind $?okbNoms (create$))
  (foreach ?fx $?okb (bind $?okbNoms (create$ $?okbNoms (fact-slot-value ?fx nom))))
  (bind $?estNoms (create$))
  (foreach ?fx $?est (bind $?estNoms (create$ $?estNoms (fact-slot-value ?fx nom))))

  (printout t crlf ">> DEBUG ABS: plat-ok-base=" (length$ $?okb)
              " | plat-estacio-ok=" (length$ $?est) crlf)
  (printout t "   alguns plat-ok-base: " (subseq$ $?okbNoms 1 (min 5 (length$ $?okbNoms))) crlf)
  (printout t "   alguns plat-estacio-ok: " (subseq$ $?estNoms 1 (min 5 (length$ $?estNoms))) crlf))


; ------------------------------------------------------------
; MÒDUL: ASSOCIACIÓ HEURÍSTICA (al·lèrgens i dietes per GRUP)
; ------------------------------------------------------------
(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))

; Per cada grup, marca PLAT apte a al·lèrgens i dieta
(defrule AssociacioHeuristica::plat-per-grup
  (peticio)
  (plat-estacio-ok (nom ?np))
  (plat-ok-base (nom ?np))
  (grup-restriccio (id ?gid) (alergens $?ALS) (dieta ?diet))
  =>
  (bind ?ok TRUE)
  (bind ?P (nth$ 1 (find-all-instances ((?p Plat)) (eq (send ?p get-nom) ?np))))
  (if (not ?P) then (bind ?ok FALSE))
  (if ?ok then
    (bind $?ings (send ?P get-te_ingredients))
    (foreach ?n $?ings
      (if ?ok then
        (bind ?I (ingredient-by-name ?n))
        (if (not ?I) then (bind ?ok FALSE)
        else
          (bind $?ialgs (send ?I get-alergens))
          (foreach ?a $?ALS
            (if (member$ ?a (create$ $?ialgs)) then (bind ?ok FALSE)))
          (bind $?idiet (send ?I get-dietes))
          (if (not (dieta-ing-compatible ?diet $?idiet)) then (bind ?ok FALSE))
        ))))
  (if ?ok then (assert (plat-ok-grup (nom ?np) (gid ?gid))))
)

; Begudes per grup (al·lèrgens/dieta simples)
(defrule AssociacioHeuristica::beguda-per-grup
  (beguda-ok-base (nom ?nb))
  (grup-restriccio (id ?gid) (alergens $?ALS) (dieta ?diet))
  =>
  (bind ?B (nth$ 1 (find-all-instances ((?b Beguda)) (eq (send ?b get-nom) ?nb))))
  (bind ?ok TRUE)
  (bind $?balgs (send ?B get-alergens))
  (foreach ?a $?ALS (if (member$ ?a (create$ $?balgs)) then (bind ?ok FALSE)))
  (bind $?bd (send ?B get-dietes))
  ; si el grup té dieta, exigim que la beguda no la violi (si hi ha etiquetes)
  (if (and ?ok (neq ?diet cap) (> (length$ (create$ $?bd)) 0))
      then (if (not (dieta-ing-compatible ?diet $?bd)) then (bind ?ok FALSE)))
  (if ?ok then (assert (beguda-ok-grup (nom ?nb) (gid ?gid))))
)

; ------------------------------------------------------------
; MÒDUL: REFINAMENT (candidats i pressupost per plat)
; ------------------------------------------------------------
(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL) (export ?ALL))

; Candidats “base” (sense grups) -> per composició menú únic
(defrule RefinamentHeuristica::indexar-candidats-base
  (peticio)
  (plat-estacio-ok (nom ?np))
  (plat-ok-base (nom ?np))  ; <-- afegim formalitat com a condició dura d'indexació
  =>
  (bind ?P (nth$ 1 (find-all-instances ((?p Plat)) (eq (send ?p get-nom) ?np))))
  (bind ?pv (send ?P get-preu_venta))
  (bind $?ord (send ?P get-te_ordre))
  (foreach ?o $?ord
    (assert (plat-candidat (nom ?np) (ordre ?o) (preu ?pv))))
)



; També podríem indexar candidats per grup si després vols menús per grup:
(deftemplate plat-candidat-grup (slot gid (type INTEGER)) (slot nom) (slot ordre) (slot preu (type FLOAT)))
(defrule RefinamentHeuristica::indexar-candidats-per-grup
  (grup-restriccio (id ?gid))
  (plat-ok-grup (nom ?np) (gid ?gid))
  =>
  (bind ?P (nth$ 1 (find-all-instances ((?p Plat)) (eq (send ?p get-nom) ?np))))
  (bind ?pv (send ?P get-preu_venta))
  (bind $?ord (send ?P get-te_ordre))
  (foreach ?o $?ord
    (assert (plat-candidat-grup (gid ?gid) (nom ?np) (ordre ?o) (preu ?pv))))
)

; Quants candidats indexats (a punt per fer score)
(defrule RefinamentHeuristica::debug-count-candidats
  (declare (salience -5))
  (respostes-completes)
  =>
  (bind $?c (find-all-facts ((?c plat-candidat)) TRUE))
  (bind $?p (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) primer)))
  (bind $?s (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) segon)))
  (bind $?o (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) postres)))
  (printout t ">> DEBUG: plat-candidat total: " (length$ $?c)
              " | primers: " (length$ $?p)
              " | segons: " (length$ $?s)
              " | postres: " (length$ $?o) crlf)
)

; --- DEBUG REF (candidats indexats per ordre) ---
(defrule RefinamentHeuristica::debug-ref
  (declare (salience -1))
  (respostes-completes)
  =>
  (bind $?cand (find-all-facts ((?c plat-candidat)) TRUE))
  (bind $?p (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) primer)))
  (bind $?s (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) segon)))
  (bind $?o (find-all-facts ((?c plat-candidat)) (eq (fact-slot-value ?c ordre) postres)))

  (bind $?pN (create$))
  (foreach ?fx $?p (bind $?pN (create$ $?pN (fact-slot-value ?fx nom))))
  (bind $?sN (create$))
  (foreach ?fx $?s (bind $?sN (create$ $?sN (fact-slot-value ?fx nom))))
  (bind $?oN (create$))
  (foreach ?fx $?o (bind $?oN (create$ $?oN (fact-slot-value ?fx nom))))

  (printout t ">> DEBUG REF: plat-candidat total=" (length$ $?cand)
            " | primers=" (length$ $?p)
            " | segons=" (length$ $?s)
            " | postres=" (length$ $?o) crlf)
  (printout t "   alguns primers: " (subseq$ $?pN 1 (min 5 (length$ $?pN))) crlf)
  (printout t "   alguns segons: " (subseq$ $?sN 1 (min 5 (length$ $?sN))) crlf)
  (printout t "   alguns postres: " (subseq$ $?oN 1 (min 5 (length$ $?oN))) crlf)
)


; ------------------------------------------------------------
; MÒDUL: PUNTUACIÓ (scoring suau: temperatura, complexitat, mida)
; ------------------------------------------------------------
(defmodule Puntuacio (import MAIN ?ALL) (import RefinamentHeuristica ?ALL) (export ?ALL))

(defrule Puntuacio::calcular-plat-score
  (peticio)
  ?c <- (plat-candidat (nom ?np) (ordre ?o) (preu ?pv))
  =>
  (assert (plat-score (nom ?np) (ordre ?o) (preu ?pv)
                      (score (calc-plat-score ?np ?o))))
)
(defrule Puntuacio::debug-count-scores
  (declare (salience -10))
  (respostes-completes)
  =>
  (bind $?sp (find-all-facts ((?s plat-score)) (eq (fact-slot-value ?s ordre) primer)))
  (bind $?ss (find-all-facts ((?s plat-score)) (eq (fact-slot-value ?s ordre) segon)))
  (bind $?so (find-all-facts ((?s plat-score)) (eq (fact-slot-value ?s ordre) postres)))
  (printout t ">> DEBUG: plat-score primers/segons/postres = "
              (length$ $?sp) "/" (length$ $?ss) "/" (length$ $?so) crlf)
)

; ------------------------------------------------------------
; MÒDUL: COMPOSICIÓ (usa plat-score i genera menús)
; ------------------------------------------------------------
(defmodule ComposicioMenus (import MAIN ?ALL) (import Puntuacio ?ALL))

; ==== Helpers ja existents (reutilitzats) ====
(deffunction preu-beguda-nom (?nom)
  (if (eq ?nom "") then (return 0.0))
  (bind ?B (nth$ 1 (find-all-instances ((?b Beguda)) (eq (send ?b get-nom) ?nom))))
  (if ?B then (send ?B get-preu_venta) else 0.0)
)

(deffunction pick-beguda-general ()
  (bind ?cands (find-all-instances ((?b Beguda)) (eq (send ?b get-es_general) si)))
  (if (> (length$ ?cands) 0)
      then (return (send (nth$ 1 ?cands) get-nom))
      else (return "")) 
)

(deffunction begudes-compatibles-amb-plat (?ordre ?nom-plat)
  (bind ?P (nth$ 1 (find-all-instances ((?p Plat)) (eq (send ?p get-nom) ?nom-plat))))
  (bind $?ptags (if ?P then (send ?P get-tags) else (create$)))
  (bind $?out (create$))
  (do-for-all-instances ((?b Beguda)) TRUE
    (bind ?bn (send ?b get-nom))
    (if (<= (length$ (find-all-facts ((?fb beguda-ok-base)) (eq (fact-slot-value ?fb nom) ?bn))) 0)
        then (progn)
        else
          (bind $?bt (send ?b get-marida_amb_tags))
          (bind $?bo (send ?b get-marida_amb_ordre))
          (bind ?ok-ordre (or (= (length$ (create$ $?bo)) 0) (member$ ?ordre (create$ $?bo))))
          (bind ?inter FALSE)
          (foreach ?t $?ptags (if (member$ ?t (create$ $?bt)) then (bind ?inter TRUE)))
          (if (and ?ok-ordre ?inter) then (bind $?out (create$ $?out ?bn)))))
  $?out
)

(deffunction _menu-total (?bm ?pr ?sg ?po ?bgen ?bpr ?bsg ?bpo)
  (bind ?t 0.0)
  ; preu plats
  (bind ?fpr (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?pr) (eq (fact-slot-value ?ps ordre) primer)))))
  (bind ?fsg (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?sg) (eq (fact-slot-value ?ps ordre) segon)))))
  (bind ?fpo (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?po) (eq (fact-slot-value ?ps ordre) postres)))))
  (bind ?t (+ ?t (if ?fpr then (fact-slot-value ?fpr preu) else 0.0)))
  (bind ?t (+ ?t (if ?fsg then (fact-slot-value ?fsg preu) else 0.0)))
  (bind ?t (+ ?t (if ?fpo then (fact-slot-value ?fpo preu) else 0.0)))
  ; preu begudes
  (if (eq ?bm general)
      then (bind ?t (+ ?t (preu-beguda-nom ?bgen)))
      else (bind ?t (+ ?t (preu-beguda-nom ?bpr) (preu-beguda-nom ?bsg) (preu-beguda-nom ?bpo))))
  ?t
)

; ==== Helpers nous per accedir a puntuacions i TOP-K ====
(deffunction get-plat-score (?nom ?ordre)
  (bind ?f (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?nom)
                                                          (eq (fact-slot-value ?ps ordre) ?ordre)))))
  (if ?f then (fact-slot-value ?f score) else 0)
)

(deffunction collect-score-facts (?ordre)
  (find-all-facts ((?s plat-score)) (eq (fact-slot-value ?s ordre) ?ordre))
)

(deffunction topk-noms-per-ordre (?ordre ?k)
  (bind $?fs (collect-score-facts ?ordre))
  (bind $?out (create$))
  (bind ?kk (min ?k (length$ $?fs)))
  (while (> ?kk 0)
    (bind ?b (pick-best-score-fact $?fs))
    (if ?b then
      (bind $?out (create$ $?out (fact-slot-value ?b nom)))
      (bind $?fs (remove-fact ?b $?fs)))
    (bind ?kk (- ?kk 1)))
  $?out
)

(deffunction choose-begudes-for-combo (?bm ?pr ?sg ?po)
  (bind ?bg "") (bind ?bpr "") (bind ?bsg "") (bind ?bpo "")
  (if (eq ?bm general) then
    (bind ?bg (pick-beguda-general))
   else
    (bind $?bp1 (begudes-compatibles-amb-plat primer  ?pr))
    (bind $?bp2 (begudes-compatibles-amb-plat segon   ?sg))
    (bind $?bp3 (begudes-compatibles-amb-plat postres ?po))
    (if (> (length$ $?bp1) 0) then (bind ?bpr (nth$ 1 $?bp1)))
    (if (> (length$ $?bp2) 0) then (bind ?bsg (nth$ 1 $?bp2)))
    (if (> (length$ $?bp3) 0) then (bind ?bpo (nth$ 1 $?bp3))))
  (create$ ?bg ?bpr ?bsg ?bpo)
)

(deffunction pick-min-menu-by-preu (?facts)
  (if (<= (length$ ?facts) 0) then (return FALSE))
  (bind ?best (nth$ 1 ?facts))
  (foreach ?f ?facts
    (if (< (fact-slot-value ?f preu) (fact-slot-value ?best preu)) then (bind ?best ?f)))
  ?best
)

(deffunction pick-max-menu-by-preu (?facts)
  (if (<= (length$ ?facts) 0) then (return FALSE))
  (bind ?best (nth$ 1 ?facts))
  (foreach ?f ?facts
    (if (> (fact-slot-value ?f preu) (fact-slot-value ?best preu)) then (bind ?best ?f)))
  ?best
)

(deffunction pick-best-menu-by-score (?facts)
  (if (<= (length$ ?facts) 0) then (return FALSE))
  (bind ?best (nth$ 1 ?facts))
  (foreach ?f ?facts
    (bind ?sb (fact-slot-value ?best score))
    (bind ?sp (fact-slot-value ?f score))
    (if (or (> ?sp ?sb)
            (and (= ?sp ?sb)
                 (< (fact-slot-value ?f preu) (fact-slot-value ?best preu))))
        then (bind ?best ?f)))
  ?best
)

; ==== Impressió de menú (reutilitzem format) ====
(deffunction print-menu (?idx ?pr ?sg ?po ?bmode ?bgen ?bpr ?bsg ?bpo)
  (bind ?ppr (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?pr) (eq (fact-slot-value ?ps ordre) primer)))))
  (bind ?psg (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?sg) (eq (fact-slot-value ?ps ordre) segon)))))
  (bind ?ppo (nth$ 1 (find-all-facts ((?ps plat-score)) (and (eq (fact-slot-value ?ps nom) ?po) (eq (fact-slot-value ?ps ordre) postres)))))
  (bind ?preu-pr (if ?ppr then (fact-slot-value ?ppr preu) else 0.0))
  (bind ?preu-sg (if ?psg then (fact-slot-value ?psg preu) else 0.0))
  (bind ?preu-po (if ?ppo then (fact-slot-value ?ppo preu) else 0.0))
  (bind ?total (+ ?preu-pr ?preu-sg ?preu-po))
  (if (eq ?bmode general) then
    (bind ?total (+ ?total (preu-beguda-nom ?bgen)))
   else
    (bind ?total (+ ?total (preu-beguda-nom ?bpr) (preu-beguda-nom ?bsg) (preu-beguda-nom ?bpo))))

  (printout t crlf "*** Menú " ?idx " ***" crlf)
  (printout t "  Entrant:   " ?pr "  [" ?preu-pr " €]" crlf)
  (printout t "  Principal: " ?sg "  [" ?preu-sg " €]" crlf)
  (printout t "  Postres:   " ?po "  [" ?preu-po " €]" crlf)
  (if (eq ?bmode general) then
    (printout t "  Beguda:    " (if (neq ?bgen "") then ?bgen else "--")
                    (if (neq ?bgen "") then (str-cat "  [" (preu-beguda-nom ?bgen) " €]") else "") crlf)
   else
    (printout t "  Beguda 1r: " (if (neq ?bpr "") then ?bpr else "--")
                    (if (neq ?bpr "") then (str-cat "  [" (preu-beguda-nom ?bpr) " €]") else "") crlf)
    (printout t "  Beguda 2n: " (if (neq ?bsg "") then ?bsg else "--")
                    (if (neq ?bsg "") then (str-cat "  [" (preu-beguda-nom ?bsg) " €]") else "") crlf)
    (printout t "  Beguda P.: " (if (neq ?bpo "") then ?bpo else "--")
                    (if (neq ?bpo "") then (str-cat "  [" (preu-beguda-nom ?bpo) " €]") else "") crlf))
  (printout t "  -----------------------------------------------------------" crlf)
  (printout t "  TOTAL per persona: " ?total " €" crlf)
  ?total
)

; ==== Regla principal basada en SCORING (amb diagnòstic) ====
(defrule ComposicioMenus::mostrar-menus
  (declare (auto-focus TRUE))
  (respostes-completes)
  (peticio (beguda-mode ?bm) (pressupost-min ?pmin) (pressupost-max ?pmax))
  =>
  (bind ?bm2 (if (eq ?bm indiferent) then general else ?bm))

  ; ---- DIAGNÒSTIC PREVI: comptar tot abans d’avançar ----
  (bind $?okb (find-all-facts ((?f plat-ok-base)) TRUE))
  (bind $?est (find-all-facts ((?f plat-estacio-ok)) TRUE))
  (bind $?cand (find-all-facts ((?c plat-candidat)) TRUE))
  (printout t crlf ">> CHECKPOINT: ok-base=" (length$ $?okb)
                " | estacio-ok=" (length$ $?est)
                " | candidats=" (length$ $?cand) crlf)

  (if (or (= (length$ $?okb) 0) (= (length$ $?est) 0)) then
    (printout t "*** ERROR: No hi ha plats que passin formalitat o estacionalitat. Revisa ingredients/estacions. ***" crlf)
    (return))

  ; 1) Assegurem que hi ha puntuacions
  (bind $?p1 (collect-score-facts primer))
  (bind $?p2 (collect-score-facts segon))
  (bind $?p3 (collect-score-facts postres))
  (printout t ">> CHECKPOINT: scores 1r/2n/postres = "
               (length$ $?p1) "/" (length$ $?p2) "/" (length$ $?p3) crlf)

  (if (or (<= (length$ $?p1) 0) (<= (length$ $?p2) 0) (<= (length$ $?p3) 0)) then
    (printout t "*** No hi ha suficients plats puntuats per construir menús (manca algun ordre). ***" crlf)
    (return))

  ; 2) TOP-K per ordre (segons score)
  (bind $?PR (topk-noms-per-ordre primer  ?*TOPK*))
  (bind $?SG (topk-noms-per-ordre segon   ?*TOPK*))
  (bind $?PO (topk-noms-per-ordre postres ?*TOPK*))
  (printout t ">> CHECKPOINT: TOPK primers/segons/postres = "
              (length$ $?PR) "/" (length$ $?SG) "/" (length$ $?PO) crlf)

  ; 3) Enumerem combinacions i creem menu-candidat
  (foreach ?pr $?PR
    (foreach ?sg $?SG
      (foreach ?po $?PO
        (bind ?s (+ (get-plat-score ?pr primer)
                    (get-plat-score ?sg segon)
                    (get-plat-score ?po postres)))
        (bind $?B (choose-begudes-for-combo ?bm2 ?pr ?sg ?po))
        (bind ?bgen (nth$ 1 $?B))
        (bind ?bpr  (nth$ 2 $?B))
        (bind ?bsg  (nth$ 3 $?B))
        (bind ?bpo  (nth$ 4 $?B))
        (bind ?tt  (_menu-total ?bm2 ?pr ?sg ?po ?bgen ?bpr ?bsg ?bpo))
        (assert (menu-candidat (pr ?pr) (sg ?sg) (po ?po)
                               (bmode ?bm2) (bgen ?bgen) (bpr ?bpr) (bsg ?bsg) (bpo ?bpo)
                               (preu ?tt) (score ?s))))))

  (printout t crlf "=== Propostes de menús (barat / mitjà / car) ===" crlf)

  ; 4) Selecció final
  (bind $?ALL (find-all-facts ((?m menu-candidat)) TRUE))
  (bind $?IN  (if (and (numberp ?pmin) (numberp ?pmax))
                  then (find-all-facts ((?m menu-candidat))
                          (and (>= (fact-slot-value ?m preu) ?pmin)
                               (<= (fact-slot-value ?m preu) ?pmax)))
                  else (create$)))

  (if (> (length$ $?ALL) 0) then
    (printout t ">> CHECKPOINT: menús generats=" (length$ $?ALL)
                 " | dins pressupost=" (length$ $?IN) crlf))

  (if (> (length$ $?IN) 0) then
      (bind ?cheap (pick-min-menu-by-preu $?IN))
      (bind $?rest (remove-fact ?cheap $?IN))
      (bind ?exp   (pick-max-menu-by-preu $?rest))
      (bind $?rest (remove-fact ?exp $?rest))
      (bind ?mid   (pick-best-menu-by-score $?rest))
      (if ?cheap then (print-menu "1 · BARAT"
                    (fact-slot-value ?cheap pr) (fact-slot-value ?cheap sg) (fact-slot-value ?cheap po)
                    (fact-slot-value ?cheap bmode)
                    (fact-slot-value ?cheap bgen) (fact-slot-value ?cheap bpr)
                    (fact-slot-value ?cheap bsg) (fact-slot-value ?cheap bpo)))
      (if ?mid then (print-menu "2 · MITJÀ"
                    (fact-slot-value ?mid pr) (fact-slot-value ?mid sg) (fact-slot-value ?mid po)
                    (fact-slot-value ?mid bmode)
                    (fact-slot-value ?mid bgen) (fact-slot-value ?mid bpr)
                    (fact-slot-value ?mid bsg) (fact-slot-value ?mid bpo)))
      (if ?exp then (print-menu "3 · CAR"
                    (fact-slot-value ?exp pr) (fact-slot-value ?exp sg) (fact-slot-value ?exp po)
                    (fact-slot-value ?exp bmode)
                    (fact-slot-value ?exp bgen) (fact-slot-value ?exp bpr)
                    (fact-slot-value ?exp bsg) (fact-slot-value ?exp bpo)))
    else
      (printout t "Cap combinació cau dins del rang [" ?pmin " — " ?pmax "] €/pp. Et mostro les millors per puntuació." crlf)
      (bind ?best1 (pick-best-menu-by-score $?ALL))
      (bind $?r (remove-fact ?best1 $?ALL))
      (bind ?best2 (pick-best-menu-by-score $?r))
      (bind $?r (remove-fact ?best2 $?r))
      (bind ?best3 (pick-best-menu-by-score $?r))
      (if ?best1 then (print-menu "A · TOP" 
                    (fact-slot-value ?best1 pr) (fact-slot-value ?best1 sg) (fact-slot-value ?best1 po)
                    (fact-slot-value ?best1 bmode)
                    (fact-slot-value ?best1 bgen) (fact-slot-value ?best1 bpr)
                    (fact-slot-value ?best1 bsg) (fact-slot-value ?best1 bpo)))
      (if ?best2 then (print-menu "B · TOP" 
                    (fact-slot-value ?best2 pr) (fact-slot-value ?best2 sg) (fact-slot-value ?best2 po)
                    (fact-slot-value ?best2 bmode)
                    (fact-slot-value ?best2 bgen) (fact-slot-value ?best2 bpr)
                    (fact-slot-value ?best2 bsg) (fact-slot-value ?best2 bpo)))
      (if ?best3 then (print-menu "C · TOP" 
                    (fact-slot-value ?best3 pr) (fact-slot-value ?best3 sg) (fact-slot-value ?best3 po)
                    (fact-slot-value ?best3 bmode)
                    (fact-slot-value ?best3 bgen) (fact-slot-value ?best3 bpr)
                    (fact-slot-value ?best3 bsg) (fact-slot-value ?best3 bpo)))
  )
)

