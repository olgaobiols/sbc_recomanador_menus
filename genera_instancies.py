
"""
Generador d'instancies CLIPS a partir del cataleg CSV.

Usage basica:
    python3 genera_instancies.py -i cataleg_global.csv -o instancies_cataleg.clp

El fitxer de sortida s'escriu en format `definstances` amb les instancies de la
classe `Plat`, mirroring the structure used in the ontology (`v8_ontologia.clp`)
and the toy instances (`instancies_prova.clp`).
"""

from __future__ import annotations

import argparse
import csv
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, List, Sequence

# ---------------------------------------------------------------------------
# Utilities de normalitzacio i format


def _strip_accents(value: str) -> str:
    """Remove diacritics while keeping base characters."""
    normalized = unicodedata.normalize("NFKD", value)
    return "".join(char for char in normalized if not unicodedata.combining(char))


def _slugify(value: str) -> str:
    """
    Converteix una cadena a un identificador valid per a instancies CLIPS.
    Exemple: "Llobarro al forn" -> "plat-llobarro-al-forn".
    """
    base = _strip_accents(value).lower()
    tokens = []
    current = []
    for char in base:
        if char.isalnum():
            current.append(char)
        elif current:
            tokens.append("".join(current))
            current = []
    if current:
        tokens.append("".join(current))

    # Elimina paraules buides tipiques que no aporten significado
    stopwords = {
        "de",
        "del",
        "la",
        "el",
        "les",
        "els",
        "un",
        "una",
        "uns",
        "unes",
        "amb",
        "i",
        "a",
    }
    filtered = [token for token in tokens if token not in stopwords]
    slug = "-".join(filtered or tokens or ["plat"])
    slug = slug[:120].strip("-") or "plat"
    if not slug.startswith("plat-"):
        slug = f"plat-{slug}"
    return slug


def _ensure_unique(name: str, used: set[str]) -> str:
    """Guarantee que el nom d'instancia es unic."""
    candidate = name
    suffix = 2
    while candidate in used:
        candidate = f"{name}-{suffix}"
        suffix += 1
    used.add(candidate)
    return candidate


def _clips_string(value: str) -> str:
    """Wrap string amb cometes escapant les cometes internes."""
    escaped = value.replace('"', r"\"")
    return f"\"{escaped}\""


def _clips_symbol(value: str) -> str:
    """Normalitza un valor per tractar-lo com a simbol CLIPS."""
    lowered = value.strip().lower()
    lowered = lowered.replace(" ", "-")
    lowered = lowered.replace("·", "-").replace("/", "-")
    lowered = lowered.replace("’", "'")
    lowered = lowered.replace("--", "-")
    lowered = lowered.strip("-")
    return _strip_accents(lowered or "-")


def _normalize_mida(value: str) -> str:
    """Adapta el valor de mida de racio a la nomenclatura esperada."""
    mapping = {
        "gran": "gran",
        "mitja": "mitja",
        "mitjo": "mitja",
        "petit": "petita",
        "petita": "petita",
        "pica-pica": "pica-pica",
    }
    key = value.strip().lower()
    key_ascii = _strip_accents(key)
    normalized = mapping.get(key_ascii, key_ascii)
    return _clips_symbol(normalized)


def _normalize_temperatura(value: str) -> str:
    """Capitalitza la temperatura per millorar la lectura."""
    cleaned = value.strip()
    return cleaned.capitalize() if cleaned else ""


def _normalize_procedencia(value: str) -> str:
    """Uniformitza el text de procedencia, substituint guions per buit."""
    cleaned = value.strip()
    return "" if cleaned in {"—", "-"} else cleaned


def _normalize_tipus(value: str) -> str:
    """Mapeig directe del tipus del CSV a les instancies d'Ordre."""
    mapping = {
        "primer": "ordre-primer",
        "segon": "ordre-segon",
        "postre": "ordre-postres",
    }
    key = value.strip().lower()
    mapped = mapping.get(key)
    if mapped is None:
        raise ValueError(f"No s'ha pogut mapar el tipus '{value}' a una instancia d'Ordre.")
    return mapped


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
    especificacio: str
    font: str


def _row_to_plat(row: dict, used_names: set[str]) -> PlatRow | None:
    raw_name = (row.get("nom_plat") or "").strip()
    if not raw_name:
        return None

    instance_base = _slugify(raw_name)
    instance_name = _ensure_unique(instance_base, used_names)

    complexitat = _clips_symbol(row.get("complexitat", ""))
    formalitat = (row.get("formalitat") or "").strip()
    mida_racio = _normalize_mida(row.get("mida_racio", ""))
    temperatura = _normalize_temperatura(row.get("temperatura", ""))
    procedencia = _normalize_procedencia(row.get("procedencia", ""))
    tipus = _normalize_tipus(row.get("tipus", ""))

    especificacio = (row.get("especificacio") or "").strip()
    font = (row.get("__source") or "").strip()

    return PlatRow(
        instance_name=instance_name,
        nom=raw_name,
        complexitat=complexitat,
        formalitat=formalitat,
        mida_racio=mida_racio,
        temperatura=temperatura,
        procedencia=procedencia,
        te_ordre=tipus,
        especificacio=especificacio,
        font=font,
    )


# ---------------------------------------------------------------------------
# Generacio d'instancies


def _format_plat_instance(plat: PlatRow) -> List[str]:
    """
    Construeix el bloc de text per a una instancia `Plat`.
    S'utilitzen comentaris per conservar informacio addicional del CSV
    (especificacio i origen del registre) sense requerir nous slots.
    """
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
    lines.append("  )")
    return lines


def generate_instances(rows: Iterable[PlatRow]) -> str:
    """Uneix totes les instancies en un bloc `definstances`."""
    body_lines: List[str] = []
    for plat in rows:
        body_lines.extend(_format_plat_instance(plat))
    joined_body = "\n".join(body_lines)
    return (
        ";;; Fitxer generat automaticament per genera_instancies.py\n"
        ";;; Conte les instancies de la classe Plat derivades de cataleg_global.csv\n\n"
        "(definstances plats-cataleg\n"
        f"{joined_body}\n"
        ")\n"
    )


# ---------------------------------------------------------------------------
# CLI


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Genera instancies CLIPS a partir d'un CSV.")
    parser.add_argument(
        "-i",
        "--input",
        type=Path,
        default=Path("cataleg_global.csv"),
        help="Ruta al CSV d'entrada (per defecte: cataleg_global.csv).",
    )
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        default=Path("instancies_cataleg.clp"),
        help="Fitxer CLP de sortida (per defecte: instancies_cataleg.clp).",
    )
    return parser.parse_args(argv)


def read_csv(path: Path) -> List[dict]:
    if not path.exists():
        raise FileNotFoundError(f"No s'ha trobat el fitxer CSV: {path}")
    with path.open(encoding="utf-8") as handle:
        return list(csv.DictReader(handle))


def main(argv: Sequence[str] | None = None) -> None:
    args = parse_args(argv)
    rows = read_csv(args.input)

    used_names: set[str] = set()
    plats: List[PlatRow] = []
    for raw_row in rows:
        plat = _row_to_plat(raw_row, used_names)
        if plat is not None:
            plats.append(plat)

    if not plats:
        raise RuntimeError("El CSV no conte plats valids per generar instancies.")

    output_text = generate_instances(plats)
    args.output.write_text(output_text, encoding="utf-8")

    print(f"S'han generat {len(plats)} instancies a {args.output.resolve()}")


if __name__ == "__main__":
    main()
