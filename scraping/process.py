import os, sys

from downsub_scraper import download_transcript
from scrape_metadata import get_video_data

vloggers = {}

for filename in os.listdir("retrieved_links"):
    if filename != ".DS_Store":

        filename = filename[:filename.index(".txt")]

        with open("retrieved_links/" + filename + ".txt") as f:
            links = f.readlines()

            vloggers[filename] = []

            for elem in links:
                if elem[24:29] == "watch":
                    vloggers[filename].append(elem.replace("\n", ""))

print("Total of {} vloggers to download.".format(len(vloggers)))

for vlogger, vlogs in vloggers.items():
    total = len(vlogs)
    all = 0
    count = 0

    for vlog in vlogs:
        all += 1
        print(vlogger + ": " + str(all) + " of " + str(total))

        try:
            count += 1
            vlog += "&gl=DE&hl=de"
            download_transcript(vlogger, count, vlog)
            view_count, published, likes, dislikes = get_video_data(vlog)
            channel_url = "https://www.youtube.com/user/" + vlogger + "/videos"

            with open("overview.txt", "a") as f:
                f.write("{},{},{},{},{},{},{},{}\n".format(vlogger, count, vlog, view_count, published, channel_url, likes, dislikes))
        except:
            print("Video " + vlog + " from " + vlogger + " not supported!")
            count -= 1

    print("Total Score for " + vlogger + ": " + str(count))
