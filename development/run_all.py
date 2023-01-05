import os
import build_objects as build

for path, dirs, files in os.walk('src/'):
    for file in files:
        if file.endswith('.yaml'):
            build.main(
                os.path.join(path, file),
                os.path.join(path, file[:-5] + '.elm')
            )
        
        pass
