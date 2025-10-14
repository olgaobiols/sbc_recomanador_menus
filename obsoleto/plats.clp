;;; PLATS ;;;
(make-instance hamburguesa
   of Plat
   (nom "Hamburguesa clàssica")
   (ingredients beef cheese bun)
   (mida-racio "mitjana")
   (complexitat "mitjana")
   (formalitat "informal")
   (puntuacio 4.5)
)

(make-instance hamburguesa-tofu
   of Plat
   (nom "Hamburguesa de tofu")
   (ingredients tofu lettuce tomato gluten-free-bun)
   (mida-racio "mitjana")
   (complexitat "mitjana")
   (formalitat "informal")
   (puntuacio 4.0)
)

(make-instance hamburguesa-sense-gluten
   of Plat
   (nom "Hamburguesa sense gluten")
   (ingredients beef cheese gluten-free-bun)
   (mida-racio "mitjana")
   (complexitat "mitjana")
   (formalitat "informal")
   (puntuacio 4.3)
)


;;; substituts ;;;
(modify hamburguesa
   (substituts (create$ hamburguesa-tofu hamburguesa-sense-gluten))
)
