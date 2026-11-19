
import numpy as np

# Sample trained-model weights (illustrative)
weights = np.array(
    [5, 8, -3, 12, 127, -128, 25, -10],
    dtype=np.int8
)

# Convert signed INT8 values into hexadecimal
with open("weights.mem", "w") as file:
    for weight in weights:
        hex_value = int(weight) & 0xFF
        file.write(f"{hex_value:02X}\n")

print("Memory file generated successfully!")
print(f"Number of weights: {len(weights)}")
