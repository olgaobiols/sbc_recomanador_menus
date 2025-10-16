;; ========================
;; PAS 2: ABSTRACCIÓ
;; ========================
(defmodule AbstraccioHeuristica
  (import MAIN ?ALL) (import PreferenciesMenu ?ALL) (export ?ALL))

;; --- Representació del perfil i objectius de pressupost
(deftemplate AbstraccioHeuristica::perfil-usuari
  (slot temporada)        ; primavera/estiu/tardor/hivern
  (slot torn)             ; dinar/sopar
  (slot espai)            ; interior/exterior
  (slot formalitat)       ; informal/formal
  (slot alcohol)          ; si/no
  (slot infantil-senior)  ; si/no
  (slot num-comensals (type INTEGER))
  (multislot alergens-prohibits)
  ;; pesos per al matching (ajustables)
  (slot pes-formalitat (type FLOAT) (default 1.0))
  (slot pes-temporada  (type FLOAT) (default 0.8))
  (slot pes-beguda     (type FLOAT) (default 0.5))
  (slot pes-alergies   (type FLOAT) (default 2.0))
  (slot pes-torn       (type FLOAT) (default 0.5))
  (slot pes-espai      (type FLOAT) (default 0.5))
)

;; tres franges de preu objectiu per persona: barat/mitjà/car
(deftemplate AbstraccioHeuristica::franja-pressupost
  (slot nom)                    ; barat | mitja | car
  (slot pp-min (type NUMBER))
  (slot pp-max (type NUMBER)))

;; helper: explodeja mots separats per espais en multifield
(deffunction AbstraccioHeuristica::split-mots (?txt)
  (if (or (eq ?txt nil) (eq ?txt "")) then (create$) else (explode$ ?txt)))

;; 2.1) Construir el perfil derivat a partir de peticio
(defrule AbstraccioHeuristica::construir-perfil
  ?p <- (peticio
          (data ?temp&~nil)
          (torn ?t&~nil)
          (espai ?e&~nil)
          (formalitat ?f&~nil)
          (alcohol ?a&~nil)
          (infantil-senior ?is&~nil)
          (num-comensals ?n&~nil)
          (pressupost ?pp&~nil)
          (alergies-si ?asi&~nil)
          (alergens ?als))
  (not (perfil-usuari))
  =>
  (bind ?al-list (if (or (eq ?asi "si") (eq ?asi "sí")) then (split-mots ?als) else (create$)))
  (assert (perfil-usuari
            (temporada ?temp) (torn ?t) (espai ?e) (formalitat ?f)
            (alcohol ?a) (infantil-senior ?is) (num-comensals ?n)
            (alergens-prohibits ?al-list)))
  ;; definir franges de preu al voltant del pressupost de referència
  (bind ?low  (* 0.85 ?pp))
  (bind ?midL (* 0.85 ?pp))
  (bind ?midH (* 1.15 ?pp))
  (bind ?high (* 1.30 ?pp))
  (assert (franja-pressupost (nom barat) (pp-min 0)     (pp-max ?low)))
  (assert (franja-pressupost (nom mitja) (pp-min ?midL) (pp-max ?midH)))
  (assert (franja-pressupost (nom car)   (pp-min ?midH) (pp-max 1.0e9)))  ; “sense límit” superior
)

;; (opcional) regles d’abstracció addicionals per derivar preferències més semàntiques
;; p.ex., “temperatura-plat” o “forquilla-servei” segons temporada, espai o torn.
(deftemplate AssociacioHeuristica::candidat-menu
  (slot menu-id)
  (slot franja)                  ; barat/mitja/car
  (slot score (type FLOAT))
  (multislot motius))

(deffunction AssociacioHeuristica::add-motiu (?old $?msgs) (create$ ?old ?msgs))
