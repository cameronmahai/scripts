import curses

class Engine:
    def __init__(self, player, game_map, entities):
        self.player = player
        self.game_map = game_map
        self.entities = entities
        self.message_log = []

    def handle_input(self, key):
        dx, dy = 0, 0
        if key == curses.KEY_UP or key == ord('k'):
            dy = -1
        elif key == curses.KEY_DOWN or key == ord('j'):
            dy = 1
        elif key == curses.KEY_LEFT or key == ord('h'):
            dx = -1
        elif key == curses.KEY_RIGHT or key == ord('l'):
            dx = 1
        elif key == ord('q'):
            return "exit"

        if dx != 0 or dy != 0:
            target_x = self.player.x + dx
            target_y = self.player.y + dy
            
            target_entity = self.get_blocking_entity_at(target_x, target_y)
            if target_entity:
                msg = self.player.attack(target_entity)
                self.message_log.append(msg)
                if target_entity.hp <= 0:
                    self.message_log.append(f"{target_entity.name} dies!")
                    self.entities.remove(target_entity)
            else:
                self.player.move(dx, dy, self.game_map, self.entities)
            
            return "turn_taken"
        
        return "no_turn"

    def get_blocking_entity_at(self, x, y):
        for entity in self.entities:
            if entity.blocks and entity.x == x and entity.y == y:
                return entity
        return None

    def render(self, stdscr):
        stdscr.erase()
        
        # Render Map
        for x in range(self.game_map.width):
            for y in range(self.game_map.height):
                tile = self.game_map.tiles[x][y]
                if tile.blocked:
                    stdscr.addch(y, x, "#", curses.color_pair(2))
                else:
                    stdscr.addch(y, x, ".", curses.color_pair(3))

        # Render Entities
        for entity in self.entities:
            stdscr.addch(entity.y, entity.x, entity.char, curses.color_pair(entity.color))

        # Status Line
        status_y = self.game_map.height + 1
        stdscr.addstr(status_y, 0, f"HP: {self.player.hp}/{self.player.max_hp} | Position: {self.player.x},{self.player.y}")

        # Message Log
        log_y = status_y + 2
        for i, msg in enumerate(self.message_log[-5:]):
            stdscr.addstr(log_y + i, 0, msg)

        stdscr.refresh()
