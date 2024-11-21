from IPython import get_ipython
try:
    from prompt_toolkit.keys import Keys

    def on_ctrlc(event):
        # Move cursor to end of line and redraw (so whole block is preserved)
        event.cli.current_buffer.cursor_position = len(event.cli.current_buffer.text)
        event.cli._redraw()

        # (Optional) Put non-empty partial commands in history
        if event.cli.current_buffer.text.strip():
            event.cli.current_buffer.append_to_history()

        print()                           # Skip to next line past cursor
        event.cli.reset()                 # Reset/redraw prompt
        event.cli.current_buffer.reset()  # Clear buffer so new line is fresh (empty)

    ip = get_ipython()
    if getattr(ip._instance, 'pt_cli', False):
        ip._instance.pt_cli.application.key_bindings_registry.add_binding(Keys.ControlC)(on_ctrlc)
except ImportError:
    pass
