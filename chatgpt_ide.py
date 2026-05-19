import tkinter as tk
from tkinter import filedialog, messagebox

class CustomIDE:
    def __init__(self, root):
        self.root = root
        self.root.title("Custom Programming Language IDE")
        self.root.geometry("800x600")
        
        self.text_area = tk.Text(self.root, wrap=tk.WORD, font=("Courier", 12))
        self.text_area.pack(fill=tk.BOTH, expand=True)
        
        # Create menu bar
        self.create_menu_bar()
        
        # Variables for file handling
        self.current_file = None

    def create_menu_bar(self):
        # Menu bar with options
        menu_bar = tk.Menu(self.root)
        
        # File menu
        file_menu = tk.Menu(menu_bar, tearoff=0)
        file_menu.add_command(label="New", command=self.new_file)
        file_menu.add_command(label="Open", command=self.open_file)
        file_menu.add_command(label="Save", command=self.save_file)
        file_menu.add_separator()
        file_menu.add_command(label="Exit", command=self.exit_program)
        menu_bar.add_cascade(label="File", menu=file_menu)
        
        # Run menu
        run_menu = tk.Menu(menu_bar, tearoff=0)
        run_menu.add_command(label="Run", command=self.run_code)
        menu_bar.add_cascade(label="Run", menu=run_menu)
        
        self.root.config(menu=menu_bar)

    def new_file(self):
        """Clear the text area to start a new file."""
        self.text_area.delete(1.0, tk.END)
        self.current_file = None

    def open_file(self):
        """Open an existing file."""
        file = filedialog.askopenfilename(defaultextension=".txt", filetypes=[("Text files", "*.txt"), ("All files", "*.*")])
        if file:
            self.current_file = file
            with open(file, 'r') as f:
                content = f.read()
            self.text_area.delete(1.0, tk.END)
            self.text_area.insert(tk.END, content)

    def save_file(self):
        """Save the current file."""
        if not self.current_file:
            self.current_file = filedialog.asksaveasfilename(defaultextension=".txt", filetypes=[("Text files", "*.txt"), ("All files", "*.*")])
        if self.current_file:
            with open(self.current_file, 'w') as f:
                content = self.text_area.get(1.0, tk.END)
                f.write(content)
            messagebox.showinfo("Info", "File saved successfully.")

    def exit_program(self):
        """Exit the IDE."""
        self.root.quit()

    def run_code(self):
        """Run the code written in the custom language (simple placeholder for your logic)."""
        code = self.text_area.get(1.0, tk.END).strip()
        if not code:
            messagebox.showwarning("Warning", "Please write some code to run.")
            return
        
        # Here, we can add an interpreter or logic for your own programming language
        output = self.process_code(code)
        
        # Display output (for now just show a placeholder message)
        messagebox.showinfo("Output", output)

    def process_code(self, code):
        """Placeholder for processing code written in your custom language."""
        # Implement the interpreter logic for your custom programming language here
        # For now, we just return the code as it is.
        return f"Code processed:\n\n{code}"

if __name__ == "__main__":
    root = tk.Tk()
    app = CustomIDE(root)
    root.mainloop()
