import srt


def load_srt(filename):
    # load original .srt file
    # parse .srt file to list of subtitles
    print("load_srt(): Loading {}".format(filename))
    with open(filename, encoding="utf8") as f:
        text = f.read()
    return list(srt.parse(text))


def update_srt(langfile, subs):
    # change subtitles' content to translated lines
    print("update_srt(): langfile: {}".format(langfile))

    with open(langfile, encoding="utf8") as f:
        lines = f.readlines()
    i = 0
    try:
        for line in lines:
            subs[i].content = line
            i += 1
    except Exception as e:
        print(e)
    return subs


def write_srt(lang, lang_subs, out_file):
    filename = f"{out_file}.{lang}.srt"
    f = open(filename, "w", encoding="utf8")
    f.write(srt.compose(lang_subs, strict=True))
    f.close()
    print("write_srt(): Wrote SRT file {}".format(filename))
    return


def txt2srt(orgfile, langfile, lang, out_file):
    subs = load_srt(orgfile)
    lang_subs = update_srt(langfile, subs)
    write_srt(lang, lang_subs, out_file)
    return