import pandas as pd
import ast
import unicodedata
import re

def slugify(name: str) -> str:
    """Converteix un nom arbitrari a un símbol segur per CLIPS."""
    s = unicodedata.normalize('NFKD', str(name)).encode('ascii', 'ignore').decode('ascii')
    s = s.lower()
    s = re.sub(r'[^a-z0-9]+', '-', s)   # tot el que no és [a-z0-9] passa a '-'
    s = s.strip('-')                    # treu guions inicials/finals
    if not s:
        s = 'plat'
    if s[0].isdigit():                  # evita començar per dígit
        s = 'plat-' + s
    return s

def unique_name(base: str, used: set) -> str:
    """Garanteix noms únics afegint -2, -3, ... si cal."""
    if base not in used:
        used.add(base)
        return base
    i = 2
    while f"{base}-{i}" in used:
        i += 1
    final = f"{base}-{i}"
    used.add(final)
    return final

# Carrega el CSV
df = pd.read_csv('BASE_DEFINITIVA.csv')

# Shuffle (treu random_state si vols barreja diferent cada execució)
df = df.sample(frac=1, random_state=123).reset_index(drop=True)

used_names = set()

with open('instancies_plats.clp', 'w', encoding='utf-8') as f:
    f.write("(definstances plats-cataleg\n")

    for _, row in df.iterrows():
        # --------- te_ordre i filtre de begudes ----------
        ordre_raw = str(row['te_ordre']).strip().lower()
        if ordre_raw == "begudes":
            continue
        ordre_norm = ordre_raw.replace('"', '').replace("'", "")
        if not ordre_norm.startswith("ordre-"):
            ordre_norm = "ordre-" + ordre_norm.replace(" ", "-")
        ordre = ordre_norm

        # --------- camps bàsics ----------
        nom_text = str(row['nom_plat']).replace('"', "'")
        instance_base = slugify(nom_text)                     # sense parèntesis ni accents
        instance_name = unique_name(instance_base, used_names)

        formalitat = row.get('formalitat', 'desconeguda')
        temperatura = row.get('temperatura', 'desconeguda')

        # com a símbols (evitar espais)
        complexitat = str(row.get('complexitat', 'desconeguda')).strip().lower().replace(' ', '-')
        mida_racio  = str(row.get('mida_racio',  'desconeguda')).strip().lower().replace(' ', '-')

        preu = row.get('preu_cost', 0.0)

        # --------- apte_esdeveniment com símbols (pot venir llista o string) ----------
        raw_apte = str(row.get('apte_esdeveniment', 'tots'))
        try:
            apte_list = ast.literal_eval(raw_apte)
            if isinstance(apte_list, list):
                apte_clean = [x.strip().lower().replace(" ", "-").replace("totes", "tots") for x in apte_list if str(x).strip()]
            else:
                apte_clean = [str(apte_list).strip().lower().replace(" ", "-").replace("totes", "tots")]
        except Exception:
            apte_clean = [raw_apte.strip().lower().replace(" ", "-").replace("totes", "tots")]
        apte_str = " ".join(apte_clean) if apte_clean else "tots"

        # --------- disponibilitat_plats com símbols ----------
        dispo = str(row.get('disponibilitat_plats', "['primavera','estiu','tardor','hivern']"))
        try:
            dispo_list = ast.literal_eval(dispo)
        except Exception:
            dispo_list = [x for x in dispo.strip("[]").replace("'", "").split(",")]
        dispo_clean = [str(x).strip().lower().replace(" ", "-") for x in dispo_list if str(x).strip()]
        dispo_str = " ".join(dispo_clean) if dispo_clean else "primavera estiu tardor hivern"

        # --------- ingredients com strings ----------
        ingredients = str(row.get('ingredients', "[]"))
        try:
            ingr_list = ast.literal_eval(ingredients)
        except Exception:
            ingr_list = [x for x in ingredients.strip("[]").replace("'", "").split(",")]
        ingr_str = " ".join([f"\"{str(x).strip()}\"" for x in ingr_list if str(x).strip()])

        # --------- escriu la instància ----------
        f.write(f'  ({instance_name} of Plat\n')
        f.write(f'    (nom "{nom_text}")\n')
        f.write(f'    (formalitat "{formalitat}")\n')
        f.write(f'    (temperatura "{temperatura}")\n')
        f.write(f'    (complexitat {complexitat})\n')
        f.write(f'    (mida_racio {mida_racio})\n')
        f.write(f'    (te_ordre {ordre})\n')
        f.write(f'    (apte_esdeveniment {apte_str})\n')
        f.write(f'    (preu_cost {preu})\n')
        f.write(f'    (disponibilitat_plats {dispo_str})\n')
        f.write(f'    (te_ingredients_noms {ingr_str})\n')
        f.write("  )\n\n")

    f.write(")\n")

print("Fitxer 'instancies_plats.clp' generat correctament (begudes excloses, noms sense parèntesis).")
