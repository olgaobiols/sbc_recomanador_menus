;;; ---------------------------------------------------------
;;; Ontologia RicoRico (versió consensuada)
;;; Data: 25/10/2025
;;;
;;; Enums (SÍMBOLS, unificats):
;;;   Estacions:        primavera | estiu | tardor | hivern | tot_any
;;;   Formalitat:       formal | informal
;;;   Ordre:            primer | segon | postres     ; (multi-rol permès)
;;;   Complexitat:      baixa | mitjana | alta
;;;   Mida ració:       petita | mitjana | gran
;;;   Temperatura:      fred | tebi | calent
;;;   UE-14:            gluten llet ous peix crustacis molluscs fruits_secs
;;;                     cacauet soja api mostassa sesam sulfites tramussos
;;;   Dietes:           VG V HALAL KOSHER
;;;   Beguda mode:      general | per_plat
;;;   Alcohol:          si | no
;;;   Tags cuina:       carne peix vegetal sopa estofat pasta arros fregit forn planxa
;;;                     cru picant dolc acid fumat lleuger consistent
;;;   Categoria menú:   barat | mitja | car
;;;
;;; Notes:
;;; - Esdeveniment NO inclou beguda/alcohol (van a RestriccioClient).
;;; - La disponibilitat del PLAT es recomana derivar-la dels ingredients.
;;;   Si cal override manual, tens un multislot opcional al Plat.
;;; - Les referències Plat/Beguda dins Menu es guarden per NOM (STRING).
;;; ---------------------------------------------------------

(defclass Esdeveniment
  (is-a USER)
  (role concrete)
  (pattern-match reactive)
  (slot ocasio
    (type SYMBOL)
    (allowed-symbols boda baptisme comunio congres)
    (create-accessor read-write))
  (slot formalitat
    (type SYMBOL)
    (allowed-symbols formal informal)
    (create-accessor read-write))
  (slot epoca
    (type SYMBOL)
    (allowed-symbols primavera estiu tardor hivern)
    (create-accessor read-write))
  (slot interior
    (type SYMBOL)
    (allowed-symbols si no)
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
)

(defclass RestriccioClient
  (is-a USER)
  (role concrete)
  (pattern-match reactive)
  (multislot alergens_prohibits
    (type SYMBOL)
    (allowed-symbols
      gluten llet ous peix crustacis molluscs fruits_secs
      cacauet soja api mostassa sesam sulfites tramussos)
    (create-accessor read-write))
  (multislot dietes
    (type SYMBOL)
    (allowed-symbols VG V HALAL KOSHER)
    (create-accessor read-write))
  (slot beguda_mode
    (type SYMBOL)
    (allowed-symbols general per_plat)
    (create-accessor read-write))
  (slot alcohol
    (type SYMBOL)
    (allowed-symbols si no)
    (create-accessor read-write))
)

(defclass Ingredient
  (is-a USER)
  (role concrete)
  (pattern-match reactive)
  (slot nom
    (type STRING)
    (create-accessor read-write))
  (multislot alergens
    (type SYMBOL)
    (allowed-symbols
      gluten llet ous peix crustacis molluscs fruits_secs
      cacauet soja api mostassa sesam sulfites tramussos)
    (create-accessor read-write))
  (multislot dietes
    (type SYMBOL)
    (allowed-symbols VG V HALAL KOSHER)
    (create-accessor read-write))
  (multislot disponibilitat
    (type SYMBOL)
    (allowed-symbols primavera estiu tardor hivern tot_any)
    (create-accessor read-write))
)

(defclass Plat
  (is-a USER)
  (role concrete)
  (pattern-match reactive)
  (slot nom
    (type STRING)
    (create-accessor read-write))
  (multislot te_ordre
    (type SYMBOL)
    (allowed-symbols primer segon postres)
    (create-accessor read-write))
  (slot formalitat
    (type SYMBOL)
    (allowed-symbols formal informal)
    (create-accessor read-write))
  (slot temperatura
    (type SYMBOL)
    (allowed-symbols fred tebi calent)
    (create-accessor read-write))
  (slot complexitat
    (type SYMBOL)
    (allowed-symbols baixa mitjana alta)
    (create-accessor read-write))
  (slot mida_racio
    (type SYMBOL)
    (allowed-symbols petita mitjana gran)
    (create-accessor read-write))

  ; Override opcional (si no derives de ingredients, el pots usar)
  (multislot disponibilitat_plats
    (type SYMBOL)
    (allowed-symbols primavera estiu tardor hivern tot_any)
    (create-accessor read-write))

  (slot preu_cost
    (type FLOAT)
    (create-accessor read-write))

  ; TAGS per compatibilitat gestionada al MAIN
  (multislot tags
    (type SYMBOL)
    (allowed-symbols
      ; Proteïna
      carn peix marisc vegetal
      ; Tècnica / Tipus
      sopa estofat pasta arros fregit forn planxa brasa confitat cru
      ; Intensitat
      lleuger consistent
      ; Perfil
      picant dolc acid fumat xocolata citric)
    (create-accessor read-write))

  ; Ingredients per nom (derivaràs al·lergens/dietes/temporada)
  (multislot te_ingredients
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
    (allowed-symbols formal informal)
    (create-accessor read-write))
  (slot alcohol
    (type SYMBOL)
    (allowed-symbols si no)
    (create-accessor read-write))
  (slot preu_cost
    (type FLOAT)
    (create-accessor read-write))
  ; NOVETAT: per poder marcar begudes “per a tot el menú”
  (slot es_general
    (type SYMBOL)
    (allowed-symbols si no)
    (create-accessor read-write))
  ; NOVETAT: al·lèrgens i dietes de la beguda
  (multislot alergens
    (type SYMBOL)
    (allowed-symbols
      gluten llet ous peix crustacis molluscs fruits_secs
      cacauet soja api mostassa sesam sulfites tramussos)
    (create-accessor read-write))
  (multislot dietes
    (type SYMBOL)
    (allowed-symbols VG V HALAL KOSHER)
    (create-accessor read-write))
  ; IMPORTANT: tags alineats amb els del Plat
  (multislot marida_amb_tags
    (type SYMBOL)
    (allowed-symbols
      carn peix marisc vegetal
      sopa estofat pasta arros fregit forn planxa brasa confitat cru
      lleuger consistent
      picant dolc acid fumat xocolata citric)
    (create-accessor read-write))
  (multislot marida_amb_ordre
    (type SYMBOL)
    (allowed-symbols primer segon postres)
    (create-accessor read-write))
)


(defclass Menu
  (is-a USER)
  (role concrete)
  (pattern-match reactive)
  ; Plats pel seu NOM (STRING) — unicitat s'ha de garantir al MAIN
  (slot primer
    (type STRING)
    (create-accessor read-write))
  (slot segon
    (type STRING)
    (create-accessor read-write))
  (slot postres
    (type STRING)
    (create-accessor read-write))
  ; Beguda: o general, o per-ordre
  (slot beguda_general
    (type STRING)
    (default "")
    (create-accessor read-write))
  (slot beguda_primer
    (type STRING)
    (default "")
    (create-accessor read-write))
  (slot beguda_segon
    (type STRING)
    (default "")
    (create-accessor read-write))
  (slot beguda_postres
    (type STRING)
    (default "")
    (create-accessor read-write))
  (slot preu_total_pp
    (type FLOAT)
    (create-accessor read-write))
  (slot categoria
    (type SYMBOL)
    (allowed-symbols barat mitja car)
    (create-accessor read-write))
  (multislot justificacio
    (type STRING)
    (create-accessor read-write))
)

