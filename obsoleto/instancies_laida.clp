;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fitxer: instancies.clp
;; Exemple d'instancies per provar l'ontologia
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ========== INGREDIENTS ==========

(make-instance tomàquet of Ingredient
   (nom "Tomàquet")
   (estacio "estiu")
   (compleix_restriccions "vegà")
)

(make-instance enciam of Ingredient
   (nom "Enciam")
   (estacio "primavera")
   (compleix_restriccions "vegà")
)

(make-instance pollastre of Ingredient
   (nom "Pollastre")
   (estacio "totes")
   (compleix_restriccions "sense-gluten")
)

(make-instance tofu of Ingredient
   (nom "Tofu")
   (estacio "totes")
   (compleix_restriccions "vegà")
)

(make-instance pa of Ingredient
   (nom "Pa")
   (estacio "totes")
   (compleix_restriccions "conté-gluten")
)

(make-instance pa-sense-gluten of Ingredient
   (nom "Pa sense gluten")
   (estacio "totes")
   (compleix_restriccions "sense-gluten")
)

(make-instance xocolata of Ingredient
   (nom "Xocolata")
   (estacio "totes")
   (compleix_restriccions "vegetarià")
)

(make-instance llet of Ingredient
   (nom "Llet")
   (estacio "totes")
   (compleix_restriccions "no-vegà")
)

(make-instance maduixes of Ingredient
   (nom "Maduixes")
   (estacio "primavera")
   (compleix_restriccions "vegà")
)

;; ========== BEGUDES ==========

(make-instance aigua of Beguda
   (nom "Aigua mineral")
   (formalitat "neutra")
   (preu "1")
   (compleix_restriccions "totes")
   (putuacio 5.0)
)

(make-instance vi-negre of Beguda
   (nom "Vi negre")
   (formalitat "formal")
   (preu "8")
   (compleix_restriccions "vegetarià")
   (putuacio 4.5)
)

(make-instance cervesa of Beguda
   (nom "Cervesa artesana")
   (formalitat "informal")
   (preu "3")
   (compleix_restriccions "conté-gluten")
   (putuacio 4.2)
)

;; ========== PLATS ==========

;; --- Primers plats ---
(make-instance amanida-verda of Plat
   (nom "Amanida verda")
   (ingredients (create$ tomàquet enciam))
   (mida-racio "petita")
   (complexitat "baixa")
   (formalitat "informal")
   (putuacio 4.3)
)

(make-instance sopa-verdures of Plat
   (nom "Sopa de verdures")
   (ingredients (create$ tomàquet enciam))
   (mida-racio "mitjana")
   (complexitat "baixa")
   (formalitat "formal")
   (putuacio 4.0)
)

;; --- Segons plats ---
(make-instance pollastre-planxa of Plat
   (nom "Pollastre a la planxa amb pa")
   (ingredients (create$ pollastre pa))
   (mida-racio "gran")
   (complexitat "baixa")
   (formalitat "informal")
   (putuacio 4.4)
)

(make-instance tofu-planxa of Plat
   (nom "Tofu a la planxa amb pa sense gluten")
   (ingredients (create$ tofu pa-sense-gluten))
   (mida-racio "gran")
   (complexitat "baixa")
   (formalitat "informal")
   (putuacio 4.2)
)

;; Assignem substituts
(modify pollastre-planxa
   (substitut (create$ tofu-planxa))
)

;; --- Postres ---
(make-instance maduixes-xocolata of Plat
   (nom "Maduixes amb xocolata")
   (ingredients (create$ maduixes xocolata))
   (mida-racio "petita")
   (complexitat "baixa")
   (formalitat "formal")
   (putuacio 4.8)
)

(make-instance mousse-xocolata of Plat
   (nom "Mousse de xocolata amb llet")
   (ingredients (create$ xocolata llet))
   (mida-racio "petita")
   (complexitat "mitjana")
   (formalitat "formal")
   (putuacio 4.5)
)

(modify mousse-xocolata
   (substitut (create$ maduixes-xocolata))
)

;; ========== MENÚS ==========

(make-instance menu-diari of Menu
   (nom "Menú diari tradicional")
   (primer_plat "Amanida verda")
   (segon_plat "Pollastre a la planxa amb pa")
   (postres "Maduixes amb xocolata")
   (beguda (create$ aigua cervesa))
   (preu 15)
   (putuacio 4.4)
)

(make-instance menu-vegà of Menu
   (nom "Menú vegetarià complet")
   (primer_plat "Sopa de verdures")
   (segon_plat "Tofu a la planxa amb pa sense gluten")
   (postres "Maduixes amb xocolata")
   (beguda (create$ aigua vi-negre))
   (preu 18)
   (putuacio 4.6)
)