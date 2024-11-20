## FTPS Upload
Currently works only in bash environment.

This is little bash script allows me to upload files from a directory to my FTP server.
How hard could this be, I hear you asking. Well, apperently globbing is not what I was after...

### How hard could this be?
First, this script goes through the globbing patterns inside of an .ftpsignore file 
and parses all of the lines that are empty or commented.
Then we need to transform those globbing patterns into a usable regex. 
(Shoutout to dan93-93 for creating a `glob_to_regex()` function)

Only then can we start looking at the files inside of a target directory.

We use .ftpsignore to ignore the files, we essentially need to inverse the regex outcome:
Instead the matched files, unmached files will be uploaded.

To upload the files one would usually use something like Firezilla or any other application that has encryption and stuff.
My FTP server is not a fun of security so we have to use an `ftp` connection.

`ftp` is good, but it has its limits, esspecially when writing scripts with it.
Thus the `curl` was chosen!

#### curl: cannot open this_directory
That's an unusual road block. `curl` cannot transfer directories as is,
so we need to pass only files. But how can we open the directory inside bash?
Turns out, quite easily - just use recursion!

#### And this is where we are right now
Hope you find a use for this tool. Enjoy :D