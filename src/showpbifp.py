import struct

def read_index(filename):
    try:
        with open(filename, "rb") as f:
            # Verificar el tamaño total del archivo
            f.seek(0, 2)  # Ir al final del archivo
            file_size = f.tell()
            f.seek(0)  # Volver al inicio
            print(f"File size: {file_size} bytes")

            # Leer dbname (cadena terminada en NULL)
            dbname = b""
            while (char := f.read(1)) != b"\x00":
                if not char:
                    raise ValueError("Unexpected end of file while reading dbname.")
                dbname += char
            dbname = dbname.decode("utf-8")
            print(f"Database Name: {dbname}")

            # Leer el número de objetos
            n = struct.unpack("i", f.read(4))[0]
            print(f"Number of Objects: {n}")

            # Leer las dimensiones
            dim = struct.unpack("i", f.read(4))[0]
            print(f"Dimensions: {dim}")

            # Leer el número de permutantes
            n_permutants = struct.unpack("i", f.read(4))[0]
            print(f"Number of Permutants: {n_permutants}")

            # Leer el número de ficticios
            n_ficticious = struct.unpack("i", f.read(4))[0]
            print(f"Number of Ficticious Distances: {n_ficticious}")

            permutation_size = n_permutants + n_ficticious

            # Leer los permutantes
            permutants = struct.unpack(f"{n_permutants}i", f.read(4 * n_permutants))
            print(f"Permutants: {permutants}")

            # Leer las distancias ficticias
            ficticious_distances = struct.unpack(f"{n_ficticious}f", f.read(4 * n_ficticious))
            print(f"Ficticious Distances: {ficticious_distances}")

            # Calcular el tamaño de la permutación
            print(f"Permutation Size: {permutation_size}")

            # Leer los objetos
            objects = []
            for i in range(n):
                obj_id = i + 1
                remaining = file_size - f.tell()
                if remaining < 4 * permutation_size:
                    raise ValueError(f"Not enough data to read permutation for object {obj_id}. Remaining: {remaining} bytes.")
                permutation = struct.unpack(f"{permutation_size}i", f.read(4 * permutation_size))
                objects.append({"id": obj_id, "permutation": permutation})
                # print(f"Object {obj_id}: Permutation read successfully.")

            # Mostrar los datos finales
            print("Objects:")
            for obj in objects:
                print(f"{obj['id']} {obj['permutation']}")

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except ValueError as ve:
        print(f"Error: {ve}")
    except struct.error as se:
        print(f"Error reading binary data: {se}")
    except Exception as e:
        print(f"Unexpected Error: {e}")

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)
    
    filename = sys.argv[1]
    read_index(filename)
