import json

json_path = 'assets/code_numerique.json'

with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

count_modified = 0

def traverse(node):
    global count_modified
    if isinstance(node, dict):
        if 'articles' in node:
            for art in node['articles']:
                texte = art.get('texte', '')
                if ' : ' in texte:
                    # In case the text naturally had " : ", our previous script only added it once at the start.
                    # Or there might be other " : ". Let's split by the FIRST occurrence.
                    parts = texte.split(' : ', 1)
                    title = parts[0].strip()
                    body = parts[1].strip()
                    
                    # If it's a short title as expected
                    if len(title.split()) <= 15:
                        art['titre'] = title
                        art['texte'] = body
                        count_modified += 1
        for k, v in node.items():
            if k != 'articles':
                traverse(v)

traverse(data)

with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

print(f"Extracted 'titre' for {count_modified} articles.")
