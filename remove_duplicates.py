"""Removes duplicates from names.txt"""
import os

path = os.getcwd()
names_file = path + "\\names.txt"
names_new_file = path + "\\names_new.txt"

with open(names_file, "r", encoding="utf-8") as file:
    print("Reading file\n")
    names_list = file.read().split("\n")

for i, name in enumerate(names_list):
    if name == "":
        del names_list[i]

names_set = sorted(set(names_list))
print("Duplicates removed!")
print(f"Original Name Count: {len(names_list)}")
print(f"New Name Count: {len(names_set)}")

with open(names_new_file, "w", encoding="utf-8") as file:
    print("Writing to file\n")
    names_str = "\n".join(names_set)
    file.write(names_str)

print("File write complete!")
