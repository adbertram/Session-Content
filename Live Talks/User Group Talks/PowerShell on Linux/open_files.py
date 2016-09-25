import glob
# glob supports Unix style pathname extensions
text_files = glob.glob('*.txt')
for file_name in sorted(text_files):
    print('    ------' + file_name)

    with open(file_name) as f:
        for line in f:
            print('    ' + line.rstrip())

    print