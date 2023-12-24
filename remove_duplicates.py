import os

path = os.getcwd()+"\\names.txt"
print(path)

with open(path, "r") as file:
    names = file.read().split("\n")

print(names[0])
print(len(names))
