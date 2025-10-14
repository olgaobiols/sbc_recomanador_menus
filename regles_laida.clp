;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fitxer: regles.clp
;; Regles per generar automàticament un menú personalitzat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; --- Pregunta el pressupost màxim al client ---
(defrule preguntar-preu
   (declare (salience 100))
   =>
   (printout t crlf "Introdueix el preu màxim que vols pagar pel menú: " )
   (bind ?preu-max (read))
   (assert (preu-maxim ?preu-max))
   (printout t "Perfecte! Intentaré trobar-te un menú dins de " ?preu-max " €." crlf)
)

;; --- Selecciona un primer plat ---
(defrule triar-primer
   (preu-maxim ?max)
   (not (primer-seleccionat ?))
   (object (is-a Plat) (nom ?n) (formalitat "informal"|"formal"))
   =>
   (assert (primer-seleccionat ?n))
   (printout t "Primer plat triat: " ?n crlf)
)

;; --- Selecciona un segon plat ---
(defrule triar-segon
   (preu-maxim ?max)
   (primer-seleccionat ?)
   (not (segon-seleccionat ?))
   (object (is-a Plat) (nom ?n) (formalitat "informal"|"formal"))
   (test (neq ?n (fact-slot-value (find-fact ((?f primer-seleccionat)) TRUE) 1))) ;; que no sigui el mateix
   =>
   (assert (segon-seleccionat ?n))
   (printout t "Segon plat triat: " ?n crlf)
)

;; --- Selecciona postres ---
(defrule triar-postres
   (preu-maxim ?max)
   (segon-seleccionat ?)
   (not (postres-seleccionat ?))
   (object (is-a Plat) (nom ?n))
   (test (neq ?n (fact-slot-value (find-fact ((?f segon-seleccionat)) TRUE) 1)))
   =>
   (assert (postres-seleccionat ?n))
   (printout t "Postres triades: " ?n crlf)
)

;; --- Selecciona una beguda ---
(defrule triar-beguda
   (preu-maxim ?max)
   (postres-seleccionat ?)
   (not (beguda-seleccionada ?))
   (object (is-a Beguda) (nom ?n) (preu ?p))
   =>
   (assert (beguda-seleccionada ?n))
   (printout t "Beguda triada: " ?n crlf)
)

;; --- Crear el menú final ---
(defrule crear-menu-personalitzat
   (preu-maxim ?max)
   (primer-seleccionat ?p1)
   (segon-seleccionat ?p2)
   (postres-seleccionat ?p3)
   (beguda-seleccionada ?b)
   (not (menu-creat))
   =>
   (make-instance menu-auto of MenuPersonalitzat
      (nom "Menú recomanat automàticament")
      (primer_plat ?p1)
      (segon_plat ?p2)
      (postres ?p3)
      (beguda (create$ ?b))
      (preu ?max)
      (putuacio 4.0))
   (assert (menu-creat))
   (printout t crlf "S'ha creat un menú personalitzat dins del teu pressupost!" crlf)
   (printout t "  Primer plat: " ?p1 crlf)
   (printout t "  Segon plat:  " ?p2 crlf)
   (printout t "  Postres:     " ?p3 crlf)
   (printout t "  Beguda:      " ?b crlf)
   (printout t "---------------------------------------" crlf)
)

