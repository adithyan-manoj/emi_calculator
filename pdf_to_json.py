import os
import json
import pdfplumber
import re

pdf_dir = 'pdfs'
data = {}

for filename in os.listdir(pdf_dir):
    if not filename.endswith('.pdf'):
        continue
    filepath = os.path.join(pdf_dir, filename)
    
    # Determine branch from filename first as it's more reliable in these templates
    if 'punalur' in filename.lower():
        branch_name = 'Punalur'
    elif 'adoor' in filename.lower():
        branch_name = 'Adoor'
    elif 'alappuzha' in filename.lower():
        branch_name = 'Alappuzha'
    elif 'kollam' in filename.lower():
        branch_name = 'Kollam'
    else:
        branch_name = 'Unknown'
    
    records = []
    
    with pdfplumber.open(filepath) as pdf:
        for page in pdf.pages:
            text = page.extract_text()
            
            # If we still don't know the branch, try the text
            if branch_name == 'Unknown':
                match = re.search(r'The Post Master\s+(.*?)\s+HPO', text, re.IGNORECASE)
                if match:
                    branch_name = match.group(1).strip()

            table = page.extract_table()
            if table:
                header_row = -1
                for i, row in enumerate(table):
                    if row[0] and ('Memo' in row[0] or 'No' in row[0]):
                        header_row = i
                        break
                
                if header_row != -1:
                    for row in table[header_row+1:]:
                        if not any(row): continue
                        
                        memo_cell = row[0] if row[0] else ''
                        if '\n' in memo_cell:
                            memo_cell = memo_cell.split('\n')[0]
                        if not memo_cell or not memo_cell.strip().isdigit():
                            continue 
                            
                        name_cell = row[1] if row[1] else ''
                        name = name_cell.split('\n')[0].strip()
                        member_no = memo_cell.strip()
                        
                        ac_lines = row[2].split('\n') if row[2] else []
                        pos_lines = row[3].split('\n') if row[3] else []
                        # pdue_lines = row[4].split('\n') if row[4] else []
                        emi_lines = row[5].split('\n') if row[5] else []
                        
                        def parse_float(val):
                            if not val or val.strip() == '-' or val.strip() == '': return 0.0
                            return float(val.replace(',', '').replace(' ', '').strip())
                        
                        num_loans = max(len(ac_lines), len(pos_lines), len(emi_lines))
                        
                        for i in range(num_loans):
                            ac = ac_lines[i].strip() if i < len(ac_lines) else f"UNKNOWN-{i}"
                            pos = parse_float(pos_lines[i] if i < len(pos_lines) else '0')
                            emi = parse_float(emi_lines[i] if i < len(emi_lines) else '0')
                            
                            records.append({
                                'member_no': member_no,
                                'name': name,
                                'account_no': ac,
                                'base_emi': emi,
                                'principal_os': pos
                            })
                            
    if branch_name in data:
        data[branch_name].extend(records)
    else:
        data[branch_name] = records

with open('extracted_data.json', 'w') as f:
    json.dump(data, f, indent=2)

print("Extraction complete. Generated extracted_data.json")
