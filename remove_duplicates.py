"""Removes duplicates from names.txt"""
import os

# Get absolute file path for text file
path = os.getcwd()
names_file = path + "\\names.txt"
names_new_file = path + "\\names_new.txt"

# Reads text file and saves lines to list
with open(names_file, "r", encoding="utf-8") as file:
    print("Reading file\n")
    names_str = file.read()
    # Removes empty lines in txt file
    # Stores each name as a string in a list
    names_list = [line for line in names_str.split("\n") if line.strip()]

# initials_set = {}

# f_list = names_list[0].split()
# print(f_list)

# count = 0

# for i, name in enumerate(names_list):
#     if re.search("\n\W", name):
#         # del names_list[i]
#         count += 1

# print(f"Count: {count}")

names_set = sorted(set(names_list))
print("Duplicates removed!")
print(f"Original Name Count: {len(names_list)}")
print(f"New Name Count: {len(names_set)}")

with open(names_new_file, "w", encoding="utf-8") as file:
    print("Writing to file\n")
    names_str = "\n".join(names_set)
    file.write(names_str)

print("File write complete!")
