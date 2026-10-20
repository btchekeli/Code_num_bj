import json

with open('assets/code_numerique.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Check Livre 1 -> Titre II -> Chapitre V
l1 = data.get("LIVRE PREMIER : DES RESEAUX ET SERVICES DE COMMUNICATIONS ELECTRONIQUES", {})
t2 = l1.get("TITRE II : DES COMMUNICATIONS ELECTRONIQUES", {})
c5 = t2.get("CHAPITRE V  : DE LA DOMINANCE ET DE LA CONCURRENCE", {})
print("Keys under Chapitre V:", list(c5.keys()))
if "SECTION I  : DE LA REGULATION DES OPERATEURS DOMINANTS" in c5:
    s1 = c5["SECTION I  : DE LA REGULATION DES OPERATEURS DOMINANTS"]
    print("Keys under Section I:", list(s1.keys()))

# Check Livre 5
l5 = data.get("LIVRE CINQUIEME : DE LA PROTECTION DES DONNEES A CARACTERE PERSONNEL", {})
print("\nKeys under Livre 5:", list(l5.keys()))
t2_l5 = l5.get("TITRE II : DU TRAITEMENTS DES DONNEES A CARACTERE PERSONNEL", {})
print("Keys under Livre 5 -> Titre II:", list(t2_l5.keys()))
