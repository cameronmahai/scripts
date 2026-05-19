def main():
    print("--- My Python CLI (Type 'exit' or 'quit' to stop) ---")
    
    while True:
        # 1. Read input from the user
        user_input = input(">> ").strip().lower()
        
        # 2. Check for exit conditions
        if user_input in ["exit", "quit", "q"]:
            print("Goodbye!")
            break
            
        # 3. Handle specific commands (Eval & Print)
        if not user_input:
            continue
        elif user_input == "hello":
            print("Hello there! How can I help you today?")
        elif user_input == "status":
            print("The system is currently running.")
        else:
            print(f"Unknown command: '{user_input}'")

if __name__ == "__main__":
    main()

