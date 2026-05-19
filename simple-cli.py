import argparse

def main():
    parser = argparse.ArgumentParser(description="A simple CLI tool.")
    parser.add_argument("name", help="The name of the person to greet.")
    parser.add_argument("-v", "--verbose", action="store_true", help="Increase output verbosity.")
    
    args = parser.parse_args()
    
    if args.verbose:
        print(f"Hello, {args.name}! I am running in verbose mode.")
    else:
        print(f"Hello, {args.name}!")

if __name__ == "__main__":
    main()

