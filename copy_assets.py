import os
import shutil
import json

src_dir = "/Users/vansh/Desktop/cat_tab"
assets_dir = "/Users/vansh/Desktop/rent-zone/rent-zone/Assets.xcassets"

mapping = {
    "blazzer men.png": "m_blazer",
    "co ords and sets men.png": "m_coord",
    "hoodies men.png": "m_hoodie",
    "jacket men.png": "m_jacket",
    "kurta men.png": "m_kurta",
    "kurti women.png": "w_kurti",
    "party.png": "w_party",
    "shirt men.png": "m_shirt",
    "t shirts women.png": "w_top",
    "trac men.png": "m_vest",
    "tshirt men.png": "m_tshirt"
}

contents_json = {
  "images" : [
    {
      "filename" : "image.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

for src_name, dst_name in mapping.items():
    src_path = os.path.join(src_dir, src_name)
    if os.path.exists(src_path):
        # determine if men or women for subfolder organization, although xcassets doesn't care much, it's good practice.
        folder = "Women" if dst_name.startswith("w_") else "Men"
        target_dir = os.path.join(assets_dir, "Categories", folder, f"{dst_name}.imageset")
        
        os.makedirs(target_dir, exist_ok=True)
        
        # Copy image
        shutil.copy2(src_path, os.path.join(target_dir, "image.png"))
        
        # Write Contents.json
        with open(os.path.join(target_dir, "Contents.json"), "w") as f:
            json.dump(contents_json, f, indent=2)
            
        print(f"Copied {src_name} to {dst_name}.imageset")
    else:
        print(f"Warning: {src_name} not found")

