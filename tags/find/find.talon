tag: edit.find
-
hunt this: edit.find()
hunt this (pace | paste):
    edit.find()
    sleep(25ms)
    edit.paste()
hunt this <user.text>: edit.find(text)
hunt next: edit.find_next()
hunt previous: edit.find_previous()

# ERIS_BEGIN Extra find stuff
hunt now:
    edit.find("")
    edit.find_next()
hunt now (pace | paste):
    edit.find("")
    sleep(25ms)
    edit.paste()
    edit.find_next()
hunt now <user.text>:
    edit.find(text)
    edit.find_next()
# ERIS_END