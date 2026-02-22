import sys

def compare_files(file1, file2, k):
    total_groups = 0
    total_matches = 0
    sum_percentages = 0.0

    with open(file1, "r") as f1, open(file2, "r") as f2:
        while True:
            lines1 = [f1.readline().strip() for _ in range(k)]
            lines2 = [f2.readline().strip() for _ in range(k)]

            # Eliminar líneas vacías
            lines1 = [line for line in lines1 if line]
            lines2 = [line for line in lines2 if line]

            # Si ambos archivos están vacíos, terminamos
            if not lines1 and not lines2:
                break

            total_groups += 1

            set1 = set(lines1)
            set2 = set(lines2)

            matches = len(set1.intersection(set2))
            total_matches += matches

            if set1:  # Evitar división por cero
                block_percentage = (matches / len(set1)) * 100
                sum_percentages += block_percentage  # Acumular porcentaje del bloque

        if total_groups > 0:
            # Promedio de los porcentajes por bloque
            average_block_percentage = sum_percentages / total_groups
            print(f"Average block percentage: {average_block_percentage:.2f}%")
        else:
            print("No data to compare.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python <script> <file1> <file> <k>")
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]
    k = int(sys.argv[3])

    compare_files(file1, file2, k)
