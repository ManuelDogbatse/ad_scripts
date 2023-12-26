"""Removes duplicates from names.txt"""
import os

# Get absolute file path for text file
path = os.getcwd()
names_file = path + "\\names.txt"
names_formatted_file = path + "\\names_formatted.txt"

# Reads text file and saves lines to list
with open(names_file, "r", encoding="utf-8") as file:
    print("Reading file")
    names_str = file.read()
    # Removes empty lines in txt file
    # Stores each name as a string in a list
    names_list = [line for line in names_str.split("\n") if line.strip()]
    usernames_list = [name[0].lower() + name.split()[1].lower() for name in names_list]

print("Creating dictionary of full names and usernames")
# Merge names and usernames together
name_uname_list = zip(usernames_list, names_list)
# Convert into a dictionary to remove duplicate usernames
names_dict = dict(name_uname_list)

print("Sorting dictionary in alphabetic order")
names_dict = dict(sorted(names_dict.items()))

print("Duplicates removed successfully")
print(
    f"Original names list count: {len(names_list)}\nNew names list count: {len(names_dict)}"
)

# Write new list of names to text file
with open(names_formatted_file, "w", encoding="utf-8") as file:
    print("Writing to file")
    names_str = "\n".join(names_dict.values())
    file.write(names_str)

print("File write complete")
