import sys
import venv
print(dir(__builtins__))
#print(sys.builtin_module_names)
for i in sys.builtin_module_names:
    print(i)