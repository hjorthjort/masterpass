import urllib3, re
from urllib.parse import quote

http = urllib3.PoolManager()

# I want to avoid special characters.
oddChars = re.compile(r'[^A-Za-z0-9]')

# Swedish, English and German

for lang in ["Swedish", "English (American)", "German"]:
    url = 'https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/%s.dic' % quote(lang)
    response = http.request('GET', url)
    print('Fetching ' + url)
    responseString = str(response.data, 'utf8')
    # All lines in these collection end in "/<some letter>". This splits the
    # string into lines, while also getting rid of this ending.
    lines = [ line.split('/')[0] for line in responseString.split('\n') ]
    # First line contains number of rows.
    filtered = lines[1:]
    # Only allow words with characters A-Z, a-z and 0-9.
    filtered = [ line for line in filtered if oddChars.search(line) is None ]
    # Only allow words of 5 characters or more, and 10 or less
    filtered = [ line for line in filtered if len(line) >= 5 and len(line) <= 10 ]

    with open('dict/%s' % lang.lower(), 'w') as f:
        print("\n".join(filtered), file=f)
