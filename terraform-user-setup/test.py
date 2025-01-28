import re
input_string = "module.EVENTBRIDGEUSERNOTIFICATION.[0]"
result = re.sub(r'\[.*\]|_|\.', '', input_string)
print(result)
