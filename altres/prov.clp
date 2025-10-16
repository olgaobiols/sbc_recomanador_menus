(deffunction round2 (?x) (/ (float (round (* ?x 100))) 100.0))
(deffunction factor-complexitat (?c)
  (if (eq ?c baixa) then 1.10 else (if (eq ?c mitjana) then 1.25 else 1.50)))
(deffunction factor-formalitat (?f) (if (eq ?f "formal") then 1.15 else 1.00))

(defrule Economia::calcula-preu-venta-plat
  ?p <- (object (is-a Plat)
                (nom ?np)
                (complexitat ?cx)
                (mida_racio ?r)
                (formalitat ?ff)
                (preu_venta ?pv))
  ;; només calcula si no hi ha pvp (nil o ≤0)
  (test (or (not (numberp ?pv)) (<= ?pv 0)))
  =>
  (bind ?cost
    (accumulate
      (bind ?s 0.0)
      (object (is-a Ingredient)
              (part_de $? ?p $?)
              (preu_cost ?cu))
      (+ ?s (if (and (numberp ?cu) (> ?cu 0)) then ?cu else 0.0))))
  (bind ?frac  (if (and (numberp ?r) (> ?r 1.0)) then ?r else 1.0))
  (bind ?preu (round2 (* ?cost (factor-complexitat ?cx) (factor-formalitat ?ff) ?frac 1.35)))
  (send ?p put-preu_venta ?preu)
)




(deffunction round2 (?x) (/ (float (round (* ?x 100))) 100.0))

(deffunction factor-formalitat-beguda (?f)
  (if (eq ?f "formal") then 1.10 else 1.00))

(deffunction factor-alcohol (?a)
  (if (eq ?a si) then 1.15 else 1.05))

(deffunction marge-beguda () 1.30)   ; ajusta-ho si cal
(deffunction marge-menu   () 1.00)   ; marge extra a nivell menú (si vols)


(defrule ComposicioMenus::calcula-preu-venta-beguda
  ?b <- (object (is-a Beguda)
                (preu_cost ?pc)
                (preu_venta ?pv))
  (test (or (not (numberp ?pv)) (<= ?pv 0)))
  =>
  (bind ?alc  (send ?b get-alcohol))      ; si / no
  (bind ?form (send ?b get-formalitat))   ; "formal" / ...
  (bind ?falc (factor-alcohol ?alc))
  (bind ?fform (factor-formalitat-beguda ?form))
  (bind ?marge (marge-beguda))
  (bind ?pvp  (round2 (* ?pc ?falc ?fform ?marge)))
  (send ?b put-preu_venta ?pvp))


(defrule ComposicioMenus::calcula-preu-venta-menu
  ?m <- (object (is-a Menu)
                (preu_venta ?pm&?VARIABLE))
  =>
  ;; ---------- Suma de PLATS del menú ----------
  (bind ?sum-plats
    (accumulate
      (bind ?s 0.0)
      (object (is-a Plat) (part_de $? ?m $?) (preu_venta ?pp))
      (+ ?s (if (and (numberp ?pp) (> ?pp 0)) then ?pp else 0.0))))

  ;; ---------- Beguda GENERAL del menú ----------
  (bind ?sum-beguda-general
    (accumulate
      (bind ?sb 0.0)
      (object (is-a Beguda) (part_de $? ?m $?) (preu_venta ?pb))
      (+ ?sb (if (and (numberp ?pb) (> ?pb 0)) then ?pb else 0.0))))

  ;; ---------- Begudes PER-PLAT (acompanya plats del menú) ----------
  (bind ?sum-beguda-per-plat 0.0)
  (foreach ?b (find-all-instances
                ((?bx Beguda))
                (and
                  (neq (length$ (send ?bx get-acompanya)) 0)
                  (exists
                    (object (is-a Plat)
                            (part_de $? ?m $?)
                            (name ?pid))
                    (test (member ?self (send ?bx get-acompanya))))))
    (bind ?pb (send ?b get-preu_venta))
    (if (and (numberp ?pb) (> ?pb 0)) then
      (bind ?sum-beguda-per-plat (+ ?sum-beguda-per-plat ?pb))))

  ;; ---------- Total i marge a nivell menú (si en vols) ----------
  (bind ?total-brut (+ ?sum-plats ?sum-beguda-general ?sum-beguda-per-plat))
  (bind ?pvp-menu (round2 (* ?total-brut (marge-menu))))
  (send ?m put-preu_venta ?pvp-menu)

  ;; ---------- (Opcional) Assignar ID si no n'hi ha ----------
  ;; Requereix que a l'ontologia hi hagi (slot id (type SYMBOL)) a Menu.
  (if (slot-existp ?m id) then
    (bind ?id (send ?m get-id))
    (if (or (not (symbolp ?id)) (eq ?id nil)) then
      (send ?m put-id (gensym*))))

  ;; ---------- (Opcional) Regenerar nom del menú segons atributs ----------
  ;; Exemples: “Menú mediterrània · 34,90€” o “Menú (sense etiqueta) · 27,50€”
  (bind ?tc (send ?m get-tipus_cuina)) ; multislot STRING
  (bind ?etiqueta (if (> (length$ ?tc) 0) then (nth$ 1 ?tc) else ""))
  (bind ?nom-auto
        (if (neq ?etiqueta "")
            then (str-cat "Menú " ?etiqueta " · " ?pvp-menu "€")
            else (str-cat "Menú · " ?pvp-menu "€")))
  (send ?m put-nom ?nom-auto))
