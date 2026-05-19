import math
import os
import time

# Cube vertices in 3D space
vertices = [
    [-1, -1, -1],  # 0
    [ 1, -1, -1],  # 1
    [ 1,  1, -1],  # 2
    [-1,  1, -1],  # 3
    [-1, -1,  1],  # 4
    [ 1, -1,  1],  # 5
    [ 1,  1,  1],  # 6
    [-1,  1,  1]   # 7
]

# Cube edges defined by the vertex indices
edges = [
    [0, 1], [1, 2], [2, 3], [3, 0],  # Bottom face
    [4, 5], [5, 6], [6, 7], [7, 4],  # Top face
    [0, 4], [1, 5], [2, 6], [3, 7]   # Vertical edges
]

# Projection matrix for perspective
def project(vertex, width, height, fov, viewer_distance):
    x, y, z = vertex
    # Apply perspective projection
    factor = fov / (fov + z + viewer_distance)
    x_proj = int(x * factor + width / 2)
    y_proj = int(-y * factor + height / 2)
    return x_proj, y_proj

# Rotate the 3D cube on X and Y axes
def rotate(vertices, angle_x, angle_y):
    rotated_vertices = []
    for vertex in vertices:
        x, y, z = vertex

        # Rotate around X-axis
        x_new = x
        y_new = y * math.cos(angle_x) - z * math.sin(angle_x)
        z_new = y * math.sin(angle_x) + z * math.cos(angle_x)

        # Rotate around Y-axis
        x_final = x_new * math.cos(angle_y) + z_new * math.sin(angle_y)
        y_final = y_new
        z_final = -x_new * math.sin(angle_y) + z_new * math.cos(angle_y)

        rotated_vertices.append([x_final, y_final, z_final])

    return rotated_vertices

# Function to draw a line between two points using Bresenham's line algorithm
def draw_line(canvas, x1, y1, x2, y2):
    dx = abs(x2 - x1)
    dy = abs(y2 - y1)
    sx = 1 if x1 < x2 else -1
    sy = 1 if y1 < y2 else -1
    err = dx - dy

    while True:
        if 0 <= x1 < len(canvas[0]) and 0 <= y1 < len(canvas):
            canvas[y1][x1] = '#'
        if x1 == x2 and y1 == y2:
            break
        e2 = err * 2
        if e2 > -dy:
            err -= dy
            x1 += sx
        if e2 < dx:
            err += dx
            y1 += sy

# Function to render the cube on the console
def render(vertices, edges, width, height, fov, viewer_distance):
    # Clear screen (works on Unix-like systems, you may need to adjust for Windows)
    os.system('clear' if os.name != 'nt' else 'cls')

    # Project vertices to 2D space
    projected_vertices = [project(vertex, width, height, fov, viewer_distance) for vertex in vertices]

    # Create a blank canvas
    canvas = [[' ' for _ in range(width)] for _ in range(height)]

    # Draw edges
    for edge in edges:
        start, end = edge
        x1, y1 = projected_vertices[start]
        x2, y2 = projected_vertices[end]

        # Draw the edge using Bresenham's line algorithm
        draw_line(canvas, x1, y1, x2, y2)

    # Print the canvas
    for row in canvas:
        print(''.join(row))

# Main loop for animation
def main():
    width, height = 40, 20  # Terminal size
    fov = 4.0  # Field of view
    viewer_distance = 4.0  # Viewer distance from the cube

    angle_x, angle_y = 0, 0  # Initial angles

    while True:
        # Rotate the cube
        rotated_vertices = rotate(vertices, angle_x, angle_y)

        # Render the cube
        render(rotated_vertices, edges, width, height, fov, viewer_distance)

        # Update rotation angles for the next frame
        angle_x += 0.05
        angle_y += 0.05

        # Wait before the next frame
        time.sleep(0.1)

if __name__ == "__main__":
    main()
