import urllib3, re

http = urllib3.PoolManager()

# I want to avoid special characters.
oddChars = re.compile(r'[^A-Za-z0-9]')

# Swedish

response = http.request('GET', 
        'https://raw.githubusercontent.com/titoBouzout/Dictionaries/master/Swedish.dic')
responseString = str(response.data, 'utf8')
lines = [ line.split('/')[0] for line in responseString.split('\n') ]

# Only allow words with characters A-Z, a-z and 0-9.
filtered = [ line for line in lines if oddChars.search(line) is None ]
# Only allow words of 5 characters or more.
filtered = [ line for line in filtered if len(line) >= 5 ]

with open('dict/swedish', 'w') as f:
    print("\n".join(filtered), file=f)
