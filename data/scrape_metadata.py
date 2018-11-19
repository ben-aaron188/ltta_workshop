# load dependencies
from __future__ import division
import requests
import sys
import os
from bs4 import BeautifulSoup
import re


def get_video_data(url):
    html = requests.get(url).text

    view_count_start = html.index("watch-view-count") + 18
    view_count_end = html.index("Aufrufe</div>") - 1
    likes = html.index("Ich mag das Video (")
    likes_end = html.index(" andere auch)")
    dislikes = html.index("Ich mag das Video nicht (")
    dislikes_end = html.index(" andere)")

    likes_count = html[likes + 23:likes_end]
    dislikes_count = html[dislikes + 29:dislikes_end]

    published = html.index("Published") + 20
    # title = html.index("title")
    # comment_count = html.index("count-text")
    view_count = html[view_count_start:view_count_end]
    date_published = html[published:published + 10]
    # print(html[title - 100:title + 100])
    # print(html[comment_count - 100:comment_count + 100])

    return view_count, date_published, likes_count, dislikes_count
