'''Create a zip file of the latest commit in the git repository.

Used to create consistently named zip files that don't include undesired or
uncommited files.
'''
import json
import os
import os.path
import shutil
import subprocess
import sys
import time
import zipfile

NAME = 'callfunc'

def main():
    project_dir = os.path.join(os.path.dirname(__file__), '..')
    json_path = os.path.join(project_dir, 'haxelib.json')

    with open(json_path) as file:
        doc = json.load(file)
        version = doc['version']

    timestamp = time.strftime('%Y%m%d-%H%M%S', time.gmtime())
    name = '{name}-{version}-{timestamp}.zip'.format(
        name=NAME, version=version, timestamp=timestamp)
    output_dir = os.path.join(project_dir, 'out', 'release')
    output_path = os.path.join(output_dir, name)

    print('Outputting to', output_path)

    os.makedirs(output_dir, exist_ok=True)
    subprocess.run(['git', 'archive', 'HEAD', '-o', output_path], cwd=project_dir)

    if '--bin' in sys.argv:
        shutil.copy2(
            os.path.join(project_dir, 'script', 'template', 'bin.md'),
            os.path.join(project_dir, 'bin', 'README.md')
        )

        add_bin(output_path, project_dir)

    if '--sign' in sys.argv:
        sign(output_path)

    print('Done')

def add_bin(zip_filename: str, project_dir: str):
    print('Adding binaries')

    filenames = (
        'bin/README.md',
        'bin/libffi.txt',
        'bin/linux-x86-64/callfunc-1.1.0_4f22b89/callfunc.hdll',
        'bin/linux-x86-64/libffi-3.3/libffi.so',
        'bin/linux-x86-64/libffi-3.3/libffi.so.7',
        'bin/macos/callfunc-1.1.0_4f22b89/callfunc.hdll',
        'bin/macos/libffi-3.3/libffi.dylib',
        'bin/macos/libffi-3.3/libffi.7.dylib',
        'bin/windows-x86/callfunc-1.1.0_4f22b89/callfunc.hdll',
        'bin/windows-x86/libffi-3.3/libffi.dll',
        'bin/windows-x86-64/callfunc-1.1.0_4f22b89/callfunc.hdll',
        'bin/windows-x86-64/libffi-3.3/libffi.dll',
    )

    zip_file = zipfile.ZipFile(zip_filename, mode='a')

    for filename in filenames:
        print('Adding', filename)
        zip_file.write(os.path.join(project_dir, filename), filename)

def sign(filename: str):
    print('Sign release:')
    subprocess.run(['gpg', '--armor', '--detach-sign', filename])

if __name__ == '__main__':
    main()
