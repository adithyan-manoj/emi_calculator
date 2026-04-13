import fitz
import sys

doc = fitz.open("pdfs/Document society_kollam_apr.pdf")
page = doc[0]
print("--- Fonts ---")
print(page.get_fonts())

print("\n--- Text with positions ---")
for block in page.get_text("dict")["blocks"]:
    if "lines" in block:
        for line in block["lines"]:
            for span in line["spans"]:
                print(f"[{span['bbox']}] ({span['size']}pt {span['font']}): {repr(span['text'])}")

