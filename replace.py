import os
import glob

replacements = {
    "code_civil_app_bar.dart": "code_num_app_bar.dart",
    "code_civil_drawer.dart": "code_num_drawer.dart",
    "code_civil.json": "code_numerique.json",
    "code_civil.db": "code_numerique.db",
    "code_civil_app": "code_numerique_app",
    "Code des personnes et de la famille des béninois": "Code du numérique en République du Bénin",
    "Code des personnes et de\\n la famille des béninois": "Code du numérique en\\n République du Bénin",
    "Code des personnes": "Code du numérique",
    "Code civil": "Code du numérique",
    "code civil": "code numérique"
}

# pubspec.yaml
with open("pubspec.yaml", "r", encoding="utf-8") as f:
    content = f.read()

for k, v in replacements.items():
    content = content.replace(k, v)

with open("pubspec.yaml", "w", encoding="utf-8") as f:
    f.write(content)

# Dart files
dart_files = glob.glob("lib/**/*.dart", recursive=True)
for filepath in dart_files:
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    original = content
    for k, v in replacements.items():
        content = content.replace(k, v)
        
    if original != content:
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
            
print("Replacement completed.")
