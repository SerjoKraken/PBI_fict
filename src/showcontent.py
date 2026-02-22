import struct
import sys


def leer_archivo_binario(archivo_bin):
    with open(archivo_bin, 'rb') as f:
        # Leer la cabecera: dimension y funcion (2 enteros)
        funcion, dimension = struct.unpack('ii', f.read(8))  # Leer dos enteros (4 bytes cada uno)

        # Mostrar la cabecera
        print(f"{funcion} {dimension}")

        # Leer los datos: suponemos que cada fila tiene 'dimension' valores de tipo float
        while True:
            # Intentamos leer una fila completa de 'dimension' floats
            data = f.read(dimension * 4)  # Cada float es de 4 bytes
            if not data:
                break  # Si no hay más datos, terminamos

            # Convertir los datos binarios en floats
            fila = struct.unpack(f'{dimension}f', data)

            # Imprimir la fila de datos
            print(" ".join(f"{x:.6f}" for x in fila))



args = sys.argv[1:]

if len(args) != 1:
    print("Usage: python showcontent.py <file_path>")
    sys.exit(1)

leer_archivo_binario(args[0])
