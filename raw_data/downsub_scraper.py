import urllib.parse
import re, csv
from urllib.request import Request, urlopen, urlretrieve
from bs4 import BeautifulSoup as bs, SoupStrainer
import wget, os, sys, httplib2, requests, shutil, time


# Source: https://stackoverflow.com/a/5251383
def slugify(value):
    filename = re.sub(r'[/\\:*?"<>|]', '', value)

    return filename


# Download transcript given a url and a title.
def download_transcript(vlogger, id, url):
    orig = "http://downsub.com/?url="
    encode = urllib.parse.quote(url, safe='')
    target_url = orig + encode

    http = httplib2.Http()
    status, response = http.request(target_url)

    links = []
    for link in bs(response, parseOnlyThese=SoupStrainer('a')):
        links.append(link)

    target_link = str(links[2])
    start = target_link.find('"')
    end = target_link.rfind('"')

    download_link = ("http://downsub.com" + target_link[(start + 2):end]).replace("amp;", "", 1)

    # Solution derived from https://stackoverflow.com/a/34695096
    req = requests.get(download_link, stream=True)

    if req.status_code == 200:

        if not os.path.exists("output_dir/" + vlogger):
            os.makedirs("output_dir/" + vlogger)

        title = "output_dir/" + vlogger + "/" + str(id) + ".txt"

        with open(title, 'wb') as f:
            req.raw.decode_content = True
            shutil.copyfileobj(req.raw, f)

        f.close()
