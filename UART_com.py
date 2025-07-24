import tkinter as tk
from tkinter import messagebox
import serial
import time

# UART Setup
try:
    ser = serial.Serial('COM10', baudrate=115200, timeout=1)
except serial.SerialException:
    ser = None
    print("Failed to connect to COM10. Please check the port.")

class PixelGridApp:
    def __init__(self, root):
        self.root = root
        self.root.title("8x8 Pixel Transmitter")

        self.grid = [[0 for _ in range(8)] for _ in range(8)]  # 8x8 grid state
        self.buttons = [[None for _ in range(8)] for _ in range(8)]

        self.create_widgets()

    def create_widgets(self):
        # Create 8x8 grid of toggle buttons
        for row in range(8):
            for col in range(8):
                btn = tk.Button(self.root, width=4, height=2,
                                bg="white", command=lambda r=row, c=col: self.toggle(r, c))
                btn.grid(row=row, column=col)
                self.buttons[row][col] = btn

        # Send button
        send_button = tk.Button(self.root, text="Send", bg="lightblue", command=self.send_data)
        send_button.grid(row=9, column=0, columnspan=8, sticky="we")

        # Status label
        self.status_label = tk.Label(self.root, text="Status: Ready")
        self.status_label.grid(row=10, column=0, columnspan=8)

        # Bytes display label
        self.bytes_label = tk.Label(self.root, text="Sent Bytes: []", font=("Courier", 10))
        self.bytes_label.grid(row=11, column=0, columnspan=8)

    def toggle(self, row, col):
        # Toggle pixel state and update button color
        self.grid[row][col] ^= 1
        new_color = "black" if self.grid[row][col] else "white"
        self.buttons[row][col].configure(bg=new_color)

    def grid_to_bytes(self):
        # Convert each row into a single byte
        byte_list = []
        for row in self.grid:
            byte = 0
            for bit in row:
                byte = (byte << 1) | bit
            byte_list.append(byte)
        return byte_list

    def send_data(self):
        if ser is None or not ser.is_open:
            messagebox.showerror("Error", "Serial port not connected!")
            return

        grid_bytes = self.grid_to_bytes()
        full_data = [0x00, 0x00] + grid_bytes  # Add 2 dummy bytes at the beginning

        try:
            for b in full_data:
                ser.write(bytes([b]))
                time.sleep(0.01)  # 10 ms delay between bytes

            self.status_label.config(text="Status: Sent Successfully")
            self.bytes_label.config(text=f"Sent Bytes: {[f'{b:#04x}' for b in full_data]}")
        except Exception as e:
            self.status_label.config(text="Status: Failed")
            messagebox.showerror("Transmission Error", str(e))

if __name__ == "__main__":
    root = tk.Tk()
    app = PixelGridApp(root)
    root.mainloop()

    if ser:
        ser.close()
