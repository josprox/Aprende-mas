from PIL import Image
import os

def pad_image(input_path, output_path, scale_factor=0.60):
    try:
        if not os.path.exists(input_path):
            print(f"Error: {input_path} not found.")
            return

        original = Image.open(input_path).convert("RGBA")
        width, height = original.size
        
        # New size for the logo content
        new_width = int(width * scale_factor)
        new_height = int(height * scale_factor)
        
        # Resize original logo
        resized = original.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Create new white background image of the same original size
        # Using white since that's the splash background color
        new_image = Image.new("RGBA", (width, height), (255, 255, 255, 0)) 
        
        # Paste resized logo in center
        paste_x = (width - new_width) // 2
        paste_y = (height - new_height) // 2
        
        new_image.paste(resized, (paste_x, paste_y), resized)
        
        # Save
        new_image.save(output_path)
        print(f"Successfully created padded image at {output_path}")

    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    pad_image("assets/img/logo.png", "assets/img/logo_splash.png")
