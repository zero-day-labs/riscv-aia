import sys

def generate_aia_define(arg1, arg2):
    if arg1 == 'IRQC_APLIC':
        irqc_type_value = '1'
    elif arg1 == 'IRQC_AIA':
        irqc_type_value = '2'
    else:
        raise ValueError("Invalid argument for arg1. Must be '1' or '2'.")

    if arg2 == 'APLIC_MINIMAL':
        aplic_type_value = '1'
    elif arg2 == 'APLIC_SCALABLE':
        aplic_type_value = '2'
    else:
        raise ValueError("Invalid argument for arg2. Must be '1' or '2'.")

    with open('aia_define.py', 'w') as f:
        f.write(f"IRQC_TYPE = {irqc_type_value}\n")
        f.write(f"APLIC_TYPE = {aplic_type_value}\n")

def main():
    if len(sys.argv) != 3:
        print("Usage: python generate_aia_define.py <arg1> <arg2>")
        return

    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    generate_aia_define(arg1, arg2)

if __name__ == "__main__":
    main()
