from talon import Module, Context, actions, cron, ui, ctrl
from talon.screen import Screen
import time

HOLD_TIMEOUT = 0.2

screen: Screen = ui.main_screen()
mod = Module()
mod.tag("gamepad_sleep", "Indicates that the gamepad commands are inactive")
ctx = Context()
ctx.tags = ["user.gamepad_sleep"]


cron_job = None
is_gamepad_asleep = True
slow_scroll = False
slow_mouse_move = True
mouse_freeze_time = 0
scroll_active_time = 0.0
mouse_active = False
mouse_active_time = 0.0
_x = 0
_y = 0


@mod.action_class
class Actions:

    def gamepad_sleep_toggle():
        """Toggles the gamepad between its own wake and sleep modes"""
        global is_gamepad_asleep
        is_gamepad_asleep = not is_gamepad_asleep
        set_tags_for_sleep()


    def gamepad_sleep_set(enable: bool):
        """Sets the gamepad between its own wake and sleep modes"""
        global is_gamepad_asleep
        is_gamepad_asleep = enable
        set_tags_for_sleep()

    def gamepad_scroll(x: float, y: float):
        """Perform gamepad scrolling"""
        global cron_job, _x, _y, scroll_active_time
        multiplier = 0.5 if slow_scroll else 3
        _x = x**3 * multiplier
        _y = y**3 * multiplier
        # actions.user.hud_add_log('event', 'Scroll {}, {}'.format(x, y))

        if _x != 0 or _y != 0:
            if cron_job is None:
                scroll_active_time = time.time()
                cron_job = cron.interval("16ms", scroll_continuous_helper)
                # if mouse_active:
                #     gamepad_mouse_move(x, y)
                # else:
                #     cron_job = cron.interval("16ms", scroll_continuous_helper)
        elif cron_job is not None:
            cron.cancel(cron_job)
            cron_job = None
            scroll_active_time = 0.0

    def gamepad_mouse_move(dx: float, dy: float):
        """Perform gamepad mouse cursor movement"""
        multiplier = 0.05 if slow_mouse_move else 0.3
        x, y = ctrl.mouse_pos()
        screen = get_screen(x, y)
        # actions.user.hud_add_log('event', 'Scroll {x:.2f}, {y:.2f}'.format(x=dx, y=dy))
        dx = dx**3 * screen.dpi * multiplier
        dy = dy**3 * screen.dpi * multiplier
        ctrl.mouse_move(x + dx, y + dy)

    def gamepad_mouse_freeze(button_down: bool):
        """Toggle gamepad mouse freeze"""
        global mouse_freeze_time
        if button_down:
            mouse_freeze_time = time.perf_counter()
            actions.user.mouse_freeze_toggle()
        elif time.perf_counter() - mouse_freeze_time > HOLD_TIMEOUT:
            actions.user.mouse_freeze_toggle()

    def gamepad_scroll_slow_toggle():
        """Toggle gamepad slow scroll mode"""
        global slow_scroll
        slow_scroll = not slow_scroll
        # actions.user.notify(f"Gamepad slow scroll: {slow_scroll}")

    def gamepad_mouse_move_slow_toggle(enable: bool):
        """Toggle gamepad slow mouse move mode"""
        global slow_mouse_move
        slow_mouse_move = enable
        # actions.user.notify(f"Gamepad slow move: {slow_mouse_move}")

    def gamepad_mouse_jump(direction: str):
        """Move the mouse cursor to the specified quadrant of the active screen"""
        x, y = ctrl.mouse_pos()
        rect = ui.screen_containing(x, y).rect

        # Half distance between cursor and screen edge
        match direction:
            case "up":
                y = rect.top + (y - rect.top) / 2
            case "down":
                y = rect.bot - (rect.bot - y) / 2
            case "left":
                x = rect.left + (x - rect.left) / 2
            case "right":
                x = rect.right - (rect.right - x) / 2

        # # Move one fourth of screen width/height
        # match direction:
        #     case "up":
        #         y -= rect.height / 4
        #     case "down":
        #         y += rect.height / 4
        #     case "left":
        #         x -= rect.width / 4
        #     case "right":
        #         x += rect.width / 4

        ctrl.mouse_move(x, y)
    
    def gamepad_listen_for_mouse_stop(dx: float, dy: float):
        """Listens for mouse start/stop to turn mouse active/inactive"""
        global mouse_active, mouse_active_time
        if mouse_active:
            if dx == 0 and dy == 0:
                mouse_active = False
                mouse_active_time = 0.0
        else:
            if dx != 0 or dy != 0:
                mouse_active = True
                mouse_active_time = time.time()



def set_tags_for_sleep():
    if is_gamepad_asleep:
        ctx.tags = ["user.gamepad_sleep"]
        actions.user.hud_add_log('event', 'zzzzzzz')
    else:
        ctx.tags = []
        actions.user.hud_add_log('success', 'game on girly!')


def scroll_continuous_helper():
    actions.mouse_scroll(x=_x, y=_y, by_lines=True)


def get_screen(x: float, y: float) -> Screen:
    global screen
    if not screen.contains(x, y):
        screen = ui.screen_containing(x, y)
    return screen
