'''Create a zip file of the latest commit in the git repository.

Used to create consistently named zip files that don't include undesired or
uncommited files.
'''
import json
import os
import os.path
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
        add_bin(output_path, project_dir)

    if '--sign' in sys.argv:
        sign(output_path)

    print('Done')

def add_bin(zip_filename: str, project_dir: str):
    print('Adding binaries')

    filenames = (
        'bin/libffi.txt',
        'bin/macos/callfunc-0.3.0_2f42754/callfunc.hdll',
        'bin/macos/libffi-3.3-rc0_80d0710/ffi.h',
        'bin/macos/libffi-3.3-rc0_80d0710/ffitarget.h',
        'bin/macos/libffi-3.3-rc0_80d0710/libffi.7.dylib',
        'bin/windows-x86-64/libffi-3.3-rc0-1_20f4c8a/ffi.h',
        'bin/windows-x86-64/libffi-3.3-rc0-1_20f4c8a/ffitarget.h',
        'bin/windows-x86-64/libffi-3.3-rc0-1_20f4c8a/libffi.dll',
        'bin/windows-x86-64/libffi-3.3-rc0-1_20f4c8a/libffi.lib',
        'bin/windows-x86-64/libffi-3.3-rc0-1_20f4c8a/libffi.pdb',
        'bin/windows-x86/callfunc-0.3.0_2f42754/callfunc.exp',
        'bin/windows-x86/callfunc-0.3.0_2f42754/callfunc.hdll',
        'bin/windows-x86/callfunc-0.3.0_2f42754/callfunc.lib',
        'bin/windows-x86/libffi-3.3-rc0-1_20f4c8a/ffi.h',
        'bin/windows-x86/libffi-3.3-rc0-1_20f4c8a/ffitarget.h',
        'bin/windows-x86/libffi-3.3-rc0-1_20f4c8a/libffi.dll',
        'bin/windows-x86/libffi-3.3-rc0-1_20f4c8a/libffi.lib',
        'bin/windows-x86/libffi-3.3-rc0-1_20f4c8a/libffi.pdb',
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
