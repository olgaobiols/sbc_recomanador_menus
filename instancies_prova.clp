(definstances instancies-prova
  ([primer] of Ordre)
  ([principal] of Ordre)
  ([postre] of Ordre)

  ([vi-negre] of Beguda
    (nom "Vi negre criança")
    (preu_venta 12.0))

  ([plat-escalivada] of Plat
    (nom "Escalivada")
    (preu_venta 9.0)
    (formalitat "Tradicional")
    (temperatura "Fred")
    (te_ordre [primer]))

  ([plat-fricando] of Plat
    (nom "Fricandó de vedella")
    (preu_venta 20.0)
    (formalitat "Formal")
    (temperatura "Calent")
    (te_ordre [principal])
    (marida_amb [vi-negre]))

  ([plat-crema-catalana] of Plat
    (nom "Crema catalana")
    (preu_venta 14.0)
    (formalitat "Familiar")
    (temperatura "Fred")
    (te_ordre [postre]))
)
