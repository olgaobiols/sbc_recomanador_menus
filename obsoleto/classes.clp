;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sistema de recomanació de menús
;; Fitxer: menus.clp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass Esdeveniment (is-a USER)
   (role concrete)
   (slot nom (type STRING))
   (slot numero_comensals (type INTEGER))
   (slot estacio (type STRING)) ; tardor, hivern, primavera, estiu
   (slot formalitat (type STRING)) ; alta, mitjana, baixa
   (slot hora (type STRING)) ; nit/dia
   (slot direccio (type STRING)) ; mar/muntanya
   (slor interior (type BOOLEAN))
)

(defclass Comensal (is-a USER)
   (role concrete)
   (slot nom (type STRING))
   (slot edat (type INTEGER))
   (multislot restriccionsPersonals (type INSTANCE))
)

(defclass Menu (is-a USER)
   (role concrete)
   (slot nom (type STRING))
   (slot primer_plat (type STRING))
   (slot segon_plat (type STRING))
   (slot postres (type STRING))
   (multislot beguda (type STRING))
   (slot preu (type INTEGER))
   (slot putuacio (type FLOAT))
)

(defclass Plat (is-a USER)
   (role concrete)
   (slot nom (type STRING))
   (multislot ingredients (type INSTANCE))
   (slot tipus (type STRING)) ; primer_plat, segon_plat o postres
   (slot mida-racio (type STRING)) ; lleugera, pesada
   (slot complexitat (type STRING)) ; baixa, mitjana, alta
   (slot formalitat (type STRING)) ; baixa, mitjana, alta
   (slot putuacio (type FLOAT))
)

(defclass Beguda (is-a USER)
    (role concrete)
    (slot nom (type STRING))
    (slot formalitat (type STRING))
    (slot preu (type STRING))
    (multislot compleix_restriccions (type STRING))
    (slot putuacio (type FLOAT))
)

(defclass Ingredient (is-a USER)
   (role concrete)
   (slot nom (type STRING))
   (slot compleix_restriccions (type STRING))
)

(defclass Restriccio (is-a USER)
   (role abstract)
   (slot nom (type STRING))
   (multislot ingredientsProhibits (type INSTANCE))
)
