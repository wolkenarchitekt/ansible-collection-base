import os
import platform
import sys

from IPython.terminal.prompts import Prompts, Token

ipy_config = get_config()


# Set old completion style
ipy_config.TerminalInteractiveShell.display_completions = 'readlinelike'

# Common imports
ipy_config.InteractiveShellApp.exec_lines = [
    'import re, sys, glob, timeit, os',
]

# Autoreload code - use provided sample startup file to activate autoreload on startup
ipy_config.InteractiveShellApp.extensions = [
    'autoreload'
]

# Display shorter banner
ipy_config.TerminalIPythonApp.display_banner = False
print("Python {0} [{1}]".format(platform.python_version(), sys.executable))


def print_highlighted_code(file_path):
    from pygments import highlight
    from pygments.lexers import PythonLexer
    from pygments.formatters import TerminalFormatter

    with open(file_path, 'r') as file:
        code = file.read()
    highlighted_code = highlight(code, PythonLexer(), TerminalFormatter())
    print(highlighted_code)


startup_file = os.environ.get("IPYTHON_STARTUP", "")
if startup_file:
    print("Loading startup file: %s" % startup_file)
    # print_highlighted_code(startup_file)
    c.InteractiveShellApp.exec_lines.append('run -i ' + startup_file)

c.InteractiveShellApp.exec_lines.append('%autoreload 2')
