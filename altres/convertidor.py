# csv_a_clips.py
# Converteix un CSV (com el teu) a instàncies CLIPS (classe Plat)
# Ús:
#   python csv_a_clips.py plats_catalans_bonviveur.csv sortida.clp
# Si no passes arguments: llegeix "plats_catalans_bonviveur.csv" i escriu "plats_catalans.clp"

import csv
import re
import sys
import unicodedata
from pathlib import Path

# ---------- Helpers de normalització ----------
def strip_accents(s: str) -> str:
    if not isinstance(s, str):
        s = str(s or "")
    nfkd = unicodedata.normalize("NFKD", s)
    return "".join(c for c in nfkd if not unicodedata.combining(c))

def slugify_token(s: str) -> str:
    """Converteix a símbol CLIPS: minúscula, sense accents, amb guions, sense caràcters rars."""
    s = s.strip()
    s = strip_accents(s).lower()
    s = re.sub(r"\([^)]*\)", " ", s)                     # treu parèntesis
    s = re.sub(r"[·•×/|,;:]+", " ", s)                  # separadors → espais
    s = re.sub(r"\s+", " ", s).strip()
    stop = {"de","del","la","el","los","las","un","una","unos","unas","y","o","con","sin","al","a","en","para"}
    parts = [p for p in s.split() if p not in stop]
    s = "-".join(parts)
    s = re.sub(r"[^a-z0-9\-]", "", s)                   # només lletres/números/guions
    s = re.sub(r"-+", "-", s).strip("-")
    return s

def make_instance_name(nombre: str, used: set) -> str:
    base = slugify_token(nombre) or "plat"
    name = f"plat-{base}"
    i = 2
    while name in used:
        name = f"plat-{base}-{i}"
        i += 1
    used.add(name)
    return name

def parse_ingredients(raw: str) -> list:
    """
    Rep 'a | b | c' i retorna ['a','b','c'] com símbols CLIPS (normalitzats).
    Si queda buit, retorna ['-'].
    """
    if not raw:
        return ["-"]
    parts = re.split(r"\s*\|\s*|\s*;\s*|\s*/\s*", raw)
    out = []
    for p in parts:
        p = p.strip()
        if not p:
            continue
        # neteja quantitats residus
        p = re.sub(r"\b\d+(?:[.,]\d+)?\b", " ", p)
        p = re.sub(r"\b(g|gr|kg|mg|ml|l|litros?|cucharadas?|cucharaditas?|tazas?|vasos?|unidades?|uds?)\b\.?", " ", p, flags=re.I)
        p = re.sub(r"\s+", " ", p).strip()
        tok = slugify_token(p)
        if tok:
            out.append(tok)
    # dedup preservant ordre
    seen, clean = set(), []
    for t in out:
        if t not in seen:
            seen.add(t)
            clean.append(t)
    return clean or ["-"]

def q(s: str) -> str:
    """ Posa cometes dobles escapant-les si cal """
    s = (s or "").strip()
    s = s.replace('"', r'\"')
    return f"\"{s}\""

def placeholder(s: str) -> str:
    s = (s or "").strip()
    return s if s else "-"

def write_slot(f, slot_name: str, value, force_string: bool = True):
    """
    Escriu un slot:
      - si és llista → multicamp
      - si és string/num → escriu string i posa '-' si buit
      - si és float → escriu com a número sense cometes
    """
    if isinstance(value, list):
        if not value:
            value = ["-"]
        f.write(f"   ({slot_name} {' '.join(value)})\n")
    elif isinstance(value, float):
        f.write(f"   ({slot_name} {value})\n")
    else:
        val = placeholder(str(value) if value is not None else "")
        f.write(f"   ({slot_name} {q(val)})\n")

# ---------- Conversió principal ----------
def csv_a_clips(in_csv: Path, out_clp: Path):
    # Columnes esperades:
    # nombre, Orden, compatibilidad, temperatura, procedencia plato, complejidad,
    # precio de venta, formalitat, ingredientes, (url ignorat)
    rows = []
    with in_csv.open("r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    used_names = set()
    with out_clp.open("w", encoding="utf-8") as f:
        f.write(";;; Instàncies generades automàticament des del CSV\n\n")
        count = 0
        for r in rows:
            nombre = (r.get("nombre") or "").strip()
            if not nombre:
                continue

            inst = make_instance_name(nombre, used_names)
            ingredientes = parse_ingredients(r.get("ingredientes",""))

            orden        = (r.get("Orden") or "").strip()
            compat       = (r.get("compatibilidad") or "").strip()
            temp         = (r.get("temperatura") or "").strip()
            procedencia  = (r.get("procedencia plato") or "").strip()
            comple       = (r.get("complejidad") or "").strip()
            formalitat   = (r.get("formalitat") or "").strip()

            # preu com FLOAT
            preu_raw = (r.get("precio de venta") or "").strip()
            if preu_raw:
                # normalitza decimal
                try:
                    preu_val = float(preu_raw.replace(',', '.'))
                except ValueError:
                    preu_val = 0.0  # valor per defecte per preus invàlids
            else:
                preu_val = 0.0  # valor per defecte per preus buits

            f.write(f"(make-instance {inst}\n")
            f.write("   of Plat\n")
            write_slot(f, "nom", nombre)
            write_slot(f, "orden", orden)
            write_slot(f, "compatibilitat", compat)
            write_slot(f, "temperatura", temp)
            write_slot(f, "procedencia", procedencia)
            write_slot(f, "complexitat", comple)
            write_slot(f, "preu", preu_val)            # float value
            write_slot(f, "formalitat", formalitat)
            write_slot(f, "ingredients", ingredientes) # multicamp (o '-')
            f.write(")\n\n")
            count += 1

        f.write(f";;; Total d'instàncies: {count}\n")

def main():
    in_path = Path(sys.argv[1]) if len(sys.argv) >= 2 else Path("plats_catalans_bonviveur.csv")
    out_path = Path(sys.argv[2]) if len(sys.argv) >= 3 else Path("plats_catalans.clp")

    if not in_path.exists():
        print(f" No s'ha trobat el CSV: {in_path}")
        sys.exit(1)

    csv_a_clips(in_path, out_path)
    print(f" Fitxer CLIPS generat: {out_path.resolve()}")

if __name__ == "__main__":
    main()
