class Entity:
    def __init__(self, x, y, char, color, name, blocks=False):
        self.x = x
        self.y = y
        self.char = char
        self.color = color
        self.name = name
        self.blocks = blocks

    def move(self, dx, dy, game_map, entities):
        target_x = self.x + dx
        target_y = self.y + dy
        if not game_map.is_blocked(target_x, target_y):
            if not any(e.blocks and e.x == target_x and e.y == target_y for e in entities):
                self.x += dx
                self.y += dy

    def attack(self, target):
        damage = 5 # Simple fixed damage for now
        target.hp -= damage
        return f"{self.name} hits {target.name} for {damage} damage!"

class Player(Entity):
    def __init__(self, x, y):
        super().__init__(x, y, "@", 1, "Player", blocks=True)
        self.hp = 30
        self.max_hp = 30

class NPC(Entity):
    def __init__(self, x, y, char, color, name, hp):
        super().__init__(x, y, char, color, name, blocks=True)
        self.hp = hp
        self.max_hp = hp
