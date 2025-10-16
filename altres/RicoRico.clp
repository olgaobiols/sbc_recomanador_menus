
; #########################################
; ############### ONTOLOGIA ###############
; #########################################

(defclass Bebida "Guarda la información referente a una bebida."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Restricciones alimentarias que cumple el ingrediente.
    (multislot CumpleRestricciones
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Indica si las bebidas del menu generado son o no alcoholicas.
    (single-slot BebidaAlcoholica
        (type SYMBOL)
        (create-accessor read-write))
    ;;; Precio del producto.
    (single-slot Precio
        (type FLOAT)
        (create-accessor read-write))
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
    ;;; Bebidas incompatibles con una bebida en concreto
    (multislot BebidasIncompatibles
        (type INSTANCE)
        (create-accessor read-write))
)

(defclass Ingrediente "Guarda la información referente a un ingrediente."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Restricciones alimentarias que cumple el ingrediente.
    (multislot CumpleRestricciones
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
    ;;; Lista de temporadas donde el producto está disponible.
    (multislot Disponibilidad
        (type INSTANCE)
        (create-accessor read-write))
)

(defclass Plato "Guarda la información referente a un plato. Esta es la clase alrededor de la qual se envuelve toda la ontología."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; La complejidad del plato indica si es apropiado o no servirlo para un número elevado de comensales.
    (single-slot Complejidad
        (type INTEGER)
        (create-accessor read-write))
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
    ;;; Ingredientes de los que se compone el plato.
    (multislot Ingredientes
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Preferencias que el plato satisface.
    (multislot CumplePreferencias
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Descripción general del plato.
    (single-slot InfoGeneral
        (type STRING)
        (create-accessor read-write))
    ;;; Precio del producto.
    (single-slot Precio
        (type FLOAT)
        (create-accessor read-write))
    ;;; Lista de platos no compatibles con el plato.
    (multislot PlatosIncompatibles
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Indica si el plato es considerado un primero, un segundo, ambos, o un postre.
    (single-slot TipoEnMenu
        (type STRING)
        (create-accessor read-write))
    ;;; Bebidas que acompañan bien al plato.
    (multislot BebidasRecomendadas
        (type INSTANCE)
        (create-accessor read-write))
)

(defclass Menu "Recoge la información de la construcción de un menú hecha por el programa, una instancia representa una posible parte de la solución que se enseña al usuario. Inicialmente no tiene instancias."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Segundo plato del menú.
    (single-slot Segundo
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Indica el nivel de satisfacción de preferencias del usuario que tiene el menú.
    (single-slot PuntuacionMenu
        (type INTEGER)
        (create-accessor read-write))
    ;;; Lista de bebidas del menú propuesto: una por plato si así lo ha pedido el usuario o sino sólo una.
    (multislot Bebidas
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Precio del producto.
    (single-slot Precio
        (type FLOAT)
        (create-accessor read-write))
    ;;; Plato de postre del menú.
    (single-slot Postre
        (type INSTANCE)
        (create-accessor read-write))
    ;;; Primer plato del menú.
    (single-slot Primero
        (type INSTANCE)
        (create-accessor read-write))
)

(defclass Preferencia "Guarda nombres de preferencias alimentarias. Los menús generados intentarán satisfacer (no obligadamente) el mayor número de éstas. Las instancias de esta clase estan definidas inicialmente y se pregunta al usuario que escoja un subconjunto de éstas para personalizar los menús."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
)

(defclass Temporada "Guarda el nombre de una temporada concreta. Hay un conjunto de instancias iniciales que cubren todas las temporadas en las que funciona el restaurante."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
)

(defclass RestriccionAlimentaria "Guarda el nombre de restricciones alimentarias de cumplimiento obligatorio, como pueden ser alérgias, intolerancias o que sea vegetariano. La solución propuesta debe contener sólamente ingredientes que cumplan las restricciones indicadas, que se preguntarán al usuario."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Nombre
        (type STRING)
        (create-accessor read-write))
)

(definstances instances
    ([Ensalada_griega] of Plato
         (Complejidad  32)
         (Nombre  "Ensalada griega")
         (Ingredientes  [atún] [aceite_de_oliva] [pimiento_verde] [cebolla] [queso] [pepino] [pimiento_rojo] [romero] [pasta] [sal] [aceituna] [orégano] [vinagre])
         (CumplePreferencias  [moderno])
         (InfoGeneral  "Plato frio de ensalada de pasta, verduras, queso y atún")
         (Precio  7.75)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Agua] [Copa_de_vino_blanco_Penedès] [Copa_de_vino_tinto_Vivanco] [Copa_de_sangría])
    )

    ([Copa_de_vino_blanco_Penedès] of Bebida
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_gluten] [intolerancia_lactosa])
         (BebidaAlcoholica  TRUE)
         (Precio  3.50)
         (Nombre  "Copa de vino blanco D.O. Penedès")
    )

    ([pollo] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Pollo")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([pera] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [vegetariano] [intolerancia_lactosa])
         (Nombre  "Pera")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([almidón] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [vegetariano])
         (Nombre  "Almidón")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([apio] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten] [vegano] [vegetariano])
         (Nombre  "Apio")
         (Disponibilidad  [otoño] [primavera] [verano] [invierno])
    )

    ([intolerancia_lactosa] of RestriccionAlimentaria
         (Nombre  "Intolerancia a la lactosa")
    )

    ([vinagre] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Vinagre")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([Refresco_Fanta] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (BebidaAlcoholica  FALSE)
         (Precio  2.20)
         (Nombre  "Refresco Fanta")
         (BebidasIncompatibles [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier])
    )

    ([Brownie] of Plato
         (Complejidad  35)
         (Nombre  "Brownie")
         (Ingredientes  [azúcar] [mantequilla] [harina] [sal] [chocolate] [frutos_secos] [huevo])
         (InfoGeneral  "Brownie casero con nueces y chocolate")
         (Precio  8.00)
         (TipoEnMenu  "postre")
         (CumplePreferencias [clásico] [moderno])
    )

    ([Cerveza_Estrella_Damm] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [vegano])
         (BebidaAlcoholica  TRUE)
         (Precio  2.50)
         (Nombre  "Cerveza Estrella Damm")
    )

    ([Ensalada_de_queso_de_cabra_y_nueces] of Plato
         (Complejidad  20)
         (Nombre  "Ensalada de queso de cabra y nueces")
         (Ingredientes  [sal] [frutos_secos] [lechuga] [vinagre] [cebolla] [zanahoria] [queso] [aceite_de_oliva])
         (CumplePreferencias  [moderno])
         (InfoGeneral  "Plato vegetariano frío de verdura y queso")
         (Precio  8.50)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Copa_de_vino_tinto_Vivanco] [Agua] [Copa_de_vino_blanco_Empordà] [Cerveza_Daura])
    )

    ([Revuelto_de_espinacas_y_langostinos] of Plato
         (Complejidad  25)
         (Nombre  "Revuelto de espinacas y langostinos")
         (Ingredientes  [langostino] [guindilla] [sal] [ajo] [queso] [huevo] [espinaca] [aceite_de_oliva])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Plato caliente de verdura y pescado")
         (Precio  13.50)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Copa_de_vino_rosado_Los_Frailes] [Copa_de_vino_tinto_Vivanco] [Cava_Anna_de_Codorniu] [Agua])
    )

    ([leche] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_gluten])
         (Nombre  "Leche")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([huevo] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Huevo")
         (Disponibilidad  [invierno] [otoño] [verano] [primavera])
    )

    ([Poke_bowl_vegano] of Plato
         (Complejidad  35)
         (Nombre  "Poke bowl vegano")
         (Ingredientes  [cebolla] [soja_texturizada] [arroz] [tomate] [salsa_de_soja] [aguacate])
         (CumplePreferencias  [moderno])
         (InfoGeneral  "Plato vegano frío de arroz y verdura")
         (Precio  10.00)
         (PlatosIncompatibles  [Poke_bowl_vegano])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Agua] [Agua_con_gas] [Zumo_natural] [Copa_de_vino_rosado_Los_Frailes])
    )

    ([gambas__rojas] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Gambas rojas")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([café] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [vegetariano] [intolerancia_lactosa])
         (Nombre  "Café")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([seta] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Seta")
         (Disponibilidad  [invierno] [otoño])
    )

    ([lima] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Lima")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([Taco_cristalizado_de_mojito_y_menta] of Plato
         (Complejidad  50)
         (Nombre  "Taco cristalizado de mojito y menta")
         (Ingredientes  [azúcar] [agua] [mango] [menta] [ron] [lima] [melón] [agar_agar])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Postre frío, taco de azúcar cristalizado de lima, melón menta y mango")
         (Precio  26.50)
         (TipoEnMenu  "postre")
    )

    ([lechuga] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Lechuga")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([rucula] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Rúcula")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([albahaca] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Albahaca")
         (Disponibilidad  [verano] [otoño] [primavera] [invierno])
    )

    ([Refresco_Nestea] of Bebida
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (BebidaAlcoholica  FALSE)
         (Precio  2.20)
         (Nombre  "Refresco Nestea")
         (BebidasIncompatibles [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier])
    )

    ([berenjena] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Berenjena")
         (Disponibilidad  [invierno] [otoño])
    )

    ([azúcar] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Azúcar")
         (Disponibilidad  [verano] [invierno] [otoño] [primavera])
    )

    ([guindilla] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Guindilla")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([otoño] of Temporada
         (Nombre  "Otoño")
    )

    ([patata] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten] [vegetariano] [vegano])
         (Nombre  "Patata")
         (Disponibilidad  [invierno] [otoño] [verano] [primavera])
    )

    ([Tiramisú] of Plato
         (Complejidad  35)
         (Nombre  "Tiramisú")
         (Ingredientes  [azúcar] [huevo] [queso] [café] [almidón] [harina] [sal] [cacao])
         (InfoGeneral  "Tiramisú casero")
         (Precio  8.00)
         (TipoEnMenu  "postre")
         (CumplePreferencias [regional] [clásico] [sibarita])
    )

    ([nabo] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano] [vegano] [intolerancia_lactosa])
         (Nombre  "Nabo")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([Copa_de_sangría] of Bebida
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (BebidaAlcoholica  TRUE)
         (Precio  4.00)
         (Nombre  "Copa de Sangría")
    )

    ([queso] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano])
         (Nombre  "Queso")
         (Disponibilidad  [invierno] [verano] [otoño] [primavera])
    )

    ([ron] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (Nombre  "Ron")
         (Disponibilidad  [invierno] [primavera] [otoño] [verano])
    )

    ([pimienta] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten] [vegetariano] [vegano])
         (Nombre  "Pimienta")
         (Disponibilidad  [invierno] [otoño] [primavera] [verano])
    )

    ([Refresco_Aquarius] of Bebida
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (BebidaAlcoholica  FALSE)
         (Precio  2.20)
         (Nombre  "Refresco Aquarius")
         (BebidasIncompatibles [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier])
    )

    ([regional] of Preferencia
         (Nombre  "Estilo regional")
    )

    ([Cerveza_Daura] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [intolerancia_gluten] [vegetariano])
         (BebidaAlcoholica  TRUE)
         (Precio  2.70)
         (Nombre  "Cerveza Daura (Sin Gluten)")
    )

    ([melón] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Melón")
         (Disponibilidad [otoño] [verano])
    )

    ([esparrago] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [intolerancia_gluten] [vegetariano])
         (Nombre  "Espárrago")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([primavera] of Temporada
         (Nombre  "Primavera")
    )

    ([Mariscada_de_calamares_y_langostinos] of Plato
         (Complejidad  40)
         (Nombre  "Mariscada de calamares y langostinos")
         (Ingredientes  [perejil] [romero] [langostino] [sal] [calamar] [cebolla] [vino_blanco] [aceite_de_oliva])
         (CumplePreferencias  [clásico] [sibarita])
         (InfoGeneral  "Plato frío de pescado")
         (Precio  25.00)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier] [Copa_de_vino_tinto_Vivanco] [Agua])
    )

    ([trufa] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (Nombre  "Trufa")
         (Disponibilidad  [otoño] [invierno])
    )

    ([Bocadillo_de_tortilla_de_patata] of Plato
         (Complejidad  5)
         (Nombre  "Bocadillo de tortilla de patata")
         (Ingredientes  [tomate] [huevo] [pan] [aceite_de_oliva] [patata])
         (CumplePreferencias  [regional] [clásico])
         (InfoGeneral  "Plato caliente, pan con tortilla de patata, aceite y tomate")
         (Precio  3.00)
         (PlatosIncompatibles  [Bocadillo_de_butifarra] [Bocadillo_de_tortilla_de_patata])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Refresco_Coca_Cola] [Refresco_Aquarius] [Agua] [Agua_con_gas])
    )

    ([Risotto_de_setas] of Plato
         (Complejidad  60)
         (Nombre  "Risotto de setas")
         (Ingredientes  [sal] [pimienta] [seta] [arroz] [caldo_de_verduras] [ajo] [vino_blanco] [cebolla])
         (CumplePreferencias  [moderno] [sibarita])
         (InfoGeneral  "Plato vegano caliente de pasta")
         (Precio  14.00)
         (PlatosIncompatibles  [Risotto_de_setas])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Copa_de_sangría] [Agua] [Copa_de_vino_blanco_Empordà] [Agua_con_gas])
    )

    ([zanahoria] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten] [vegetariano] [vegano])
         (Nombre  "Zanahoria")
         (Disponibilidad  [verano] [otoño] [primavera] [invierno])
    )

    ([ñoquis] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Ñoquis")
         (Disponibilidad  [invierno] [otoño] [primavera] [verano])
    )

    ([agar_agar] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Agar Agar")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([espinaca] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [intolerancia_lactosa] [vegano] [vegetariano])
         (Nombre  "Espinacas")
         (Disponibilidad  [otoño] [primavera] [verano] [invierno])
    )

    ([mango] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [vegano] [intolerancia_gluten])
         (Nombre  "Mango")
         (Disponibilidad  [otoño] [invierno] [verano] [primavera])
    )

    ([Copa_de_vino_tinto_Fuenteseca] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [intolerancia_gluten] [vegetariano])
         (BebidaAlcoholica  TRUE)
         (Precio  3.00)
         (Nombre  "Copa de vino tinto Fuenteseca")
    )

    ([caldo_de_verduras] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Caldo de verduras")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([chocolate] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano])
         (Nombre  "Chocolate")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([lentejas] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Lentejas")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([Arroz_a_la_cubana] of Plato
         (Complejidad  45)
         (Nombre  "Arroz a la cubana")
         (Ingredientes  [plátano] [sal] [arroz] [tomate] [ajo] [aceite_de_oliva] [agua] [huevo])
         (CumplePreferencias  [clásico] [regional])
         (InfoGeneral  "Plato caliente de arroz con huevo y platano")
         (Precio  11.25)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Agua] [Copa_de_vino_tinto_Fuenteseca] [Cerveza_Daura] [Cerveza_Estrella_Galicia_1906] [Cerveza_Estrella_Damm] [Cerveza_Moritz])
    )

    ([agua] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Agua")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([verano] of Temporada
         (Nombre  "Verano")
    )

    ([ternera] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Ternera")
         (Disponibilidad  [verano] [invierno] [otoño] [primavera])
    )

    ([Copa_de_vino_blanco_Empordà] of Bebida
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (BebidaAlcoholica  TRUE)
         (Precio  4.50)
         (Nombre  "Copa de vino blanco D.O. Empordà")
    )

    ([ajo] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Ajo")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([soja_texturizada] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Soja texturizada")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

    ([mantequilla] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano])
         (Nombre  "Mantequilla")
         (Disponibilidad  [verano] [otoño] [invierno] [primavera])
    )

    ([gelatina_en_hoja] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Gelatina en hoja")
         (Disponibilidad  [invierno] [verano] [otoño] [primavera])
    )

    ([sibarita] of Preferencia
         (Nombre  "Estilo sibarita")
    )

    ([clásico] of Preferencia
         (Nombre  "Estilo clásico")
    )

    ([vegetariano] of RestriccionAlimentaria
         (Nombre  "Vegetariano/a")
    )

    ([manzana] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [vegetariano] [intolerancia_lactosa])
         (Nombre  "Manzana")
         (Disponibilidad  [verano] [primavera] [otoño] [invierno])
    )

    ([Pasta_al_pesto] of Plato
         (Complejidad  25)
         (Nombre  "Pasta al pesto")
         (Ingredientes  [ajo] [perejil] [albahaca] [aceite_de_oliva] [pasta] [sal] [frutos_secos])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Plato vegano caliente de pasta")
         (Precio  7.75)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Agua] [Agua_con_gas] [Copa_de_vino_rosado_Los_Frailes] [Copa_de_sangría])
    )

    ([naranja] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Naranja")
         (Disponibilidad  [otoño] [verano] [invierno] [primavera])
    )

    ([aceite_de_oliva] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [vegano] [intolerancia_gluten])
         (Nombre  "Aceite de oliva virgen extra")
         (Disponibilidad  [otoño] [invierno] [primavera] [verano])
    )

    ([Ñoquis_con_kale_y_frutos_secos] of Plato
         (Complejidad  18)
         (Nombre  "Ñoquis con kale y frutos secos")
         (Ingredientes  [sal] [frutos_secos] [col] [ajo] [ñoquis] [aceite_de_oliva])
         (CumplePreferencias  [moderno] [regional])
         (InfoGeneral  "Plato caliente vegano")
         (Precio  11.50)
         (PlatosIncompatibles  [Ñoquis_con_kale_y_frutos_secos])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Cerveza_Moritz] [Cerveza_Daura] [Agua_con_gas] [Agua] [Copa_de_sangría] [Copa_de_vino_blanco_Penedès])
    )

    ([Copa_de_vino_rosado_Los_Frailes] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [intolerancia_gluten] [vegetariano])
         (BebidaAlcoholica  TRUE)
         (Precio  3.50)
         (Nombre  "Copa de vino rosado Los Frailes")
    )

    ([harina] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Harina")
         (Disponibilidad  [otoño] [invierno] [verano] [primavera])
    )

    ([vino_blanco] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [vegano] [intolerancia_gluten])
         (Nombre  "Vino blanco")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([cacao] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Cacao")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

    ([invierno] of Temporada
         (Nombre  "Invierno")
    )

    ([Macarrones_con_chorizo] of Plato
         (Complejidad  30)
         (Nombre  "Macarrones con chorizo")
         (Ingredientes  [pasta] [sal] [huevo] [tomate] [queso] [aceite_de_oliva] [agua] [chorizo])
         (CumplePreferencias  [regional] [clásico])
         (InfoGeneral  "Plato caliente de pasta y carne")
         (Precio  8.50)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Cerveza_Estrella_Damm] [Refresco_Nestea] [Refresco_Aquarius] [Agua] [Copa_de_vino_tinto_Fuenteseca] [Copa_de_sangría])
    )

    ([hummus] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Hummus")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([fresa] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Fresas")
         (Disponibilidad  [primavera] [verano])
    )

    ([pimiento_rojo] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano] [intolerancia_lactosa] [vegano])
         (Nombre  "Pimiento rojo")
         (Disponibilidad  [invierno] [otoño] [verano] [primavera])
    )

    ([arroz] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [vegano] [intolerancia_gluten])
         (Nombre  "Arroz")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([pepino] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [vegetariano] [intolerancia_lactosa])
         (Nombre  "Pepino")
         (Disponibilidad  [invierno] [otoño] [primavera] [verano])
    )

    ([romero] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Romero")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([perejil] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [vegano] [intolerancia_gluten])
         (Nombre  "Perejil")
         (Disponibilidad  [otoño] [primavera] [verano] [invierno])
    )

    ([salsa_de_soja] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Salsa de soja")
         (Disponibilidad  [invierno] [otoño] [primavera] [verano])
    )

    ([Risotto_de_setas_y_trufas] of Plato
         (Complejidad  60)
         (Nombre  "Risotto de setas y trufas")
         (Ingredientes  [trufa] [sal] [pimienta] [seta] [arroz] [caldo_de_verduras] [ajo] [queso] [aceite_de_oliva] [cebolla])
         (CumplePreferencias  [sibarita] [clásico])
         (InfoGeneral  "Plato caliente, risotto con setas y exquisitas trufas negras")
         (Precio  40.00)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Copa_de_vino_blanco_Penedès] [Copa_de_vino_blanco_Empordà] [Champagne_Renard-Barnier] [Agua] [Agua_con_gas] [Cava_Anna_de_Codorniu])
    )

    ([Canelones_de_pollo] of Plato
         (Complejidad  75)
         (Nombre  "Canelones de pollo")
         (Ingredientes  [cebolla] [queso] [aceite_de_oliva] [pimentón_dulce] [mantequilla] [pasta] [pollo] [leche] [harina] [sal] [tomate] [ajo])
         (CumplePreferencias  [clásico] [regional])
         (InfoGeneral  "Plato caliente de pasta y carne")
         (Precio  14.50)
         (PlatosIncompatibles  [Canelones_de_pollo])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Agua] [Copa_de_vino_tinto_Fuenteseca] [Copa_de_sangría] [Copa_de_vino_rosado_Los_Frailes] [Cerveza_Moritz])
    )

    ([cereza] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Cerezas")
         (Disponibilidad  [primavera] [verano])
    )

    ([wagyu] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Carne de Wagyu")
         (Disponibilidad  [invierno] [verano] [otoño] [primavera])
    )

    ([atún] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Atún")
         (Disponibilidad  [primavera] [verano] [invierno] [otoño])
    )

    ([Tacos_de_hummus_con_aguacate] of Plato
         (Complejidad  15)
         (Nombre  "Tacos de hummus con aguacate")
         (Ingredientes  [pepino] [aceite_de_oliva] [sal] [tortillas] [lechuga] [hummus] [aguacate])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Plato frío vegano")
         (Precio  10.75)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Copa_de_vino_tinto_Fuenteseca] [Agua] [Copa_de_vino_blanco_Penedès] [Zumo_natural])
    )

    ([butifarra] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Butifarra")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

    ([Melón] of Plato
         (Complejidad  4)
         (Nombre  "Melón")
         (Ingredientes  [melón])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Fruta de temporada")
         (Precio  3.00)
         (TipoEnMenu  "postre")
         (PlatosIncompatibles  [Melón_con_jamón])
    )

    ([frutos_secos] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (Nombre  "Frutos secos")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([jamón] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Jamón")
         (Disponibilidad  [verano] [otoño] [primavera] [invierno])
    )

    ([Cerezas] of Plato
         (Complejidad  3)
         (Nombre  "Cerezas")
         (Ingredientes  [cereza])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Fruta de temporada")
         (Precio  4.00)
         (TipoEnMenu  "postre")
    )

    ([Bocadillo_de_butifarra] of Plato
         (Complejidad  5)
         (Nombre  "Bocadillo de butifarra")
         (Ingredientes  [tomate] [aceite_de_oliva] [butifarra] [pan])
         (CumplePreferencias  [regional] [clásico])
         (InfoGeneral  "Bocadillo caliente de butifarra con pan con tomate y aceite")
         (Precio  3.50)
         (PlatosIncompatibles  [Bocadillo_de_butifarra] [Bocadillo_de_tortilla_de_patata])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Refresco_Nestea] [Refresco_Aquarius] [Agua] [Refresco_Fanta])
    )

    ([pan] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa])
         (Nombre  "Pan")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([calamar] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Calamar")
         (Disponibilidad  [primavera] [invierno] [otoño])
    )

    ([granada] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Granada")
         (Disponibilidad  [invierno])
    )

    ([plátano] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Plátano")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

    ([salmón] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Salmón")
         (Disponibilidad  [primavera] [invierno] [verano] [otoño])
    )

    ([Espaguetis_a_la_napolitana] of Plato
         (Complejidad  10)
         (Nombre  "Espaguetis a la napolitana")
         (Ingredientes  [tomate] [sal] [aceite_de_oliva] [pasta])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Plato caliente de pasta con salsa de tomate")
         (Precio  4.00)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Agua] [Copa_de_vino_blanco_Penedès] [Refresco_Fanta] [Refresco_Nestea] [Refresco_Aquarius] [Refresco_Coca_Cola] [Agua_con_gas])
    )

    ([tortillas] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Tortillas de tacos")
         (Disponibilidad  [primavera] [invierno] [verano] [otoño])
    )

    ([Solomillo_de_Wagyu_con_verduras_salteadas] of Plato
         (Complejidad  30)
         (Nombre  "Solomillo de Wagyu con verduras salteadas")
         (Ingredientes  [zanahoria] [salsa_de_soja] [pimiento_rojo] [aceite_de_oliva] [cebolla] [sal] [wagyu])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Solomillo de la famosa carne Wagyu con un salteado de verduras con salsa de soja")
         (Precio  50.00)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Copa_de_vino_tinto_Vivanco] [Copa_de_vino_tinto_Fuenteseca] [Agua] [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier])
    )

    ([sal] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegano] [intolerancia_gluten] [vegetariano])
         (Nombre  "Sal")
         (Disponibilidad  [primavera] [invierno] [verano] [otoño])
    )

    ([Hamburguesa_vegana_de_lentejas] of Plato
         (Complejidad  50)
         (Nombre  "Hamburguesa vegana de lentejas")
         (Ingredientes  [sal] [patata] [frutos_secos] [arroz] [lentejas] [tomate] [ajo] [cebolla] [pan])
         (CumplePreferencias  [moderno])
         (InfoGeneral  "Plato caliente vegano")
         (Precio  12.50)
         (PlatosIncompatibles  [Hamburguesa_vegana_de_lentejas])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Cerveza_Estrella_Damm] [Cerveza_Daura] [Agua] [Agua_con_gas] [Refresco_Fanta] [Refresco_Nestea] [Refresco_Coca_Cola])
    )

    ([Agua_con_gas] of Bebida
         (CumpleRestricciones  [vegano] [intolerancia_gluten] [vegetariano] [intolerancia_lactosa])
         (BebidaAlcoholica  FALSE)
         (Precio  1.60)
         (Nombre  "Agua con gas")
    )

    ([pimentón_dulce] of Ingrediente
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [intolerancia_gluten] [vegetariano])
         (Nombre  "Pimentón dulce")
         (Disponibilidad  [invierno] [otoño] [verano] [primavera])
    )

    ([tomate] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Tomate")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

    ([Berenjenas_rellenas_gratinadas] of Plato
         (Complejidad  60)
         (Nombre  "Berenjenas rellenas gratinadas")
         (Ingredientes  [atún] [queso] [cebolla] [aceite_de_oliva] [calabacín] [sal] [berenjena])
         (CumplePreferencias  [moderno] [regional])
         (InfoGeneral  "Plato caliente de pescado y verdura")
         (Precio  14.00)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Copa_de_vino_blanco_Penedès] [Copa_de_vino_rosado_Los_Frailes] [Copa_de_sangría] [Agua])
    )

    ([pimiento_verde] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [intolerancia_gluten] [vegano])
         (Nombre  "Pimiento verde")
         (Disponibilidad  [verano] [invierno] [otoño] [primavera])
    )

    ([uva] of Ingrediente
         (CumpleRestricciones  [vegano] [vegetariano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Uvas")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([menta] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [vegano] [intolerancia_gluten])
         (Nombre  "Menta")
         (Disponibilidad  [verano] [primavera] [otoño])
    )

    ([Parrillada_de_verduras] of Plato
         (Complejidad  70)
         (Nombre  "Parrillada de gelatina de verduras")
         (Ingredientes  [gelatina_en_hoja] [zanahoria] [agar_agar] [aceite_de_oliva] [nabo] [cebolla] [pimiento_verde] [pimiento_rojo] [apio] [esparrago] [sal])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Plato frío sibarita, de gelatinas hechas de verduras")
         (Precio  35.50)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Copa_de_vino_rosado_Los_Frailes] [Champagne_Renard-Barnier] [Copa_de_vino_tinto_Vivanco] [Agua] [Cava_Anna_de_Codorniu])
    )

    ([orégano] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Orégano")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([intolerancia_gluten] of RestriccionAlimentaria
         (Nombre  "Intolerancia al gluten")
    )

    ([Copa_de_vino_tinto_Vivanco] of Bebida
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa] [intolerancia_gluten])
         (BebidaAlcoholica  TRUE)
         (Precio  4.00)
         (Nombre  "Copa de vino tinto Vivanco")
    )

    ([Batido_de_fresa_y_plátano] of Plato
         (Complejidad  6)
         (Nombre  "Batido mediano de fresa y plátano frescos")
         (Ingredientes  [fresa] [plátano] [leche])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Batido fresco de fresa y plátano")
         (Precio  7.00)
         (TipoEnMenu  "postre")
    )

    ([Salmón_al_horno_con_patata] of Plato
         (Complejidad  45)
         (Nombre  "Salmón al horno con patata")
         (Ingredientes  [sal] [patata] [salmón] [ajo] [cebolla] [aceite_de_oliva])
         (CumplePreferencias  [moderno] [sibarita])
         (InfoGeneral  "Plato caliente de pescado")
         (Precio  13.00)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Copa_de_vino_blanco_Empordà] [Agua] [Copa_de_vino_rosado_Los_Frailes] [Cava_Anna_de_Codorniu])
    )

    ([chorizo] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Chorizo")
         (Disponibilidad  [primavera] [invierno] [otoño] [verano])
    )

    ([Espaguetis_con_mozzarella_albahaca_y_tomate] of Plato
         (Complejidad  20)
         (Nombre  "Espaguetis con mozzarella albahaca y tomate")
         (Ingredientes  [sal] [orégano] [tomate] [queso] [aceite_de_oliva] [albahaca] [pasta])
         (CumplePreferencias  [clásico])
         (InfoGeneral  "Plato vegetariano templado de pasta")
         (Precio  11.25)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Cerveza_Estrella_Galicia_1906] [Cerveza_Daura] [Refresco_Aquarius] [Agua] [Cerveza_Moritz])
    )

    ([judía] of Ingrediente
         (CumpleRestricciones  [vegetariano] [intolerancia_gluten] [vegano] [intolerancia_lactosa])
         (Nombre  "Judía")
         (Disponibilidad  [primavera] [verano] [otoño] [invierno])
    )

    ([Carpaccio_de_gamba_con_nougatine_de_curry_y_boletus] of Plato
         (Complejidad  90)
         (Nombre  "Carpaccio de gamba con nougatine de curry y boletus")
         (Ingredientes  [cebolla] [aceite_de_oliva] [gambas__rojas] [azúcar] [harina] [sal] [rucula] [curry] [seta])
         (CumplePreferencias  [sibarita] [moderno])
         (InfoGeneral  "Plato de frío de gamba para paladares exquisitos.")
         (Precio  30.00)
         (PlatosIncompatibles  [Carpaccio_de_gamba_con_nougatine_de_curry_y_boletus])
         (TipoEnMenu  "primero_segundo")
         (BebidasRecomendadas  [Copa_de_vino_blanco_Empordà] [Champagne_Renard-Barnier] [Cava_Anna_de_Codorniu] [Agua])
    )

    ([Macedonia] of Plato
         (Complejidad  15)
         (Nombre  "Macedonia")
         (Ingredientes  [uva] [granada] [pera] [plátano] [manzana] [naranja])
         (InfoGeneral  "Macedonia de frutas de temporada")
         (Precio  8.00)
         (TipoEnMenu  "postre")
         (CumplePreferencias [regional] [clásico])
    )

    ([Cerveza_Estrella_Galicia_1906] of Bebida
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa])
         (BebidaAlcoholica  TRUE)
         (Precio  3.00)
         (Nombre  "Cerveza Estrella Galicia 1906")
    )

    ([curry] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (Nombre  "Curry")
         (Disponibilidad  [otoño] [verano] [invierno] [primavera])
    )

    ([aguacate] of Ingrediente
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_gluten] [intolerancia_lactosa])
         (Nombre  "Aguacate")
         (Disponibilidad  [verano] [primavera] [invierno] [otoño])
    )

    ([Cerveza_Moritz] of Bebida
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_lactosa])
         (BebidaAlcoholica  TRUE)
         (Precio  3.50)
         (Nombre  "Cerveza Moritz")
    )

    ([Flan_de_huevo] of Plato
         (Complejidad  35)
         (Nombre  "Flan de huevo")
         (Ingredientes  [canela] [azúcar] [leche] [huevo])
         (InfoGeneral  "Flan casero de huevo con canela")
         (Precio  8.00)
         (TipoEnMenu  "postre")
         (CumplePreferencias [clásico] [sibarita])
    )

    ([Zumo_natural] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [vegano] [intolerancia_gluten])
         (BebidaAlcoholica  FALSE)
         (Precio  3.00)
         (Nombre  "Zumo natural")
    )

    ([cebolla] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano] [intolerancia_lactosa] [vegano])
         (Nombre  "Cebolla")
         (Disponibilidad  [invierno] [otoño] [primavera] [verano])
    )

    ([Agua] of Bebida
         (CumpleRestricciones  [vegetariano] [intolerancia_lactosa] [vegano] [intolerancia_gluten])
         (BebidaAlcoholica  FALSE)
         (Precio  1.50)
         (Nombre  "Agua")
    )

    ([Cava_Anna_de_Codorniu] of Bebida
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (BebidaAlcoholica  TRUE)
         (Precio  19.00)
         (Nombre  "Cava Anna de Codorniu")
         (BebidasIncompatibles [Refresco_Aquarius] [Refresco_Coca_Cola] [Refresco_Fanta] [Refresco_Nestea] [Zumo_natural])
    )

    ([Refresco_Coca_Cola] of Bebida
         (CumpleRestricciones  [vegetariano] [vegano] [intolerancia_gluten] [intolerancia_lactosa])
         (BebidaAlcoholica  FALSE)
         (Precio  2.20)
         (Nombre  "Refresco Coca Cola")
         (BebidasIncompatibles [Cava_Anna_de_Codorniu] [Champagne_Renard-Barnier])
    )

    ([pasta] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [vegano])
         (Nombre  "Pasta")
         (Disponibilidad  [otoño] [verano] [primavera] [invierno])
    )

    ([Entrecot_a_la_plancha_con_salteado_de_verduras] of Plato
         (Complejidad  55)
         (Nombre  "Entrecot a la plancha con salteado de verduras")
         (Ingredientes  [calabacín] [aceite_de_oliva] [mantequilla] [sal] [patata] [ternera] [tomate] [ajo] [pimiento_verde] [pimiento_rojo] [cebolla])
         (CumplePreferencias  [clásico] [sibarita])
         (InfoGeneral  "Plato caliente de carne y verduras")
         (Precio  23.50)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Agua] [Agua_con_gas] [Cava_Anna_de_Codorniu] [Copa_de_vino_tinto_Vivanco])
    )

    ([aceituna] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegetariano] [vegano] [intolerancia_lactosa])
         (Nombre  "Aceitunas")
         (Disponibilidad  [otoño] [invierno] [verano] [primavera])
    )

    ([col] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (Nombre  "Col")
         (Disponibilidad  [primavera] [otoño] [verano] [invierno])
    )

    ([langostino] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [intolerancia_gluten])
         (Nombre  "Langostino")
         (Disponibilidad  [invierno] [verano] [primavera] [otoño])
    )

    ([Melón_con_jamón] of Plato
         (Complejidad  5)
         (Nombre  "Melón con jamón")
         (Ingredientes  [melón] [jamón])
         (CumplePreferencias  [regional])
         (InfoGeneral  "Plato frío de fruta y jamón")
         (Precio  6.50)
         (TipoEnMenu  "primero")
         (BebidasRecomendadas  [Agua] [Copa_de_vino_blanco_Penedès] [Zumo_natural] [Agua_con_gas])
         (PlatosIncompatibles  [Melón])
    )

    ([Champagne_Renard-Barnier] of Bebida
         (CumpleRestricciones  [vegano] [intolerancia_lactosa] [vegetariano] [intolerancia_gluten])
         (BebidaAlcoholica  TRUE)
         (Precio  27.00)
         (Nombre  "Champagne Renard-Barnier")
         (BebidasIncompatibles [Refresco_Aquarius] [Refresco_Coca_Cola] [Refresco_Fanta] [Refresco_Nestea] [Zumo_natural])
    )

    ([vegano] of RestriccionAlimentaria
         (Nombre  "Vegano/a")
    )

    ([moderno] of Preferencia
         (Nombre  "Estilo moderno")
    )

    ([Albóndigas_con_champiñones] of Plato
         (Complejidad  75)
         (Nombre  "Albóndigas con champiñones")
         (Ingredientes  [perejil] [cebolla] [huevo] [agua] [aceite_de_oliva] [sal] [ternera] [seta] [harina] [ajo])
         (CumplePreferencias  [regional] [clásico])
         (InfoGeneral  "Plato caliente de carne picada y setas")
         (Precio  12.00)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Agua] [Agua_con_gas] [Cerveza_Daura] [Cerveza_Moritz] [Copa_de_vino_tinto_Fuenteseca])
    )

    ([Butifarra_con_judías] of Plato
         (Complejidad  40)
         (Nombre  "Butifarra con judías")
         (Ingredientes  [ajo] [aceite_de_oliva] [perejil] [judía] [sal] [butifarra])
         (CumplePreferencias  [clásico] [regional])
         (InfoGeneral  "Plato caliente de carne y legumbres")
         (Precio  11.50)
         (TipoEnMenu  "segundo")
         (BebidasRecomendadas  [Refresco_Nestea] [Copa_de_vino_tinto_Vivanco] [Agua] [Agua_con_gas] [Cerveza_Estrella_Damm])
    )

    ([canela] of Ingrediente
         (CumpleRestricciones  [intolerancia_lactosa] [vegetariano] [intolerancia_gluten] [vegano])
         (Nombre  "Canela")
         (Disponibilidad  [primavera] [otoño] [verano] [invierno])
    )

    ([calabacín] of Ingrediente
         (CumpleRestricciones  [intolerancia_gluten] [vegano] [intolerancia_lactosa] [vegetariano])
         (Nombre  "Calabacín")
         (Disponibilidad  [verano] [invierno] [primavera] [otoño])
    )

)


; CLASES QUE NO FORMAN PARTE  DE LA ONTOLOGIA

(defclass PuntuacionPlato "Guarda un plato y su puntuacion."
    (is-a USER)
    (role concrete)
    (pattern-match reactive)
    ;;; Nombre identificador de una instancia de la clase.
    (single-slot Plato
        (type INSTANCE)
        (create-accessor read-write))
    (single-slot Puntuacion
        (type INTEGER)
        (create-accessor read-write)
        (default 0))
)

; VARIABLES GLOBALES
(defglobal ?*COMPLEJIDAD_BAJA* = 15)
(defglobal ?*COMPLEJIDAD_MEDIA* = 35)
(defglobal ?*COMPLEJIDAD_ALTA* = 55)

(defglobal ?*NUM_COMENSALES_BAJO* = 5)
(defglobal ?*NUM_COMENSALES_MEDIO* = 10)
(defglobal ?*NUM_COMENSALES_ALTO* = 25)


; #########################################
; ######## DECLARACION DE MODULOS #########
; #########################################

(defmodule MAIN (export ?ALL))

(defmodule recogida_datos_evento
  (import MAIN ?ALL)
	(export ?ALL)
)

(defmodule analisis_datos
  (import MAIN ?ALL)
  (export ?ALL)
)

(defmodule generacion_resultados
  (import MAIN ?ALL)
  (import recogida_datos_evento deftemplate ?ALL)
  (import analisis_datos deftemplate ?ALL)
  (export ?ALL)
)

; regla inicial, el programa empieza aquí, se empieza dando la bienvenida al cliente

(defrule MAIN::initialRule "Regla inicial"
	(declare (salience 10))
	=>
  	(printout t"         Personalización de Menú con RicoRico         " crlf)
	(printout t"----------------------------------------------------------" crlf)
  	(printout t crlf)
	(printout t"Estimado cliente, a continuación se le formularán una serie de preguntas para poder recomendarle 3 menús diferentes." crlf)
	(printout t crlf)
    (focus recogida_datos_evento)
)

; #########################################
; ########## RECOGIDA DE DATOS ############
; #########################################

; a continuación definimos las funciones que usaremos para hacer las preguntas
; para recopilar la información necesaria del cliente

; funcion para hacer una pregunta numerica
(deffunction MAIN::pregunta_numerica (?pregunta ?primera ?ultima)
  ; se saca la pregunta por pantalla
  (bind ?linea (format nil "%s " ?pregunta))
  (printout t ?linea)
  ; se guarda la respuesta del usuario en la variable ?respuesta
  (bind ?respuesta (read))
  ; mientras la respuesta no este dentro del rango acceptado o no se responda
  ; con un integer, se vuelve a pedir una respuesta
  (while (or (not (integerp ?respuesta)) (not(and(>= ?respuesta ?primera)(<= ?respuesta ?ultima)))) do
    (bind ?linea (format nil "%s (%d - %d):" "Por favor, responda con un valor dentro del rango de respuestas " ?primera ?ultima))
    (printout t ?linea crlf)
    (bind ?respuesta (read))
  )
  ?respuesta
)

; funcion para hacer una pregunta numerica con una unica opcion
(deffunction MAIN::pregunta_single_choice (?pregunta $?llista_elem)
  (bind ?linea (format nil "%s" ?pregunta))
  (printout t ?linea crlf)
  (progn$ (?elem ?llista_elem)
    (bind ?linea (format nil " %d. %s" ?elem-index ?elem))
    (printout t ?linea crlf)
  )
  (format t "%s" "Escriba el índice de la respuesta: ")
  (bind ?respuesta (read))
  (while (or (not (integerp ?respuesta)) (or (< ?respuesta 1)(> ?respuesta (length$ ?llista_elem)))) do
    (bind ?linea (format nil "%s (%d - %d):" "Por favor, responda con un valor dentro del rango de respuestas " 1 (length$ ?llista_elem)))
    (printout t ?linea crlf)
    (bind ?respuesta (read))
  )
  ?respuesta
)

; funcion para hacer una pregunta de si/no. Devuelve TRUE si la respuesta es si o s, otherwise devuelve FALSE
(deffunction MAIN::pregunta_si_no (?pregunta)
  (bind ?linea (format nil "%s %s" ?pregunta " (si/no): "))
  (printout t ?linea)
  (bind ?respuesta (read))
  (if (or (eq ?respuesta si) (eq ?respuesta s))
    then TRUE
    else FALSE)
)

; funcion para hacer una pregunta con múltiples respuestas.
(deffunction MAIN::pregunta_multi_choice (?pregunta $?lista_elem)
  (bind ?linea (format nil "%s" ?pregunta))
  (printout t ?linea crlf)
  (progn$ (?elem ?lista_elem)
    (bind ?linea (format nil " %d. %s" ?elem-index ?elem))
    (printout t ?linea crlf)
  )
  (printout t "" crlf)
  (printout t " 0. Ninguna de las opciones anteriores" crlf)
  (printout t "" crlf)
  (printout t "Escriba los índices de sus respuestas separados por un espacio: ")
  (bind ?entrada (readline))
  (bind ?indices_respuesta (str-explode ?entrada))
  (bind $?resultado (create$))
  (progn$ (?indice ?indices_respuesta)
    (if (= ?indice 0) then
      (bind $?resultado (create$))
      (return ?resultado)
    )
    (if (and (integerp ?indice) (and (> ?indice 0) (<= ?indice (length$ ?lista_elem))))
      then (if (not (member ?indice ?resultado))
        then (bind ?resultado (insert$ ?resultado (+ (length$ ?resultado) 1) ?indice))
      )
    )
  )
  ?resultado
)

; #########################################
; ###### PREGUNTAS PARA EL CLIENTE ########
; #########################################

; template para recolectar los datos del evento
(deftemplate MAIN::datos_evento ;
  (slot tipo_evento (type SYMBOL)) ; guarda si es familiar o un congreso
  (slot numero_comensales (type INTEGER)) ;
  (slot precio_min (type FLOAT)) ;
  (slot precio_max (type FLOAT)) ;
  (multislot restricciones (type INSTANCE)) ; guarda las restricciones alimentarias
  (multislot ingredientes_prohibidos (type INSTANCE)) ;
  (multislot preferencias (type INSTANCE)) ; guarda los estilos que quiere el cliente
  (slot bebida_alcoholica (type SYMBOL)(default FALSE)) ; guarda si se quieren bebidas alcoholicas o no
  (slot bebida_por_platos (type SYMBOL)(default FALSE)) ; guarda si se quiere una bebida por plato o solo una para toda la comida
  (slot temporada_actual (type INSTANCE)) ; guarda la temporada en la que se realiza el evento
)

; hechos para respetar el orden de las preguntas hechas al cliente, a medida que
; hacemos las preguntas vamos poniendo su respectivo hecho representativo a TRUE
(deffacts recogida_datos_evento::preparacion "Establece hechos para poder recoger los datos del evento"
  (numero_comensales FALSE)
  (precio_min FALSE)
  (precio_max FALSE)
  (restricciones_alimentarias FALSE)
  (alergias_alimentarias FALSE)
  (preferencias_alimentarias FALSE)
  (bebida_por_platos FALSE)
  (bebida_alcoholica FALSE)
  (temporada FALSE)
)

; - Se trata de un evento familiar o un congreso?
;   1. Familiar
;   2. Congreso
(defrule recogida_datos_evento::familiar_congreso "Indica si el evento es familiar o un congreso"
  ; inicialmente no tenemos instanciada ninguna template datos_evento
  (not (datos_evento))
  =>
  (bind ?respuesta (pregunta_single_choice "¿Se trata de un evento familiar o de un congreso?" "Familiar" "Congreso"))
  (if (= ?respuesta 1) then (bind ?tipo_evento familiar))
  (if (= ?respuesta 2) then (bind ?tipo_evento congreso))
  (assert (familiar_congreso TRUE))
  (assert (datos_evento (tipo_evento ?tipo_evento)))
)

; - Cuantos comensales habran en el evento?
;   # (se espera un número)
(defrule recogida_datos_evento::numero_comensales "Indica el numero de comensales presentes en el evento"
  ?fact <- (numero_comensales FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?respuesta (pregunta_numerica "¿Cuántos comensales habrá en el evento?" 1 500))
  (retract ?fact)
  (assert (numero_comensales TRUE))
  (modify ?datos_evento (numero_comensales ?respuesta))
)

; - Indique su presupuesto minimo:
;   # (se espera un número)
(defrule recogida_datos_evento::precio_min "Indica precio mínimo del menú"
  ?fact <- (precio_min FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?respuesta (pregunta_numerica "¿Cuál será el precio mínimo del menú?" 5 80))
  (retract ?fact)
  (assert (precio_min TRUE))
  (modify ?datos_evento (precio_min ?respuesta))
)

; - Indique su presupuesto maximo:
;   # (se espera un número)
(defrule recogida_datos_evento::precio_max "Indica precio máximo del menú"
  ?fact <- (precio_max FALSE)
  ?datos_evento <- (datos_evento(precio_min ?precio_min))
  =>
  (bind ?respuesta (pregunta_numerica "¿Cuál será el precio máximo del menú?" ?precio_min 100))
  (retract ?fact)
  (assert (precio_max TRUE))
  (modify ?datos_evento (precio_max ?respuesta))
)

; - Qué restricciones alimentarias hay?
;   1. Vegeteriano
;   2. Vegano
;   3. Intolerante a la lactosa
;   4. Intolerancia al gluten
(defrule recogida_datos_evento::restricciones_alimentarias "Indica que restricciones alimentarias hay"
  ?fact <- (restricciones_alimentarias FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?restricciones (find-all-instances ((?inst RestriccionAlimentaria)) TRUE ))
  (bind $?posibles_respuestas (create$ ))
  (loop-for-count (?i 1 (length$ $?restricciones)) do
    (bind ?i_restriccion (nth$ ?i ?restricciones))
    (bind ?i_respuesta (send ?i_restriccion get-Nombre))
    (bind $?posibles_respuestas (insert$ $?posibles_respuestas (+ (length$ $?posibles_respuestas) 1) ?i_respuesta))
  )

  (bind ?choice (pregunta_multi_choice "¿Qué restricciones alimentarias hay?" $?posibles_respuestas))

  (bind $?respuesta (create$))
  (loop-for-count (?i 1 (length$ ?choice)) do
    (bind ?index (nth$ ?i ?choice))
    (bind ?i_choice (nth$ ?index ?restricciones))
    (bind $?respuesta (insert$ $?respuesta (+ (length$ $?respuesta) 1) ?i_choice))
  )
  (retract ?fact)
  (assert (restricciones_alimentarias TRUE))
  (modify ?datos_evento (restricciones $?respuesta))
)

; - ¿Entre los miembros del grupo hay alguien que tenga alergia o deteste algun ingrediente concreto?
;   1. Si
;   2. No
;   [Solo en caso afirmativo de la anterior pregunta]
; - Marque, de entre todos los ingredientes de nuestros platos, quales no pueden aparecer en el menu.
;   [Lista de ingredientes].
(defrule recogida_datos_evento::alergias_alimentarias "Indica si deben prohibirse alimentos"
  ?fact <- (alergias_alimentarias FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?si_no (pregunta_si_no "¿Entre los miembros del grupo hay alguien que tenga alergia o deteste algún ingrediente concreto?"))
  (bind $?respuesta (create$ ))
  (if ?si_no then
    (bind ?ingredientes (find-all-instances ((?inst Ingrediente)) TRUE))
    (bind $?respuestas (create$ ))
    (loop-for-count (?i 1 (length$ $?ingredientes)) do
      (bind ?i_ingrediente (nth$ ?i ?ingredientes))
      (bind ?i_nom (send ?i_ingrediente get-Nombre))
      (bind $?respuestas(insert$ $?respuestas (+ (length$ $?respuestas) 1) ?i_nom))
    )

    (bind ?escogido (pregunta_multi_choice "Selecciona los ingredientes que no toleras: " $?respuestas))
    (loop-for-count (?i 1 (length$ ?escogido)) do
      (bind ?curr-index (nth$ ?i ?escogido))
      (bind ?curr-ingredientes (nth$ ?curr-index ?ingredientes))
      (bind $?respuesta(insert$ $?respuesta (+ (length$ $?respuesta) 1) ?curr-ingredientes))
    )
  )
  (retract ?fact)
  (assert (alergias_alimentarias TRUE))
  (modify ?datos_evento (ingredientes_prohibidos $?respuesta))
)

; - Alguna preferencia respecto al tipo de platos? (elegir solo 1 opción??)
;   1. Clasicos
;   2. Modernos
;   3. Regionales
;   4. Sibaritas
(defrule recogida_datos_evento::preferencias_alimentarias "Indica la preferencia del estilo de plato"
  ?fact <- (preferencias_alimentarias FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?preferencias (find-all-instances ((?inst Preferencia)) TRUE ))
  (bind $?posibles_respuestas (create$ ))
  (loop-for-count (?i 1 (length$ $?preferencias)) do
    (bind ?i_preferencia (nth$ ?i ?preferencias))
    (bind ?i_respuesta (send ?i_preferencia get-Nombre))
    (bind $?posibles_respuestas (insert$ $?posibles_respuestas (+ (length$ $?posibles_respuestas) 1) ?i_respuesta))
  )
  (bind ?choice (pregunta_multi_choice "¿Tiene alguna preferencia respecto al estilo de los platos?" $?posibles_respuestas))
  (bind $?respuesta (create$ ))
  (loop-for-count (?i 1 (length$ ?choice)) do
    (bind ?index (nth$ ?i ?choice))
    (bind ?i_choice (nth$ ?index ?preferencias))
    (bind $?respuesta (insert$ $?respuesta (+ (length$ $?respuesta) 1) ?i_choice))
  )
  (retract ?fact)
  (assert (preferencias_alimentarias TRUE))
  (modify ?datos_evento (preferencias $?respuesta))
)

; - Quieres una bebida por cada plato? (s/n)
(defrule recogida_datos_evento::bebida_por_plato "Indica si el menú debe considerar una bebida para cada plato o una comuna para todos"
  ?fact <- (bebida_por_platos FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?respuesta (pregunta_si_no "¿Desea que el menú incorpore una bebida individual para cada plato?"))
  (retract ?fact)
  (assert (bebida_por_platos TRUE))
  (modify ?datos_evento (bebida_por_platos ?respuesta))
)


; - Quieres bebidas alcoholicas? (s/n)
(defrule recogida_datos_evento::bebida_alcoholica "Indica si el menú puede tener o no bebidas alcoholicas"
  ?fact <- (bebida_alcoholica FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?respuesta (pregunta_si_no "¿El menú propuesto puede contener bebidas alcohólicas?"))
  (retract ?fact)
  (assert (bebida_alcoholica TRUE))
  (modify ?datos_evento (bebida_alcoholica ?respuesta))
)

; - ¿Para que epoca desea hacer la reserva?
;   1. Invierno
;   2. Primavera
;   3. Verano
;   4. Otoño
(defrule recogida_datos_evento::temporada_actual "Indica la temporada para la cual se hace la reserva"
  ?fact <- (temporada FALSE)
  ?datos_evento <- (datos_evento)
  =>
  (bind ?temporadas (find-all-instances ((?inst Temporada)) TRUE ))
  (bind $?posibles_respuestas (create$ ))
  (loop-for-count (?i 1 (length$ $?temporadas)) do
    (bind ?i_temporada (nth$ ?i ?temporadas))
    (bind ?i_respuesta (send ?i_temporada get-Nombre))
    (bind $?posibles_respuestas (insert$ $?posibles_respuestas (+ (length$ $?posibles_respuestas) 1) ?i_respuesta))
  )
  (bind ?choice (pregunta_single_choice "¿Para qué temporada del año desea hacer la reserva en Rico Rico?" $?posibles_respuestas))
  (bind ?respuesta (nth$ ?choice ?temporadas))
  (retract ?fact)
  (assert (temporada TRUE))
  (modify ?datos_evento (temporada_actual ?respuesta))
)

; una vez hemos acabado de hacer las preguntas, pasamos a analizar los datos,
; accedemos a un nuevo módulo

(defrule recogida_datos_evento::cambio_a_modulo_analisis "Una vez hechas todas las preguntas pasamos al modulo de analisis de los datos"
  (familiar_congreso TRUE)
  (numero_comensales TRUE)
  (precio_min TRUE)
  (precio_max TRUE)
  (restricciones_alimentarias TRUE)
  (alergias_alimentarias TRUE)
  (preferencias_alimentarias TRUE)
  (bebida_por_platos TRUE)
  (bebida_alcoholica TRUE)
  (temporada TRUE)
  =>
  (focus analisis_datos)
)

; #########################################
; ########### ANÁLISIS DE DATOS ###########
; #########################################

; procesamos los datos dados por el cliente

; Estructura que contiene los datos que recogemos al hacer las preguntas iniciales
(deftemplate analisis_datos::datos_analisis ;
  (multislot ingredientes_validos (type INSTANCE)) ;
  (multislot primeros_platos_validos (type INSTANCE)) ;
  (multislot segundos_platos_validos (type INSTANCE)) ;
  (multislot postres_validos (type INSTANCE)) ;
  (multislot bebidas_validas (type INSTANCE)) ;
  (multislot puntuaciones_primeros_platos (type INSTANCE)) ;
  (multislot puntuaciones_segundos_platos (type INSTANCE)) ;
  (multislot puntuaciones_postres (type INSTANCE)) ;
)

; hechos para respetar el orden de las reglas para analizar los datos, a medida que
; procesamos unos datos vamos poniendo su respectivo hecho representativo a TRUE

(deffacts analisis_datos::analisis "Establece hechos para poder hacer el analisis de los datos"
  (datos_analisis)
  (analisis_ingredientes_validos FALSE)
  (filtrado_ingredientes_temporada FALSE)
  (seleccion_primeros FALSE)
  (seleccion_segundos FALSE)
  (seleccion_postres FALSE)
  (analisis_bebidas_validas FALSE)
  (puntuaciones FALSE)
)

; Poda de los ingredientes que no cumplen las restricciones alimentarias o las alergias

; Hemos definido dos funciones, en el caso de que no haya ninguna restriccion alimentaria
; ni ningún ingrediente prohibido, se buscan todas las instancias de ingredientes y se
; añaden a la template datos_analisis. En el caso contrario accedemos a la siguiente función
; (seleccion_ingredientes_validos) y sólo añadimos las instancias de los ingredentes que
; el cliente tolera.

(defrule analisis_datos::todos_ingredientes_validos "Crear hechos con los ingredientes que se pueden usar (todos)"
  (declare (salience 1))
  ?fact <- (analisis_ingredientes_validos FALSE)
  ?datos_analisis <- (datos_analisis)
  (datos_evento (restricciones $?rest_alim))
  (datos_evento (ingredientes_prohibidos $?ingr_prohib))
  (test (= (length$ ?rest_alim) 0)) ; miramos que no haya ninguna restriccion alimentaria
  (test (= (length$ ?ingr_prohib) 0)) ; miramos que no haya ningún ingrediente prohibido
  =>
  (bind ?ingredientes (find-all-instances ((?inst Ingrediente)) TRUE ))
  (retract ?fact)
  (assert (analisis_ingredientes_validos TRUE))
  (modify ?datos_analisis (ingredientes_validos $?ingredientes))
)

(defrule analisis_datos::seleccion_ingredientes_validos "Crear hechos con los ingredientes que se pueden usar"
  ?fact <- (analisis_ingredientes_validos FALSE)
  ?datos_analisis <- (datos_analisis (ingredientes_validos $?ingr_valid_analisis))
  (datos_evento (restricciones $?rest_alim))
  (datos_evento (ingredientes_prohibidos $?ingr_prohib))
  =>
  (bind ?ingredientes (find-all-instances ((?inst Ingrediente)) TRUE ))
  (loop-for-count (?i 1 (length$ $?ingredientes)) do
    (bind ?i_ingrediente (nth$ ?i ?ingredientes))
    (if (not (member ?i_ingrediente ?ingr_prohib)) then
      (bind ?i_cumple_restricciones (send ?i_ingrediente get-CumpleRestricciones))
      (bind ?no_cumple FALSE)
      (loop-for-count (?j 1 (length$ $?rest_alim)) do
        (bind ?j_restriccion (nth$ ?j ?rest_alim))
        (if (not (member ?j_restriccion ?i_cumple_restricciones)) then
          (bind ?no_cumple TRUE)
          (break)
        )
      )
      ; en el caso de que el ingrediente cumpla las restricciones alimentarias y
      ; no forme parte de los ingredientes prohibidos, lo añadimos a datos_analisis
      (if (not ?no_cumple) then
        (bind ?ingr_valid_analisis (insert$ $?ingr_valid_analisis (+ (length$ $?ingr_valid_analisis) 1) ?i_ingrediente))
      )
    )
  )
  (retract ?fact)
  (assert (analisis_ingredientes_validos TRUE))
  (modify ?datos_analisis (ingredientes_validos $?ingr_valid_analisis))
)

; Filtra la lista de ingredientes válidos y descarta aquellos
; que no cumplen la restricción de temporada
(defrule analisis_datos::filtrar_ingredientes_temporada "Hay ciertos ingredientes disponibles solo algunas temporadas"
  ?fact <- (filtrado_ingredientes_temporada FALSE)
  ?datos_analisis <- (datos_analisis (ingredientes_validos $?ingr_valid_analisis))
  (datos_evento (temporada_actual ?temporada))
  =>
  (bind ?ingr_filtrados (find-all-instances ((?inst Ingrediente))
    (and
      (member ?inst ?ingr_valid_analisis) ; miramos que el ingrediente pertenezca a los validos (seleccionados anteriormente)
      (member ?temporada ?inst:Disponibilidad) ; miramos que el ingrediente esté disponible en la temporada del evento
    )
  ))
  (retract ?fact)
  (assert (filtrado_ingredientes_temporada TRUE))
  (modify ?datos_analisis (ingredientes_validos $?ingr_filtrados))
)

; Función que descarta aquellos platos cuyos ingredientes el usuario ha especificado que no se pueden servir
(deffunction analisis_datos::comprueba_ingredientes (?lista_platos ?lista_ingredientes)
  (bind $?resultado (create$))
  (loop-for-count (?i 1 (length$ $?lista_platos)) do
    (bind ?plato_apto TRUE)
    (bind ?i_plato (nth$ ?i ?lista_platos))
    (bind $?ingr_plato (send ?i_plato get-Ingredientes) )
    (loop-for-count (?j 1 (length$ $?ingr_plato)) do
      (bind ?j_ingr (nth$ ?j ?ingr_plato))
      ; si hay un ingrediente perteneciente al plato que no esté disponible, descartamos el plato
      (if (not (member ?j_ingr ?lista_ingredientes)) then
        (bind ?plato_apto FALSE)
        (break)
      )
    )
    ; en el caso contrario, todos los ingredientes están disponibles y nos guardamos el plato
    (if ?plato_apto then
      (bind ?resultado (insert$ $?resultado (+ (length$ $?resultado) 1) ?i_plato))
    )
  )
  ?resultado
)

; Inicializa la lista de primeros platos que cumplen todas las restricciones especificadas por el usuario
(defrule analisis_datos::determinar_primeros "Escojer los primeros platos cuyos ingredientes sean todos validos"
  ?fact <- (seleccion_primeros FALSE)
  ?datos_analisis <- (datos_analisis (ingredientes_validos $?ingr_valid_analisis))
  =>
  (bind ?primeros_platos (find-all-instances ((?inst Plato))
    (or ; nos quedamos con los platos que sean de tipo "Primero" o "Primero o Segundo"
      (= (str-compare ?inst:TipoEnMenu "primero") 0)
      (= (str-compare ?inst:TipoEnMenu "primero_segundo") 0)
    )
  ))
  (bind ?resultado (comprueba_ingredientes $?primeros_platos $?ingr_valid_analisis))
  (retract ?fact)
  (assert (seleccion_primeros TRUE))
  (modify ?datos_analisis (primeros_platos_validos $?resultado))
)

; Inicializa la lista de segundos platos que cumplen todas las restricciones especificadas por el usuario
(defrule analisis_datos::determinar_segundos "Escojer los segundos platos cuyos ingredientes sean todos validos"
  ?fact <- (seleccion_segundos FALSE)
  ?datos_analisis <- (datos_analisis (ingredientes_validos $?ingr_valid_analisis))
  =>
  (bind ?segundos_platos (find-all-instances ((?inst Plato))
    (or ; nos quedamos con los platos que sean de tipo "Segundo" o "Primero o Segundo"
      (= (str-compare ?inst:TipoEnMenu "segundo") 0)
      (= (str-compare ?inst:TipoEnMenu "primero_segundo") 0)
    )
  ))
  (bind ?resultado (comprueba_ingredientes $?segundos_platos $?ingr_valid_analisis))
  (retract ?fact)
  (assert (seleccion_segundos TRUE))
  (modify ?datos_analisis (segundos_platos_validos $?resultado))
)

; Inicializa la lista de postres que cumplen todas las restricciones especificadas por el usuario
(defrule analisis_datos::determinar_postres "Escojer los postres cuyos ingredientes sean todos validos"
  ?fact <- (seleccion_postres FALSE)
  ?datos_analisis <- (datos_analisis (ingredientes_validos $?ingr_valid_analisis))
  =>
  (bind ?postres (find-all-instances ((?inst Plato))
    (= (str-compare ?inst:TipoEnMenu "postre") 0)
  ))
  (bind ?resultado (comprueba_ingredientes $?postres $?ingr_valid_analisis))
  (retract ?fact)
  (assert (seleccion_postres TRUE))
  (modify ?datos_analisis (postres_validos $?resultado))
)

; Inicializa la lista de bebidas que cumplen todas las restricciones especificadas por el usuario
(defrule analisis_datos::seleccion_bebidas_validas "Crear hechos con las bebidas que se pueden usar"
  ?fact <- (analisis_bebidas_validas FALSE)
  ?datos_analisis <- (datos_analisis)
  (datos_evento (restricciones $?rest_alim) (bebida_alcoholica ?alcoholica))
  =>
  (bind ?resultado (create$))
  (bind ?bebidas (find-all-instances ((?inst Bebida)) TRUE ))
  (loop-for-count (?i 1 (length$ $?bebidas)) do
    (bind ?i_bebida (nth$ ?i ?bebidas))
    (bind ?i_es_alcoholica (send ?i_bebida get-BebidaAlcoholica))
    (if (or ?alcoholica (and (not ?alcoholica) (not ?i_es_alcoholica))) then
      ; entramos únicamente si se permiten todo tipo de bebidas o si solo se permiten bebidas
      ; no alcoholicas y la bebida no lo es
      (bind ?i_cumple_restricciones (send ?i_bebida get-CumpleRestricciones))
      (bind ?cumple TRUE)
      (loop-for-count (?j 1 (length$ $?rest_alim)) do
        (bind ?j_restriccion (nth$ ?j ?rest_alim))
        (if (not (member ?j_restriccion ?i_cumple_restricciones)) then
          (bind ?cumple FALSE)
          (break)
        )
      )
      (if ?cumple then
        ; añadimos la bebida a bebidas_validas si cumple con la restricción de alcohol
        ; y si cumple las restricciones alimentarias (el gluten para las cervezas por ejemplo)
        (bind ?resultado (insert$ $?resultado (+ (length$ $?resultado) 1) ?i_bebida))
      )
    )
  )
  (retract ?fact)
  (assert (analisis_bebidas_validas TRUE))
  (modify ?datos_analisis (bebidas_validas $?resultado))
)

; Función que, dependiendo del tipo de evento escojido (familiar o congreso), las preferencias
; especificadas por el usuario y la complejidad del plato, devuelve un entero representando
; la puntuación de ese plato
(deffunction analisis_datos::puntos_tipo_evento (?tipo_evento ?complejidad ?preferencias_plato)
  (bind ?puntos_acumulados 0)

  ; en el caso de que el evento sea de tipo familiar, favorecemos determinados estilos de comida
  ; y favorecemos una complejidad mayor en los platos
  (if (eq ?tipo_evento familiar) then
      (if (<= ?complejidad ?*COMPLEJIDAD_BAJA*) then (bind ?puntos_acumulados (+ ?puntos_acumulados 1)))
      (if (and (> ?complejidad ?*COMPLEJIDAD_BAJA*) (<= ?complejidad ?*COMPLEJIDAD_MEDIA*)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 3)))
      (if (and (> ?complejidad ?*COMPLEJIDAD_MEDIA*) (<= ?complejidad ?*COMPLEJIDAD_ALTA*)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 6)))
      (if (<= ?complejidad ?*COMPLEJIDAD_ALTA*) then (bind ?puntos_acumulados (+ ?puntos_acumulados 8)))

      (if (member [clásico]  $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 5)))
      (if (member [segional] $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 3)))
      (if (member [sibarita] $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 5)))
      (if (member [moderno]  $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 1)))

  ; en el caso de que el evento sea de tipo congreso, favorecemos otros  estilos de comida
  ; y favorecemos una complejidad menor en los platos
  else
      (if (<= ?complejidad ?*COMPLEJIDAD_BAJA*) then (bind ?puntos_acumulados (+ ?puntos_acumulados 6)))
      (if (and (> ?complejidad ?*COMPLEJIDAD_BAJA*) (<= ?complejidad ?*COMPLEJIDAD_MEDIA*)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 3)))
      (if (and (> ?complejidad ?*COMPLEJIDAD_MEDIA*) (<= ?complejidad ?*COMPLEJIDAD_ALTA*)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 1)))

      (if (member [clásico]  $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 4)))
      (if (member [segional] $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 3)))
      (if (member [sibarita] $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 2)))
      (if (member [moderno]  $?preferencias_plato) then (bind ?puntos_acumulados (+ ?puntos_acumulados 5)))
  )

  ?puntos_acumulados
)

; Función que devuelve un valor que depende del número de comensales y la complejidad del plato
(deffunction analisis_datos::puntos_numero_comensales (?numero_comensales ?complejidad)
  (if (> ?numero_comensales ?*NUM_COMENSALES_ALTO*)  then (+ (* ?complejidad -0.15) 20))
  (if (> ?numero_comensales ?*NUM_COMENSALES_MEDIO*) then (+ (* ?complejidad -0.1)  20))
  (if (> ?numero_comensales ?*NUM_COMENSALES_BAJO*)  then (+ (* ?complejidad -0.5)  20))
  (+ (* ?complejidad 0.01)  20)
)

; Función que devuelve un valor que depende de las preferencias especificadas por el usuario
; y las preferencias que cumple el plato en concreto. Cuantas más preferencias cumpla el
; plato, mayor será el valor devuelto
(deffunction analisis_datos::puntos_preferencias (?preferencias ?preferencias_plato)
  (bind ?puntos_acumulados 0)
  (bind ?es_clasico (member [clásico] ?preferencias))
  (bind ?es_regional (member [regional] ?preferencias))
  (bind ?es_sibarita (member [sibarita] ?preferencias))
  (bind ?es_moderno (member [moderno] ?preferencias))

  (if (and ?es_clasico (member [clásico] ?preferencias_plato)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 15)))
  (if (and ?es_regional (member [regional] ?preferencias_plato)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 15)))
  (if (and ?es_sibarita (member [sibarita] ?preferencias_plato)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 15)))
  (if (and ?es_moderno (member [moderno] ?preferencias_plato)) then (bind ?puntos_acumulados (+ ?puntos_acumulados 15)))

  ?puntos_acumulados
)

; Función que devuelve TRUE si el plato es vegano, FALSE si no lo es
(deffunction analisis_datos::plato_es_vegano (?plato)
  (bind ?ingredientes (send ?plato get-Ingredientes))
  (loop-for-count (?i 1 (length$ $?ingredientes))
    (bind ?ingr (nth$ ?i ?ingredientes))
    (if (not (member [vegano] (send ?ingr get-CumpleRestricciones))) then
        (return FALSE)
    )
  )
  (return TRUE)
)

; Función que penaliza servir platos vegetarianos o veganos a clientes que no lo son.
(deffunction analisis_datos::puntos_vegano_vegetariano (?restricciones ?tipo_plato ?plato)
    (bind ?no_es_vegano (not (member vegano ?restricciones)))
    (bind ?no_es_vegetariano (not (member vegetariano ?restricciones)))
    (if (and (and (and ?no_es_vegano ?no_es_vegetariano) (plato_es_vegano ?plato))
        (or (eq ?tipo_plato "segundo") (eq ?tipo_plato "primero_segundo"))) then
            (return -6)
    else (return 0)
    )
)

; Función que suma los puntos de las 3 funciones anteriores para tener una puntuación final del plato
(deffunction analisis_datos::calcula_puntuacion_plato ( ?tipo_evento ?numero_comensales ?restricciones ?preferencias ?plato ) "Calcula las puntuaciones de los platos"
    (bind ?complejidad (send ?plato get-Complejidad))
    (bind $?preferencias_plato (send ?plato get-CumplePreferencias))
    (bind ?tipo_plato (send ?plato get-TipoEnMenu))

    (bind ?puntos_acumulados (puntos_tipo_evento ?tipo_evento ?complejidad $?preferencias_plato))
    (bind ?puntos_acumulados (+ ?puntos_acumulados (puntos_numero_comensales ?numero_comensales ?complejidad)))
    (bind ?puntos_acumulados (+ ?puntos_acumulados (puntos_preferencias ?preferencias ?preferencias_plato)))
    (bind ?puntos_acumulados (+ ?puntos_acumulados (puntos_vegano_vegetariano ?restricciones ?tipo_plato ?plato)))

    ?puntos_acumulados
)

; Para cada plato valido (primeros, segundos y postres) se calcula su puntuación
; y se crea una instancia PuntuacionPlato, dicha instancia guarda la instancia del plato y su puntuación
(defrule analisis_datos::puntuaciones_iniciales "puntuaciones de los platos segun las preferencias del cliente"
    ?fact <- (puntuaciones FALSE)
    ?datos_analisis <- (datos_analisis (primeros_platos_validos $?primeros) (segundos_platos_validos $?segundos) (postres_validos $?postres))
    (datos_evento (tipo_evento ?tipo_evento))
    (datos_evento (numero_comensales ?numero_comensales))
    (datos_evento (restricciones $?restricciones))
    (datos_evento (preferencias $?preferencias))
    =>
    (bind ?resultado (create$))
    (setgen 1)
    (loop-for-count (?i 1 (length$ $?primeros)) do
      (bind ?i_plato (nth$ ?i ?primeros))
      (bind ?inst (gensym))
      (make-instance ?inst of PuntuacionPlato)
      (bind ?id (instance-name ?inst))
      (send ?id put-Plato ?i_plato)
      (send ?id put-Puntuacion (calcula_puntuacion_plato ?tipo_evento ?numero_comensales ?restricciones ?preferencias ?i_plato))
      (bind ?resultado (insert$ ?resultado (+ (length$ $resultado) 1) ?id))
    )
    (bind ?resultado1 (create$))
    (loop-for-count (?i 1 (length$ $?segundos)) do
      (bind ?i_plato (nth$ ?i ?segundos))
      (bind ?inst (gensym))
      (make-instance ?inst of PuntuacionPlato)
      (bind ?id (instance-name ?inst))
      (send ?id put-Plato ?i_plato)
      (send ?id put-Puntuacion (calcula_puntuacion_plato ?tipo_evento ?numero_comensales ?restricciones ?preferencias ?i_plato))
      (bind ?resultado1 (insert$ ?resultado1 (+ (length$ $resultado1) 1) ?id))
    )
    (bind ?resultado2 (create$))
    (loop-for-count (?i 1 (length$ $?postres)) do
      (bind ?i_plato (nth$ ?i ?postres))
      (bind ?inst (gensym))
      (make-instance ?inst of PuntuacionPlato)
      (bind ?id (instance-name ?inst))
      (send ?id put-Plato ?i_plato)
      (send ?id put-Puntuacion (calcula_puntuacion_plato ?tipo_evento ?numero_comensales ?restricciones ?preferencias ?i_plato))
      (bind ?resultado2 (insert$ ?resultado2 (+ (length$ $resultado2) 1) ?id))
    )
    (modify ?datos_analisis (puntuaciones_primeros_platos $?resultado) (puntuaciones_segundos_platos $?resultado1) (puntuaciones_postres $?resultado2))
    (retract ?fact)
    (assert (puntuaciones TRUE))
)

; una vez hemos acabado de analizar los datos, pasamos a generar las soluciones,
; accedemos a un nuevo módulo

(defrule analisis_datos::cambio_a_modulo_generacion_resultados "Una vez hecho el analisis pasamos al modulo de generacion de resultados"
  (analisis_ingredientes_validos TRUE)
  (filtrado_ingredientes_temporada TRUE)
  (seleccion_primeros TRUE)
  (seleccion_segundos TRUE)
  (seleccion_postres TRUE)
  (analisis_bebidas_validas TRUE)
  (puntuaciones TRUE)
  =>
  (focus generacion_resultados)
)

; #########################################
; ####### GENERACIÓN DE SOLUCIONES ########
; #########################################

; Función para elegir un elemento aleatorio (cogida del FAQs)
(deffunction generacion_resultados::random-element ( ?li )
  (bind ?li (create$ ?li))
  (bind ?max (length ?li))
  (bind ?r (random 1 ?max))
  (bind ?ins (nth$ ?r ?li))
  (return ?ins)
)

; Estructura que contiene los datos que recogemos para generar las soluciones finales
(deftemplate generacion_resultados::datos_generacion ;
  (multislot seleccion_primeros (type INSTANCE)) ; los 7 primeros platos con mejor puntuación
  (multislot seleccion_segundos (type INSTANCE)) ; los 7 segundos platos con mejor puntuación
  (multislot seleccion_postres  (type INSTANCE)) ; los 7 postres con mejor puntuación

  ; límites calculados dado el rango de precio del usuario
  (slot rango_min (type FLOAT))
  (slot rango_medio1 (type FLOAT))
  (slot rango_medio2 (type FLOAT))
  (slot rango_max (type FLOAT))

  ; menú generado en caso de que no haya ninguno en el rango de precios
  (slot edge_case_menu (type INSTANCE))

  (multislot menus_primer_rango (type INSTANCE)) ; menús solución que entran en el primer rango de precios
  (multislot menus_segundo_rango (type INSTANCE)) ; menús solución que entran en el segundo rango de precios
  (multislot menus_tercer_rango  (type INSTANCE)) ; menús solución que entran en el tercer rango de precios

  (multislot solucion  (type INSTANCE)) ; solución con 1 o 3 menús
)

; hechos para respetar el orden en que vamos generando el resultado
; vamos poniendo su respectivo hecho representativo a TRUE

(deffacts generacion_resultados::generacion
  (datos_generacion)
  (seleccion_platos FALSE)
  (rango_precios nil) ; determina si la solución está dentro del rango de precios, por encima o por debajo
  (generacion_menu FALSE)
)

; Devuelve una lista con todas las bebidas que se pueden asignar a un plato
(deffunction generacion_resultados::posibles_bebidas_plato (?bebidas_validas ?bebidas_recomendadas $?bebidas_recomendadas_extra)
  (if (= (length$ $?bebidas_recomendadas_extra) 0) then
    (bind ?result (find-all-instances ((?inst Bebida)) (and (member ?inst $?bebidas_validas) (member ?inst $?bebidas_recomendadas) )))
  else
    (bind ?result (find-all-instances ((?inst Bebida)) (and (member ?inst $?bebidas_validas) (and (member ?inst $?bebidas_recomendadas) (member ?inst $?bebidas_recomendadas_extra)))))
  )
  ?result
)

; Define el orden no-descendente de los platos
(deffunction generacion_resultados::ordenPlatos (?pl1 ?pl2)
    (< (send ?pl1 get-Puntuacion) (send ?pl2 get-Puntuacion))
)

; Define el orden no-descendente de los menús
(deffunction generacion_resultados::ordenMenus (?m1 ?m2)
    (< (send ?m1 get-PuntuacionMenu) (send ?m1 get-PuntuacionMenu))
)

(defrule generacion_resultados::preparacion_subconjunto ; Inicializamos seleccion_primeros seleccion_segundos y seleccion_postres
    ?fact <- (seleccion_platos FALSE)
    ?datos_analisis <- (datos_analisis (puntuaciones_primeros_platos $?primeros) (puntuaciones_segundos_platos $?segundos) (puntuaciones_postres $?postres))
    ?datos_generacion <- (datos_generacion)
    =>

    (bind ?primeros (sort ordenPlatos ?primeros))
    (bind ?segundos (sort ordenPlatos ?segundos))
    (bind ?postres (sort ordenPlatos ?postres))

    (bind ?seleccion_primeros (create$))
    (loop-for-count (?i 1 (min 7 (length$ $?primeros))) do
        (bind ?seleccion_primeros (insert$ $?seleccion_primeros ?i (nth$ ?i $?primeros)))
    )

    (bind ?seleccion_segundos (create$))
    (loop-for-count (?i 1 (min 7 (length$ $?segundos))) do
        (bind ?seleccion_segundos (insert$ $?seleccion_segundos ?i (nth$ ?i $?segundos)))
    )

    (bind ?seleccion_postres (create$))
    (loop-for-count (?i 1 (min 7 (length$ $?postres))) do
        (bind ?seleccion_postres (insert$ $?seleccion_postres ?i (nth$ ?i $?postres)))
    )

    (modify ?datos_generacion (seleccion_primeros ?seleccion_primeros) (seleccion_segundos ?seleccion_segundos) (seleccion_postres ?seleccion_postres))
    (retract ?fact)
    (assert (seleccion_platos TRUE))
)

; Devuelve TRUE si los dos platos son compatibles entre ellos y FALSE en caso contrario
(deffunction generacion_resultados::compatibles (?primero ?segundo)
    (if (member (instance-name ?primero) (send ?segundo get-PlatosIncompatibles)) then FALSE
    else TRUE)
)

; Devuelve la suma de las puntuaciones de los tres platos
(deffunction generacion_resultados::calcula_puntuacion (?primero ?segundo ?postre)
  (bind ?puntuacion_primero (send ?primero get-Puntuacion))
  (bind ?puntuacion_segundo (send ?segundo get-Puntuacion))
  (bind ?puntuacion_postre (send ?postre get-Puntuacion))

  (bind ?punt (+ (+ ?puntuacion_primero ?puntuacion_segundo) ?puntuacion_postre))
  ?punt
)

; Crea todas la combinaciones de menú posibles a partir de los primeros, segundos y postres
; seleccionados anteriormente, y calcula su precio. Las bebidas todavía no se incluyen en el menú
(defrule generacion_resultados::combinaciones_menus_sin_bebidas
    (declare (salience 1))
    ?fact_previo <- (seleccion_platos TRUE)
    ?datos_generacion <- (datos_generacion (seleccion_primeros $?seleccion_primeros) (seleccion_segundos $?seleccion_segundos) (seleccion_postres $?seleccion_postres))
    ; a continuación selecciona todas las combinaciones de primero, segundo y postre tales que no
    ; exista un menú instanciado con esta combinación y tales que sean compatibles entre ellos
    ?pref_primero <- (object (is-a PuntuacionPlato) (Plato ?primero))
    (test (member (instance-name ?pref_primero) ?seleccion_primeros))
    ?pref_segundo <- (object (is-a PuntuacionPlato) (Plato ?segundo))
    (test (member (instance-name ?pref_segundo) ?seleccion_segundos))
    ?pref_postre <- (object (is-a PuntuacionPlato) (Plato ?postre))
    (test (member (instance-name ?pref_postre) ?seleccion_postres))
    (not (object (is-a Menu) (Primero ?primero) (Segundo ?segundo) (Postre ?postre)))
    (test (compatibles ?primero ?segundo))
    (test (compatibles ?primero ?postre))
    (test (compatibles ?segundo ?postre))
    =>
    ; si se encuentra una combinación válida se crea una instancia de Menu con esta combinación
    (bind ?inst (gensym))
    (make-instance ?inst of Menu
         (Primero ?primero)
         (Segundo ?segundo)
         (Postre  ?postre)
         (PuntuacionMenu (calcula_puntuacion ?pref_primero ?pref_segundo ?pref_postre))
    )
    (send (instance-name ?inst) calcula_precio)
)

; Inicializa los rangos de precio de los menús en base a los rangos de precio especificados
; por el usuario y los precios máximos y mínimos de los menús. En caso de que el rango
; de precio especificado por el usuario no incluya nungún menú activa un flag específico
(defrule generacion_resultados::rangos_de_precios
    ?fact <- (rango_precios nil)
    ?datos_evento <- (datos_evento (precio_min ?min_precio_evento) (precio_max ?max_precio_evento) (bebida_por_platos ?multiples_bebidas))
    ?datos_analisis <- (datos_analisis (bebidas_validas $?bebidas_compatibles))
    ?datos_generacion <- (datos_generacion)
    =>
    ; para determinar los rangos de precios, vamos a calcular el precio del menú
    ; válido más barato para crear el lowerbound y el más caro para el upperbound
    (bind ?menus (find-all-instances ((?inst Menu)) TRUE))
    (if (> (length$ $?menus) 0) then
        ; inicializamos el lowerbound y el upperbound con el precio del primer menú
        (bind ?primer_menu (nth$ 1 ?menus))
        (bind ?min_menu ?primer_menu)
        (bind ?max_menu ?primer_menu)
        (bind ?primer_precio (send ?primer_menu get-Precio))
        (bind ?min_precio_menu ?primer_precio)
        (bind ?max_precio_menu ?primer_precio)
        (loop-for-count (?i 2 (length$ $?menus))
            (bind ?precio (send (nth$ ?i ?menus) get-Precio))
            (if (< ?precio ?min_precio_menu) then
                ; si encontramos un menú con un precio inferior al mínimo, lo asignamos como mínimo
                (bind ?min_precio_menu ?precio)
                (bind ?min_menu (nth$ ?i ?menus))
            )
            (if (> ?precio ?max_precio_menu) then
                ; si encontramos un menú con un precio superior al máximo, lo asignamos como máximo
                (bind ?max_precio_menu ?precio)
                (bind ?max_menu (nth$ ?i ?menus))
            )
        )

        ; a continuación nos quedamos con la/s bebida/s más baratas y más caras
        ; para completar el menú más barato y el más caro

        ; inicializamos todas las bebidas con la primera de las válidas
        (bind ?min_bebida (send (nth$ 1 ?bebidas_compatibles) get-Precio))
        (bind ?max_bebida (send (nth$ 1 ?bebidas_compatibles) get-Precio))
        (bind ?min_bebida2 (send (nth$ 1 ?bebidas_compatibles) get-Precio))
        (bind ?max_bebida2 (send (nth$ 1 ?bebidas_compatibles) get-Precio))

        (loop-for-count (?i 2 (length$ $?bebidas_compatibles))
            (bind ?precio (send (nth$ ?i $?bebidas_compatibles) get-Precio))
            (if (< ?precio ?min_bebida) then
              ; si encontramos una bebida con un precio inferior al mínimo, lo asignamos como mínimo
              (bind ?min_bebida2 ?min_bebida)
              (bind ?min_bebida ?precio)
            )
            (if (> ?precio ?max_bebida) then
              ; si encontramos una bebida con un precio superior al máximo, lo asignamos como máximo
              (bind ?max_bebida2 ?max_bebida)
              (bind ?max_bebida ?precio)
            )
        )

        ; sumamos al menú el la mitad del precio de la/s bebida/s
        (if (not ?multiples_bebidas) then
            (bind ?min_precio_menu (+ ?min_precio_menu (* ?min_bebida 0.5)))
            (bind ?max_precio_menu (+ ?max_precio_menu (* ?max_bebida 0.5)))
        else
            (bind ?min_precio_menu (+ ?min_precio_menu (* (+ ?min_bebida ?min_bebida2) 0.5)))
            (bind ?max_precio_menu (+ ?max_precio_menu (* (+ ?max_bebida ?max_bebida2) 0.5)))
        )

        ; asignamos como lowerbound el máximo entre el precio mínimo dado por el cliente
        ; y el precio del menú válido mínimo. El caso es análogo para el upperbound
        (bind ?min_rango (max ?min_precio_menu ?min_precio_evento))
        (bind ?max_rango (min ?max_precio_menu ?max_precio_evento))

        ; en el caso de que el rango máximo sea igual o inferior al rango mínimo
        ; propuesto por el cliente, no tendremos ningún menú que entre en el rango,
        ; por lo tanto buscaremos el menú más caro posible para adaptarse al máximo
        ; a las preferencias del cliente. El caso es análogo para el caso opuesto
        (if (<= ?max_rango ?min_precio_evento) then
            (assert (rango_precios mayor)) ; accederemos a la función que se encarga de encontrar el menú válido más caro de la selección final
            (modify ?datos_generacion (edge_case_menu ?max_menu))
        else
            (if (>= ?min_rango ?max_precio_evento) then
                (assert (rango_precios menor)) ; accederemos a la función que se encarga de encontrar el menú válido más barato de la selección final
                (modify ?datos_generacion (edge_case_menu ?min_menu))
            else
                ; en el caso en que haya menús con precios dentro del rango establecido por el cliente,
                ; accedemos a la función que calcula los 3 menús
                (bind ?rango (/ (- ?max_rango ?min_rango) 3))
                (modify ?datos_generacion (rango_min ?min_rango) (rango_medio1 (+ ?min_rango ?rango)) (rango_medio2 (+ ?min_rango (* 2 ?rango))) (rango_max ?max_rango))
                (assert (rango_precios correcto))
            )
        )
    )
    (retract ?fact)
)

; Elige el menú más caro entre los menús generados, y le asigna las bebidas más caras
(defrule generacion_resultados::seleccion_menus_mayor
    ?fact <- (rango_precios mayor)
    ?datos_evento <- (datos_evento (bebida_por_platos ?multiples_bebidas))
    ?datos_generacion <- (datos_generacion (edge_case_menu ?menu_max))
    ?datos_analisis <- (datos_analisis (bebidas_validas $?bebidas_compatibles))
    =>

    (bind ?bebidas_primero (send (send ?menu_max get-Primero) get-BebidasRecomendadas))
    (bind ?bebidas_segundo (send (send ?menu_max get-Segundo) get-BebidasRecomendadas))

    (bind ?primera_bebida_max (nth$ 1 $?bebidas_primero))
    (bind ?segunda_bebida_max (nth$ 1 $?bebidas_segundo))

    (bind ?suma_bebidas 0)
    (bind ?bebidas (create$))

    (if ?multiples_bebidas then
        ; Seleccionamos las dos bebidas tales que su suma sea lo más cara posible
        (loop-for-count (?i 1 (length$ $?bebidas_primero))
            (bind ?primera_bebida (nth$ ?i $?bebidas_primero))
            (if (member ?primera_bebida $?bebidas_compatibles) then
                (loop-for-count (?j 1 (length$ $?bebidas_segundo))
                    (bind ?segunda_bebida (nth$ ?j $?bebidas_segundo))
                    (if (member ?segunda_bebida $?bebidas_compatibles) then
                        (if (not (eq (instance-name ?primera_bebida) (instance-name ?segunda_bebida))) then
                            (bind ?suma_bebidas_i_j (+ (send ?primera_bebida get-Precio) (send ?segunda_bebida get-Precio)))
                            (if (> ?suma_bebidas_i_j ?suma_bebidas) then
                                (bind ?suma_bebidas ?suma_bebidas_i_j)
                                (bind ?primera_bebida_max ?primera_bebida)
                                (bind ?segunda_bebida_max ?segunda_bebida)
                            )
                        )
                    )
                )
            )
        )
        (bind ?bebidas (insert$ $?bebidas 1 ?primera_bebida_max))
        (bind ?bebidas (insert$ $?bebidas 2 ?segunda_bebida_max))
    else
        ; Seleccionamos las dos bebidas comaptibles con ambos platos,
        ; tales que su suma sea lo más cara posible
        (bind ?bebida_max [Agua])
        (loop-for-count (?i 1 (length$ $?bebidas_primero))
            (bind ?primera_bebida (nth$ ?i $?bebidas_primero))
            (if (member ?primera_bebida $?bebidas_compatibles) then
                (loop-for-count (?j 1 (length$ $?bebidas_segundo))
                    (bind ?segunda_bebida (nth$ ?j $?bebidas_segundo))
                    (if (and (eq (instance-name ?primera_bebida) (instance-name ?segunda_bebida)) (> ?suma_bebidas (send ?primera_bebida get-Precio))) then
                        (bind ?suma_bebidas (send ?primera_bebida get-Precio))
                        (bind ?bebida_max ?primera_bebida)
                    )
                )
            )
        )
        (bind ?bebidas (insert$ $?bebidas 1 ?bebida_max))
    )

    ; Asignamos las bebidas al menú y lo añadimos a la solución
    (send ?menu_max put-Bebidas $?bebidas)
    (send ?menu_max calcula_precio)
    (bind ?solucion (create$))
    (bind ?solucion (insert$ $?solucion 1 ?menu_max))

    (modify ?datos_generacion (solucion ?solucion))
    (retract ?fact)
    (assert (imprime_solucion TRUE))
)

; Elige el menú más barato entre los menús generados, y le asigna las bebidas más baratas
(defrule generacion_resultados::seleccion_menus_menor
    ?fact <- (rango_precios menor)
    ?datos_evento <- (datos_evento (bebida_por_platos ?multiples_bebidas))
    ?datos_generacion <- (datos_generacion (edge_case_menu ?menu_min))
    ?datos_analisis <- (datos_analisis (bebidas_validas $?bebidas_compatibles))
    =>

    (bind ?bebidas_primero (send (send ?menu_min get-Primero) get-BebidasRecomendadas))
    (bind ?bebidas_segundo (send (send ?menu_min get-Segundo) get-BebidasRecomendadas))

    (bind ?primera_bebida_min (nth$ 1 $?bebidas_primero))
    (bind ?segunda_bebida_min (nth$ 1 $?bebidas_segundo))

    (bind ?suma_bebidas 10000000)
    (bind ?bebidas (create$))

    (if ?multiples_bebidas then
        ; Seleccionamos las dos bebidas tales que su suma sea lo más barata posible
        (loop-for-count (?i 1 (length$ $?bebidas_primero))
            (bind ?primera_bebida (nth$ ?i $?bebidas_primero))
            (if (member ?primera_bebida $?bebidas_compatibles) then
                (loop-for-count (?j 1 (length$ $?bebidas_segundo))
                    (bind ?segunda_bebida (nth$ ?j $?bebidas_segundo))
                    (if (member ?segunda_bebida $?bebidas_compatibles) then
                        (if (not (eq (instance-name ?primera_bebida) (instance-name ?segunda_bebida))) then
                            (bind ?suma_bebidas_i_j (+ (send ?primera_bebida get-Precio) (send ?segunda_bebida get-Precio)))
                            (if (< ?suma_bebidas_i_j ?suma_bebidas) then
                                (bind ?suma_bebidas ?suma_bebidas_i_j)
                                (bind ?primera_bebida_min ?primera_bebida)
                                (bind ?segunda_bebida_min ?segunda_bebida)
                            )
                        )
                    )
                )
            )
        )
        (bind ?bebidas (insert$ $?bebidas 1 ?primera_bebida_min))
        (bind ?bebidas (insert$ $?bebidas 2 ?segunda_bebida_min))
    else
        ; Seleccionamos la bebida más barata tal que sea compatible con los dos platos
        (bind ?bebida_min [Agua])
        (loop-for-count (?i 1 (length$ $?bebidas_primero))
            (bind ?primera_bebida (nth$ ?i $?bebidas_primero))
            (if (member ?primera_bebida $?bebidas_compatibles) then
              (loop-for-count (?j 1 (length$ $?bebidas_segundo))
                  (bind ?segunda_bebida (nth$ ?j $?bebidas_segundo))
                  (if (and (eq (instance-name ?primera_bebida) (instance-name ?segunda_bebida)) (< ?suma_bebidas (send ?primera_bebida get-Precio))) then
                      (bind ?suma_bebidas (send ?primera_bebida get-Precio))
                      (bind ?bebida_min ?primera_bebida)
                  )
              )
           )
        )
        (bind ?bebidas (insert$ $?bebidas 1 ?bebida_min))
    )

    ; Asignamos las bebidas al menú y lo añadimos a la solución
    (send ?menu_min put-Bebidas $?bebidas)
    (send ?menu_min calcula_precio)
    (bind ?solucion (create$))
    (bind ?solucion (insert$ $?solucion 1 ?menu_min))

    (modify ?datos_generacion (solucion ?solucion))
    (retract ?fact)
    (assert (imprime_solucion TRUE))
)

; Devuelve TRUE si el valor se encuentra dentro del rango especificado
(deffunction generacion_resultados::is_in_range (?value ?min ?max)
    (if (and (< ?min ?value) (< ?value ?max)) then TRUE else FALSE)
)

; Genera una instancia de menú que es una copia de la instancia que pasamos
; por parámetro
(deffunction generacion_resultados::crea_copia_menu (?menu)
    (bind ?inst (gensym))
    (make-instance ?inst of Menu
         (Primero (send ?menu get-Primero))
         (Segundo (send ?menu get-Segundo))
         (Postre  (send ?menu get-Postre ))
         (PuntuacionMenu (send ?menu get-PuntuacionMenu ))
         (Precio  (send ?menu get-Precio ))
    )
    (instance-name ?inst)
)

; Inserta las bebidas de la lista en el menú
(deffunction generacion_resultados::concatena_bebidas (?menu $?bebidas)
    (bind ?actuales (send ?menu get-Bebidas))
    (loop-for-count (?i 1 (length$ $?bebidas))
        (bind ?actuales (insert$ $?actuales (+ (length$ $?actuales) 1) (nth$ ?i ?bebidas)))
    )
    (send ?menu put-Bebidas ?actuales)
)

; Indica si dos bebidas son compatibles en el mismo menu o no
(deffunction generacion_resultados::son_bebidas_compatibles (?a ?b)
    (if (member ?a (send ?b get-BebidasIncompatibles)) then FALSE else TRUE)
)

; Para todos los menús generados, los divide en tres conjuntos delimitados por su precio
(defrule generacion_resultados::clasificacion_menus_rangos
    ?fact <- (rango_precios correcto)
    ?datos_evento <- (datos_evento (bebida_por_platos ?multiples_bebidas))
    ?datos_analisis <- (datos_analisis (bebidas_validas $?bebidas_validas))
    ?datos_generacion <- (datos_generacion (rango_min ?rmin) (rango_medio1 ?rmedMin) (rango_medio2 ?rmedMax) (rango_max ?rmax))
    =>
    ; Recopilamos todas las instancias de menñu que hemos creado anteriormente
    (bind ?menus (find-all-instances ((?inst Menu)) TRUE))

    ; Inicializamos tres listas vacñias para los tres rangos de precio
    (bind ?baratos (create$))
    (bind ?medios (create$))
    (bind ?caros (create$))

    ; Por cada menú, lo intentamos clasificar en uno de los  tres rangos de precio
    (loop-for-count (?i 1 (length$ $?menus))
        (bind ?menu_i (nth$ ?i ?menus))
        (bind ?inserted_to_baratos FALSE)
        (bind ?inserted_to_medios FALSE)
        (bind ?inserted_to_caros FALSE)
        (bind ?bebidas_primero (send (send ?menu_i get-Primero) get-BebidasRecomendadas))
        (bind ?bebidas_segundo (send (send ?menu_i get-Segundo) get-BebidasRecomendadas))
        (loop-for-count (?i 1 (length$ $?bebidas_primero))
            (bind ?bebida_i (nth$ ?i ?bebidas_primero))
            (if (member ?bebida_i ?bebidas_validas) then
                (loop-for-count (?j 1 (length$ $?bebidas_segundo))
                    (bind ?bebida_j (nth$ ?j ?bebidas_segundo))
                    (if (member ?bebida_j ?bebidas_validas) then
                        (bind ?nuevo_precio -1)
                        (if ?multiples_bebidas then
                            (if (and (not (eq (instance-name ?bebida_i) (instance-name ?bebida_j))) (son_bebidas_compatibles ?bebida_i ?bebida_j)) then
                                (bind ?nuevo_precio (+ (send ?menu_i get-Precio) (* (+ (send ?bebida_i get-Precio) (send ?bebida_j get-Precio)) 0.5)))
                            )
                        else
                            (if (eq (instance-name ?bebida_i) (instance-name ?bebida_j)) then
                                (bind ?nuevo_precio (+ (send ?menu_i get-Precio) (* (send ?bebida_i get-Precio) 0.5)))
                            )
                        )
                        ; Intentamos asignar el menú en uno de los rangos
                        (if (not(= ?nuevo_precio -1)) then
                            (if (is_in_range ?nuevo_precio ?rmin ?rmedMin) then
                                (if (not ?inserted_to_baratos) then
                                    (bind ?menu_i_barato (crea_copia_menu ?menu_i))
                                    (bind ?baratos (insert$ $?baratos (+ (length$ $?baratos) 1) ?menu_i_barato))
                                    (bind ?inserted_to_baratos TRUE)
                                )
                                (if ?multiples_bebidas then (concatena_bebidas ?menu_i_barato ?bebida_i ?bebida_j)
                                else (concatena_bebidas ?menu_i_barato ?bebida_i))
                            )
                            (if (is_in_range ?nuevo_precio ?rmedMin ?rmedMax) then
                                (if (not ?inserted_to_medios) then
                                    (bind ?menu_i_medio (crea_copia_menu ?menu_i))
                                    (bind ?medios (insert$ $?medios (+ (length$ $?medios) 1) ?menu_i_medio))
                                    (bind ?inserted_to_medios TRUE)
                                )
                                (if ?multiples_bebidas then (concatena_bebidas ?menu_i_medio ?bebida_i ?bebida_j)
                                else (concatena_bebidas ?menu_i_medio ?bebida_i))
                            )
                            (if (is_in_range ?nuevo_precio ?rmedMax ?rmax) then
                                (if (not ?inserted_to_caros) then
                                    (bind ?menu_i_caro (crea_copia_menu ?menu_i))
                                    (bind ?caros (insert$ $?caros (+ (length$ $?caros) 1) ?menu_i_caro))
                                    (bind ?inserted_to_caros TRUE)
                                )
                                (if ?multiples_bebidas then (concatena_bebidas ?menu_i_caro ?bebida_i ?bebida_j)
                                else (concatena_bebidas ?menu_i_caro ?bebida_i))
                            )
                        )
                    )
                )
            )
        )
    )

    ; Inicializa las listas para los tres rangos de precio
    (modify ?datos_generacion (menus_primer_rango ?baratos) (menus_segundo_rango ?medios) (menus_tercer_rango ?caros))
    (retract ?fact)
    (assert (imprime_solucion FALSE))
)

; Devuelve TRUE si, entre dos menús, el número de platos que coinciden es menor
; o igual que nc. En caso contrario, devuelve FALSE.
(deffunction generacion_resultados::numero_coincidencias (?m1 ?m2)
    (bind ?num_coincidencias 0)
    (if (eq (instance-name (send ?m1 get-Primero)) (instance-name (send ?m2 get-Primero))) then (bind ?num_coincidencias (+ 1 ?num_coincidencias)))
    (if (eq (instance-name (send ?m1 get-Segundo)) (instance-name (send ?m2 get-Primero))) then (bind ?num_coincidencias (+ 1 ?num_coincidencias)))
    (if (eq (instance-name (send ?m1 get-Primero)) (instance-name (send ?m2 get-Segundo))) then (bind ?num_coincidencias (+ 1 ?num_coincidencias)))
    (if (eq (instance-name (send ?m1 get-Segundo)) (instance-name (send ?m2 get-Segundo))) then (bind ?num_coincidencias (+ 1 ?num_coincidencias)))
    (if (eq (instance-name (send ?m1 get-Postre)) (instance-name (send ?m2 get-Postre))) then (bind ?num_coincidencias (+ 1 ?num_coincidencias)))

    ?num_coincidencias
)

; Añade las bebidas a un menú
(deffunction generacion_resultados::anadir_bebidas_a_menu (?menu ?mult)
    (bind ?bebidas (send ?menu get-Bebidas))
    ;(if (eq (length$ $?bebidas) 0) then (printout t "WHAT THE HELL IS GOING ON" crlf))
    (if ?mult then
        (bind ?index (* (random 1 (/ (length$ $?bebidas) 2)) 2))
        (send ?menu put-Bebidas (nth$ (- ?index 1) ?bebidas) (nth$ ?index ?bebidas))
    else
        (if (eq (length$ $?bebidas) 1) then (bind ?index 1) else
            (bind ?index (random 1 (length$ $?bebidas)))
        )
        (send ?menu put-Bebidas (nth$ ?index ?bebidas))
    )
    (send ?menu calcula_precio)
    ?menu
)

; De los menus preseleccionados que pueden ir a cada rango se intenta escoger tres de los que tengan mayor puntuación dando prioridad
; (medio > barato > caro) de modo que haya el menor numero de coincidencias de platos entre menus (hasta un máximo de 3, es decir, todos).
; Si alguno de los rangos está vacío se selecciona solo un menú siguiendo las mismas prioridades y si todos estan vacíos no se selecciona ninguno.
(defrule generacion_resultados::seleccion_menus_correctos
    ?fact <- (imprime_solucion FALSE)
    ?datos_evento <- (datos_evento (bebida_por_platos ?multiples_bebidas))
    ?datos_generacion <- (datos_generacion (rango_min ?rmin) (rango_medio1 ?rmedMin) (rango_medio2 ?rmedMax) (rango_max ?rmax) (menus_primer_rango $?baratos) (menus_segundo_rango $?medios) (menus_tercer_rango $?caros))
    =>
    (bind ?baratos (sort ordenMenus ?baratos))
    (bind ?medios (sort ordenMenus ?medios))
    (bind ?caros (sort ordenMenus ?caros))

    (bind ?solucion (create$))
    (bind ?solution_found FALSE)
    (loop-for-count (?coincidencias 0 3)
        (loop-for-count (?i 1 (length$ $?medios))
            (bind ?menu_medio (nth$ ?i ?medios))
            (loop-for-count (?j 1 (length$ $?baratos))
                (bind ?menu_barato (nth$ ?j ?baratos))
                (bind ?num_coincidencias_mb (numero_coincidencias ?menu_medio ?menu_barato))
                (if (<= ?num_coincidencias_mb 1) then
                    (loop-for-count (?k 1 (length$ $?caros))
                        (bind ?menu_caro (nth$ ?k ?caros))
                        (bind ?num_coincidencias_mc (numero_coincidencias ?menu_medio ?menu_caro))
                        (bind ?suma_coincidencias (+ ?num_coincidencias_mc  ?num_coincidencias_mb))
                        (if (<= ?suma_coincidencias ?coincidencias) then
                            (bind ?num_coincidencias_bc (numero_coincidencias ?menu_barato ?menu_caro))
                            (bind ?suma_coincidencias (+ ?suma_coincidencias  ?num_coincidencias_bc))
                            (if (<= ?suma_coincidencias ?coincidencias) then
                                (bind ?solucion (insert$ $?solucion 1 (anadir_bebidas_a_menu ?menu_barato ?multiples_bebidas)))
                                (bind ?solucion (insert$ $?solucion 2 (anadir_bebidas_a_menu ?menu_medio ?multiples_bebidas)))
                                (bind ?solucion (insert$ $?solucion 3 (anadir_bebidas_a_menu ?menu_caro ?multiples_bebidas)))
                                (bind ?solution_found TRUE)
                            )
                        )
                        (if ?solution_found then (break))
                    )
                )
                (if ?solution_found then (break))
            )
            (if ?solution_found then (break))
        )
        (if ?solution_found then (break))
    )

    ; Si no hemos sido capaces de seleccionar almenos un menú para cada rango de precio,
    ; elegimos uno de los menús generados y lo insertamos en la solución.
    (if (not ?solution_found) then
        (if (not (= (length$ $?medios) 0)) then
            (bind ?solucion (insert$ $?solucion 1 (anadir_bebidas_a_menu (nth$ 1 $?medios) ?multiples_bebidas)))
        else
            (if (not (= (length$ $?baratos) 0)) then
                (bind ?solucion (insert$ $?solucion 1 (anadir_bebidas_a_menu (nth$ 1 $?baratos) ?multiples_bebidas)))
            else
                (if (not (= (length$ $?caros) 0)) then
                    (bind ?solucion (insert$ $?solucion 1 (anadir_bebidas_a_menu (nth$ 1 $?caros) ?multiples_bebidas)))
                )
            )
        )
    )

    (modify ?datos_generacion (solucion ?solucion))
    (retract ?fact)
    (assert (imprime_solucion TRUE))
)

; Se imprimen por salida estándar todos los menus que se han seleccionado como parte de la solucion.
; Si por algun motivo no hay 3 menus, se informa del motivo.
(defrule generacion_resultados::mostrar_soluciones
    ?fact <- (imprime_solucion TRUE)
    ?datos_generacion <- (datos_generacion (edge_case_menu ?edge_case) (solucion $?sol))
    =>
    ; Si solo hemos encontrado una solución, explicamos el motivo y la mostramos por pantalla
    (if (= (length$ $?sol) 1) then
        (if (not (eq ?edge_case [nil])) then
            (printout t "Actualmente, por desgracia, no disponemos de un menú que entre en el rango de precios dado, aún así," crlf)
            (printout t "a continuación le hacemos la propuesta que más se acerca a su presupuesto cumpliendo sus preferencias." crlf)
        else
            (printout t "Por desgracia no hemos encontrado 3 menús que se ajusten a sus preferencias" crlf) ; Explicar millor que ha passat
        )
    ; Si no hemos encontrado ninguna solución, imprimimos un mensaje por pantalla
    else
        (if (= (length$ $?sol) 0) then
            (printout t "Lo sentimos mucho pero no disponemos de ningún menú que se adapte a sus preferencias en estos momentos." crlf)
        )
    )
    ; Imprimimos las soluciones encontradas
    (loop-for-count (?i 1 (length$ $?sol))
        (send (nth$ ?i ?sol) print)
    )
    (retract ?fact)
    (assert (pregunta_detallada TRUE))
)

; - Quieres ver información detallada de los platos de alguno de los menús? (s/n)
(defrule generacion_resultados::pregunta_info_detallada
    ?fact <- (pregunta_detallada TRUE)
    ?datos_generacion <- (datos_generacion (solucion $?sol))
    =>
    (bind $?posibles_respuestas (create$ ))
    (loop-for-count (?i 1 (length$ $?sol)) do
      (bind ?label (format nil "Menú número: %d" ?i))
      (bind $?posibles_respuestas (insert$ $?posibles_respuestas (+ (length$ $?posibles_respuestas) 1) ?label))
    )
    (bind ?choice (pregunta_multi_choice "¿Quiere ver información detallada de los platos de alguno de los menús?" $?posibles_respuestas))

    (loop-for-count (?i 1 (length$ ?choice)) do
      (bind ?index (nth$ ?i ?choice))
      (if (= ?index 0) then (break))
      (bind ?i_choice (nth$ ?index ?sol))
      (send ?i_choice print-details)
    )
    (retract ?fact)
)

; #########################################
; ###### MESSAGE HANDLERS DE CLASES #######
; #########################################

; Funcion para escribir por pantalla la recomendacion de un menu concreto
(defmessage-handler Menu print primary ()
  ; Nombre de los platos
  (bind ?nombre_primero (send ?self:Primero get-Nombre))
  (bind ?nombre_segundo (send ?self:Segundo get-Nombre))
  (bind ?nombre_postre  (send ?self:Postre  get-Nombre))

  ; Nombre de las bebidas
  (bind $?bebidas ?self:Bebidas)
  (bind $?nombre_bebidas (create$))
  (loop-for-count (?i 1 (length$ $?bebidas)) do
    (bind ?i_bebida (nth$ ?i ?bebidas))
    (bind ?i_nombre (send ?i_bebida get-Nombre))
    (bind $?nombre_bebidas (insert$ $?nombre_bebidas (+ (length$ $?nombre_bebidas) 1) ?i_nombre))
  )

  (printout t "-------------------------------------------------------------------------" crlf)
  (printout t "|                            MENÚ RECOMENDADO                           |" crlf)
  (printout t "=========================================================================" crlf)
  (printout t "|                           --    PLATOS    --                          |" crlf)
  (bind ?line (format nil "Primer plato:    %s" ?nombre_primero))
  (format t "|    %-63s    |%n" ?line)
  (bind ?line (format nil "Segundo plato:   %s" ?nombre_segundo))
  (format t "|    %-63s    |%n" ?line)
  (bind ?line (format nil "Postres:         %s" ?nombre_postre))
  (format t "|    %-63s    |%n" ?line)
  (printout t "-------------------------------------------------------------------------" crlf)
  (printout t "|                           --    BEBIDAS   --                          |" crlf)

  (if (= (length$ $?nombre_bebidas) 1) then
    (bind ?nombre_bebida_unica (nth$ 1 ?nombre_bebidas))
    (bind ?line (format nil "Bebida única:    %s" ?nombre_bebida_unica))
    (format t "|    %-63s    |%n" ?line)
  else
    (bind ?nombre_bebida_primero (nth$ 1 ?nombre_bebidas))
    (bind ?line (format nil "Bebida del primero: %s" ?nombre_bebida_primero))
    (format t "|    %-63s    |%n" ?line)
    (bind ?nombre_bebida_segundo (nth$ 2 ?nombre_bebidas))
    (bind ?line (format nil "Bebida del segundo: %s" ?nombre_bebida_segundo))
    (format t "|    %-63s    |%n" ?line)
  )
  (printout t "-------------------------------------------------------------------------" crlf)
  (bind ?line (format nil "              Precio total del menú: %.2f euros" ?self:Precio))
  (format t "|    %-63s    |%n" ?line)
  (printout t "-------------------------------------------------------------------------" crlf)
)

(defmessage-handler Menu print-details primary ()

  (printout t "-------------------------------------------------------------------------" crlf)
  (printout t "" crlf)

  (printout t "      PLATOS" crlf)
  (printout t "" crlf)
  ; Informacion detallada de los platos
  (printout t (send ?self:Primero get-Nombre) crlf)
  (printout t "   Descripción: " (send ?self:Primero get-InfoGeneral) crlf)
  (printout t "   Complejidad (tiempo de elaboración:)" crlf)
  (printout t "     " (send ?self:Primero get-Complejidad) " min." crlf)
  (printout t "   Estilos: " crlf)
  (bind ?estilos_prim (send ?self:Primero get-CumplePreferencias))
  (loop-for-count (?i 1 (length$ $?estilos_prim)) do
    (bind ?i_estilo (nth$ ?i ?estilos_prim))
    (printout t "     " (send ?i_estilo get-Nombre) crlf)
  )
  (printout t "   Ingredientes: " crlf)
  (bind ?ingr_prim (send ?self:Primero get-Ingredientes))
  (loop-for-count (?i 1 (length$ $?ingr_prim)) do
    (bind ?i_ingr (nth$ ?i ?ingr_prim))
    (printout t "     " (send ?i_ingr get-Nombre) crlf)
  )
  (printout t "" crlf)

  (printout t (send ?self:Segundo get-Nombre) crlf)
  (printout t "   Descripción: " (send ?self:Segundo get-InfoGeneral) crlf)
  (printout t "   Complejidad (tiempo de elaboración:)" crlf)
  (printout t "     " (send ?self:Segundo get-Complejidad) " min." crlf)
  (printout t "   Estilos: " crlf)
  (bind ?estilos_seg (send ?self:Segundo get-CumplePreferencias))
  (loop-for-count (?i 1 (length$ $?estilos_seg)) do
    (bind ?i_estilo (nth$ ?i ?estilos_seg))
    (printout t "     " (send ?i_estilo get-Nombre) crlf)
  )
  (printout t "   Ingredientes: " crlf)
  (bind ?ingr_seg (send ?self:Segundo get-Ingredientes))
  (loop-for-count (?i 1 (length$ $?ingr_seg)) do
    (bind ?i_ingr (nth$ ?i ?ingr_seg))
    (printout t "     " (send ?i_ingr get-Nombre) crlf)
  )
  (printout t "" crlf)
  (printout t "      POSTRE" crlf)
  (printout t "" crlf)

  (printout t (send ?self:Postre get-Nombre) crlf)
  (printout t "   Descripción: " (send ?self:Postre get-InfoGeneral) crlf)
  (printout t "   Complejidad (tiempo de elaboración:)" crlf)
  (printout t "     " (send ?self:Postre get-Complejidad) " min." crlf)
  (printout t "   Estilos: " crlf)
  (bind ?estilos_pos (send ?self:Postre get-CumplePreferencias))
  (loop-for-count (?i 1 (length$ $?estilos_pos)) do
    (bind ?i_estilo (nth$ ?i ?estilos_pos))
    (printout t "     " (send ?i_estilo get-Nombre) crlf)
  )
  (printout t "   Ingredientes: " crlf)
  (bind ?ingr_pos (send ?self:Postre get-Ingredientes))
  (loop-for-count (?i 1 (length$ $?ingr_pos)) do
    (bind ?i_ingr (nth$ ?i ?ingr_pos))
    (printout t "     " (send ?i_ingr get-Nombre) crlf)
  )
  (printout t "" crlf)
  (printout t "      BEBIDAS" crlf)
  (printout t "" crlf)
  ; Nombre de las bebidas
  (bind $?bebidas ?self:Bebidas)
  (bind $?nombre_bebidas (create$))
  (loop-for-count (?i 1 (length$ $?bebidas)) do
    (bind ?i_bebida (nth$ ?i ?bebidas))
    (bind ?i_nombre (send ?i_bebida get-Nombre))
    (bind ?i_alcoholica (send ?i_bebida get-BebidaAlcoholica))
    (printout t ?i_nombre crlf)
    (if ?i_alcoholica then (printout t "   Contiene alcohol" crlf) else (printout t "   Sin alcohol" crlf))
    (printout t "" crlf)
  )

  (printout t "" crlf)
  (printout t "-------------------------------------------------------------------------" crlf)
)

; handler para calcular el precio de un menu a partir de los precios individuales de sus componentes
(defmessage-handler Menu calcula_precio primary ()
  (bind ?precio_primero (send ?self:Primero get-Precio))
  (bind ?precio_segundo (send ?self:Segundo get-Precio))
  (bind ?precio_postre (send ?self:Postre get-Precio))
  (bind ?precio_bebida 0)

  (if (> (length$ ?self:Bebidas) 0) then
      (bind ?precio_bebida (send (nth$ 1 ?self:Bebidas) get-Precio))
  )

  (if (= (length$ ?self:Bebidas) 2) then
      (bind ?precio_bebida (+ ?precio_bebida (send (nth$ 2 ?self:Bebidas) get-Precio)))
  )


  (send ?self put-Precio (+ (+ (+ (* 0.5 ?precio_primero) (* 0.6 ?precio_segundo)) (* 0.3 ?precio_postre)) (* 0.5 ?precio_bebida)))

)
