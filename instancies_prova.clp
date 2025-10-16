(definstances beguda-instances
  (vi-blanc of Beguda
    (nom "Vi blanc jove")
    (preu_cost 4.2)
    (alcohol si)                
    (formalitat "formal")
    (procedencia "Penedès")
  )
)

(definstances comensal-instances
  (maria-comensal of Comensal
    (nom "Maria")
    (edat 25)
    (restriccions-alergen gluten lactosa)
  )
)

(definstances ingredient-instances
  (pastanaga of Ingredient
    (nom "Pastanaga")
    (alergens)                   
    (preu_cost 0.25)
    (alternativa_restriccio "carbassó")
    (disponibilitat "sempre") 
  )
)

(definstances ordre-instances
  (ordre-primer of Ordre)
  (ordre-segon  of Ordre)
  (ordre-postres of Ordre)
)
  
(definstances menu-instances
  (menu-formal-1 of Menu
    (nom "Menú Formal 1")
    (tipus_cuina "mediterrània")
  )
)

(definstances plat-instances
  (plat-escalivada of Plat
    (nom "Escalivada")
    (formalitat "formal")
    (temperatura "Fred")
    (alergens lactosa)           
    (complexitat baixa)
    (mida_racio mitja)
    (procedencia "Catalunya")
  )
)


