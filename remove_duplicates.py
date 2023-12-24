"""Removes duplicates from names.txt"""
import os

path = os.getcwd()+"\\names.txt"
print(path)

with open(path, "r", encoding="utf-8") as file:
    names_list = file.read().split("\n")

print(names_list[0])
print(len(names_list))

names_set = sorted(set(names_list))
print(names_set)
print(len(names_set))
