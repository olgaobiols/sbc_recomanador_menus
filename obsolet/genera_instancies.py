"""
Generador d'instancies CLIPS a partir del cataleg CSV.

Usage basica:
    python3 genera_instancies.py -i cataleg_global_with_dispo_cost.csv -o instancies_cataleg.clp
"""

from __future__ import annotations

import argparse
import csv
import sys
import unicodedata
import ast
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence

# ---------------------------------------------------------------------------
# Utilities de normalitzacio i format

ESTACIONS_CANON = ("primavera", "estiu", "tardor", "hivern")
ALIASES_ESTACIONS = {
    "spring": "primavera", "summer": "estiu", "autumn": "tardor", "fall": "tardor", "winter": "hivern",
    "primavera": "primavera", "estiu": "estiu", "tardor": "tardor", "hivern": "hivern",
    "verano": "estiu", "otoño": "tardor", "invierno": "hivern",
}

def _strip_accents(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    return "".join(ch for ch in normalized if not unicodedata.combining(ch))

def _slugify(value: str) -> str:
    base = _strip_accents(value).lower()
    tokens, current = [], []
    for ch in base:
        if ch.isalnum():
            current.append(ch)
        elif current:
            tokens.append("".join(current)); current = []
    if current: tokens.append("".join(current))
    stop = {"de","del","la","el","les","els","un","una","uns","unes","amb","i","a"}
    filtered = [t for t in tokens if t not in stop]
    slug = "-".join(filtered or tokens or ["plat"])[:120].strip("-") or "plat"
    return slug if slug.startswith("plat-") else f"plat-{slug}"

def _ensure_unique(name: str, used: set[str]) -> str:
    cand, k = name, 2
    while cand in used:
        cand = f"{name}-{k}"; k += 1
    used.add(cand); return cand

def _clips_string(value: str) -> str:
    s = value.replace("\\", "\\\\").replace('"', '\\"').replace("\r\n", "\n").replace("\r", "\n").replace("\n", " ")
    return f"\"{s}\""

def _clips_symbol(value: str) -> str:
    s = value.strip().lower().replace(" ", "-").replace("·","-").replace("/","-")
    s = s.replace("’","'").replace("--","-").strip("-")
    return _strip_accents(s or "-")

def _normalize_mida(value: str) -> str:
    mapping = {"gran":"gran","mitja":"mitja","mitjo":"mitja","petit":"petita","petita":"petita","pica-pica":"pica-pica"}
    key = _strip_accents(value.strip().lower())
    return _clips_symbol(mapping.get(key, key))

def _normalize_temperatura(value: str) -> str:
    cleaned = value.strip()
    return cleaned.capitalize() if cleaned else ""

def _normalize_procedencia(value: str) -> str:
    cleaned = value.strip()
    return "" if cleaned in {"—","-"} else cleaned

def _normalize_tipus(value: str) -> str:
    mapping = {
        "primer":"ordre-primer",
        "segon":"ordre-segon",
        "postre":"ordre-postres",
        "postres":"ordre-postres",
    }
    key = value.strip().lower()
    mapped = mapping.get(key)
    if mapped is None:
        raise ValueError(f"tipus desconegut: {value!r}")
    return mapped

def _normalize_apte_event(value: str) -> str:
    return "tots" if not value or not value.strip() else _clips_symbol(value)

def _parse_list_like(s) -> list[str]:
    """Accepta '["a","b"]' o 'a,b; c' i retorna llista d'strings neta."""
    if s is None:
        return []
    s = str(s).strip()
    if not s:
        return []
    try:
        v = ast.literal_eval(s)
        if isinstance(v, (list, tuple)):
            return [str(x).strip() for x in v]
    except Exception:
        pass
    parts = re.split(r"[;,]", s)
    return [p.strip() for p in parts if p.strip()]

def _normalize_estacions_list(vals: list[str]) -> list[str]:
    """Normalitza estacions (alias → canònic), elimina duplicats i ordena primavera→hivern."""
    out = []
    seen = set()
    for v in vals:
        k = _strip_accents(str(v)).strip().lower()
        canon = ALIASES_ESTACIONS.get(k, k)
        if canon in ESTACIONS_CANON and canon not in seen:
            seen.add(canon); out.append(canon)
    # ordena segons l'ordre canònic
    order = {e:i for i,e in enumerate(ESTACIONS_CANON)}
    out.sort(key=lambda x: order.get(x, 99))
    return out

def _parse_float_monetary(value) -> float | None:
    """Converteix un valor monetari a float. Accepta formats amb €/espais, ',' o '.' com a separador decimal.
    Retorna None si és buit o '-/—'."""
    if value is None:
        return None
    s = str(value).strip()
    if not s or s in {"-", "—"}:
        return None
    # Elimina símbols comuns de moneda i espais
    s = s.replace("€", "").replace("EUR", "").replace("eur", "").replace(" ", "")
    # Normalitza separadors: detecta milers/decimals habituals
    if "," in s and "." in s:
        # Casos com 1.234,56 -> '.' milers, ',' decimals
        if s.rfind(",") > s.rfind("."):
            s = s.replace(".", "")
            s = s.replace(",", ".")
        else:
            # Casos com 1,234.56 -> ',' milers, '.' decimals
            s = s.replace(",", "")
    elif "," in s:
        s = s.replace(",", ".")
    # Conserva només dígits, signes i el punt decimal
    s = re.sub(r"[^0-9\.\-]", "", s)
    try:
        return float(s)
    except Exception:
        return None

# ---------------------------------------------------------------------------
# Estructures de dades

@dataclass(frozen=True)
class PlatRow:
    instance_name: str
    nom: str
    complexitat: str
    formalitat: str
    mida_racio: str
    temperatura: str
    procedencia: str
    te_ordre: str
    apte_esdeveniment: str
    disponibilitat_plats: List[str]   # NOVETAT
    preu_cost: float | None           # NOVETAT: slot numèric opcional
    especificacio: str
    font: str

def _looks_like_header_row(row: dict) -> bool:
    """Detecta files que en realitat repeteixen els headers."""
    sample: dict[str, str] = {}
    for k, v in row.items():
        if not isinstance(k, str):
            continue
        key = k.strip().lower()
        if isinstance(v, list):
            val = " ".join(str(x) for x in v)
        else:
            val = "" if v is None else str(v)
        sample[key] = val.strip().lower()
    return any(sample[k] == k for k in sample) or (sample.get("nom_plat", "") == "nom_plat")

def _row_to_plat(row: dict, used_names: set[str]) -> PlatRow | None:
    raw_name = (row.get("nom_plat") or "").strip()
    if not raw_name:
        return None
    instance_name = _ensure_unique(_slugify(raw_name), used_names)

    complexitat = _clips_symbol(row.get("complexitat",""))
    formalitat  = (row.get("formalitat") or "").strip()
    mida_racio  = _normalize_mida(row.get("mida_racio",""))
    temperatura = _normalize_temperatura(row.get("temperatura",""))
    procedencia = _normalize_procedencia(row.get("procedencia",""))
    especificacio = (row.get("especificacio") or "").strip()
    font = (row.get("__source") or "").strip()
    apte_esdeveniment = _normalize_apte_event(row.get("apte_esdeveniment","tots"))

    # Disponibilitat (llista d'estacions; no s'accepta 'totes' com a simbol)
    dispo_raw_list = _parse_list_like(row.get("disponibilitat_plats"))
    dispo_norm = _normalize_estacions_list(dispo_raw_list)

    # Tipus amb tolerancia: si falla, fem skip de la fila amb avís
    tipus_raw = row.get("tipus","")
    try:
        tipus = _normalize_tipus(tipus_raw)
    except ValueError:
        print(f"[WARN] Fila ignorada (tipus invàlid): nom_plat={raw_name!r}, tipus={tipus_raw!r}", file=sys.stderr)
        return None

    # Nou: parseig del preu/cost
    preu_cost = _parse_float_monetary(row.get("preu_cost"))

    return PlatRow(
        instance_name=instance_name,
        nom=raw_name,
        complexitat=complexitat,
        formalitat=formalitat,
        mida_racio=mida_racio,
        temperatura=temperatura,
        procedencia=procedencia,
        te_ordre=tipus,
        apte_esdeveniment=apte_esdeveniment,
        disponibilitat_plats=dispo_norm,
        preu_cost=preu_cost,
        especificacio=especificacio,
        font=font,
    )

# ---------------------------------------------------------------------------
# Generacio d'instancies

def _format_plat_instance(plat: PlatRow) -> List[str]:
    lines: List[str] = []
    comment_bits = []
    if plat.especificacio and plat.especificacio != "—":
        comment_bits.append(f"especificacio: {plat.especificacio}")
    if plat.font:
        comment_bits.append(f"origen: {plat.font}")
    if comment_bits:
        lines.append(f"  ; {' | '.join(comment_bits)}")

    lines.append(f"  ({plat.instance_name} of Plat")
    lines.append(f"    (nom {_clips_string(plat.nom)})")
    if plat.procedencia:
        lines.append(f"    (procedencia {_clips_string(plat.procedencia)})")
    lines.append(f"    (formalitat {_clips_string(plat.formalitat)})")
    if plat.temperatura:
        lines.append(f"    (temperatura {_clips_string(plat.temperatura)})")
    if plat.complexitat and plat.complexitat != "-":
        lines.append(f"    (complexitat {plat.complexitat})")
    if plat.mida_racio and plat.mida_racio != "-":
        lines.append(f"    (mida_racio {plat.mida_racio})")
    if plat.te_ordre and plat.te_ordre != "-":
        lines.append(f"    (te_ordre {plat.te_ordre})")
    if plat.apte_esdeveniment and plat.apte_esdeveniment != "-":
        lines.append(f"    (apte_esdeveniment {plat.apte_esdeveniment})")

    # Nou: slot numèric de preu/cost (sense cometes)
    if plat.preu_cost is not None:
        lines.append(f"    (preu_cost {plat.preu_cost:.2f})")

    # NOVETAT: bolcar el multislot disponibilitat_plats
    # esperat: (disponibilitat_plats primavera estiu ...) o buit si no hi ha dades
    if plat.disponibilitat_plats:
        # imprimeix com a símbols (sense cometes)
        vals = " ".join(_clips_symbol(s) for s in plat.disponibilitat_plats)
        lines.append(f"    (disponibilitat_plats {vals})")

    lines.append("  )")
    return lines

def generate_instances(rows: Iterable[PlatRow]) -> str:
    body_lines: List[str] = []
    for plat in rows:
        body_lines.extend(_format_plat_instance(plat))
    return (
        ";;; Fitxer generat automaticament per genera_instancies.py\n"
        ";;; Conte les instancies de la classe Plat derivades de cataleg_global_with_dispo_cost.csv\n\n"
        "(definstances plats-cataleg\n"
        + "\n".join(body_lines) + "\n"
        ")\n"
    )

# ---------------------------------------------------------------------------
# CSV IO

def read_csv(path: Path) -> List[dict]:
    if not path.exists():
        raise FileNotFoundError(f"No s'ha trobat el fitxer CSV: {path}")
    text = path.read_text(encoding="utf-8-sig")  # elimina BOM si hi és
    # Sniff del dialecte per si el separador no es coma
    try:
        sniffer = csv.Sniffer()
        dialect = sniffer.sniff(text.splitlines()[0] + "\n" + text.splitlines()[1])
    except Exception:
        dialect = csv.excel  # fallback: coma
    rows: List[dict] = []
    reader = csv.DictReader(text.splitlines(), dialect=dialect)
    for r in reader:
        if _looks_like_header_row(r):
            print("[WARN] S'ha detectat i saltat una fila d'encapçalament duplicada.", file=sys.stderr)
            continue
        rows.append(r)
    return rows

# ---------------------------------------------------------------------------
# CLI

def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Genera instancies CLIPS a partir d'un CSV.")
    p.add_argument("-i","--input", type=Path, default=Path("cataleg_global_with_dispo_cost.csv"),
                   help="Ruta al CSV d'entrada (per defecte: cataleg_global_with_dispo_cost.csv).")
    p.add_argument("-o","--output", type=Path, default=Path("instancies_cataleg.clp"),
                   help="Fitxer CLP de sortida (per defecte: instancies_cataleg.clp).")
    return p.parse_args(argv)

def main(argv: Sequence[str] | None = None) -> None:
    args = parse_args(argv)
    rows = read_csv(args.input)

    used_names: set[str] = set()
    plats: List[PlatRow] = []
    for raw in rows:
        if not raw: 
            continue
        plat = _row_to_plat(raw, used_names)
        if plat is not None:
            plats.append(plat)

    if not plats:
        raise RuntimeError("El CSV no conte plats valids per generar instancies.")

    out = generate_instances(plats)
    args.output.write_text(out, encoding="utf-8")
    print(f"S'han generat {len(plats)} instancies a {args.output.resolve()}")

if __name__ == "__main__":
    main()
