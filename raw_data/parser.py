import os, sys

count = 0

for folder in os.listdir("output_dir/raw"):
    if folder != ".DS_Store":

        for filename in os.listdir("output_dir/raw/" + folder):

            if not os.path.exists("output_dir/parsed/" + folder):
                os.makedirs("output_dir/parsed/" + folder)

            with open("output_dir/raw/" + folder + "/" + filename) as f:

                parsed = []

                try:
                    for elem in f.readlines():
                        if "-->" not in elem:
                            elem = elem.replace("\n", "")

                            while "<" in elem and ">" in elem:
                                rub = elem[elem.index("<"):elem.index(">") + 1]
                                elem = elem.replace(rub, "")

                            while "[" in elem and "]" in elem:
                                rub = elem[elem.index("["):elem.index("]") + 1]
                                elem = elem.replace(rub, "")

                            if elem != "" and not elem.isdigit():
                                parsed.append(elem)
                except:
                    print("Error for " + folder + "," + filename)

            with open("output_dir/parsed/" + folder + "/" + filename, "a") as f:
                for elem in parsed:
                    f.write(elem + "\n")

            count += 1

            # if count % 2000 == 0:
            print("Now at " + str(count) + ": " + folder + ", " + filename)

print("FINISHED")
