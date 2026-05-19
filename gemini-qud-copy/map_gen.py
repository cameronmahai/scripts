import random

class Tile:
    def __init__(self, blocked, block_sight=None):
        self.blocked = blocked
        if block_sight is None:
            block_sight = blocked
        self.block_sight = block_sight

class GameMap:
    def __init__(self, width, height):
        self.width = width
        self.height = height
        self.tiles = self.initialize_tiles()

    def initialize_tiles(self):
        return [[Tile(True) for y in range(self.height)] for x in range(self.width)]

    def is_blocked(self, x, y):
        if x < 0 or x >= self.width or y < 0 or y >= self.height:
            return True
        return self.tiles[x][y].blocked

    def make_map(self):
        # Cellular Automata for organic caves
        chance_to_start_alive = 0.45
        for x in range(self.width):
            for y in range(self.height):
                if random.random() < chance_to_start_alive:
                    self.tiles[x][y].blocked = False
                    self.tiles[x][y].block_sight = False

        for _ in range(5):
            self.do_ca_step()

        # Ensure borders are closed
        for x in range(self.width):
            self.tiles[x][0].blocked = True
            self.tiles[x][self.height-1].blocked = True
        for y in range(self.height):
            self.tiles[0][y].blocked = True
            self.tiles[self.width-1][y].blocked = True

    def do_ca_step(self):
        new_tiles = [[Tile(True) for y in range(self.height)] for x in range(self.width)]
        for x in range(1, self.width - 1):
            for y in range(1, self.height - 1):
                nbs = self.count_alive_neighbors(x, y)
                if self.tiles[x][y].blocked:
                    if nbs > 4:
                        new_tiles[x][y].blocked = False
                        new_tiles[x][y].block_sight = False
                    else:
                        new_tiles[x][y].blocked = True
                        new_tiles[x][y].block_sight = True
                else:
                    if nbs >= 4:
                        new_tiles[x][y].blocked = False
                        new_tiles[x][y].block_sight = False
                    else:
                        new_tiles[x][y].blocked = True
                        new_tiles[x][y].block_sight = True
        self.tiles = new_tiles

    def count_alive_neighbors(self, x, y):
        count = 0
        for i in range(-1, 2):
            for j in range(-1, 2):
                if i == 0 and j == 0:
                    continue
                if not self.tiles[x+i][y+j].blocked:
                    count += 1
        return count

    def get_starting_position(self):
        while True:
            x = random.randint(1, self.width - 2)
            y = random.randint(1, self.height - 2)
            if not self.tiles[x][y].blocked:
                return x, y
