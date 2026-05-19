import curses
import random
from entities import Player, NPC
from map_gen import GameMap
from engine import Engine

def main(stdscr):
    # Setup Curses
    curses.curs_set(0)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK) # Player
    curses.init_pair(2, curses.COLOR_BLUE, curses.COLOR_BLACK)  # Wall (Qud-like blue)
    curses.init_pair(3, curses.COLOR_GREEN, curses.COLOR_BLACK) # Floor
    curses.init_pair(4, curses.COLOR_RED, curses.COLOR_BLACK)   # Enemy

    screen_height, screen_width = stdscr.getmaxyx()
    map_width = 60
    map_height = 20

    if screen_width < map_width or screen_height < map_height + 10:
        stdscr.addstr(0, 0, "Terminal window too small! Resize and try again.")
        stdscr.getch()
        return

    # Initialize Map
    game_map = GameMap(map_width, map_height)
    game_map.make_map()

    # Initialize Player
    px, py = game_map.get_starting_position()
    player = Player(px, py)

    # Initialize Entities
    entities = [player]
    # Add some NPCs
    for _ in range(5):
        nx, ny = game_map.get_starting_position()
        npc = NPC(nx, ny, "s", 4, "Snapjaw", 10)
        entities.append(npc)

    # Initialize Engine
    engine = Engine(player, game_map, entities)

    # Game Loop
    while True:
        engine.render(stdscr)
        
        try:
            key = stdscr.getch()
        except KeyboardInterrupt:
            break

        action = engine.handle_input(key)

        if action == "exit":
            break
        
        if action == "turn_taken":
            # NPC Turn
            for entity in entities:
                if entity != player and entity.hp > 0:
                    dx = 0
                    dy = 0
                    if entity.x < player.x: dx = 1
                    elif entity.x > player.x: dx = -1
                    elif entity.y < player.y: dy = 1
                    elif entity.y > player.y: dy = -1
                    
                    if entity.x + dx == player.x and entity.y + dy == player.y:
                        msg = entity.attack(player)
                        engine.message_log.append(msg)
                    else:
                        entity.move(dx, dy, game_map, entities)

        if player.hp <= 0:
            engine.message_log.append("You have died! Press Q to quit.")
            engine.render(stdscr)
            while True:
                key = stdscr.getch()
                if key == ord('q'):
                    break
            break

if __name__ == "__main__":
    curses.wrapper(main)
