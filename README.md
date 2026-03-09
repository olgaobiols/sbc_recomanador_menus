# Rule-Based System for Gastronomic Menu Recommendation

This project implements a **Knowledge-Based System (KBS)** designed to automate personalized menu generation for the catering company **"Rico Rico"**. Developed in **CLIPS**, the system uses heuristic reasoning and a custom-built culinary ontology to propose coherent menus based on user preferences and complex constraints.

Developed as the first project for the **Knowledge-Based Systems (SBC)** course of the **Bachelor's Degree in Artificial Intelligence (UPC)**.

## Authors
- **Blanca Mira Fradera**
- **Laida Queral Llopart**
- **Olga Obiols Fuentes**

## Project Overview
The system acts as an expert consultant that guides users through a set of preferences to generate three distinct menu proposals (Economic, Mid-range, and Premium). It balances gastronomic coherence with logistical and dietary realities.

### Key Factors Considered:
- **Event Context**: Type of celebration (wedding, anniversary, congress, etc.), seasonality (winter, summer, etc.), and venue (indoor/outdoor).
- **Hard Constraints**: Strict adherence to 14 EU-regulated allergens and specific diets (Vegan, Vegetarian, Halal, and Kosher).
- **Logistics**: Guest count (handling mass events up to 600+ people) and target budget per person.
- **Gastronomic Coherence**: Heuristics for dish pairing, temperature suitability, and avoiding ingredient redundancy.

## System Architecture
The reasoning process is structured into a modular pipeline using **Forward Chaining** and **Focus Control**:

1. **Preferences Capture**: Interactive interview to collect event details and dietary needs.
2. **Heuristic Abstraction (Filtering)**: Reduction of the dish and beverage catalog by discarding options that do not match the season, formality, or dietary restrictions.
3. **Heuristic Association (Composition)**: Combining starters, main courses, and desserts. This module ensures variety and culinary balance.
4. **Heuristic Refinement (Selection)**: Application of a cost model (including service fees and complexity adjustments) to select the three most representative and viable options.

## Knowledge Representation
- **Ontology**: Designed in **Protégé** and implemented via `defclass` in CLIPS. It includes five core classes: `Event`, `Menu`, `Dish`, `Drink`, and `Ingredient`.
- **Expert Knowledge**: Insights provided by a professional sommelier (Josep Maria Queral) were used to formalize beverage pairing rules and formality levels.
- **Data Source**: A refined version of the **Wikibooks Cookbook** dataset, enriched with semantic attributes (formality, seasonality, and complexity) using NLP techniques and manual supervision.

## Technologies
- **CLIPS**: Expert system shell and programming language for the inference engine.
- **Protégé**: Initial conceptual modeling of the culinary ontology.
- **Python**: Used for data preprocessing, semantic enrichment, and automatic generation of CLIPS instances.

## Repository Structure
- `ontologia.clp`: Definitions of classes, slots, and templates.
- `instancies.clp`: Catalog of over 1,100 dishes, drinks, and ingredients.
- `main.clp`: Core logic, interaction rules, and modular control flow.
- `jocs-de-prova/`: Test cases covering various scenarios (e.g., low-cost beach wedding, vegan corporate dinner).

## How to Run
1. Open the **CLIPS** environment.
2. Load the system files in the following order:
   ```clips
   (load "ontologia.clp")
   (load "instancies.clp")
   (load "main.clp")
  ```
3. Initialize the environment and start the execution:
  ```clips
  (reset)
  (run)
  ```
4. Follow the interactive prompts in the console.

## Features & Justification
The system provides a **Global Justification** at the end of the process, explaining the reasoning behind each selected dish and beverage. This transparency ensures that the recommendations are not only accurate but also explainable to the end-user.
