;;; ---------------------------------------------------------
;;; v5_ontologia.clp
;;; Translated by owl2clips
;;; Translated to CLIPS from ontology v5_ontologia.ttl
;;; :Date 14/10/2025 19:27:58

(defclass Beguda
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot acompanya
        (type INSTANCE)
        (create-accessor read-write))
    (multislot part_de
        (type INSTANCE)
        (create-accessor read-write))
    (slot alcohol
        (type SYMBOL)
        (create-accessor read-write))
    (slot formalitat
        (type STRING)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot preu_cost
        (type FLOAT)
        (create-accessor read-write))
    (slot preu_venta
        (type FLOAT)
        (create-accessor read-write))
    (slot procedencia
        (type STRING)
        (create-accessor read-write))
)

(defclass Comensal
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot esta_en
        (type INSTANCE)
        (create-accessor read-write))
    (multislot imposa
        (type INSTANCE)
        (create-accessor read-write))
    (slot edat
        (type INTEGER)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
)

(defclass Esdeveniment
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot disposa_de
        (type INSTANCE)
        (create-accessor read-write))
    (slot adreça
        (type STRING)
        (create-accessor read-write))
    (slot data
        (type SYMBOL)
        (create-accessor read-write))
    (slot formalitat
        (type STRING)
        (create-accessor read-write))
    (slot hora
        (type SYMBOL)
        (create-accessor read-write))
    (slot interior
        (type SYMBOL)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot num_comensals
        (type INTEGER)
        (create-accessor read-write))
    (slot ocasio
        (type STRING)
        (create-accessor read-write))
)

(defclass Ingredient
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot disponible_a
        (type INSTANCE)
        (create-accessor read-write))
    (multislot part_de
        (type INSTANCE)
        (create-accessor read-write))
    (multislot alergens
        (type SYMBOL)
        (create-accessor read-write))
    (multislot alternativa_restriccio
        (type STRING)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot preu_cost
        (type FLOAT)
        (create-accessor read-write))
    (multislot sabor
        (type STRING)
        (create-accessor read-write))
)

(defclass Menu
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot compleix_amb
        (type INSTANCE)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot preu_venta
        (type FLOAT)
        (create-accessor read-write))
    (multislot tipus_cuina
        (type STRING)
        (create-accessor read-write))
)

(defclass Ordre
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
)

(defclass Plat
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot combina_amb
        (type INSTANCE)
        (create-accessor read-write))
    (multislot marida_amb
        (type INSTANCE)
        (create-accessor read-write))
    (multislot part_de
        (type INSTANCE)
        (create-accessor read-write))
    (multislot te_ordre
        (type INSTANCE)
        (create-accessor read-write))
    (multislot alergens
        (type SYMBOL)
        (create-accessor read-write))
    (slot complexitat
        (type SYMBOL)
        (create-accessor read-write))
    (slot formalitat
        (type STRING)
        (create-accessor read-write))
    (slot mida_racio
        (type INTEGER)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot preu_venta
        (type FLOAT)
        (create-accessor read-write))
    (slot procedencia
        (type STRING)
        (create-accessor read-write))
    (slot temperatura
        (type STRING)
        (create-accessor read-write))
)

(defclass Restriccions
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (slot nom
        (type STRING)
        (create-accessor read-write))
)

(defclass Temporada
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (multislot es_en
        (type INSTANCE)
        (create-accessor read-write))
    (slot nom
        (type STRING)
        (create-accessor read-write))
)

(definstances instances
)
