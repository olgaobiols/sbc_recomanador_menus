;;; ---------------------------------------------------------
;;; v8_ontologia.clp
;;; Translated by owl2clips
;;; Translated to CLIPS from ontology v8_ontologia.ttl
;;; :Date 16/10/2025 10:26:37
(defclass Plat
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot temperatura
        (type STRING)
        (create-accessor read-write)) ;; filtre check-temperatura
    (slot formalitat
        (type STRING)
        (create-accessor read-write)) ;; filtre a check-formalitat
    (slot complexitat
        (type SYMBOL)
        (create-accessor read-write)) ;; filtre a check-complexitat i pricing
    (slot mida_racio
        (type SYMBOL)
        (create-accessor read-write)) ;; filtre d’esdeveniment i compatibilitat.
    (multislot te_ordre
        (type SYMBOL)
        (create-accessor read-write)) ;; filtratge per ordre (primer/segon/postres).
    (multislot disponibilitat_plats
        (type SYMBOL)
        (create-accessor read-write)) ;; filtre a check-dispo
    (multislot apte_esdeveniment
        (type SYMBOL)
        (create-accessor read-write)) ;; filtre a check-event    
    (slot preu_cost
        (type FLOAT)
        (create-accessor read-write)) ;; càlcul del preu de menú. 
    (slot categoria
        (type SYMBOL)
        (create-accessor read-write)) ;; compatibilitat i “pes” de categoria.
    (slot procedencia_plat
        (type STRING)
        (create-accessor read-write)) 
    (multislot te_ingredients_noms
        (type STRING)
        (create-accessor read-write))
)



(defclass Beguda
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (multislot formalitat
        (type SYMBOL)
        (create-accessor read-write))
    (slot alcohol
        (type SYMBOL)
        (create-accessor read-write))
    (slot maridatge
        (type SYMBOL)
        (create-accessor read-write))
    (slot preu_cost
        (type FLOAT)
        (create-accessor read-write))
    (slot es_general
        (type SYMBOL)
        (create-accessor read-write))
    (multislot alergen
        (type SYMBOL)
        (create-accessor read-write))
    (multislot dietes
        (type SYMBOL)
        (create-accessor read-write))
)



(defclass Ingredient
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    (slot nom
        (type STRING)
        (create-accessor read-write))
    (slot preu_cost
        (type FLOAT)
        (create-accessor read-write))
    (slot alergen
        (type STRING)
        (default "-")
        (create-accessor read-write))
    (multislot dietes
        (type SYMBOL)
        (create-accessor read-write))
)


(defclass Menu
  (is-a USER)
  (role concrete)
  (pattern-match reactive)

  ;; Enllaços a plats
  (slot primer
    (type INSTANCE)
    (allowed-classes Plat)
    (create-accessor read-write))
  (slot segon
    (type INSTANCE)
    (allowed-classes Plat)
    (create-accessor read-write))
  (slot postres
    (type INSTANCE)
    (allowed-classes Plat)
    (create-accessor read-write))

  ;; Enllaç a les begudes seleccionades
  (multislot begudes
    (type INSTANCE)
    (allowed-classes Beguda)
    (create-accessor read-write))

  ;; Mode de beguda (general / per-plat) – per traçar decisions
  (slot beguda_mode
    (type SYMBOL)
    (create-accessor read-write))

  ;; Preu final per persona
  (slot preu_total
    (type FLOAT)
    (create-accessor read-write))

)


(defclass Esdeveniment
  (is-a USER)
  (role concrete)
  (pattern-match reactive)

  ;; De peticio::tipus-esdeveniment
  (slot ocasio
    (type SYMBOL) 
    (create-accessor read-write))

  (slot data
    (type SYMBOL)
    (create-accessor read-write))

  (slot interior
    (type SYMBOL)
    (create-accessor read-write))

  (slot formalitat
    (type SYMBOL)
    (create-accessor read-write))

(slot num_comensals
    (type INTEGER)
    (create-accessor read-write))

  (slot pressupost_min
    (type FLOAT)
    (create-accessor read-write))
  (slot pressupost_max
    (type FLOAT)
    (create-accessor read-write))

  (slot beguda_mode
    (type SYMBOL)
    (create-accessor read-write))

  (slot alcohol
    (type SYMBOL)
    (create-accessor read-write))

  (multislot disposa_de
    (type INSTANCE)
    (allowed-classes Menu)
    (create-accessor read-write))
)
