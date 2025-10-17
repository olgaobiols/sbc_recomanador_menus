(defmodule MAIN (export ?ALL))

(deftemplate MAIN::peticio
  (slot tipus-esdeveniment (default nil))
  (slot data (default nil))
  (slot torn (default nil))
  (slot espai (default nil))
  (slot num-comensals (type INTEGER SYMBOL) (default nil))
  (slot pressupost-min (type NUMBER SYMBOL) (default nil))
  (slot pressupost-max (type NUMBER SYMBOL) (default nil))
  (slot formalitat (default nil))
  (slot beguda-mode (default nil))
  (slot alcohol (default nil))
  (slot menu-mode (default nil))
  (slot alergies-si (default nil))
  (slot alergens (default "")))



(defmodule AssociacioHeuristica (import MAIN ?ALL) (import AbstraccioHeuristica ?ALL) (export ?ALL))

(deftemplate AssociacioHeuristica::menu-base
  (slot id (type SYMBOL))
  (slot nom (type STRING))
  (slot categoria (type SYMBOL))
  (slot preu-pp (type FLOAT))
  (slot formalitat)
  (multislot temporades)
  (multislot torns)
  (multislot espais)
  (multislot esdeveniments)
  (slot alcohol)
  (slot beguda-mode)
  (slot menu-mode (default unic))
  (multislot plats)
  (multislot begudes)
  (multislot alergens)
  (slot descripcio (type STRING)))



(defmodule RefinamentHeuristica (import MAIN ?ALL) (import AssociacioHeuristica ?ALL))

(defrule RefinamentHeuristica::sense-opcions
  (declare (salience -15))
  (perfil-usuari)
  (not (candidat-menu))
  (not (capcalera-impresa))
  =>
  (printout t crlf "No s'han trobat menús que encaixin amb els criteris indicats." crlf))

(defrule RefinamentHeuristica::mostrar-capcalera
  (declare (salience -10))
  (candidat-menu)
  (not (capcalera-impresa))
  =>
  (printout t crlf "MENÚS SUGGERITS" crlf)
  (assert (capcalera-impresa)))

(defrule RefinamentHeuristica::mostrar-candidat
  (declare (salience -11))
  ?c <- (candidat-menu (nom ?nom) (franja-preu ?cat) (preu-pp ?pp)
                       (plats $?plats) (begudes $?begudes) (descripcio ?desc)
                       (puntuacio ?score))
  =>
  (bind ?pp-str (format nil "%.2f" ?pp))
  (bind ?score-str (format nil "%.0f" ?score))
  (printout t "   • [" ?cat "] " ?nom " (" ?pp-str " €/pp, puntuació " ?score-str ")" crlf)
  (if (neq ?desc "") then (printout t "     " ?desc crlf))
  (if (> (length$ $?plats) 0) then (printout t "     Plats: " $?plats crlf))
  (if (> (length$ $?begudes) 0) then (printout t "     Begudes: " $?begudes crlf))
  (retract ?c))
