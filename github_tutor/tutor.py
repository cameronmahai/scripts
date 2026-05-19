import os
import json
import sys
from lessons import lessons

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STATE_FILE = os.path.join(BASE_DIR, "progress.json")
SANDBOX_PATH = os.path.join(BASE_DIR, "sandbox")

def load_progress():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, 'r') as f:
            return json.load(f).get("current_lesson", 0)
    return 0

def save_progress(index):
    with open(STATE_FILE, 'w') as f:
        json.dump({"current_lesson": index}, f)

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def main():
    if not os.path.exists(SANDBOX_PATH):
        os.makedirs(SANDBOX_PATH)

    current_index = load_progress()

    while current_index < len(lessons):
        lesson = lessons[current_index]
        clear_screen()
        print(f"=== {lesson.title} ===")
        print(f"\n{lesson.instruction}\n")
        print("-" * 30)
        
        user_input = input("Type 'check' to verify your work, or 'q' to quit: ").strip().lower()

        if user_input == 'q':
            print("See you next time!")
            break
        elif user_input == 'check':
            if lesson.validation_fn(SANDBOX_PATH):
                print(f"\n[CORRECT] {lesson.success_message}")
                current_index += 1
                save_progress(current_index)
                input("\nPress Enter for the next lesson...")
            else:
                print("\n[ERROR] Not quite right yet. Try again!")
                input("\nPress Enter to see instructions again...")
        else:
            print("Invalid command.")

    if current_index >= len(lessons):
        print("\nCongratulations! You've finished the basic modules.")
        # Optionally reset progress for a new run
        # os.remove(STATE_FILE)

if __name__ == "__main__":
    main()
