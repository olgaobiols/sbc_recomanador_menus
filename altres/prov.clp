(deffunction valida-opcio (?pregunta $?opcions)
  (bind ?resp_valida FALSE)
  (bind ?resp nil)

  (while (not ?resp_valida)
    (printout t ?pregunta crlf)
    ;; ABANS: (bind ?input (lowcase (readline)))
    ;; DESPRÉS (1 línia de canvi):
    (bind ?input (string-to-field (lowcase (readline))))  ; o bé: (sym-cat (lowcase (readline)))

    (if (member$ ?input ?opcions) then
        (bind ?resp_valida TRUE)
        (bind ?resp ?input)
     else
        (printout t "La resposta que has introduït no és vàlida. Si us plau, tria una de les següents: " ?opcions crlf))
  )
  ?resp
)


(deffunction valida-boolea (?prompt)
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
  ?resp)
