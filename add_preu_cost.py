import ast
import csv
import math
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Sequence, Tuple


INPUT_PATH = Path("cataleg_global_with_dispo.csv")
OUTPUT_PATH = Path("cataleg_global_with_dispo_cost.csv")


def normalize(text: str) -> str:
    """Return lowercase ascii without accents."""
    if not text:
        return ""
    normalized = unicodedata.normalize("NFKD", text)
    return normalized.encode("ascii", "ignore").decode("ascii").lower()


def parse_list(raw: Optional[str]) -> List[str]:
    """Parse ingredient-like columns stored as Python-like lists or comma strings."""
    if raw is None:
        return []
    raw = raw.strip()
    if not raw:
        return []
    safe = (
        raw.replace("’", "'")
        .replace("‘", "'")
        .replace("“", '"')
        .replace("”", '"')
    )
    try:
        parsed = ast.literal_eval(safe)
        if isinstance(parsed, (list, tuple)):
            return [str(item) for item in parsed]
    except (SyntaxError, ValueError):
        pass
    parts = [part.strip(" []'\"") for part in safe.split(",")]
    return [part for part in parts if part]


@dataclass(frozen=True)
class FamilyRule:
    name: str
    priority: int
    cost_range: Tuple[float, float]
    keywords: Tuple[str, ...]


FAMILY_RULES: Tuple[FamilyRule, ...] = (
    FamilyRule(
        name="seafood",
        priority=100,
        cost_range=(6.0, 9.0),
        keywords=(
            "gamba",
            "llagosti",
            "escamarla",
            "escamarlan",
            "musclo",
            "cloissa",
            "calamar",
            "pop",
            "sipa",
            "clotxina",
            "clotxines",
            "llamntol",
            "llamanto",
            "bogavante",
            "lobster",
            "navalla",
            "ostra",
        ),
    ),
    FamilyRule(
        name="beef_premium",
        priority=95,
        cost_range=(6.5, 8.5),
        keywords=(
            "entrecot",
            "filet",
            "solomillo",
            "chulet",
            "tbone",
            "wagyu",
            "angus",
            "kobe",
        ),
    ),
    FamilyRule(
        name="beef",
        priority=90,
        cost_range=(5.5, 7.0),
        keywords=(
            "vedella",
            "vaca",
            "ossobuco",
            "bistec",
            "rag",
            "ragout",
            "rostit de vedella",
            "rostit",
        ),
    ),
    FamilyRule(
        name="lamb_goat",
        priority=85,
        cost_range=(5.5, 7.5),
        keywords=(
            "xai",
            "anyell",
            "corder",
            "cabra",
            "cabrit",
        ),
    ),
    FamilyRule(
        name="blue_fish",
        priority=80,
        cost_range=(5.0, 7.0),
        keywords=(
            "tonyina",
            "verat",
            "sardina",
            "sardines",
            "bonitol",
            "salmo",
            "seito",
            "seit",
            "anxova",
        ),
    ),
    FamilyRule(
        name="white_fish",
        priority=70,
        cost_range=(4.5, 6.0),
        keywords=(
            "llobarro",
            "lluc",
            "bacalla",
            "orada",
            "dorada",
            "daurada",
            "rap",
            "merluza",
            "mero",
            "peix",
        ),
    ),
    FamilyRule(
        name="pork",
        priority=60,
        cost_range=(3.5, 4.5),
        keywords=(
            "porc",
            "llom",
            "secret",
            "costella",
            "panceta",
            "cansalada",
            "botifarra",
            "presa",
            "iberic",
            "iberica",
        ),
    ),
    FamilyRule(
        name="poultry",
        priority=50,
        cost_range=(3.0, 4.0),
        keywords=(
            "pollastre",
            "gall dindi",
            "dindi",
            "pit de pollastre",
            "cuixa",
            "ala",
            "pav",
            "anec",
            "magret",
            "conill",
        ),
    ),
    FamilyRule(
        name="eggs_cheese",
        priority=40,
        cost_range=(2.5, 3.5),
        keywords=(
            "ou",
            "truita",
            "formatge",
            "ricotta",
            "mascarpone",
            "mozzarella",
        ),
    ),
    FamilyRule(
        name="cereals",
        priority=35,
        cost_range=(2.0, 3.5),
        keywords=(
            "arros",
            "arrs",  # safeguard for missing accent
            "risotto",
            "pasta",
            "macarron",
            "lasanya",
            "lasagna",
            "fideua",
            "couscous",
            "paella",
            "noodle",
            "gnocchi",
        ),
    ),
    FamilyRule(
        name="veg",
        priority=30,
        cost_range=(1.5, 2.5),
        keywords=(
            "verdura",
            "crema",
            "carabassa",
            "pastanaga",
            "espinac",
            "bolet",
            "xampinyo",
            "alberginia",
            "carbasso",
            "amanida",
            "patata",
            "mongeta",
            "cigr",
            "llentia",
            "col",
            "brocoli",
            "coliflor",
            "carxofa",
            "carxofes",
            "esparrec",
            "esparrecs",
        ),
    ),
    FamilyRule(
        name="dessert_elaborate",
        priority=25,
        cost_range=(1.8, 3.5),
        keywords=(
            "pastis",
            "mousse",
            "tiraminu",
            "tiramisu",
            "coulant",
            "cheesecake",
            "torta",
            "boda",
        ),
    ),
    FamilyRule(
        name="dessert_simple",
        priority=20,
        cost_range=(0.8, 1.5),
        keywords=(
            "fruita",
            "iogurt",
            "flam",
            "natilla",
            "pannacotta",
            "galeta",
            "magdalena",
            "brownie",
        ),
    ),
)


COMPLEXITY_ADJ: Dict[str, float] = {
    "baixa": 0.0,
    "mitjana": 0.3,
    "media": 0.3,
    "mitja": 0.3,
    "alta": 0.6,
}

SIZE_ADJ: Dict[str, float] = {
    "petita": -0.3,
    "petit": -0.3,
    "mini": -0.3,
    "mitjana": 0.0,
    "mitja": 0.0,
    "mitjo": 0.0,
    "mitja raccio": 0.0,
    "gran": 0.5,
    "gran raccio": 0.5,
    "doble": 0.7,
    "familiar": 0.7,
}

PREMIUM_KEYWORDS = (
    "wagyu",
    "llamntol",
    "llamanto",
    "bogavante",
    "angus",
    "kobe",
    "foie",
    "caviar",
)


def collect_tokens(row: Dict[str, str]) -> List[str]:
    raw_pieces: List[str] = []
    for key in ("ingredients", "llista_ingredients"):
        raw_pieces.extend(parse_list(row.get(key)))
    if not raw_pieces:
        raw_pieces.append(row.get("nom_plat", ""))
    raw_pieces.append(row.get("nom_plat", ""))
    tokens: List[str] = []
    for piece in raw_pieces:
        if not piece:
            continue
        norm = normalize(piece)
        if not norm:
            continue
        tokens.append(norm)
        tokens.extend(
            sub for sub in norm.replace("/", " ").replace("-", " ").split() if sub
        )
    return tokens


def detect_family(tokens: Sequence[str], row: Dict[str, str], assumptions: List[str]) -> FamilyRule:
    found: List[Tuple[int, FamilyRule]] = []
    tokens_joined = " ".join(tokens)
    tip = normalize(row.get("tipus", ""))

    # Desserts: prioritise based on tipus when explicit.
    if "postre" in tip or "dolc" in tip:
        for rule in FAMILY_RULES:
            if rule.name.startswith("dessert"):
                for kw in rule.keywords:
                    if kw and kw in tokens_joined:
                        return rule
        return next(rule for rule in FAMILY_RULES if rule.name == "dessert_simple")

    for rule in FAMILY_RULES:
        for kw in rule.keywords:
            if kw and any(kw in token for token in tokens):
                found.append((rule.priority, rule))
                break

    if not found and tokens:
        name_hint = tokens_joined
        if any(word in name_hint for word in ("paella", "risotto", "arros", "fideua")):
            return next(rule for rule in FAMILY_RULES if rule.name == "cereals")
        if any(word in name_hint for word in ("hamburguesa", "burger")):
            return next(rule for rule in FAMILY_RULES if rule.name.startswith("beef"))

    if not found:
        if "primer" in tip:
            assumptions.append(
                f"Assumed veg base for '{row.get('nom_plat', '').strip()}' due to missing ingredient signals."
            )
            return next(rule for rule in FAMILY_RULES if rule.name == "veg")
        if "postre" in tip:
            assumptions.append(
                f"Assumed dessert simple for '{row.get('nom_plat', '').strip()}' due to missing ingredient signals."
            )
            return next(rule for rule in FAMILY_RULES if rule.name == "dessert_simple")
        assumptions.append(
            f"Assumed poultry base for '{row.get('nom_plat', '').strip()}' due to missing ingredient signals."
        )
        return next(rule for rule in FAMILY_RULES if rule.name == "poultry")

    found.sort(key=lambda item: item[0], reverse=True)
    return found[0][1]


def midpoint(cost_range: Tuple[float, float]) -> float:
    return (cost_range[0] + cost_range[1]) / 2.0


def is_premium(row: Dict[str, str], tokens: Sequence[str]) -> bool:
    name_norm = normalize(row.get("nom_plat", ""))
    combined = " ".join(tokens) + " " + name_norm
    return any(keyword in combined for keyword in PREMIUM_KEYWORDS)


def seasonal_adjustment(row: Dict[str, str], assumptions: List[str]) -> float:
    dispon = normalize(row.get("disponibilitat", ""))
    if dispon:
        if "baixa" in dispon or "escassa" in dispon:
            return 0.4
        if "mitja" in dispon or "mitjana" in dispon:
            return 0.2
        return 0.0

    seasons = parse_list(row.get("disponibilitat_plats"))
    if seasons:
        count = len(seasons)
        if count <= 1:
            return 0.4
        if count == 2:
            return 0.2
        return 0.0
    assumptions.append(
        f"Assumed high availability for '{row.get('nom_plat', '').strip()}' due to missing availability data."
    )
    return 0.0


def complexity_adjustment(row: Dict[str, str], assumptions: List[str]) -> float:
    comp = normalize(row.get("complexitat", ""))
    if comp in COMPLEXITY_ADJ:
        return COMPLEXITY_ADJ[comp]
    if comp:
        assumptions.append(
            f"Defaulted to medium complexity adjustment for '{row.get('nom_plat', '').strip()}' (value: {row.get('complexitat')})."
        )
    return COMPLEXITY_ADJ["mitjana"]


def portion_adjustment(row: Dict[str, str], assumptions: List[str]) -> float:
    size = normalize(row.get("mida_racio", ""))
    if size in SIZE_ADJ:
        return SIZE_ADJ[size]
    if size:
        assumptions.append(
            f"Defaulted to medium portion adjustment for '{row.get('nom_plat', '').strip()}' (value: {row.get('mida_racio')})."
        )
    return 0.0


def compute_cost(row: Dict[str, str], assumptions: List[str]) -> float:
    tokens = collect_tokens(row)
    family = detect_family(tokens, row, assumptions)
    base_low, base_high = family.cost_range
    base_cost = midpoint(family.cost_range)

    if family.name.startswith("beef") and is_premium(row, tokens):
        base_cost = base_low + (base_high - base_low) * 0.75
    elif is_premium(row, tokens) and family.name == "seafood":
        base_cost = base_low + (base_high - base_low) * 0.8

    cost = base_cost
    cost += complexity_adjustment(row, assumptions)
    cost += portion_adjustment(row, assumptions)
    cost += seasonal_adjustment(row, assumptions)

    cost = max(base_low, cost)
    return round(cost + 1e-8, 2)


def main() -> None:
    if not INPUT_PATH.exists():
        raise FileNotFoundError(f"Missing input file: {INPUT_PATH}")
    assumptions: List[str] = []

    with INPUT_PATH.open("r", encoding="utf-8", newline="") as infile:
        reader = csv.DictReader(infile)
        fieldnames = list(reader.fieldnames or [])
        if "preu_cost" not in fieldnames:
            fieldnames.append("preu_cost")

        rows: List[Dict[str, str]] = []
        for row in reader:
            if normalize(row.get("nom_plat", "")) == "nom_plat":
                row["preu_cost"] = ""
                assumptions.append(
                    "Preserved duplicated header row from source without cost estimation."
                )
                rows.append(row)
                continue
            cost = compute_cost(row, assumptions)
            row["preu_cost"] = f"{cost:.2f}"
            rows.append(row)

    with OUTPUT_PATH.open("w", encoding="utf-8", newline="") as outfile:
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    if assumptions:
        print("Assumptions applied:")
        for assumption in assumptions:
            print(f"- {assumption}")


if __name__ == "__main__":
    main()
