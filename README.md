# Powershell Script for Creating OUs, Users and Groups

This repo contains 2 scripts for my [Active Directory lab](https://github.com/ManuelDogbatse/active_directory):
- format_names.py
    - Reads **list of names** (from names.txt) file, removes clashing usernames, and writes the new list to a file (names_formatted.txt)
- CreateUsers.ps1
    - Reads user input for default password
    - Reads **names** (from names_formatted.txt) and **departments** (from departments.txt) and creates new OUs named after each department
    - Creates two nested OUs ('Users' and 'Computers') inside each department's OU
    - Creates groups for each department's users and computers
    - Creates new users, and evenly distributes each user to one of the department OUs