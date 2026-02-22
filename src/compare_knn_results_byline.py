import sys

def compare_files(file1, file2):
    total_lines = 0
    matching_lines = 0

    with open(file1, "r") as f1, open(file2, "r") as f2:
        while True:
            line1 = f1.readline().strip()
            line2 = f2.readline().strip()

            # Salir del bucle cuando ambos archivos lleguen al final
            if not line1 and not line2:
                break
            
            # Contar solo si alguna línea existe (en caso de tamaños diferentes)
            if line1 or line2:
                total_lines += 1
                if line1 == line2:
                    matching_lines += 1

        if total_lines > 0:
            overall_percentage = (matching_lines / total_lines) * 100
            print(f"{overall_percentage:.2f}%")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("USAGE: python <script> <file1> <file2>")
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]

    compare_files(file1, file2)
